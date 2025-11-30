# lesson-8-9: Повний CI/CD-процес з Jenkins, Terraform, Helm та Argo CD

Цей урок реалізує повний цикл розгортання Django-застосунку в Kubernetes-кластері EKS:

- **Terraform** — керування інфраструктурою як кодом
- **AWS S3 + DynamoDB** — бекенд для Terraform state
- **AWS ECR** — зберігання Docker-образів
- **AWS EKS + VPC** — Kubernetes-кластер і мережа
- **Helm** — деплой застосунку
- **Jenkins** — CI: збірка Docker-образу, пуш в ECR, оновлення Helm values
- **Argo CD** — CD у стилі GitOps: автоматична синхронізація з Git

---

## Структура проекту

```text
lesson-8-9/
│
├── main.tf                  <- Головний файл для підключення модулів
├── backend.tf               <- Налаштування бекенду для стейтів (S3 + DynamoDB)
├── outputs.tf               <- Загальні виводи ресурсів
│
├── modules/                 <- Каталог з усіма модулями
│   ├── s3-backend/          <- Модуль для S3 та DynamoDB
│   │   ├── s3.tf            <- Створення S3-бакета
│   │   ├── dynamodb.tf      <- Створення DynamoDB
│   │   ├── variables.tf     <- Змінні для S3/Dynamo
│   │   └── outputs.tf       <- Вивід ID бакета та імені таблиці
│   │
│   ├── vpc/                 <- Модуль для VPC
│   │   ├── vpc.tf           <- Створення VPC, підмереж, Internet Gateway, NAT
│   │   ├── routes.tf        <- Налаштування маршрутних таблиць
│   │   ├── variables.tf     <- Змінні для VPC
│   │   └── outputs.tf       <- Виведення ID VPC та підмереж
│   │
│   ├── ecr/                 <- Модуль для ECR
│   │   ├── ecr.tf           <- Створення ECR репозиторію
│   │   ├── variables.tf     <- Змінні для ECR
│   │   └── outputs.tf       <- Виведення URL репозиторію
│   │
│   ├── eks/                      <- Модуль для Kubernetes кластера
│   │   ├── eks.tf                <- Створення EKS-кластера
│   │   ├── node.tf               <- Створення node group для воркерів
│   │   ├── aws_ebs_csi_driver.tf <- Встановлення EBS CSI драйвера (IRSA)
│   │   ├── variables.tf          <- Змінні для EKS
│   │   └── outputs.tf            <- Виведення інформації про кластер
│   │
│   ├── jenkins/             <- Модуль для Helm-установки Jenkins
│   │   ├── jenkins.tf       <- Helm release для Jenkins + IAM роль для Kaniko
│   │   ├── variables.tf     <- Змінні (cluster_name, oidc тощо)
│   │   ├── providers.tf     <- Вимоги до провайдерів
│   │   ├── values.yaml      <- Конфігурація Jenkins (JCasC, plugins)
│   │   └── outputs.tf       <- Виводи (імʼя релізу, namespace)
│   │
│   └── argo_cd/             <- Модуль для Helm-установки Argo CD
│       ├── argo_cd.tf       <- Helm release для Argo CD + Helm release для appʼів
│       ├── variables.tf     <- Змінні (версія чарта, namespace)
│       ├── providers.tf     <- Вимоги до провайдерів
│       ├── values.yaml      <- Базова конфігурація Argo CD server
│       ├── outputs.tf       <- Виводи (hostname, команда для пароля)
│       └── charts/          <- Helm-чарт для ArgoCD Application/Repository
│           ├── Chart.yaml
│           ├── values.yaml  <- Список applications, repositories (django-app)
│           └── templates/
│               ├── application.yaml
│               └── repository.yaml
│
├── charts/
│   └── django-app/
│       ├── templates/
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   ├── configmap.yaml
│       │   └── hpa.yaml
│       ├── Chart.yaml
│       └── values.yaml      <- Налаштування образу та змінних середовища
Команди для розгортання
1. Перехід у директорію з уроком
cd lesson-8-9/
2. Ініціалізація Terraform
terraform init
3. Перевірка плану змін
terraform plan
4. Створення інфраструктури
terraform apply
Буде створено:

VPC з публічними та приватними підмережами

S3-бакет та DynamoDB-таблиця для Terraform state

ECR-репозиторій для образів (lesson-7-hw-ecr)

EKS-кластер з node group

Jenkins у namespace jenkins

Argo CD у namespace argocd

ArgoCD Application, яке підтягує lesson-8-9/charts/django-app з Git

Налаштування доступу до кластера
Оновлення kubeconfig:

aws eks --region eu-central-1 update-kubeconfig --name lesson-8-9-eks-cluster
Argo CD
Отримання початкового admin-пароля:

kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d
Argo CD Application автоматично підтягує Helm-чарт:

репозиторій: https://github.com/YOUR_GITHUB_USERNAME/DevOps_CI-CD_HW

шлях: lesson-8-9/charts/django-app

гілка: main

Після зміни values.yaml і пушу в Git — Argo CD оновлює деплоймент.

Jenkins та CI/CD
Jenkins встановлюється через Helm-чарт у модулі modules/jenkins.
Конфігурація з values.yaml:

створюється адмін-користувач

ставляться базові плагіни (kubernetes, git, workflow, JCasC тощо)

налаштовується seed-job через JCasC

Пайплайн Jenkins (Jenkinsfile):

Клонує репозиторій DevOps_CI-CD_HW

Збирає Docker-образ для Django через Kaniko

Пушить образ до ECR (lesson-7-hw-ecr)

Оновлює тег образу в lesson-8-9/charts/django-app/values.yaml

Комітить і пушить зміни в гілку main

Argo CD виявляє зміну в Git і автоматично оновлює застосунок

Jenkinsfile може зберігатися в цьому ж репозиторії або бути доданий вручну в Jenkins — це не жорстко регламентовано структурою завдання.

Видалення ресурсів
Видалити застосунок через Argo CD UI або:
(якщо встановлено додатково helm-релізи вручну — видалити їх окремо)

Видалити інфраструктуру Terraform
terraform destroy
Це видалить:

EKS-кластер та вузли

ECR-репозиторій

Jenkins, Argo CD, VPC та інші ресурси

---