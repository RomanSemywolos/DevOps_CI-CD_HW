variable "region" {
  description = "AWS region для деплою"
  type        = string
  default     = "eu-central-1"
}

variable "cluster_name" {
  description = "Назва EKS кластера"
  type        = string
  default     = "final-project-cluster"
}

variable "subnet_ids" {
  description = "Список підмереж для worker node group"
  type        = list(string)
}

variable "node_group_name" {
  description = "Назва node group"
  type        = string
  default     = "final-project-node-group"
}

variable "instance_type" {
  description = "Тип EC2 інстансів для нод"
  type        = string
  default     = "t3.medium"
}

variable "desired_size" {
  description = "Бажана кількість worker нод"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Максимальна кількість worker нод"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Мінімальна кількість worker нод"
  type        = number
  default     = 1
}

variable "vpc_id" {
  description = "ID VPC для створення SG нод"
  type        = string
}
