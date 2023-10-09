variable "name" {
    type = string
  
}

variable "rds_engine" {
    type = string
  
}

variable "engine_version" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "username" {
    type = string
  
}

variable "password" {
    type = string
  
}

variable "allocated_storage" {
    type = number
  
}

variable "db_subnet_group_name" {
    type = string
  
}

variable "db_sg" {
  type = list(string)
}