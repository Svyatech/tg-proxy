.PHONY: help generate-secrets build up down restart logs rebuild secrets

help:
	@echo "Доступные команды:"
	@echo "  make generate-secrets - Сгенерировать новые ключи в .env"
	@echo "  make build - Собрать образ"
	@echo "  make start - Запустить прокси"
	@echo "  make stop - Остановить прокси"
	@echo "  make restart - Перезапустить прокси"
	@echo "  make logs - Показать логи"
	@echo "  make secrets - Показать ключи и ссылки"
	@echo "  make rebuild - Пересобрать и запустить"
	@echo "  make secrets - Показать ключи и ссылки для подключения"

generate-secrets:
	@echo "Генерация секретных ключей..."
	@cd scripts && bash generate-secrets.sh

build:
	@echo "Сборка образа..."
	docker-compose build

up:
	@echo "Запуск прокси..."
	docker-compose up -d

down:
	@echo "Остановка прокси..."
	docker-compose down

restart:
	@echo "Перезапуск прокси..."
	docker-compose restart

logs:
	docker-compose logs -f

secrets:
	@echo "=== Ваши ключи для подключения ==="
	@docker-compose logs | grep -E "(Secret|tg://|https://t.me)"

rebuild:
	@echo "Пересборка образа..."
	docker-compose down
	docker-compose build --no-cache
	docker-compose up -d

secrets:
	@echo "Получение ссылок для подключения..."
	@echo ""
	@docker logs mtproto-proxy 2>&1 | grep -E "tg://proxy|https://t.me/proxy" || echo "⚠️  Ссылки еще не сгенерированы. Подожди несколько секунд и попробуй снова."
	@echo ""
	@echo "💡 Если ссылок нет, проверь логи: make logs"
