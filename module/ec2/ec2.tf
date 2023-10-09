resource "aws_instance" "ec2-terraform" {
    ami =  var.ami
    instance_type = "t2.micro"
    availability_zone = var.availability_zone
    security_groups = var.ec2_security_group
    tags = {
        Name = var.tags
    }
    subnet_id = var.subnet_id
    key_name = var.key_name
    root_block_device {
      volume_size = "10"
    }
  
}

output "ip" {
   value = aws_instance.ec2-terraform.private_ip
  
}

output "id" {
  value = aws_instance.ec2-terraform.id
}