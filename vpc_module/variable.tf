## variables

variable "cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "private_subnets" {
    type = list(string)
    default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
    default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "subnet_number" {
  type = number
  default = 2
}

variable "env" {
  type = string
  default = "prod"
  
}

variable "name" {
  type = string
}

variable "REGION" {
  default = "us-east-1"
}

variable "enable_private" {
  type = bool
  default = true
}