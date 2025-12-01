# Розгортання Django у Kubernetes (AWS EKS)

Цей проєкт описує інфраструктуру для запуску контейнеризованого Django-застосунку в AWS.  
Інфраструктура створюється Terraform, а сам застосунок розгортається у кластер EKS за допомогою Helm.

---

## Компоненти інфраструктури

### Terraform створює:

- **S3 + DynamoDB** — бекенд для зберігання Terraform-стану та блокування;
- **VPC** — мережа з публічними й приватними підмережами, Internet Gateway, NAT Gateway та таблицями маршрутизації;
- **ECR** — репозиторій контейнерів;
- **EKS** — Kubernetes-кластер та node group.

### Helm забезпечує:

- Deployment з образом із ECR;  
- Service типу LoadBalancer;  
- ConfigMap зі змінними середовища;  
- Horizontal Pod Autoscaler.

---

## Структура каталогу

lesson-7/
│ main.tf
│ backend.tf
│ outputs.tf
│
├── modules/
│ ├── s3-backend/
│ ├── vpc/
│ ├── ecr/
│ └── eks/
│
└── charts/
└── django-app/
├── Chart.yaml
├── values.yaml
└── templates/

---

## Розгортання Terraform-інфраструктури

### 1. Ініціалізація

terraform init

shell

### 2. Попередній перегляд змін

terraform plan

shell

### 3. Створення всіх ресурсів

terraform apply

Після цього будуть доступні: кластер EKS, репозиторій ECR, мережа VPC та бекенд S3/DynamoDB.

---

## Підготовка Docker-образу

### Авторизація в ECR

aws ecr get-login-password --region eu-central-1
| docker login --username AWS --password-stdin <account-id>.dkr.ecr.eu-central-1.amazonaws.com

shell

### Збірка та пуш образу

docker build -t django-app ./django-app
docker tag django-app:latest <ecr-repository-url>:latest
docker push <ecr-repository-url>:latest

---

## Налаштування доступу kubectl до кластера

aws eks --region eu-central-1 update-kubeconfig --name lesson-7-eks-cluster

---

## Деплой у кластер через Helm

helm install django-app ./charts/django-app

У кластері буде створено Deployment, Service із зовнішнім доступом, ConfigMap та HPA.

Після створення LoadBalancer AWS призначить публічну IP-адресу.

---

## Видалення застосунку та інфраструктури

Видалення Helm-релізу:

helm uninstall django-app

Повне видалення інфраструктури:

terraform destroy

---