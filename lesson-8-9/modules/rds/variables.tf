variable "name" {
  description = "Назва RDS інстансу або Aurora кластера"
  type        = string
}

variable "use_aurora" {
  description = "true = Aurora Cluster, false = Standard RDS"
  type        = bool
  default     = false
}

# --- RDS-only ---
variable "engine" {
  description = "Движок для стандартної RDS (postgres, mysql)"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Версія движка для стандартної RDS"
  type        = string
  default     = "17.2"
}

variable "parameter_group_family_rds" {
  description = "Сімейство параметрів для стандартної RDS (postgres15, postgres17 тощо)"
  type        = string
  default     = "postgres17"
}

variable "allocated_storage" {
  description = "Обсяг сховища для RDS інстансу (GiB)"
  type        = number
  default     = 20
}

# --- Aurora-only ---
variable "engine_cluster" {
  description = "Движок кластера Aurora (aurora-postgresql, aurora-mysql)"
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_version_cluster" {
  description = "Версія движка для Aurora"
  type        = string
  default     = "15.3"
}

variable "aurora_instance_count" {
  description = "Загальна кількість інстансів Aurora (1 writer + N readers). Для прикладу використовується тільки як описовий параметр."
  type        = number
  default     = 2
}

variable "aurora_replica_count" {
  description = "Кількість reader-реплік Aurora"
  type        = number
  default     = 1
}

variable "parameter_group_family_aurora" {
  description = "Сімейство параметрів для Aurora (aurora-postgresql15 тощо)"
  type        = string
  default     = "aurora-postgresql15"
}

# --- Common ---
variable "instance_class" {
  description = "Клас інстансу (db.t3.micro, db.t3.medium...)"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Назва бази даних"
  type        = string
}

variable "username" {
  description = "Ім'я користувача бази даних"
  type        = string
}

variable "password" {
  description = "Пароль користувача бази даних"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "ID VPC, де створюється RDS/Aurora"
  type        = string
}

variable "subnet_private_ids" {
  description = "Список приватних підмереж для DB subnet group"
  type        = list(string)
}

variable "subnet_public_ids" {
  description = "Список публічних підмереж (на випадок publicly_accessible = true)"
  type        = list(string)
}

variable "publicly_accessible" {
  description = "Чи має база бути доступною з публічної мережі"
  type        = bool
  default     = false
}

variable "multi_az" {
  description = "Multi-AZ для стандартної RDS"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Період зберігання backup'ів (днів)"
  type        = number
  default     = 7
}

variable "parameters" {
  description = "Мапа параметрів для parameter group"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Додаткові теги для всієї RDS-інфраструктури"
  type        = map(string)
  default     = {}
}

# Security Group вузлів EKS, які мають доступ до бази
variable "node_sg_id" {
  description = "ID Security Group для EKS worker nodes, яким дозволено доступ до RDS"
  type        = string
}
