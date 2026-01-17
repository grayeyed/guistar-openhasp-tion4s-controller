# Использование Ansible для OpenHASP

Документация по использованию Ansible playbook для генерации и деплоя конфигураций OpenHASP.

## Структура проекта

```
ansible/
├── playbook.yml                    # Основной playbook
├── requirements.yml               # Зависимости ролей
├── group_vars/
│   └── all.yml.example            # Пример всех переменных
├── inventory/
│   ├── openhasp_devices           # Инвентарь устройств OpenHASP
│   └── ha_servers                 # HA серверы для деплоя
├── host_vars/
│   └── plate01.yml                # Переменные конкретного устройства
└── roles/
    └── openhasp-config/           # Генерация конфигов
```

## Предварительные требования

### Установка Ansible

Для работы с проектом необходимо установить Ansible. Подробные инструкции для различных ОС доступны в официальной документации:
- **Linux**: [Installation on specific operating systems](https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html)
- **macOS**: [Installing Ansible on macOS](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-macos)
- **Windows (WSL)**: [Ansible on Windows FAQ](https://docs.ansible.com/ansible/latest/os_guide/windows_faq.html#can-i-run-ansible-on-windows)

Краткие команды:
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install ansible

# macOS
brew install ansible

# Python pip
pip install ansible
```

### Установка коллекций

```bash
ansible-galaxy collection install community.general
```

### Установка ролей

Проект использует внешние роли, описанные в `requirements.yml`. Установите их перед запуском:

```bash
cd ansible
ansible-galaxy install -r requirements.yml
```

Подробнее см. в [документации Ansible Galaxy](https://docs.ansible.com/ansible/latest/galaxy/user_guide.html#installing-roles-and-collections-from-a-file-requirements-yml).

### Настройка SSH доступа к Home Assistant

1. Установите addon **Advanced SSH & Web Terminal**
2. Отключите "Protection mode" (для полного доступа к файловой системе)
3. Задайте пароль или настройте SSH ключ
4. Убедитесь, что порт настроен на **22222**

## Настройка

### 1. Копирование и заполнение конфигураций

Скопируйте пример файла со всеми переменными:

```bash
# Копируем пример всех переменных
cp ansible/group_vars/all.yml.example ansible/group_vars/all.yml
```

### 2. Настройка общих переменных

Откройте `ansible/group_vars/all.yml` и настройте общие параметры (SSH, HA API, HACS):

```yaml
# Общие настройки для всех устройств
ha_ssh:
  host: "homeassistant.local"  # IP или hostname HA
  port: 22222                  # SSH порт
  user: "root"

ha_api:
  url: "http://homeassistant.local:8123"
  config_path: "/config"
  includes_path: "/config/includes/openhasp"

hacs:
  enabled: false  # Включить для установки HACS
```

### 3. Настройка переменных устройства

Создайте файл `ansible/host_vars/YOUR_DEVICE.yml` для каждого устройства:

```yaml
device:
  name: "your_device"

homeassistant:
  climate_entity: "climate.your_actual_entity"
  # ... остальные настройки сенсоров
```

## Использование

### Модель выполнения

Проект использует гибридную модель выполнения:
1. **Локально (localhost)**: Генерация конфигураций и загрузка `pages.jsonl` на устройства OpenHASP (через HTTP API).
2. **Удаленно (SSH)**: Деплой YAML-конфигураций на сервер Home Assistant.

### Генерация конфигураций

Генерация конфигураций для всех устройств:

```bash
cd ansible
ansible-playbook playbook.yml -i inventory/openhasp_devices --tags generate
```

Генерация только для конкретного устройства:

```bash
ansible-playbook playbook.yml -i inventory/openhasp_devices --tags generate -l plate01
```

**Результат генерации:**
- Конфигурации сохраняются в `output/generated-configs/{{ device.name }}/`
- Файлы: `{{ device.name }}_openhasp_homeassistant.yaml` (для HA), `pages.jsonl` (для устройства)

### Загрузка конфигурации на устройство

Вы можете автоматически загрузить файл `pages.jsonl` на устройство через HTTP API. Для этого в `host_vars` устройства должен быть указан IP адрес (`device.ip`).

Загрузка на все устройства:

```bash
ansible-playbook playbook.yml -i inventory/openhasp_devices --tags upload
```

Загрузка на конкретное устройство:

```bash
ansible-playbook playbook.yml -i inventory/openhasp_devices --tags upload -l plate01
```

> **Примечание**: Если вы видите предупреждение `[WARNING]: Could not match supplied host pattern, ignoring: ha_servers`, это нормально. Оно означает, что в текущем инвентаре нет группы `ha_servers`, которая используется в другой части playbook. Чтобы избежать этого, можно указывать оба инвентаря: `-i inventory/openhasp_devices -i inventory/ha_servers`.

## Работа с несколькими устройствами

Проект поддерживает управление неограниченным количеством панелей OpenHASP.

### 1. Добавление нового устройства

1.  Скопируйте файл-пример:
    ```bash
    cp ansible/host_vars/plate01.yml.example ansible/host_vars/plate02.yml
    ```
2.  Отредактируйте `ansible/host_vars/plate02.yml`, указав правильный IP и сущности Home Assistant.
3.  Добавьте имя устройства в инвентарь `ansible/inventory/openhasp_devices`.

### 2. Выборочный запуск

Вы можете ограничить выполнение playbook конкретным устройством с помощью флага `-l` (limit):

```bash
# Только генерация и загрузка для plate02
ansible-playbook playbook.yml -i inventory/openhasp_devices --tags upload -l plate02

# Деплой в HA только конфигурации для plate02
ansible-playbook playbook.yml -i inventory/openhasp_devices -i inventory/ha_servers --tags deploy -l plate02
```

### Деплой на Home Assistant

Деплой загружает на сервер HA файлы `*_openhasp_homeassistant.yaml` в директорию `includes/`. Эти файлы должны быть подключены в `configuration.yaml` HA.

Файлы `pages.jsonl` предназначены для загрузки на устройства тач-скрин вручную.

Деплой с паролем через командную строку:

```bash
ansible-playbook playbook.yml -i inventory/ha_servers --tags deploy \
  -e "ssh_password=YOUR_SSH_PASSWORD ha_long_lived_token=YOUR_HA_TOKEN"
```

Деплой с использованием SSH ключа:

```bash
ansible-playbook playbook.yml -i inventory/ha_servers --tags deploy \
  -e "ha_long_lived_token=YOUR_HA_TOKEN" \
  --private-key ~/.ssh/id_rsa_hassio
```

### Генерация + деплой

```bash
# Сначала генерируем
ansible-playbook playbook.yml -i inventory/openhasp_devices --tags generate

# Затем деплоим
ansible-playbook playbook.yml -i inventory/ha_servers --tags deploy \
  -e "ssh_password=YOUR_PASSWORD ha_long_lived_token=YOUR_TOKEN"
```

Или одной командой для всех устройств (генерация + деплой):

```bash
ansible-playbook playbook.yml -i inventory/openhasp_devices \
  -e "ssh_password=YOUR_PASSWORD ha_long_lived_token=YOUR_TOKEN"
```

## Установка HACS

### Установка HACS

Для автоматической установки HACS используется роль [jhampson-dbre.home_assistant.install_hacs](https://github.com/jhampson-dbre/ansible-role-home-assistant-hacs).

```bash
ansible-playbook playbook.yml -i inventory/ha_servers --tags deploy \
  -e "ssh_password=YOUR_PASSWORD ha_long_lived_token=YOUR_TOKEN hacs.enabled=true"
```

### Обновление HACS

HACS обновляется автоматически до последней версии при каждом запуске роли установки.

## Добавление нового устройства

### 1. Создание файла host_vars

Создайте файл `ansible/host_vars/YOUR_DEVICE.yml` на основе примера в `ansible/group_vars/all.yml.example`:

```yaml
device:
  name: "YOUR_DEVICE"

homeassistant:
  climate_entity: "climate.your_actual_entity"

  leftcorner_line_one:
    sensor: "sensor.temperature"
    unit: "°C"
    enabled: true
  # ... остальные сенсоры с реальными entity_id
```

### 2. Добавление в инвентарь

Добавьте устройство в `ansible/inventory/openhasp_devices`:

```ini
[openhasp_devices]
plate01
NEW_DEVICE_NAME
```

## Примеры переменных

### Базовая конфигурация (plate01)

```yaml
device:
  name: "plate01"

homeassistant:
  climate_entity: "climate.tion_4s_livingroom_tion_4s_livingroom"

  leftcorner_line_one:
    sensor: "sensor.temperature"
    unit: "°C"
    enabled: true

  rightcorner_line_one:
    sensor: "sensor.tion_4s_livingroom_productivity"
    unit: "m³/h"
    enabled: true
```

### Конфигурация без Boost

```yaml
homeassistant:
  # ...
  boost_enabled: false
  boost_switch: ""
  boost_time_sensor: ""
  boost_time_number: ""
```

## Troubleshooting

Подробную информацию по устранению проблем см. в [docs/troubleshooting.md](troubleshooting.md).

## Переменные окружения

| Переменная | Описание | Обязательно |
|------------|----------|-------------|
| `ssh_password` | Пароль SSH | Да (или ключ) |
| `ha_long_lived_token` | Token HA API | Да |

## Полезные команды

```bash
# Проверка синтаксиса
ansible-playbook playbook.yml --syntax-check

# Проверка подключения
ansible all -i inventory/ha_servers -m ping

# Пробный запуск (без изменений)
ansible-playbook playbook.yml -i inventory/ha_servers --check -e "ssh_password=PASSWORD"

# Подробный вывод
ansible-playbook playbook.yml -i inventory/ha_servers -vvv -e "ssh_password=PASSWORD"
```
