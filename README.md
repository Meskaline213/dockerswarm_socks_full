# Sock Shop в Яндекс.Облаке (Terraform + Docker Swarm)

Автоматизированное развёртывание микросервисного демо-приложения [Sock Shop](https://microservices-demo.github.io/) с мониторингом (Prometheus, Grafana) в инфраструктуре Яндекс.Облака с помощью Terraform, cloud-init и Docker Swarm.

---

## Архитектура и компоненты

- **Terraform** — автоматизация создания инфраструктуры (ВМ, сеть, firewall)
- **cloud-init** — автоматическая настройка ВМ, установка Docker, инициализация Swarm, деплой приложения
- **Docker Swarm** — оркестрация микросервисов
- **Sock Shop** — демонстрационное приложение (front-end, back-end, базы данных, очередь, симулятор пользователей)
- **Prometheus, Grafana** — мониторинг и визуализация метрик

---

## Требования

- Аккаунт в [Яндекс.Облаке](https://cloud.yandex.ru/)
- Terraform >= 1.0
- Доступный публичный SSH-ключ

---

## Быстрый старт

```sh
# 1. Клонируйте репозиторий
git clone https://github.com/Meskaline213/dockerswarm_socks_full.git
cd dockerswarm_socks_full

# 2. Скопируйте пример переменных и заполните своими значениями
cp terraform.tfvars.example terraform.tfvars
# Откройте terraform.tfvars и укажите yc_token, yc_cloud_id, yc_folder_id, ssh_public_key

# 3. Инициализируйте Terraform
terraform init

# 4. Примените инфраструктуру (создание и деплой полностью автоматизированы)
terraform apply -auto-approve
```

---

## Переменные Terraform

В файле `terraform.tfvars` укажите:

```hcl
yc_token    = "PASTE_YOUR_YC_TOKEN_HERE"
yc_cloud_id = "PASTE_YOUR_CLOUD_ID_HERE"
yc_folder_id = "PASTE_YOUR_FOLDER_ID_HERE"
ssh_public_key = "ssh-rsa AAAA... user@host"
```

---

## Что будет создано

- 1 менеджер и 2 воркера (Ubuntu 22.04, Docker, cloud-init)
- VPC, подсеть, security group с нужными портами
- Автоматический деплой:
  - Sock Shop (front-end, back-end, базы, очередь, симулятор)
  - Monitoring: Prometheus, Grafana, Node Exporter, Alertmanager
- Импорт дашбордов Grafana (см. папку `grafana/`)

---

## Доступ к сервисам

После деплоя в выводе Terraform появятся адреса:

- **Sock Shop:** `http://<swarm_manager_external_ip>`
- **Grafana:** `http://<swarm_manager_external_ip>:3000`
- **Prometheus:** `http://<swarm_manager_external_ip>:9090`

---

## Удаление инфраструктуры

```sh
terraform destroy -auto-approve
```

---

## Полезные команды

- Проверить сервисы на менеджере:
  ```sh
  docker service ls
  docker stack ls
  ```
- Логи сервиса:
  ```sh
  docker service logs <service_name>
  ```

---

## Контакты/автор

Автор: [Meskaline213](https://github.com/Meskaline213)

Для вопросов и предложений — создавайте issue или пишите в Telegram: @ваш_ник 