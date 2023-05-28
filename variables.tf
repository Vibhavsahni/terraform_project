variable "aws_region" {
  type = string
}

variable "my_access_key" {
  description = "User's Access Key ID"
  type        = string
  sensitive   = true
}

variable "my_secret_key" {
  description = "User's Secret access key"
  type        = string
  sensitive   = true
}

variable "subnet1_availability_zone" {
  type = string
}

variable "subnet_cidr_block" {}

variable "vpc_cidr_block" {}

variable "env_prefix" {}

variable "my_ip" {}

variable "inctance_type" {}

variable "public_key_location" {}