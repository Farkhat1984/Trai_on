# 🔍 Диагностика проблем с API Gemini

## Текущая проблема:
```
Ошибка сети: DioExceptionType.badResponse
```

Это означает, что **сервер Google получил запрос**, но **вернул ошибку**.

---

## 🆕 Добавлена детальная диагностика

Теперь при каждом запросе выводится:

### 1. Информация о запросе:
```
=== Отправка запроса ===
URL: https://generativelanguage.googleapis.com/...
Количество изображений: 1 + 1
Текст промпта: Using the provided image of a person...
responseModalities: [IMAGE]
aspectRatio: 1:1
=======================
```

### 2. Детальная информация об ошибке:
```
=== DioException детали ===
Тип: DioExceptionType.badResponse
Статус код: 400
Сообщение: ...
Ответ сервера:
{
  "error": {
    "code": 400,
    "message": "Описание ошибки от Google",
    "status": "INVALID_ARGUMENT"
  }
}
========================
```

---

## 🔴 Частые ошибки Google API:

### 1. **Ошибка 400 (Bad Request)**
```json
{
  "error": {
    "code": 400,
    "message": "Invalid request"
  }
}
```

**Причины:**
- ❌ Неправильная структура запроса
- ❌ Неверное название модели
- ❌ Неподдерживаемые параметры
- ❌ Некорректный `imageConfig`

**Решение:**
- Проверить структуру `payload`
- Убедиться что `imageConfig` на верхнем уровне
- Проверить название модели

---

### 2. **Ошибка 403 (Forbidden)**
```json
{
  "error": {
    "code": 403,
    "message": "API key not valid"
  }
}
```

**Причины:**
- ❌ Недействительный API ключ
- ❌ API ключ не активирован
- ❌ Нет доступа к модели

**Решение:**
1. Проверить API ключ: https://aistudio.google.com/app/apikey
2. Убедиться что Gemini API включен
3. Проверить квоты

---

### 3. **Ошибка 404 (Not Found)**
```json
{
  "error": {
    "code": 404,
    "message": "Model not found"
  }
}
```

**Причины:**
- ❌ Неправильное название модели
- ❌ Модель не существует
- ❌ Опечатка в URL

**Текущая модель:**
```
gemini-2.5-flash-image-preview
```

**Проверить URL:**
```
https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image-preview:generateContent
```

---

### 4. **Ошибка 429 (Too Many Requests)**
```json
{
  "error": {
    "code": 429,
    "message": "Quota exceeded"
  }
}
```

**Причины:**
- ❌ Превышен лимит запросов (15/минуту)
- ❌ Превышена дневная квота

**Решение:**
- Подождать 1-2 минуты
- Проверить квоты в консоли Google Cloud

---

### 5. **Ошибка 500+ (Server Error)**
```json
{
  "error": {
    "code": 500,
    "message": "Internal server error"
  }
}
```

**Причины:**
- ❌ Проблема на стороне Google
- ❌ Временная недоступность сервиса

**Решение:**
- Подождать несколько минут
- Повторить попытку

---

## 🚀 Как диагностировать проблему:

### Шаг 1: Запустите приложение
```powershell
flutter run
```

### Шаг 2: Попробуйте примерить одежду

### Шаг 3: Смотрите логи в консоли

Вы увидите:
```
=== Отправка запроса ===
...
=== DioException детали ===
Тип: badResponse
Статус код: 400
Ответ сервера:
{
  "error": {
    "code": 400,
    "message": "..." ← ВОТ ПРИЧИНА!
  }
}
```

### Шаг 4: Найдите причину по коду ошибки

---

## 🔧 Частые решения:

### Проблема: `imageConfig` не распознается
**Ошибка:**
```
"message": "Unknown field 'imageConfig' in generationConfig"
```

**Решение:**
Убедитесь что `imageConfig` на **верхнем уровне**:
```dart
final payload = {
  'contents': [...],
  'generationConfig': {...},
  'imageConfig': {...},  // ← Здесь!
};
```

---

### Проблема: Модель не найдена
**Ошибка:**
```
"message": "Model gemini-2.5-flash-image-preview not found"
```

**Решение:**
Проверьте название модели в `_baseUrl`:
```dart
static const String _baseUrl =
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image-preview:generateContent';
```

---

### Проблема: API ключ недействителен
**Ошибка:**
```
"message": "API key not valid"
```

**Решение:**
1. Откройте: https://aistudio.google.com/app/apikey
2. Создайте новый ключ
3. Замените в `api_service.dart`:
```dart
static const String _apiKey = 'ВАШ_НОВЫЙ_КЛЮЧ';
```

---

### Проблема: Превышен лимит
**Ошибка:**
```
"message": "Quota exceeded"
```

**Решение:**
Подождите 1-2 минуты. Бесплатный лимит:
- **15 запросов в минуту**
- **1500 запросов в день**

---

## 📊 Структура правильного запроса:

```dart
{
  "contents": [
    {
      "parts": [
        {"inlineData": {"mimeType": "image/png", "data": "..."}},
        {"inlineData": {"mimeType": "image/png", "data": "..."}},
        {"text": "..."}
      ]
    }
  ],
  "systemInstruction": {
    "parts": [{"text": "..."}]
  },
  "generationConfig": {
    "temperature": 0.4,
    "topK": 32,
    "topP": 1,
    "maxOutputTokens": 8192,
    "responseModalities": ["IMAGE"]
  },
  "imageConfig": {              // ← На верхнем уровне!
    "aspectRatio": "1:1"
  }
}
```

---

## 🧪 Тестирование API ключа:

### Простой запрос для проверки:
```bash
curl -X POST \
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image-preview:generateContent?key=ВАШ_КЛЮЧ' \
  -H 'Content-Type: application/json' \
  -d '{
    "contents": [
      {
        "parts": [
          {"text": "Generate a simple red circle"}
        ]
      }
    ],
    "generationConfig": {
      "responseModalities": ["IMAGE"]
    },
    "imageConfig": {
      "aspectRatio": "1:1"
    }
  }'
```

**Ожидаемый ответ:**
```json
{
  "candidates": [
    {
      "content": {
        "parts": [
          {
            "inlineData": {
              "mimeType": "image/png",
              "data": "base64..."
            }
          }
        ]
      },
      "finishReason": "STOP"
    }
  ]
}
```

---

## 📝 Чек-лист диагностики:

- [ ] Смотрю логи в консоли
- [ ] Вижу код ошибки (400, 403, 404, 429, 500)
- [ ] Читаю сообщение об ошибке
- [ ] Проверяю структуру запроса
- [ ] Проверяю API ключ
- [ ] Проверяю квоты
- [ ] Проверяю название модели
- [ ] Пробую простой тест

---

## 🎯 Следующие шаги:

### 1. Запустите приложение с логами:
```powershell
flutter run
```

### 2. Скопируйте полный вывод:
```
=== Отправка запроса ===
...
=== DioException детали ===
...
Ответ сервера:
...
```

### 3. Найдите код ошибки и сообщение

### 4. Примените решение из этого документа

---

## 💡 Полезные ссылки:

- **API Studio:** https://aistudio.google.com/app/apikey
- **Документация:** https://ai.google.dev/gemini-api/docs
- **Квоты:** https://console.cloud.google.com/
- **Статусы кодов:** https://developer.mozilla.org/en-US/docs/Web/HTTP/Status

---

**ВАЖНО:** Смотрите детальные логи в консоли - они покажут точную причину! 👀
