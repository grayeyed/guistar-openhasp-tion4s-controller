# Сборка прошивки OpenHASP

В данном руководстве описан процесс самостоятельной сборки прошивки OpenHASP из исходного кода для устройства ESP32-S3 (GUISTAR).

## 1. Требования к ПО

### Установка Visual Studio Code
Для разработки и сборки рекомендуется использовать VS Code:
- [Linux](https://code.visualstudio.com/docs/setup/linux)
- [macOS](https://code.visualstudio.com/docs/setup/mac)
- [Windows](https://code.visualstudio.com/docs/setup/windows)

### Дополнительные пакеты (для Linux)
```bash
sudo apt update
sudo apt install git python3-venv
```

### Установка PlatformIO
1. Откройте VS Code.
2. Перейдите в раздел **Extensions** (Ctrl+Shift+X).
3. Найдите и установите расширение **PlatformIO IDE**.
4. После установки перезапустите VS Code.

## 2. Подготовка исходного кода

Клонируйте репозиторий OpenHASP. **Важно** использовать параметр `--recursive` для загрузки всех подмодулей:

```bash
git clone --recursive https://github.com/HASwitchPlate/openHASP.git
cd openHASP
```

Если вы уже клонировали репозиторий без этого параметра, выполните:
```bash
git submodule update --init --recursive
```

Для работы с конкретной версией (например, v0.7.0):
```bash
git checkout v0.7.0-rc13
git submodule update --init --recursive
```

## 3. Настройка параметров сборки

Для данного устройства (GUISTAR ESP32-S3 480x480) используются следующие параметры:
- **Environment**: `esp32-s3-4848S040`
- **Flash Size**: 16.00 MiB
- **PSRAM**: 8 MiB (Quad SPI)
- **Display**: 480x480 ST7701S (RGB интерфейс)

### Создание конфигурации
1. Скопируйте шаблон файла конфигурации:
   ```bash
   cp platformio_override-template.ini platformio_override.ini
   ```
2. Отредактируйте `platformio_override.ini`, указав путь к конфигурации устройства:

```ini
[platformio]
extra_configs =
    user_setups/esp32s3/esp32-s3-4848S040.ini
```

### Кастомизация (опционально)
Если вы хотите использовать собственные настройки в `include/user_config_override.h`, раскомментируйте строку в `platformio_override.ini`:
```ini
[override]
build_flags =
    -DUSE_CONFIG_OVERRIDE
```

## 4. Сборка и прошивка

### Сборка через CLI
```bash
pio run -e esp32-s3-4848S040
```

### Сборка через интерфейс VS Code
1. Нажмите на иконку PlatformIO (муравей) в боковой панели.
2. Найдите в списке `esp32-s3-4848S040`.
3. Нажмите **Build**.

### Прошивка
Для загрузки прошивки на устройство:
```bash
pio run -e esp32-s3-4848S040 -t upload
```

## Полезные ссылки
- [Официальная документация по сборке OpenHASP](https://openhasp.com/0.7.0/firmware/compiling/)
- [Поддерживаемые устройства и окружения](https://openhasp.com/0.7.0/devices/esp32-s3/)
- [PlatformIO Core CLI Guide](https://docs.platformio.org/en/latest/core/index.html)
