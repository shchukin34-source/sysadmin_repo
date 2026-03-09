#!/bin/bash
# setup-zabbix.sh

set -e # Прерывать выполнение при ошибке

echo "=== Обновление пакетов ==="
sudo apt update

echo "=== Установка зависимостей для Docker ==="
sudo apt install -y ca-certificates curl gnupg lsb-release

echo "=== Добавление официального GPG-ключа Docker ==="
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "=== Добавление репозитория Docker ==="
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "=== Обновление кеша APT с Docker-репозиторием ==="
sudo apt update

echo "=== Установка Docker Engine, CLI и Compose plugin ==="
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "=== Проверка установки Docker ==="
sudo docker run hello-world

echo "=== Подготовка директории для Zabbix ==="
sudo mkdir -p /opt/zabbix
sudo mv /tmp/docker-compose.yml /opt/zabbix/
cd /opt/zabbix

echo "=== Запуск контейнеров Zabbix ==="
sudo docker compose up -d

echo "=== Готово! ==="
echo "Проверьте статус контейнеров командой: sudo docker compose -f /opt/zabbix/docker-compose.yml ps"
