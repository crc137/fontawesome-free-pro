#!/bin/bash

# Автоматический скрипт для отправки изменений на GitHub (без подтверждения)
# Автор: Alberto

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Проверяем, что мы в Git репозитории
if [ ! -d ".git" ]; then
    echo "Ошибка: Это не Git репозиторий!"
    exit 1
fi

# Проверяем статус Git
git_status=$(git status --porcelain)

if [ -z "$git_status" ]; then
    print_warning "Нет изменений для отправки."
    exit 0
fi

print_status "Найдены изменения, отправляем на GitHub..."

# Добавляем все изменения
git add .

# Создаем коммит
commit_message="Автообновление: $(date '+%Y-%m-%d %H:%M:%S')"
git commit -m "$commit_message"

# Отправляем на GitHub
current_branch=$(git branch --show-current)
git push origin "$current_branch"

if [ $? -eq 0 ]; then
    print_success "Изменения отправлены на GitHub!"
else
    echo "Ошибка при отправке на GitHub!"
    exit 1
fi 