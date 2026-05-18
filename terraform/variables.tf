variable "aws_region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Nome base do projeto"
  type        = string
  default     = "ages-rfid"
}

variable "environment" {
  description = "Ambiente (staging ou production)"
  type        = string
}

variable "db_instance_class" {
  description = "Tamanho da máquina do banco de dados"
  type        = string
}
