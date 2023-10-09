variable "availability_zone" {
    type = string
}

variable "ec2_security_group" {
    type = list(string)
  
}

variable "tags" {
    type = string
  
}

variable "subnet_id" {
    type = string
  
}

variable "key_name" {
    type = string
  
}

variable "ami" {
    type = string
  
}




