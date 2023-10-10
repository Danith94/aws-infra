variable "instance_types" {
    default = ["t2.micro"]
    type = list(string)
  
}

variable "ami_type" {
    default = "BOTTLEROCKET_x86_64"
    type = string
  
}