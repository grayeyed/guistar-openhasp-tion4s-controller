#!/bin/bash
set -e

echo "Запуск генерации конфигурации OpenHASP..."

# Проверяем наличие файла конфигурации
if [ ! -f "/app/ansible/config/variables.yml" ]; then
    echo "ОШИБКА: Файл /app/ansible/config/variables.yml не найден!"
    echo "Скопируйте ansible/config/variables.yml.example в ansible/config/variables.yml и настройте его."
    exit 1
fi

# Запускаем Ansible playbook
cd /app/ansible
ansible-playbook -i inventory/localhost playbook.yml

echo "Генерация завершена. Конфигурационные файлы в /app/output/"