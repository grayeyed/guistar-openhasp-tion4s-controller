# ESP32-S3 OpenHASP Tion 4S Controller

Ansible playbook для конфигурирования тач-скрин устройства ESP32-S3 с прошивкой OpenHASP для управления бризером Tion 4S.

## Быстрый старт

1. **Настройте variables.yml**
   ```bash
   cp ansible/config/variables.yml ansible/config/variables.yml
   # Отредактируйте с вашими параметрами
   ```

2. **Запустите генерацию конфигурации**
   ```bash
   docker-compose up --build
   ```

3. **Скопируйте файлы**
   ```bash
   ls output/generated-configs/
   # openhasp_homeassistant.yaml, pages.jsonl
   ```

## Структура проекта

```
├── ansible/                 # Ansible playbook и роли
├── docker/                  # Docker конфигурация
├── docs/                    # Документация
├── output/                  # Сгенерированные файлы
└── README.md
```

## Документация

- [Сборка прошивки](docs/firmware-build.md)
- [Прошивка устройства](docs/device-flashing.md)
- [Интеграция с Home Assistant](docs/homeassistant-integration.md)
- [Настройка MQTT](docs/mqtt-setup.md)

## Требования

- Docker
- ESP32-S3 тач-скрин (GUISTAR)
- Home Assistant с MQTT брокером
- Tion 4S бризер