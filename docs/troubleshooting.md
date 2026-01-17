# Устранение проблем

## Общие проблемы

### Устройство не подключается к WiFi
- Проверьте SSID и пароль.
- Убедитесь, что сеть 2.4GHz доступна (ESP32 не поддерживает 5GHz).
- Попробуйте сбросить настройки WiFi через серийную консоль (команды `ssid` и `pass`).

### MQTT не работает
- Проверьте Hostname, порт, логин и пароль в веб-интерфейсе OpenHASP.
- **КРИТИЧЕСКИ ВАЖНО**: Hostname в настройках MQTT устройства должен точно совпадать с именем файла в `ansible/host_vars/` (например, `plate01`).
- Убедитесь, что MQTT брокер (Mosquitto) запущен в Home Assistant.
- Проверьте логи Mosquitto в HA (Настройки -> Аддоны -> Mosquitto broker -> Логи).

### OpenHASP не появляется в HA
- Убедитесь, что компонент openHASP установлен через HACS.
- Проверьте, что в `configuration.yaml` добавлена строка: `openhasp: !include_dir_named includes/openhasp`.
- Проверьте логи Home Assistant на наличие ошибок в YAML конфигурациях.

## Проблемы с Ansible

### Ошибка SSH connection
```text
FAILED! => {"changed": false, "msg": "Unable to connect to the remote server"}
```
**Решение:**
1. Убедитесь, что в аддоне **Advanced SSH & Web Terminal** отключен **Protection mode**.
2. Проверьте, что SSH порт настроен на **22222** (стандартный порт 22 в HA OS ограничен).
3. Проверьте, что вы используете пользователя **root**.
4. Проверьте доступность хоста: `ping homeassistant.local`.

### Ошибка API (Status code 401)
```text
"msg": "Status code was 401 and not [200]"
```
**Решение:**
1. Проверьте Long-Lived Access Token в Home Assistant.
2. Убедитесь, что токен передан правильно через `-e "homeassistant.api_token=..."` или через Ansible Vault.
3. Срок действия токена мог истечь.

### Ошибки валидации переменных
```text
ОШИБКА: Не определены обязательные переменные для plate01.
```
**Решение:**
1. Проверьте файл `ansible/host_vars/YOUR_DEVICE.yml`.
2. Убедитесь, что заполнены `device.name` и `homeassistant.climate_entity`.
3. Проверьте синтаксис YAML (отступы).

## Полезные команды для диагностики

```bash
# Проверка синтаксиса Ansible
cd ansible && ansible-playbook playbook.yml --syntax-check

# Проверка подключения к HA через Ansible
ansible all -i inventory/ha_servers -m ping

# Проверка доступности HTTP API устройства
curl -I http://<DEVICE_IP>/
```
