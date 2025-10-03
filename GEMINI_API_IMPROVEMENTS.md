# Улучшения Gemini API для виртуальной примерки

## Обзор изменений

Внесены критические улучшения в `api_service.dart` на основе официальной документации Google Gemini для решения двух ключевых проблем:

1. ✅ **Фиксированный размер изображений** - теперь всегда соответствует фрейму приложения
2. ✅ **Улучшенная надежность запросов** - увеличенные таймауты и лучшая обработка ошибок

---

## 🎯 Проблема 1: Контроль размера изображений

### Что было
- Модель самостоятельно определяла размер выходных изображений
- Размеры варьировались и не всегда подходили под фрейм приложения
- Отсутствовал контроль соотношения сторон

### Что сделано
Добавлена конфигурация `imageConfig` с параметром `aspectRatio`:

```dart
'generationConfig': {
  'temperature': 0.4,
  'topK': 32,
  'topP': 1,
  'maxOutputTokens': 8192,
  'responseModalities': ['IMAGE'],
  'imageConfig': {
    'aspectRatio': aspectRatio, // Контроль соотношения сторон
  },
},
```

### Используемые соотношения сторон

| Функция | Соотношение | Разрешение | Назначение |
|---------|-------------|------------|------------|
| `generatePersonImage()` | **2:3** | 832×1248 | Портретные фото моделей в полный рост |
| `generateClothingImage()` | **1:1** | 1024×1024 | Квадратные фото одежды для каталога |
| `applyClothingToModel()` | **2:3** | 832×1248 | Результат виртуальной примерки |

### Преимущества
- ✅ Все изображения моделей имеют одинаковый портретный формат
- ✅ Идеально вписываются в `PersonDisplayWidget` (constraints: minHeight: 400, maxHeight: 600)
- ✅ Одежда в квадратном формате отлично смотрится в сетке гардероба
- ✅ Согласованный визуальный опыт

---

## 🔧 Проблема 2: Надежность запросов

### Что было
- `connectTimeout` и `receiveTimeout`: 60 секунд
- Начальная задержка между повторами: 2 секунды
- Общая обработка всех ошибок сервера (5xx)
- Запросы иногда не проходили из-за таймаутов

### Что сделано

#### 1. Увеличены таймауты
```dart
ApiService()
  : _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 120), // было 60
        receiveTimeout: const Duration(seconds: 120), // было 60
      ),
    );
```

**Почему:** Генерация изображений с AI может занимать 60-90 секунд, особенно при редактировании (applyClothingToModel).

#### 2. Увеличена начальная задержка
```dart
int delay = 3000; // было 2000 (3 секунды вместо 2)
```

**Почему:** Дает серверу больше времени на восстановление между попытками.

#### 3. Специальная обработка 503 ошибок
```dart
if (response.statusCode == 503) {
  if (attempts < maxAttempts) {
    print('Сервис временно недоступен (503), ожидание ${delay * 2}мс...');
    await Future.delayed(Duration(milliseconds: delay * 2)); // Удвоенная задержка
    delay *= 2;
    continue;
  }
  throw Exception('Сервис Google временно недоступен...');
}
```

**Почему:** 503 (Service Unavailable) часто означает временную перегрузку. Удвоенная задержка дает серверу больше времени.

---

## 📝 Улучшение промптов (Best Practices Google)

### Принципы из документации
1. **Описывайте сцену, а не перечисляйте ключевые слова**
2. **Будьте предельно конкретны**
3. **Укажите контекст и цель**
4. **Используйте фотографическую терминологию**

### Пример улучшения: generatePersonImage()

**Было (расплывчато):**
```dart
'Создай фотореалистичное изображение модели: $description'
```

**Стало (детально):**
```dart
'Create a photorealistic full-body portrait of a model in a vertical 2:3 composition. '
'The model should be: $description. '
'Use professional studio lighting with soft shadows, neutral background, '
'and ensure the model is centered in the frame. The image must be in portrait orientation (832x1248 pixels).'
```

### Пример улучшения: applyClothingToModel()

**Было (короткое):**
```dart
'Using the provided image of a person and the provided image of clothing, '
'create a realistic photo of the person wearing that clothing. '
'The person\'s face, body, pose, and background must stay exactly the same. '
'Only the clothing should change.'
```

