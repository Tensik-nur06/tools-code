#!/bin/bash
# docker_setup.sh - Автоматический скрипт для быстрого старта Docker

set -e

echo "🐳 CyberShield Academy - Docker Setup"
echo "===================================="
echo ""

# Проверь Docker установлен
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не найден. Пожалуйста установи Docker Desktop"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose не найден. Пожалуйста обновись на Docker Desktop 2.0+"
    exit 1
fi

echo "✓ Docker найден"
echo ""

# Проверь .env файл
if [ ! -f .env ]; then
    echo "⚠️  .env файл не найден"
    echo "📋 Скопирую .env.example -> .env"
    cp .env.example .env
    echo "✓ Файл создан. Отредактируй .env с твоими OAuth credentials"
    echo ""
    echo "⚠️  ВАЖНО: Отредактируй .env файл и добавь свои OAuth Client ID/Secret"
    exit 0
fi

echo "✓ .env файл найден"
echo ""

# Останови старые контейнеры
echo "🛑 Останавливаю старые контейнеры..."
docker-compose down 2>/dev/null || true
echo ""

# Запусти контейнеры
echo "🚀 Запускаю контейнеры..."
docker-compose up -d --build

echo ""
echo "⏳ Ожидаю инициализации БД (обычно 5-15 сек)..."
sleep 10

# Проверь что контейнеры запустились
echo ""
echo "✓ Контейнеры запущены!"
echo ""
docker-compose ps
echo ""

# Выведи информацию о доступе
echo "🎉 Готово!"
echo ""
echo "📍 Сервисы доступны на:"
echo "  🔙 Backend API:     http://localhost:8000"
echo "  📚 API Документация: http://localhost:8000/docs"
echo "  🎛️  pgAdmin:         http://localhost:5050"
echo ""
echo "🔐 pgAdmin credentials:"
echo "  Email:    admin@cybershield.local"
echo "  Password: admin_password_change_me"
echo ""
echo "📊 БД credentials:"
echo "  Host:     localhost:5432"
echo "  User:     cybershield_user"
echo "  Password: cybershield_secure_password_change_me"
echo "  Database: cybershield"
echo ""
echo "📖 Смотри DOCKER_QUICKSTART.md для более подробной информации"
echo ""
echo "🛑 Чтобы остановить: docker-compose down"
echo ""
