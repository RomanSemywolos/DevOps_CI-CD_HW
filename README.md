# Final Project — DevOps інфраструктура на AWS

Комплексна інфраструктура Django-застосунку на AWS із використанням Terraform, Kubernetes (EKS), Jenkins, ArgoCD, RDS/Aurora та моніторингом Prometheus + Grafana.

## Технології

- Terraform — інфраструктура як код.
- AWS: S3, DynamoDB, VPC, ECR, EKS, RDS/Aurora.
- Docker — контейнеризація.
- Kubernetes + Helm — деплой.
- Jenkins — CI/CD.
- Argo CD — GitOps деплоймент.
- Prometheus, Grafana, AlertManager — моніторинг і алертинг.

## Структура проєкту

```
django-app/
├── app/
├── Dockerfile
├── Jenkinsfile
├── docker-compose.yml
├── manage.py
└── requirements.txt

final-project/
├── backend.tf
├── main.tf
├── outputs.tf
│
├── modules/
│   ├── s3-backend/
│   │   ├── s3.tf
│   │   ├── dynamodb.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── vpc/
│   │   ├── vpc.tf
│   │   ├── routes.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── ecr/
│   │   ├── ecr.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── eks/
│   │   ├── eks.tf
│   │   ├── aws_ebs_csi_driver.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── rds/
│   │   ├── rds.tf
│   │   ├── aurora.tf
│   │   ├── shared.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── jenkins/
│   │   ├── jenkins.tf
│   │   ├── variables.tf
│   │   ├── providers.tf
│   │   ├── values.yaml
│   │   └── outputs.tf
│   │
│   └── argo_cd/
│       ├── argo_cd.tf
│       ├── variables.tf
│       ├── providers.tf
│       ├── values.yaml
│       ├── outputs.tf
│       └── charts/
│           ├── Chart.yaml
│           ├── values.yaml
│           └── templates/
│               ├── application.yaml
│               └── repository.yaml
│
└── charts/
    └── django-app/
        ├── Chart.yaml
        ├── values.yaml
        └── templates/
            ├── deployment.yaml
            ├── service.yaml
            ├── configmap.yaml
            └── hpa.yaml
```

## Розгортання інфраструктури

### 1. Ініціалізація Terraform

```
cd final-project/
terraform init
terraform plan
terraform apply
```

Створюються S3, DynamoDB, VPC, ECR, EKS, RDS/Aurora, Jenkins, Argo CD, Prometheus, Grafana, AlertManager.

### 2. Перевірка стану кластерів

```
kubectl get all -n jenkins
kubectl get all -n argocd
kubectl get all -n monitoring
```

## Збірка та пуш Docker-образу в ECR

### Авторизація

```
aws ecr get-login-password --region eu-central-1 \
 | docker login --username AWS --password-stdin 140083317091.dkr.ecr.eu-central-1.amazonaws.com
```

### Збірка та пуш

```
docker build -t django-app ./django-app
docker tag django-app:latest 140083317091.dkr.ecr.eu-central-1.amazonaws.com/final-project-hw-ecr:latest
docker push 140083317091.dkr.ecr.eu-central-1.amazonaws.com/final-project-hw-ecr:latest
```

## Налаштування kubeconfig

```
aws eks --region eu-central-1 update-kubeconfig --name final-project-hw-cluster
```

## Деплой Django через Helm

```
cd charts/
helm upgrade --install django-app ./django-app
```

## Port-forward для інструментів

### Jenkins

```
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
```

### Argo CD

```
kubectl port-forward svc/argocd-server 8081:443 -n argocd
```

### Grafana

```
kubectl port-forward svc/grafana 3000:80 -n monitoring
```

## Видалення ресурсів

```
helm uninstall django-app
terraform destroy
```

## Універсальний RDS-модуль

Підтримка двох режимів:

- RDS Instance
- Aurora Cluster (writer + reader)

Створюються:

- subnet group  
- security group  
- parameter group  
- кластер або інстанс  
- reader endpoints (Aurora)

### Приклад використання

```
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

  instance_class       = "db.t3.medium"
  allocated_storage    = 20

  db_name              = "djangoapp"
  username             = "postgres"
  password             = "pass2315wd"

  vpc_id               = module.vpc.vpc_id
  subnet_private_ids   = module.vpc.private_subnets
  subnet_public_ids    = module.vpc.public_subnets

  multi_az              = true
  backup_retention_period = 7

  node_sg_id = module.eks.eks_nodes_sg_id
}
```

## Моніторинг

Модуль автоматично встановлює:

- Prometheus  
- Grafana  
- Alertmanager  
- Node exporter  
- Kube-state-metrics  
- Prometheus Operator  
- ServiceMonitor для Django  
- кастомні алерти  

### Основні дашборди

- Kubernetes Cluster  
- Pods / Deployments  
- Node Exporter  
- Django (через django-prometheus)

### Алерти

- HighMemoryUsage (>80%)  
- HighCPUUsage (>80%)  
- PodRestarting  
- CrashLoopBackoff  
- KubernetesNodeNotReady  

Slack інтеграція активується параметрами:

```
slack_webhook_url
slack_channel
```

## Підсумок

Інфраструктура включає:

- VPC  
- EKS кластер  
- RDS / Aurora  
- Jenkins  
- ArgoCD  
- ECR  
- Prometheus + Grafana  
- Повний Helm-чарт Django  
- HPA автоскейлінг  
- централізований Terraform backend  

Усе розгортається та керується через Terraform.
