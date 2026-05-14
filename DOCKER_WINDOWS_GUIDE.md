# 🐳 Docker для Windows - Быстрый старт

## ✅ Требования

1. **Docker Desktop для Windows** - скачай с https://www.docker.com/products/docker-desktop
2. **WSL 2 backend** включён (обычно по умолчанию включено)
3. **Git Bash** или PowerShell

## 🚀 Запуск в 3 шага

### Шаг 1: Создать файл с OAuth credentials

Создай файл `.env` в корневой папке проекта:

```env
GOOGLE_CLIENT_ID=your_google_client_id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your_google_client_secret

GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret

MICROSOFT_CLIENT_ID=your_microsoft_client_id
MICROSOFT_CLIENT_SECRET=your_microsoft_client_secret

APPLE_CLIENT_ID=your_apple_client_id
APPLE_CLIENT_SECRET=your_apple_client_secret
```

**Или просто скопируй существующий файл:**
```bash
copy .env.example .env
```

### Шаг 2: Запустить скрипт (выбери один)

#### Вариант 1: **Двойной клик** (самый просто!)
1. Открой файл `docker_setup.bat` 
2. Двойной клик
3. Готово! ✓

#### Вариант 2: **PowerShell**
```powershell
docker-compose up -d
```

#### Вариант 3: **Git Bash**
```bash
docker-compose up -d
```

### Шаг 3: Проверить что всё работает

Открой в браузере:
- **Backend API**: http://localhost:8000
- **API Swagger Doc**: http://localhost:8000/docs
- **pgAdmin (управление БД)**: http://localhost:5050

## 📊 Доступ к данным

### через pgAdmin (графический интерфейс)

1. Откройhttp://localhost:5050
2. Email: `admin@cybershield.local`
3. Password: `admin_password_change_me`
4. Нажми **Add New Server**
5. Заполни:
   - **Name**: `CyberShield`
   - **Host**: `db` (или `localhost` если не работает)
   - **Port**: `5432`
   - **Username**: `cybershield_user`
   - **Password**: `cybershield_secure_password_change_me`
6. Нажми Save

Теперь можешь видеть: **Databases → cybershield → Tables → users**

### через PowerShell (SQL запросы)

```powershell
# Установи PostgreSQL client (если не установлен)
# Или используй Docker для запроса

# Подключись и посмотри всех пользователей
docker exec cybershield-db psql -U cybershield_user -d cybershield -c "SELECT * FROM users;"
```

### через API

```powershell
# Получить списокпользователей
curl.exe http://localhost:8000/api/auth/users

# Получить пользователя по ID
curl.exe http://localhost:8000/api/auth/users/1
```

## 🛑 Остановить докер

### Вариант 1: PowerShell
```powershell
docker-compose down
```

### Вариант 2: Остановить полностью (с удалением данных!)
```powershell
docker-compose down -v
```

## 🆘 Решение проблем Windows

### ❌ Error: Docker daemon is not running

**Решение:**
- Открой Docker Desktop с Start меню
- Дождись пока уведомление скажет "Docker engine started"

### ❌ Error: "Port 5432 is already in use"

**Решение 1:** Остановить другой PostgreSQL
```powershell
# Найти процесс который использует порт
netstat -ano | findstr :5432

# Если уже запущен Docker контейнер
docker stop cybershield-db
```

**Решение 2:** Использовать другой порт
- Отредактируй `docker-compose.yml`
- Найди `ports:` и `- "5432:5432"`
- Измени на `- "5433:5432"` (или другой свободный порт)
- Запусти заново: `docker-compose up -d`

### ❌ Error: No space left on device

**Решение:**
```powershell
# Очистить Docker
docker system prune -a

# Или пересоздать
docker-compose down -v
docker-compose up -d
```

### ❌ Docker не может подключиться к БД

**Решение:**
```powershell
# Посмотреть логи backend
docker logs cybershield-backend

# Посмотреть статус контейнеров
docker ps -a

# Если нужно перезапустить
docker-compose restart backend
```

### ❌ WSL 2 проблемы

**Решение:**
```powershell
# Обновить WSL
wsl --update

# Включить WSL 2 интеграцию
# Settings → Resources → WSL Integration → включить "Ubuntu" или распределение
```

## 📈 Полезные команды

```powershell
# Просмотр всех контейнеров
docker-compose ps

# Логи backend в реальном времени
docker-compose logs -f backend

# Логи БД
docker-compose logs -f db

# Запустить bash внутри контейнера backend
docker-compose exec backend bash

# Запустить psql внутри контейнера БД
docker-compose exec db psql -U cybershield_user -d cybershield

# Перестроить образ backend (если изменились зависимости)
docker-compose up -d --build backend

# Удалить все Docker resources (внимание!)
docker system prune -a --volumes
```

## 🔐 Security для Production

Когда развёртываешь на production:

1. **Измени все пароли** в `docker-compose.yml`
2. **Включи HTTPS** (используй nginx reverse proxy)
3. **Отключи debug mode**: `DEBUG: "False"`
4. **Используй .env файл** вместо hardcoded переменных
5. **Запусти с restart policy**: `restart: always`

Пример для production:
```yaml
backend:
  restart: always
  environment:
    DEBUG: "False"
    COOKIE_SECURE: "True"  # Только HTTPS
```

## ✅ Готово!

Теперь у тебя есть:
- ✅ PostgreSQL в Docker
- ✅ FastAPI backend с OAuth
- ✅ Управление БД через pgAdmin
- ✅ Все контейнеры в одной сети
- ✅ Простой старт одной командой

**Запусти:** `docker_setup.bat` (двойной клик)

Или: `docker-compose up -d`

И всё готово к работе! 🚀