**Стало (пошаговое с критическими требованиями):**
```dart
'Using the first image of a person and the second image of clothing, '
'create a professional photorealistic portrait showing the person wearing that exact clothing item. '
'CRITICAL REQUIREMENTS: '
'1) Preserve the person\'s face, facial features, hairstyle, and body shape EXACTLY as in the original. '
'2) Keep the original pose, background, and lighting unchanged. '
'3) Apply the clothing naturally with realistic fabric folds, proper fit, and accurate shadows. '
'4) Maintain the same camera angle and composition. '
'5) The final image must be in vertical portrait orientation (2:3 aspect ratio, 832x1248 pixels).'
```

**Улучшения:**
- ✅ Четкая структура (пронумерованные требования)
- ✅ Конкретные детали (facial features, fabric folds, etc.)
- ✅ Явное указание соотношения сторон в промпте
- ✅ Использование слов "CRITICAL" и "EXACTLY" для акцента

---

## 🎨 Соответствие фрейму приложения

### PersonDisplayWidget
```dart
AnimatedContainer(
  constraints: const BoxConstraints(
    minHeight: 400,
    maxHeight: 600,
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Image.memory(
      base64Decode(base64Image),
      fit: BoxFit.cover, // Изображение идеально заполняет фрейм
    ),
  ),
)
```

**Результат:** Изображения 2:3 (832×1248) идеально вписываются с `BoxFit.cover`:
- Без искажений
- Без пустого пространства
- Профессиональный вид

---

## 📊 Таблица соотношений из документации Google

| Соотношение | Разрешение | Токены | Использование |
|-------------|-----------|--------|---------------|
| 1:1 | 1024×1024 | 1290 | Квадратные (одежда, логотипы) |
| 2:3 | 832×1248 | 1290 | **Портреты** (наш выбор) |
| 3:2 | 1248×832 | 1290 | Альбомная ориентация |
| 3:4 | 864×1184 | 1290 | Почти портрет |
| 9:16 | 768×1344 | 1290 | Вертикальное видео |
| 16:9 | 1344×768 | 1290 | Широкоформатное |

---

## 🚀 Ожидаемые результаты

### Стабильность
- ✅ Меньше таймаутов благодаря 120-секундным лимитам
- ✅ Лучшая обработка временных сбоев (503)
- ✅ Более интеллектуальные повторные попытки

### Качество изображений
- ✅ Предсказуемые размеры (всегда 2:3 для моделей)
- ✅ Лучшее качество благодаря детальным промптам
- ✅ Более точное сохранение лиц при примерке

### Пользовательский опыт
- ✅ Согласованный визуальный стиль
- ✅ Изображения идеально вписываются в UI
- ✅ Меньше ошибок и неудачных запросов

---

## 📚 Источники

- [Google Gemini Image Generation Documentation](https://ai.google.dev/gemini-api/docs/image-generation)
- Best Practices: "Describe the scene, not just list keywords"
- Aspect Ratio Configuration: `imageConfig.aspectRatio`
- Error Handling: Exponential backoff with special 503 handling

---

## 🔄 Обратная совместимость

Все изменения обратно совместимы:
- Существующий код продолжает работать
- Параметр `aspectRatio` имеет значение по умолчанию ('2:3')
- Улучшенная обработка ошибок не ломает существующую логику

---

## 🧪 Рекомендации по тестированию

1. **Тест размеров:**
   - Сгенерируйте модель → проверьте, что изображение 832×1248
   - Сгенерируйте одежду → проверьте, что изображение 1024×1024
   - Примерьте одежду → проверьте, что результат 832×1248

2. **Тест надежности:**
   - Сделайте 5-10 последовательных запросов
   - Проверьте, что таймауты не возникают
   - При сбое сервера (503) проверьте повторные попытки

3. **Тест качества:**
   - Примерьте одежду на модель
   - Проверьте сохранение лица, позы, фона
   - Убедитесь, что одежда выглядит естественно

---

## ⚙️ Возможные дальнейшие улучшения

1. Добавить выбор соотношения сторон в UI (для пользователя)
2. Кэшировать сгенерированные изображения
3. Добавить прогресс-индикатор с оставшимся временем
4. Реализовать пакетную генерацию (несколько вариантов одежды)

---

Дата обновления: 3 октября 2025
Версия API: gemini-2.5-flash-image-preview
