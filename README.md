# lesson-8-9: Повний CI/CD-процес із Jenkins, Terraform, Helm та Argo CD

Цей проєкт реалізує комплексний DevOps-процес, де інфраструктура, CI та CD працюють разом.  
Поєднання Terraform, Jenkins, Helm та Argo CD забезпечує автоматичний збір Docker-образів, оновлення Helm-чарта та синхронізацію застосунку у Kubernetes-кластері AWS EKS.

## Використані технології

- **Terraform** – інфраструктура як код.
- **AWS S3 + DynamoDB** – зберігання Terraform state та блокування.
- **AWS ECR** – контейнерний реєстр для Docker-образів.
- **AWS VPC** – приватна мережа з публічними та приватними підмережами.
- **AWS EKS** – Kubernetes-кластер.
- **Helm** – деплой Django-застосунку.
- **Jenkins** – CI-сервер для автоматизації збірки образів.
- **Kaniko** – бездемоновий Docker builder у Kubernetes.
- **Argo CD** – GitOps CD: відстеження змін у Git та автоматичне оновлення кластера.

---

# Структура проєкту

```
lesson-8-9/
│
├── main.tf                  <- Підключення всіх модулів
├── backend.tf               <- Бекенд Terraform (S3 + DynamoDB)
├── outputs.tf               <- Загальні вихідні дані
│
├── modules/                 <- Індивідуальні модулі Terraform
│   ├── s3-backend/          <- S3 та DynamoDB для тераформ-стейту
│   │   ├── s3.tf
│   │   ├── dynamodb.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── vpc/                 <- VPC з публічними та приватними підмережами
│   │   ├── vpc.tf
│   │   ├── routes.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── ecr/                 <- Репозиторій ECR
│   │   ├── ecr.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── eks/                 <- Kubernetes-кластер EKS
│   │   ├── eks.tf
│   │   ├── node.tf
│   │   ├── aws_ebs_csi_driver.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── jenkins/             <- Helm-чарт Jenkins + роль Kaniko
│   │   ├── jenkins.tf
│   │   ├── values.yaml
│   │   ├── variables.tf
│   │   ├── providers.tf
│   │   └── outputs.tf
│   │
│   └── argo_cd/             <- Встановлення Argo CD і Argo Applications
│       ├── argo_cd.tf
│       ├── values.yaml
│       ├── providers.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── charts/
│           ├── Chart.yaml
│           ├── values.yaml     <- Список Applications + Git репозиторії
│           └── templates/
│               ├── application.yaml
│               └── repository.yaml
│
├── charts/                  <- Helm-чарт Django застосунку
│   └── django-app/
│       ├── templates/
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   ├── configmap.yaml
│       │   └── hpa.yaml
│       ├── Chart.yaml
│       └── values.yaml      <- Налаштування образу + змінних середовища
```

---

# Розгортання інфраструктури

## 1. Перейти в директорію

```bash
cd lesson-8-9/
```

## 2. Ініціалізація Terraform

```bash
terraform init
```

## 3. Перевірка плану

```bash
terraform plan
```

## 4. Створення інфраструктури

```bash
terraform apply
```

### Буде створено:

- VPC (3 публічні + 3 приватні підмережі)
- S3-бакет та DynamoDB-таблиця для Terraform state
- ECR репозиторій: **lesson-7-hw-ecr**
- EKS-кластер з node group
- Jenkins (через Helm)
- Argo CD та Argo CD Applications (GitOps)
- Application для Django-чарта

---

# Налаштування доступу до Kubernetes

Оновлення kubeconfig:

```bash
aws eks --region eu-central-1 update-kubeconfig --name lesson-7-hw-cluster
```

---

# Збірка та пуш Docker образу (без Jenkins)

(Для тесту)

```bash
aws ecr get-login-password --region eu-central-1 \
  | docker login --username AWS --password-stdin <account>.dkr.ecr.eu-central-1.amazonaws.com

docker build -t django-app ./django
docker tag django-app:latest <repo-url>:latest
docker push <repo-url>:latest
```

---

# Jenkins (CI)

Jenkins встановлюється через Terraform у namespace `jenkins`.

Функціональність пайплайна (Jenkinsfile):

1. Клонує репозиторій DevOps_CI-CD_HW
2. Збирає Docker-образ через Kaniko
3. Пушить образ у ECR
4. Оновлює `image.tag` у `charts/django-app/values.yaml`
5. Комітить і пушить зміни у гілку `main`
6. Argo CD автоматично підхоплює оновлення

Jenkins отримує всі необхідні права через IRSA (IAM роль `*-jenkins-kaniko-role`).

---

# Argo CD (CD)

Argo CD працює у namespace `argocd`.

Тут створюється Argo CD Application, який:

- відстежує репозиторій:  
  `https://github.com/RomanSemywolos/DevOps_CI-CD_HW`
- слідкує за шляхом:  
  `lesson-8-9/charts/django-app`
- автоматично синхронізує зміни Helm-чарта

## Отримання початкового пароля

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
-o jsonpath='{.data.password}' | base64 -d
```

---

# Видалення інфраструктури

### 1. Видалити деплой через Argo CD (або просто залишити — terraform сам прибере кластер)

### 2. Видалити всі ресурси Terraform:

```bash
terraform destroy
```

Це прибере:

- EKS + вузли
- Jenkins
- Argo CD
- ECR
- VPC
- NAT + Internet Gateway
- S3 та DynamoDB (якщо не захищені)

---

## ✔ Результат

Після завершення:

- Джанго-застосунок розгортається через Helm у кластері.
- CI/CD повністю автоматизований:
  - Jenkins будує образ → пушить в ECR → оновлює Helm-чарт.
  - Argo CD підтягує нову версію з Git → оновлює кластер.
- Вся інфраструктура створена Terraform і може бути легко знищена або відтворена.
