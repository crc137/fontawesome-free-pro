#!/bin/bash

# Скрипт для автоматической отправки изменений на GitHub
# Автор: Alberto
# Дата создания: $(date)

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для вывода с цветом
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверяем, что мы в Git репозитории
if [ ! -d ".git" ]; then
    print_error "Это не Git репозиторий!"
    exit 1
fi

print_status "Проверяем статус Git..."

# Проверяем статус Git
git_status=$(git status --porcelain)

if [ -z "$git_status" ]; then
    print_warning "Нет изменений для отправки. Все файлы уже синхронизированы с GitHub."
    exit 0
fi

print_status "Найдены изменения:"
echo "$git_status"

# Показываем что изменилось
print_status "Детали изменений:"
git status

# Спрашиваем пользователя о продолжении
echo
read -p "Отправить изменения на GitHub? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Отправка отменена пользователем."
    exit 0
fi

# Добавляем все изменения
print_status "Добавляем изменения в индекс..."
git add .

if [ $? -ne 0 ]; then
    print_error "Ошибка при добавлении файлов в индекс!"
    exit 1
fi

# Создаем коммит
print_status "Создаем коммит..."

# Генерируем сообщение коммита на основе изменений
commit_message="Обновление: $(date '+%Y-%m-%d %H:%M:%S')"

# Если есть конкретные файлы, добавляем их в сообщение
changed_files=$(git diff --cached --name-only | head -5 | tr '\n' ' ')
if [ ! -z "$changed_files" ]; then
    commit_message="$commit_message - $changed_files"
fi

git commit -m "$commit_message"

if [ $? -ne 0 ]; then
    print_error "Ошибка при создании коммита!"
    exit 1
fi

print_success "Коммит создан: $commit_message"

# Отправляем на GitHub
print_status "Отправляем изменения на GitHub..."

# Получаем имя текущей ветки
current_branch=$(git branch --show-current)

git push origin "$current_branch"

if [ $? -eq 0 ]; then
    print_success "Изменения успешно отправлены на GitHub!"
    print_status "Ветка: $current_branch"
    print_status "Репозиторий: $(git remote get-url origin)"
else
    print_error "Ошибка при отправке на GitHub!"
    print_warning "Попробуйте выполнить 'git push origin $current_branch' вручную"
    exit 1
fi

# Показываем итоговую статистику
echo
print_status "Статистика:"
echo "  - Ветка: $current_branch"
echo "  - Репозиторий: $(git remote get-url origin)"
echo "  - Последний коммит: $(git log -1 --format='%h - %s (%cr)')"

print_success "Скрипт завершен успешно!" 