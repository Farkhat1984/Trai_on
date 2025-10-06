import 'package:dio/dio.dart';
import '../utils/logger.dart';

class ApiService {
  static const String _apiKey =
      'AIzaSyDwmmtN5K8GM5t4DKVy9ZBJ0z7sfBtdIUk'; // Add your API key here
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image-preview:generateContent';

  final Dio _dio;

  ApiService()
      : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 120),
            receiveTimeout: const Duration(seconds: 120),
          ),
        );

  Future<String> generateImage({
    String? personBase64,
    String? clothingBase64,
    required String userPrompt,
    required String systemPrompt,
    String aspectRatio = '2:3', // Портретное соотношение по умолчанию
  }) async {
    final List<Map<String, dynamic>> payloadParts = [];

    // Сначала добавляем изображения, потом текст (лучше работает)
    if (personBase64 != null) {
      payloadParts.add({
        'inlineData': {
          'mimeType': 'image/png',
          'data': personBase64,
        },
      });
    }

    if (clothingBase64 != null) {
      payloadParts.add({
        'inlineData': {
          'mimeType': 'image/png',
          'data': clothingBase64,
        },
      });
    }

    payloadParts.add({'text': userPrompt});

    final payload = {
      'contents': [
        {'parts': payloadParts}
      ],
      'systemInstruction': {
        'parts': [
          {'text': systemPrompt}
        ]
      },
      'generationConfig': {
        'temperature': 0.2, // Снижено для более точного результата (было 0.4)
        'topK': 32,
        'topP': 1,
        'maxOutputTokens': 8192,
        'responseModalities': ['IMAGE'], // Только изображение
        'imageConfig': {
          'aspectRatio': aspectRatio, // Контроль соотношения сторон
        },
      },
    };

    int attempts = 0;
    const maxAttempts = 3;
    int delay = 3000; // Увеличиваем начальную задержку до 3 секунд

    while (attempts < maxAttempts) {
      attempts++;

      try {
        logger.d('Попытка $attempts из $maxAttempts...');

        // Вывод информации о запросе (без base64 данных для читаемости)
        logger.d('=== Отправка запроса ===');
        logger.d('URL: $_baseUrl');
        logger.d(
            'Количество изображений: ${personBase64 != null ? 1 : 0} + ${clothingBase64 != null ? 1 : 0}');
        logger.d(
            'Текст промпта: ${userPrompt.length > 100 ? "${userPrompt.substring(0, 100)}..." : userPrompt}');
        final genConfig = payload['generationConfig'] as Map?;
        logger.d('responseModalities: ${genConfig?['responseModalities']}');
        logger.d('=======================');

        final response = await _dio.post(
          '$_baseUrl?key=$_apiKey',
          data: payload,
          options: Options(
            headers: {'Content-Type': 'application/json'},
          ),
        );

        if (response.statusCode == 200) {
          final result = response.data;

          // Отладка: выводим полный ответ API
          logger.d('=== Полный ответ API ===');
          logger.d('promptFeedback: ${result['promptFeedback']}');
          logger.d('candidates length: ${result['candidates']?.length ?? 0}');
          if (result['candidates'] != null &&
              (result['candidates'] as List).isNotEmpty) {
            final candidate = result['candidates'][0];
            logger.d('finishReason: ${candidate['finishReason']}');
            logger.d(
                'content.parts length: ${candidate['content']?['parts']?.length ?? 0}');
            if (candidate['content']?['parts'] != null) {
              for (var i = 0;
                  i < (candidate['content']['parts'] as List).length;
                  i++) {
                final part = candidate['content']['parts'][i];
                logger.d('Part $i: ${part.keys.toList()}');
              }
            }
          }
          logger.d('========================');

          // Проверка на блокировку контента
          if (result['promptFeedback']?['blockReason'] != null) {
            final blockReason = result['promptFeedback']['blockReason'];
            final safetyRatings = result['promptFeedback']?['safetyRatings'];
            logger.d('⚠️ БЛОКИРОВКА: $blockReason');
            if (safetyRatings != null) {
              logger.d('Safety ratings: $safetyRatings');
            }
            throw Exception(
                'Запрос заблокирован: $blockReason. Попробуйте изменить описание или использовать другие изображения.');
          }

          // Проверка наличия кандидатов
          if (result['candidates'] == null ||
              (result['candidates'] as List).isEmpty) {
            logger.d('⚠️ Пустой массив candidates');
            if (attempts < maxAttempts) {
              logger.d('Повтор попытки через $delayмс...');
              await Future.delayed(Duration(milliseconds: delay));
              delay *= 2;
              continue;
            }
            throw Exception(
                'API не вернуло результат после $maxAttempts попыток. Возможные причины:\n'
                '- Проверьте интернет-соединение\n'
                '- Попробуйте другие изображения\n'
                '- Измените описание на более простое');
          }

          final candidates = result['candidates'] as List;
          final finishReason = candidates[0]['finishReason'];

          // Проверка на фильтр безопасности
          if (finishReason == 'SAFETY') {
            final safetyRatings = candidates[0]['safetyRatings'];
            logger.d('⚠️ БЛОКИРОВКА SAFETY FILTER');
            logger.d('Safety ratings: $safetyRatings');
            throw Exception('Изображение заблокировано фильтром безопасности.\n'
                'Рекомендации:\n'
                '- Используйте нейтральные изображения\n'
                '- Избегайте откровенной одежды\n'
                '- Попробуйте другую модель или одежду');
          }

          // Обработка IMAGE_OTHER - модель не смогла сгенерировать изображение
          if (finishReason == 'IMAGE_OTHER') {
            logger.d('⚠️ IMAGE_OTHER: Модель не смогла обработать изображения');
            if (attempts < maxAttempts) {
              logger.d('Повтор попытки через $delayмс...');
              await Future.delayed(Duration(milliseconds: delay));
              delay *= 2;
              continue;
            }
            throw Exception(
                'Модель не смогла обработать изображения после $maxAttempts попыток.\n'
                'РЕКОМЕНДАЦИИ:\n'
                '1. Используйте более четкие фотографии\n'
                '2. Убедитесь, что модель и одежда на светлом фоне\n'
                '3. Попробуйте другие изображения\n'
                '4. Упростите композицию');
          }

          final parts = candidates[0]['content']?['parts'] as List?;

          // Пустой parts - повторяем попытку
          if (parts == null || parts.isEmpty) {
            if (attempts < maxAttempts) {
              logger.d('Parts пустой, повтор через $delayмс...');
              await Future.delayed(Duration(milliseconds: delay));
              delay *= 2;
              continue;
            }
            throw Exception(
                'API не вернуло изображение после $maxAttempts попыток. Возможно, модель перегружена. Попробуйте позже.');
          }

          // Поиск изображения в ответе
          dynamic imagePart;
          for (var part in parts) {
            if (part['inlineData'] != null &&
                part['inlineData']['data'] != null) {
              imagePart = part;
              break;
            }
          }

          if (imagePart == null) {
            // Проверяем, есть ли текстовый ответ (иногда API возвращает текст вместо изображения)
            dynamic textPart;
            for (var part in parts) {
              if (part['text'] != null) {
                textPart = part;
                break;
              }
            }

            logger.d('❌ Изображение не найдено в ответе API');
            logger.d(
                'Parts структура: ${parts.map((p) => p.keys.toList()).toList()}');

            if (attempts < maxAttempts) {
              logger
                  .d('Повтор попытки $attempts/$maxAttempts через $delayмс...');
              if (textPart != null) {
                logger.d(
                    '⚠️ API вернул текст вместо изображения: ${textPart['text']}');
                logger.d(
                    'ПРИЧИНА: Скорее всего изображения слишком сложные для композиции');
              }
              await Future.delayed(Duration(milliseconds: delay));
              delay *= 2;
              continue;
            }

            String errText =
                'API не вернул изображение после $maxAttempts попыток.\n';
            if (textPart != null) {
              errText += '\n⚠️ Модель вернула текст: "${textPart['text']}"\n';
              errText +=
                  '\nЭто означает, что модель не смогла обработать изображения.\n';
            }
            errText += '\nРЕКОМЕНДАЦИИ:\n'
                '1. Используйте более простые изображения\n'
                '2. Убедитесь, что фото модели четкое и хорошо освещено\n'
                '3. Одежда должна быть на чистом фоне\n'
                '4. Попробуйте другие фото\n'
                '5. Подождите минуту и повторите';
            throw Exception(errText);
          }

          logger.d('✓ Изображение успешно получено!');
          return imagePart['inlineData']['data'] as String;
        }

        // Обработка других статус кодов
        if (response.statusCode == 429) {
          if (attempts < maxAttempts) {
            logger.d('Превышен лимит запросов (429), ожидание $delayмс...');
            await Future.delayed(Duration(milliseconds: delay));
            delay *= 2;
            continue;
          }
          throw Exception(
              'Превышен лимит запросов к API. Попробуйте через несколько минут.');
        }

        if (response.statusCode == 503) {
          if (attempts < maxAttempts) {
            logger.d(
                'Сервис временно недоступен (503), ожидание ${delay * 2}мс...');
            await Future.delayed(Duration(
                milliseconds: delay * 2)); // Удвоенная задержка для 503
            delay *= 2;
            continue;
          }
          throw Exception(
              'Сервис Google временно недоступен. Попробуйте через несколько минут.');
        }

        if ((response.statusCode ?? 0) >= 500) {
          if (attempts < maxAttempts) {
            logger.d(
                'Ошибка сервера (${response.statusCode}), повтор через $delayмс...');
            await Future.delayed(Duration(milliseconds: delay));
            delay *= 2;
            continue;
          }
          throw Exception(
              'Ошибка на стороне сервера Google. Попробуйте позже.');
        }

        throw Exception(
            'Ошибка API: ${response.statusCode} - ${response.statusMessage}');
      } on DioException catch (e) {
        // Детальный вывод ошибки для отладки
        logger.d('=== DioException детали ===');
        logger.d('Тип: ${e.type}');
        logger.d('Статус код: ${e.response?.statusCode}');
        logger.d('Сообщение: ${e.message}');

        if (e.response?.data != null) {
          logger.d('Ответ сервера:');
          logger.d(e.response?.data);

          // Проверяем специфичные ошибки Google API
          if (e.response?.data is Map) {
            final data = e.response?.data as Map;
            if (data['error'] != null) {
              logger.d('Ошибка Google API: ${data['error']}');

              // Если это ошибка квоты или разрешений
              if (data['error']['code'] == 400) {
                throw Exception('Неверный запрос: ${data['error']['message']}');
              }
              if (data['error']['code'] == 403) {
                throw Exception(
                    'API ключ недействителен или нет доступа: ${data['error']['message']}');
              }
              if (data['error']['code'] == 404) {
                throw Exception(
                    'Модель не найдена. Проверьте название модели.');
              }
            }
          }
        }
        logger.d('========================');

        if (attempts < maxAttempts) {
          logger.d('Повтор через $delayмс...');
          await Future.delayed(Duration(milliseconds: delay));
          delay *= 2;
          continue;
        }

        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          throw Exception(
              'Превышено время ожидания. Проверьте интернет-соединение.');
        }

        throw Exception(
            'Ошибка сети: ${e.message}. Проверьте подключение к интернету.');
      } catch (e) {
        if (attempts < maxAttempts) {
          logger.d('Неожиданная ошибка: $e, повтор через $delayмс...');
          await Future.delayed(Duration(milliseconds: delay));
          delay *= 2;
          continue;
        }
        throw Exception('Неожиданная ошибка: $e');
      }
    }

    throw Exception(
        'Не удалось получить ответ от API после $maxAttempts попыток. Попробуйте позже.');
  }

  Future<String> generatePersonImage(String description) async {
    const systemPrompt =
        "You are an AI photographer specializing in professional fashion photography. "
        "Generate ONLY images, never text. Create photorealistic, high-quality full-body portraits. "
        "Use studio lighting, maintain sharp focus, and ensure professional composition.";

    final userPrompt =
        'Create a photorealistic full-body portrait of a model in a vertical 2:3 composition. '
        'The model should be: $description. '
        'Use professional studio lighting with soft shadows, neutral background, '
        'and ensure the model is centered in the frame. The image must be in portrait orientation (832x1248 pixels).';

    return await generateImage(
      userPrompt: userPrompt,
      systemPrompt: systemPrompt,
      aspectRatio: '2:3', // Портретное соотношение для моделей
    );
  }

  Future<String> generateClothingImage(String description) async {
    const systemPrompt =
        "You are an AI product photographer specializing in e-commerce clothing photography. "
        "Generate ONLY images, never text. Create clean, professional product photos with perfect lighting.";

    final userPrompt =
        'Create a high-resolution, studio-lit product photograph of clothing item: $description. '
        'The item should be centered on a clean white background. '
        'Use even, diffused lighting to eliminate harsh shadows and showcase details. '
        'Square composition (1024x1024 pixels) suitable for e-commerce display.';

    return await generateImage(
      userPrompt: userPrompt,
      systemPrompt: systemPrompt,
      aspectRatio: '1:1', // Квадратное соотношение для одежды
    );
  }

  Future<String> applyClothingToModel({
    required String personBase64,
    String? clothingBase64,
    String? description,
  }) async {
    // Системный промпт согласно best practices Google
    const systemPrompt =
        "You are a professional AI fashion photographer and virtual stylist. "
        "Generate ONLY photorealistic images, never text. "
        "Your specialty is creating seamless, natural-looking virtual clothing try-ons while preserving the person's identity perfectly.";

    // Упрощенный описательный промпт (описываем сцену, а не требования)
    final userPrompt = clothingBase64 != null
        ? 'This is a professional e-commerce fashion photoshoot. '
                'Take the clothing item from the second image and dress the person from the first image in it. '
                'The result should look like a natural studio photograph where the person is actually wearing this exact clothing. '
                'The person\'s face, hair, eyes, skin tone, and body proportions remain completely unchanged - they are the same person. '
                'The clothing fits naturally on their body with realistic fabric texture, wrinkles, and shadows that match the studio lighting. '
                'The background, pose, and camera angle stay identical to the original portrait. '
                '${description != null && description.isNotEmpty ? description : ""}'
            .trim()
        : 'This is a photo editing task for a professional portrait. '
                'Apply these changes to the person in the image: ${description ?? ""}. '
                'The person\'s identity must remain completely unchanged - same face, same eyes, same hair, same skin. '
                'Only the specified changes are applied, everything else stays exactly as in the original photo.'
            .trim();

    return await generateImage(
      personBase64: personBase64,
      clothingBase64: clothingBase64,
      userPrompt: userPrompt,
      systemPrompt: systemPrompt,
      aspectRatio: '2:3', // Портретное соотношение для результата примерки
    );
  }
}
