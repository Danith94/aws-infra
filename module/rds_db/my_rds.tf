resource "aws_db_instance" "db_terraform" {
  allocated_storage    = var.allocated_storage
  db_name              = var.name
  engine               =var.rds_engine
  engine_version       = var.engine_version
  instance_class       = var.instance_type
  username             = var.username
  password             = var.password
  skip_final_snapshot  = true
  db_subnet_group_name = var.db_subnet_group_name
  vpc_security_group_ids = var.db_sg
}


output "db_endpoint" {
  value = aws_db_instance.db_terraform.endpoint
}

output "db_port" {
  value = aws_db_instance.db_terraform.port
}