# 🔐 Инструкция по настройке OAuth и БД

## 📋 Содержание

1. [PostgreSQL установка](#postgresql)
2. [OAuth конфигурация](#oauth)
3. [Environment переменные](#env)
4. [Миграция БД](#migration)
5. [Запуск сервера](#запуск)

---

## PostgreSQL

### Шаг 1: Установить PostgreSQL

**Windows:**

- Скачай https://www.postgresql.org/download/windows/
- Выбери PostgreSQL 15+ версию
- При установке запомни пароль для `postgres` пользователя

**Mac:**

```bash
brew install postgresql@15
```

**Linux (Ubuntu/Debian):**

```bash
sudo apt-get install postgresql postgresql-contrib
```

### Шаг 2: Создать БД

```sql
-- Подключись как postgres
psql -U postgres

-- Создай БД
CREATE DATABASE cybershield;

-- Создай пользователя
CREATE USER cybershield_user WITH PASSWORD 'your_secure_password';

-- Дай привилегии
ALTER ROLE cybershield_user SET client_encoding TO 'utf8';
ALTER ROLE cybershield_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE cybershield_user SET default_transaction_deferrable TO on;
GRANT ALL PRIVILEGES ON DATABASE cybershield TO cybershield_user;

-- Выход
\q
```

---

## OAuth

### Google OAuth

1. Перейди в [Google Cloud Console](https://console.cloud.google.com)
2. Создай новый проект
3. Включи **Google+ API**
4. Создай **OAuth 2.0 Client ID** (тип: Web Application)
5. Добави redirect URI: `http://localhost:3000/pages/auth/oauth-callback.html?provider=google`
6. Скопируй **Client ID** и **Client Secret**

### GitHub OAuth

1. Перейди в GitHub Settings → [Developer settings](https://github.com/settings/developers)
2. OAuth Apps → **New OAuth App**
3. Заполни:
   - **Application name**: CyberShield Academy
   - **Authorization callback URL**: `http://localhost:3000/pages/auth/oauth-callback.html?provider=github`
4. Скопируй **Client ID** и **Client Secret**

### Microsoft OAuth

1. Перейди в [Azure App Registrations](https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RegisteredApps)
2. **New registration** 3.설정:
   - **Name**: CyberShield Academy
   - **Redirect URI**: `http://localhost:3000/pages/auth/oauth-callback.html?provider=microsoft`
3. Перейди в **Certificates & secrets**
4. Создай новый **Client Secret**

### Apple OAuth

1. Перейди в [Apple Developer](https://developer.apple.com)
2. **Certificates, Identifiers & Profiles**
3. Создай новый **Service ID**
4. Включи **Sign in with Apple**
5. Добави callback URL: `http://localhost:3000/pages/auth/oauth-callback.html?provider=apple`

---

## Environment переменные

ёСоздай файл `.env` в директории `backend`:

```env
  # Database
  DATABASE_URL=postgresql://cybershield_user:your_secure_password@localhost:5432/cybershield

  # JWT
  SECRET_KEY=your_super_secret_jwt_key_here_change_in_production
  ALGORITHM=HS256
  ACCESS_TOKEN_EXPIRE_MINUTES=30

  # OAuth - Google
  GOOGLE_CLIENT_ID=your_google_client_id_here
  GOOGLE_CLIENT_SECRET=your_google_client_secret_here

# OAuth - GitHub
GITHUB_CLIENT_ID=your_github_client_id_here
GITHUB_CLIENT_SECRET=your_github_client_secret_here

# OAuth - Microsoft
MICROSOFT_CLIENT_ID=your_microsoft_client_id_here
MICROSOFT_CLIENT_SECRET=your_microsoft_client_secret_here

# OAuth - Apple
APPLE_CLIENT_ID=your_apple_client_id_here
APPLE_CLIENT_SECRET=your_apple_client_secret_here

# Server
BACKEND_URL=http://localhost:8000
FRONTEND_URL=http://localhost:3000
DEBUG=True
```

---

## Миграция БД

### Шаг 1: Установить Alembic (миграции)

```bash
pip install alembic
alembic init alembic
```

### Шаг 2: Обновить `alembic/env.py`

```python
from app.core.database import SQLALCHEMY_DATABASE_URL, Base
from app.models import user, lesson, course, badge, progress

target_metadata = Base.metadata

# Добавить DATABASE_URL в конфиг
```

### Шаг 3: Создать миграцию

```bash
cd backend
alembic revision --autogenerate -m "Initial migration with OAuth support"
```

### Шаг 4: Применить миграцию

```bash
alembic upgrade head
```

### Или вручную создать таблицы:

```python
python -c "from app.core.database import engine, Base; from app.models import *; Base.metadata.create_all(bind=engine)"
```

---

## Запуск сервера

### Шаг 1: Установить зависимости

```bash
cd backend
pip install -r requirements.txt
```

### Шаг 2: Запустить FastAPI сервер

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Сервер запущен на: **http://localhost:8000**

### Шаг 3: Проверить документацию

Открой в браузере: http://localhost:8000/docs

---

## API Endpoints

### Аутентификация

```
POST /api/auth/oauth/callback/{provider}
  Параметры: provider = google|github|microsoft|apple
  Тело: { code, state }
  Ответ: { access_token, user }

POST /api/auth/login/local
  Параметры: email, password
  Ответ: { access_token, user }

POST /api/auth/logout
  Очищает cookies

GET /api/auth/me
  Получить текущего пользователя
  Headers: Authorization: Bearer {token}

GET /api/auth/users?skip=0&limit=100
  Получить список пользователей

GET /api/auth/users/{user_id}
  Получить пользователя по ID
```

---

## Тестирование OAuth локально

### Для локального тестирования используй ngrok:

```bash
# Установка
npm install -g ngrok

# Использование
ngrok http 8000
```

Это создаст URL типа `https://xxxx-xxx-xx.ngrok-free.app`

Используй этот URL в OAuth callback URI вместо `localhost`

---

## Решение проблем

### ❌ Ошибка: "No module named 'authlib'"

```bash
pip install authlib starlette python-multipart
```

### ❌ Ошибка: "psycopg2 not installed"

```bash
pip install psycopg2-binary
```

### ❌ Cookies не сохраняются

- Убедись что используешь **HTTPS** (или `secure=false` для локального тестирования)
- Проверь **SameSite** атрибут (установлен как `lax`)
- Убедись что browser не блокирует cookies

### ❌ OAuth редирект не работает

- Проверь che OAuth callback URL совпадает в:
  - OAuth приложении (Google/GitHub/etc.)
  - Frontend коде (`register.html`)
  - Backend конфигурации

---

## 🎉 Готово!

Теперь у вас есть:

- ✅ PostgreSQL база данных с поддержкой OAuth
- ✅ OAuth аутентификация (Google, GitHub, Microsoft, Apple)
- ✅ Cookie управление
- ✅ User регистрация и логин
- ✅ API endpoints для получения данных пользователей

Можешь видеть и получать данные пользователей через:

- **Frontend**: cookies автоматически отправляются при каждом запросе
- **Backend**: API endpoints `/api/auth/users` и `/api/auth/users/{user_id}`
- **Database**: прямые SQL запросы к PostgreSQL
