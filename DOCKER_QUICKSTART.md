# 🐳 Docker быстрый старт

## Требования

- Docker Desktop установлен
- Docker Compose v2+

## Запуск (3 команды)

### 1️⃣ Создать `.env` файл

Создай файл `.env` в корневой директории проекта:

```bash
# Google OAuth
GOOGLE_CLIENT_ID=your_google_client_id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your_google_client_secret

# GitHub OAuth
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret

# Microsoft OAuth
MICROSOFT_CLIENT_ID=your_microsoft_client_id
MICROSOFT_CLIENT_SECRET=your_microsoft_client_secret

# Apple OAuth
APPLE_CLIENT_ID=your_apple_client_id
APPLE_CLIENT_SECRET=your_apple_client_secret
```

### 2️⃣ Запустить все контейнеры

```bash
docker-compose up -d
```

**Это запустит:**
- 🗄️ PostgreSQL база на `localhost:5432`
- 🔙 FastAPI backend на `http://localhost:8000`
- 🎛️ pgAdmin на `http://localhost:5050` (управление БД)

### 3️⃣ Проверить что всё работает

```bash
# Проверить статус контейнеров
docker-compose ps

# Просмотреть логи backend
docker-compose logs -f backend

# Получить доступ к API документации
# Открой в браузере: http://localhost:8000/docs
```

---

## 🔌 Подключение к БД

### Через pgAdmin (UI)

1. Открой http://localhost:5050
2. Email: `admin@cybershield.local`
3. Пароль: `admin_password_change_me`
4. Добавь сервер:
   - Host: `db`
   - Port: `5432`
   - Username: `cybershield_user`
   - Password: `cybershield_secure_password_change_me`

### Через psql (CLI)

```bash
psql -h localhost -U cybershield_user -d cybershield
```

### Через Python скрипт

```python
import psycopg2

conn = psycopg2.connect(
    host="localhost",
    database="cybershield",
    user="cybershield_user",
    password="cybershield_secure_password_change_me"
)

cur = conn.cursor()
cur.execute("SELECT * FROM users;")
print(cur.fetchall())
```

---

## 📍 API Endpoints

### Проверить здоровье сервера
```bash
curl http://localhost:8000/health
```

### Swagger документация
```
http://localhost:8000/docs
```

### ReDoc документация
```
http://localhost:8000/redoc
```

---

## 🛑 Остановить контейнеры

```bash
# Останови контейнеры
docker-compose down

# Останови и удали volumes (внимание: удалит данные БД!)
docker-compose down -v
```

---

## 📊 Просмотр данных пользователей

### Через API

```bash
# Получить всех пользователей
curl http://localhost:8000/api/auth/users

# Получить пользователя по ID
curl http://localhost:8000/api/auth/users/1

# Получить текущего пользователя (с токеном)
curl -H "Authorization: Bearer {token}" http://localhost:8000/api/auth/me
```

### Через БД напрямую

```sql
-- Подключись к БД (через pgAdmin или psql)

-- Посмотри всех пользователей
SELECT id, email, username, oauth_provider, created_at FROM users;

-- Посмотри пользователей зарегистрированных через Google
SELECT * FROM users WHERE oauth_provider = 'google';

-- Посмотри последних зарегистрированных
SELECT * FROM users ORDER BY created_at DESC LIMIT 10;

-- Статистика пользователей
SELECT 
    oauth_provider,
    COUNT(*) as count 
FROM users 
GROUP BY oauth_provider;
```

---

## 🔐 Безопасность

### Обновить пароли в production

1. **Измени пароль PostgreSQL** в `docker-compose.yml`:
   ```yaml
   POSTGRES_PASSWORD: your_super_secure_password_here
   DATABASE_URL: postgresql://cybershield_user:your_super_secure_password_here@db:5432/cybershield
   ```

2. **Измени SECRET_KEY для JWT** в `docker-compose.yml`:
   ```yaml
   SECRET_KEY: use_a_very_long_random_string_min_32_chars
   ```

3. **Измени pAdmin пароль** в `docker-compose.yml`:
   ```yaml
   PGADMIN_DEFAULT_PASSWORD: your_super_secure_pgadmin_password
   ```

4. **Пересобери контейнеры:**
   ```bash
   docker-compose down
   docker-compose up -d --build
   ```

---

## 🆘 Решение проблем

### Docker не запускается

```bash
# Проверь Docker статус
docker ps

# Если не работает, перезагрузи Docker Desktop или:
sudo systemctl restart docker  # Linux
```

### Backend не может подключиться к БД

```bash
# Проверь логи backend
docker-compose logs backend

# Убедись что DB здоров
docker-compose logs db

# Пересоздай контейнеры
docker-compose down
docker-compose up -d
```

### Портозанят (port already in use)

```bash
# Проверь какой процесс занимает порт 5432
lsof -i :5432  # macOS/Linux
netstat -ano | findstr :5432  # Windows

# Или просто изменивай порт в docker-compose.yml:
ports:
  - "5433:5432"  # вместо 5432
```

### Нужно перестроить образ

```bash
docker-compose up -d --build
```

---

## 📈 Масштабирование

### Для development → production

1. **Используй env файл для secrets** (создай `.env.production`):
   ```bash
   POSTGRES_PASSWORD=production_secure_password
   SECRET_KEY=production_jwt_secret_key
   ```

2. **Отключи debug режим**:
   ```yaml
   DEBUG: "False"
   ```

3. **Используй официальные сертификаты SSL** для HTTPS

4. **Настрой CORS** для frontend домена

5. **Используй nginx reverse proxy** для production

---

## ✅ Готово!

Теперь у тебя есть полностью Docker-izированная архитектура с:
- ✅ PostgreSQL БД
- ✅ FastAPI backend с OAuth
- ✅ pgAdmin для управления БД
- ✅ Все контейнеры в одной сети
- ✅ Простой старт в одной команде

Запусти: `docker-compose up -d`

И всё готово к работе! 🚀
