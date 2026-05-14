@echo off
REM docker_setup.bat - Автоматический скрипт для быстрого старта Docker на Windows

echo.
echo Docker Setup for CyberShield Academy
echo ====================================
echo.

REM Проверь Docker установлен
docker --version >nul 2>&1
if errorlevel 1 (
    echo Error: Docker не найден. Пожалуйста установи Docker Desktop
    pause
    exit /b 1
)

docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo Error: Docker Compose не найден. Пожалуйста обновись на Docker Desktop 2.0+
    pause
    exit /b 1
)

echo ✓ Docker найден
echo.

REM Проверь .env файл
if not exist .env (
    echo Warning: .env файл не найден
    echo Копирую .env.example -^> .env
    copy .env.example .env
    echo.
    echo ✓ Файл создан. Отредактируй .env с твоими OAuth credentials
    echo.
    echo ВАЖНО: Отредактируй .env файл и добавь свои OAuth Client ID/Secret
    pause
    exit /b 0
)

echo ✓ .env файл найден
echo.

REM Останови старые контейнеры
echo Останавливаю старые контейнеры...
docker-compose down >nul 2>&1
echo.

REM Запусти контейнеры
echo Запускаю контейнеры...
docker-compose up -d --build

echo.
echo Ожидаю инициализации БД (обычно 5-15 сек)...
timeout /t 10 /nobreak

echo.
echo ✓ Контейнеры запущены!
echo.
docker-compose ps
echo.

REM Выведи информацию о доступе
echo.
echo Готово!
echo.
echo Сервисы доступны на:
echo   Backend API:       http://localhost:8000
echo   API Документация:  http://localhost:8000/docs
echo   pgAdmin:           http://localhost:5050
echo.
echo pgAdmin credentials:
echo   Email:    admin@cybershield.local
echo   Password: admin_password_change_me
echo.
echo БД credentials:
echo   Host:     localhost:5432 (или db:5432 внутри Docker)
echo   User:     cybershield_user
echo   Password: cybershield_secure_password_change_me
echo   Database: cybershield
echo.
echo Чтобы остановить: docker-compose down
echo.
pause
