resource "aws_security_group" "security_group-terraform" {
  
  name        = "terraf-sg"
  description = "Allow TLS traffic"
  vpc_id      = var.vpc_id

    ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = var.cidr_block
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.tags
  }
}

output "security_group_custom_id" {
    value = aws_security_group.security_group-terraform.id
}

