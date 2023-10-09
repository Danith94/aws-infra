variable "availability_zone-1a" {
    description = "AWS Availabilty zone specify here"
    default = "ap-southeast-1a"
}

variable "availability_zone-1b" {
    description = "AWS Availabilty zone specify here"
    default = "ap-southeast-1b"
}

variable "vpc_ip" {
    description = "ip address of the vpc"
    default = "172.20.193.0/24"
  
}

variable "public_subnet_ip" {
    description = "public ip of the subnet"
    default = "172.20.193.176/28"
  
}

variable "private_subnet_ip_a" {
    description = "private ip of the subnet"
    default = "172.20.193.0/26"
  
}
variable "private_subnet_ip_b" {
    description = "private ip of the subnet"
    default = "172.20.193.64/26"
  
}

variable "common_tag" {
    description = "tag for each resource"
    default = "terraform-infra"
  
}

variable "private_subnets" {
    description = "private subnet ip set"
    default = ["172.20.193.0/26","172.20.193.64/26"]
    type = list(string)
  
}

variable "ami" {
    type = string
    default = "ami" # add corrrect ami here
  
}

variable "db_subnet_ids" {
    type = list(string)
    default = ["172.20.193.128/28","172.20.193.144/28"]
  
}

variable "rds_engine" {
    default = "mysql"
  
}

variable "engine_version" {
    default = "5.7" // Add latest version here
  
}

variable "usernamedb" {
    default = "admin"
  
}

variable "passworddb" {
    default = "admin"
  
}

variable "instance_type" {
    default = "db.t3.micro"
  
}

