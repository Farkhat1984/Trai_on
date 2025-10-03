# Fashion AI Platform - Backend API

FastAPI backend для платформы генерации и примерки одежды с использованием Google Gemini AI.

## Возможности

### Для пользователей
- 🔐 Авторизация через Google OAuth
- 🎨 Генерация одежды с помощью AI (Google Gemini)
- 👗 Виртуальная примерка товаров магазинов
- 💰 Пополнение баланса через PayPal
- 🛍️ Покупка товаров напрямую
- 📊 История генераций и транзакций

### Для магазинов
- 🔐 Авторизация через Google OAuth
- 📦 Размещение товаров (с модерацией)
- 💳 Оплата аренды карточек товаров (месячная подписка)
- 📈 Аналитика (просмотры, примерки, покупки)
- 💵 Прямые продажи с комиссией платформе

### Для администраторов
- 👤 Панель управления
- ✅ Модерация товаров магазинов
- ⚙️ Управление настройками платформы (цены, лимиты, комиссии)
- 💸 Обработка запросов на возврат
- 📊 Общая статистика платформы

## Технологический стек (2025)

- **FastAPI** 0.115.0 - Современный async web framework
- **SQLAlchemy** 2.0.35 - ORM с async поддержкой
- **aiosqlite** 0.20.0 - Async SQLite драйвер
- **Pydantic** 2.9.2 - Валидация данных
- **Google Gemini AI** 0.8.3 - AI генерация изображений
- **PayPal SDK** - Обработка платежей
- **Google OAuth 2.0** - Авторизация
- **APScheduler** 3.10.4 - Фоновые задачи
- **Uvicorn** 0.32.0 - ASGI сервер

## Установка

### 1. Клонировать репозиторий

```bash
cd backend
```

### 2. Создать виртуальное окружение

```bash
python -m venv venv
# Windows
venv\Scripts\activate
# Linux/Mac
source venv/bin/activate
```

### 3. Установить зависимости

```bash
pip install -r requirements.txt
```

### 4. Настроить переменные окружения

Скопируйте `.env.example` в `.env` и заполните:

```bash
cp .env.example .env
```

**Обязательные настройки:**
- `SECRET_KEY` - Сгенерируйте: `openssl rand -hex 32`
- `GOOGLE_CLIENT_ID` - Google Cloud Console
- `GOOGLE_CLIENT_SECRET` - Google Cloud Console
- `GEMINI_API_KEY` - Google AI Studio
- `PAYPAL_CLIENT_ID` - PayPal Developer
- `PAYPAL_CLIENT_SECRET` - PayPal Developer
- `SMTP_USER` и `SMTP_PASSWORD` - Gmail App Password

### 5. Инициализировать базу данных

```bash
# Создать миграции (опционально при изменении моделей)
alembic revision --autogenerate -m "Initial migration"

# Применить миграции
alembic upgrade head
```

### 6. Запустить сервер

```bash
# Development
uvicorn app.main:app --reload

# Production
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

API будет доступно по адресу: `http://localhost:8000`

Документация: `http://localhost:8000/docs`

## Структура API

### Авторизация (`/api/v1/auth`)
- `POST /google/login` - Вход через Google
- `GET /google/url` - Получить URL для авторизации
- `POST /refresh` - Обновить access token

### Пользователи (`/api/v1/users`)
- `GET /me` - Профиль пользователя
- `PUT /me` - Обновить профиль
- `GET /me/balance` - Баланс и лимиты
- `GET /me/transactions` - История транзакций
- `GET /me/history` - История генераций

### Магазины (`/api/v1/shops`)
- `GET /me` - Профиль магазина
- `PUT /me` - Обновить профиль
- `GET /me/products` - Товары магазина
- `GET /me/analytics` - Аналитика
- `GET /me/transactions` - История транзакций

### Товары (`/api/v1/products`)
- `GET /` - Список товаров (с фильтрами)
- `GET /{id}` - Детали товара
- `POST /` - Создать товар (магазин)
- `PUT /{id}` - Обновить товар (магазин)
- `DELETE /{id}` - Удалить товар (магазин)
- `POST /{id}/purchase` - Купить товар (пользователь)

### Платежи (`/api/v1/payments`)
- `POST /user/top-up` - Пополнить баланс
- `POST /shop/rent-product` - Оплатить аренду товара
- `POST /capture/{order_id}` - Подтвердить платеж
- `POST /paypal/webhook` - PayPal webhook

### Генерации (`/api/v1/generations`)
- `POST /generate` - Сгенерировать одежду
- `POST /try-on` - Примерить товар

### Админ (`/api/v1/admin`)
- `GET /dashboard` - Статистика платформы
- `GET /settings` - Настройки
- `PUT /settings/{key}` - Обновить настройку
- `GET /moderation/queue` - Очередь модерации
- `POST /moderation/{id}/approve` - Одобрить товар
- `POST /moderation/{id}/reject` - Отклонить товар
- `GET /refunds` - Запросы на возврат
- `POST /refunds/{id}/process` - Обработать возврат

## Бизнес-логика

### Пользователи
1. Регистрация → получают бесплатные генерации и примерки
2. Пополнение баланса через PayPal
3. Списание за генерацию/примерку (сначала бесплатные, потом с баланса)
4. Покупка товаров с прямой оплатой через PayPal

### Магазины
1. Создание товара → отправка на модерацию
2. Оплата аренды (минимум 1 месяц) → товар активен
3. По истечении аренды → товар скрывается
4. Уведомления за 3 дня до окончания аренды

### Платформа
- Комиссия с продаж магазинов (настраивается в админке)
- Модерация товаров перед публикацией
- Обработка возвратов согласно закону о защите прав потребителей

## Фоновые задачи

Работают через APScheduler:

1. **Проверка аренды** (ежедневно в 9:00)
   - Отправка уведомлений за 3 дня до окончания

2. **Деактивация товаров** (ежедневно в 00:00)
   - Скрытие товаров с истекшей арендой

## Настройки платформы

Доступны через админ-панель:

- `user_generation_price` - Цена генерации (USD)
- `user_try_on_price` - Цена примерки (USD)
- `user_free_generations` - Бесплатных генераций
- `user_free_try_ons` - Бесплатных примерок
- `shop_product_rent_price` - Аренда товара/месяц (USD)
- `shop_min_rent_months` - Минимум месяцев аренды
- `shop_commission_rate` - Комиссия платформы (%)
- `refund_period_days` - Период возврата (дней)

## Безопасность

- JWT токены (access + refresh)
- Google OAuth 2.0
- Rate limiting (60 запросов/минуту)
- CORS настройки
- Валидация всех входных данных
- Логирование всех транзакций

## Разработка

### Создание миграций

```bash
alembic revision --autogenerate -m "Description"
alembic upgrade head
```

### Тестирование

```bash
pytest
```

### Форматирование кода

```bash
black app/
```

## Деплой

### Production настройки

В `.env` установите:
```
DEBUG=False
PAYPAL_MODE=live
```

### Запуск через Docker (опционально)

```bash
docker build -t fashion-api .
docker run -p 8000:8000 --env-file .env fashion-api
```

## Поддержка

Для вопросов и багов создавайте issue в репозитории.

## Лицензия

MIT
