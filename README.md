# Sysadmin Repository

## 📁 Структура проекта

- `/zabbix-project/` - Terraform-конфигурация для развертывания Zabbix на Proxmox
  - `main.tf` - основной файл Terraform
  - `docker-compose.yml` - конфигурация Zabbix в Docker
  - `setup-zabbix.sh` - скрипт установки
  - `cloud-init.yaml` - конфигурация cloud-init

- `/training/` - Учебные материалы и эксперименты
  - `/old-training/` - Первые опыты с Terraform
  - `/terraform-proxmox/` - Эксперименты с Proxmox провайдером

## 🚀 Быстрый старт

```bash
cd zabbix-project
terraform init
terraform plan
terraform apply


### **Шаг 4: Закоммитим изменения структуры**
```bash
# Посмотрим, что изменилось
git status

# Добавим все изменения
git add .

# Закоммитим
git commit -m "Reorganize repository structure: separate zabbix project from training materials"

# Отправим на GitHub
git push origin main
