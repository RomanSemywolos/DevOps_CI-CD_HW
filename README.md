# Інфраструктура для Django-застосунку з CI/CD та універсальним RDS-модулем

Цей проєкт реалізує повний стек інфраструктури для Django-застосунку в AWS, включаючи Kubernetes, GitOps, CI/CD, контейнеризацію та універсальний Terraform-модуль для RDS/Aurora.

---

## Використані технології

- **Terraform** — інфраструктура як код  
- **AWS**:
  - S3 + DynamoDB — бекенд Terraform state  
  - VPC — мережа  
  - ECR — контейнерний реєстр  
  - EKS — Kubernetes кластер  
  - RDS / Aurora — база даних  
- **Docker** — контейнеризація застосунку  
- **Kubernetes + Helm** — деплой  
- **Jenkins** — CI/CD  
- **Argo CD** — GitOps  

---

## Структура проєкту

```
lesson-8-9/
│
├── main.tf
├── backend.tf
├── outputs.tf
│
├── modules/
│   ├── s3-backend/
│   ├── vpc/
│   ├── ecr/
│   ├── eks/
│   ├── rds/
│   │   ├── rds.tf
│   │   ├── aurora.tf
│   │   ├── shared.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── jenkins/
│   └── argo_cd/
│
└── charts/
    └── django-app/
        ├── templates/
        ├── Chart.yaml
        └── values.yaml
```

---

# Розгортання інфраструктури

## 1. Ініціалізація Terraform

```bash
terraform init
```

## 2. Перевірка плану

```bash
terraform plan
```

## 3. Створення всіх ресурсів

```bash
terraform apply
```

### У результаті створюється:

- VPC з публічними та приватними підмережами  
- S3 + DynamoDB для Terraform backend  
- ECR репозиторій  
- EKS Kubernetes кластер  
- **Aurora Cluster або стандартна RDS** (залежно від `use_aurora`)  
- Jenkins і Argo CD  
- Деплой Django через Helm  

---

# Docker + ECR

## Логін у ECR

```bash
aws ecr get-login-password --region eu-central-1 \
  | docker login --username AWS --password-stdin 273497135368.dkr.ecr.eu-central-1.amazonaws.com
```

## Збірка образу

```bash
docker build -t django-app ./django-app
```

## Пуш у ECR

```bash
docker tag django-app:latest 273497135368.dkr.ecr.eu-central-1.amazonaws.com/lesson-7-hw-ecr:latest
docker push 273497135368.dkr.ecr.eu-central-1.amazonaws.com/lesson-7-hw-ecr:latest
```

---

# Kubernetes + Helm

## Налаштування kubeconfig

```bash
aws eks --region eu-central-1 update-kubeconfig --name lesson-7-hw-cluster
```

## Деплой Django застосунку

```bash
cd charts/
helm install django-app ./django-app
```

## Видалення

```bash
helm uninstall django-app
terraform destroy
```

---

# Універсальний RDS-модуль

Модуль автоматично створює:

- **DB Subnet Group**  
- **Security Group**, яка пропускає трафік тільки з EKS worker nodes  
- **Parameter Group**  
- Aurora Cluster (writer + readers) або стандартну RDS instance  

Модуль повністю керується через змінні — жодного hardcode.

---

## Приклад використання

```hcl
module "rds" {
  source = "./modules/rds"

  name                 = "django-db"
  use_aurora           = true
  aurora_replica_count = 1

  engine_cluster             = "aurora-postgresql"
  engine_version_cluster     = "15.3"
  parameter_group_family_aurora = "aurora-postgresql15"

  engine                     = "postgres"
  engine_version             = "17.2"
  parameter_group_family_rds = "postgres17"

  instance_class    = "db.t3.medium"
  allocated_storage = 20

  db_name   = "djangoapp"
  username  = "postgres"
  password  = "pass2315wd"

  subnet_private_ids   = module.vpc.private_subnets
  subnet_public_ids    = module.vpc.public_subnets
  publicly_accessible  = false

  vpc_id     = module.vpc.vpc_id
  node_sg_id = module.eks.eks_nodes_sg_id

  multi_az                = true
  backup_retention_period = 7

  parameters = {
    max_connections            = "200"
    log_min_duration_statement = "500"
  }

  tags = {
    Environment = "dev"
    Project     = "djangoapp"
  }
}
```

---

# Можливості RDS-модуля

- Підтримка **Aurora Cluster** та **Standard RDS**  
- Автоматичні ресурси:
  - DB Subnet Group  
  - Security Group  
  - Parameter Group  
- Повна підтримка **PostgreSQL і MySQL**  
- Multi-AZ  
- Backup retention  
- Reader endpoints (Aurora)  

---

# Зміна типу бази

## Aurora → Standard RDS

```hcl
use_aurora = false
```

## Зміна типу двигуна

```hcl
engine = "mysql"
engine_version = "8.0.35"
```

## Зміна класу інстансу

```hcl
instance_class = "db.t3.micro"
```

## Додавання параметрів

```hcl
parameters = {
  max_connections = "300"
}
```

---

