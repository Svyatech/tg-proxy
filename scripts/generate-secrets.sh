#!/bin/bash

set -e

ENV_EXAMPLE="../.env.example"
ENV_FILE="../.env"

# Проверяем наличие .env.example
if [ ! -f "$ENV_EXAMPLE" ]; then
    echo "Файл $ENV_EXAMPLE не найден!"
    exit 1
fi

generate_secret() {
    head -c 16 /dev/urandom | xxd -ps
}

# Проверяем существующий .env с ключами
if [ -f "$ENV_FILE" ]; then
    EXISTING_SECRET=$(grep "^SECRET=" "$ENV_FILE" | cut -d'=' -f2)
    if [ -n "$EXISTING_SECRET" ]; then
        # Считаем количество существующих ключей
        EXISTING_COUNT=$(echo "$EXISTING_SECRET" | tr ',' '\n' | wc -l | tr -d ' ')

        echo "✅ Ключи уже существуют в $ENV_FILE"
        echo "📊 Текущее количество ключей: $EXISTING_COUNT"
        echo ""
        echo "Выберите действие:"
        echo "  1) Добавить новые ключи к существующим"
        echo "  2) Перезаписать все ключи"
        echo "  3) Отменить"
        echo ""
        read -p "Ваш выбор (1/2/3): " -n 1 -r CHOICE
        echo
        echo ""

        case $CHOICE in
            1)
                echo "Добавление новых ключей..."
                read -p "Сколько ключей добавить? (по умолчанию 3): " ADD_COUNT
                ADD_COUNT=${ADD_COUNT:-3}

                NEW_SECRETS=()
                for i in $(seq 1 $ADD_COUNT); do
                    SECRET=$(generate_secret)
                    NEW_SECRETS+=("$SECRET")
                    echo "  Новый ключ $i: $SECRET"
                done

                NEW_SECRET_STRING=$(IFS=,; echo "${NEW_SECRETS[*]}")
                COMBINED_SECRET="$EXISTING_SECRET,$NEW_SECRET_STRING"

                sed -i.bak "s|^SECRET=.*|SECRET=$COMBINED_SECRET|" "$ENV_FILE"
                rm -f "$ENV_FILE.bak"

                TOTAL_COUNT=$((EXISTING_COUNT + ADD_COUNT))
                echo ""
                echo "✅ Добавлено $ADD_COUNT новых ключей!"
                echo "📊 Всего ключей: $TOTAL_COUNT"
                echo "🔑 SECRET=$COMBINED_SECRET"
                exit 0
                ;;
            2)
                echo "Перезапись всех ключей..."
                ;;
            3)
                echo "❌ Генерация отменена"
                exit 0
                ;;
            *)
                echo "❌ Неверный выбор. Генерация отменена"
                exit 1
                ;;
        esac
    fi
fi

echo "Генерация секретных ключей для MTProto Proxy..."

SECRETS_COUNT=$(grep "^SECRET_COUNT=" "$ENV_EXAMPLE" | cut -d'=' -f2 | tr -d ' ')
SECRETS_COUNT=${SECRETS_COUNT:-5}

echo "Генерируем $SECRETS_COUNT ключей..."

SECRETS=()
for i in $(seq 1 $SECRETS_COUNT); do
    SECRET=$(generate_secret)
    SECRETS+=("$SECRET")
    echo "  Ключ $i: $SECRET"
done

SECRET_STRING=$(IFS=,; echo "${SECRETS[*]}")

# Копируем .env.example в .env и заменяем SECRET
cp "$ENV_EXAMPLE" "$ENV_FILE"
sed -i.bak "s|^SECRET=.*|SECRET=$SECRET_STRING|" "$ENV_FILE"
rm -f "$ENV_FILE.bak"

echo ""
echo "Файл $ENV_FILE создан с $SECRETS_COUNT ключами!"
echo "SECRET=$SECRET_STRING"
