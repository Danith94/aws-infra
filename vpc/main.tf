data "aws_availability_zones" "available" {
   all_availability_zones = true
}

resource "aws_vpc" "vpc-dgb" {

    cidr_block = var.vpc_ip
    tags = {
        Name = var.common_tag
    }
    enable_dns_hostnames = true
 
}


output "vpc_id" {
    value = aws_vpc.vpc-dgb.id
  
}

// Creating Internet Gateway
resource "aws_internet_gateway" "gw-dgb" {
    vpc_id = aws_vpc.vpc-dgb.id
    tags = {
      Name = var.common_tag
    }
  
}

// Creating public subnet
resource "aws_subnet" "public-subnet-dgb" {

    vpc_id =  aws_vpc.vpc-dgb.id
    tags = {
      Name = var.common_tag
    }
    cidr_block =  var.public_subnet_ip
    availability_zone = data.aws_availability_zones.available.names[0]
    map_public_ip_on_launch = true
  
}

// Creating private subnet 
resource "aws_subnet" "private-subnet1-dgb" {

    vpc_id =  aws_vpc.vpc-dgb.id
    tags = {
      Name = var.common_tag
    }
    cidr_block =  var.private_subnet_ip_a
    availability_zone = data.aws_availability_zones.available.names[0]
    map_public_ip_on_launch = false
  
}

// Creating private subnet 
resource "aws_subnet" "private-subnet2-dgb" {

    vpc_id =  aws_vpc.vpc-dgb.id
    tags = {
      Name = var.common_tag
    }
    cidr_block =  data.aws_availability_zones.available.names[1]
    availability_zone = var.availability_zone-1b
    map_public_ip_on_launch = false
  
}

// Creating public route table
resource "aws_route_table" "public-rt-dgb" {
    vpc_id = aws_vpc.vpc-dgb.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw-dgb.id
    }
    tags = {
      Name = var.common_tag
    }
  
}

// Route table association
resource "aws_route_table_association" "associate-public-dgb" {
    subnet_id = aws_subnet.public-subnet-dgb.id
    route_table_id = aws_route_table.public-rt-dgb.id
  
}

// Elastic IP
resource "aws_eip" "elastic-ip-dgb" {
    domain = "vpc"
 
}

output "aws_nat_gateway_ip" {
   value = aws_eip.elastic-ip-dgb.public_ip
  
}

// Nat Gateway
resource "aws_nat_gateway" "nt-gw-dgb" {
    subnet_id = aws_subnet.public-subnet-dgb
    allocation_id = aws_eip.elastic-ip-dgb
    tags = {
      Name = var.common_tag
    }

}
//Private Route Table
resource "aws_route_table" "private-rt-dgb" {
    vpc_id = aws_vpc.vpc-dgb.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nt-gw-dgb.id
    }
    tags = {
      Name = var.common_tag
    }
  
}

// Private Route Table association
resource "aws_route_table_association" "associate-private-rt-dgb" {
  count = length(var.private_subnets)
  subnet_id = var.private_subnets[count.index]
  route_table_id = aws_route_table.private-rt-dgb
}


########## EC2 instance on private subnet

module "pvt_ec2_security_group" {
  source = "../module/security_group"
  cidr_block = ["172.123.23.9/28"]
  vpc_id =  aws_vpc.vpc-dgb.id
  tags = var.common_tag

}

module "pvt_ec2" {
  source = "../module/ec2"
  ami = var.ami
  availability_zone = data.aws_availability_zones.available.names[0]
  subnet_id = aws_subnet.private-subnet1-dgb
  key_name = "terraform-key"
  ec2_security_group = ["${module.pvt_ec2_security_group.security_group_custom_id}"]
  tags = var.common_tag

}

module "my_custom_tls_key" {
  source = "../module/tls_private_key"
}

module "key_pair" {
  source = "../module/aws_key_pair"
  key_name = "terraform-key"
  public_key = module.my_custom_tls_key.public_key_openssh
  
}


########## EC2 instance on public subnet

module "jump_host_security_group" {
  source = "../module/security_group"
  cidr_block = ["0.0.0.0/0"]
  vpc_id =  aws_vpc.vpc-dgb.id
  tags = var.common_tag

}

module "jump_host" {
  source = "../module/ec2"
  ami = var.ami
  availability_zone = data.aws_availability_zones.available.names[0]
  subnet_id = aws_subnet.public-subnet-dgb
  key_name = "jump_host_key"
  ec2_security_group = ["${module.jump_host_security_group.security_group_custom_id}"]
  tags = var.common_tag

}

resource "aws_eip" "jump_host_public_ip" {
    domain = "vpc"
    instance = module.jump_host.id
 
}

module "jump_host_tls_key" {
  source = "../module/tls_private_key"
}

module "jump_host_key_pair" {
  source = "../module/aws_key_pair"
  key_name =  "jump_host_key" 
  public_key = module.jump_host_tls_key.public_key_openssh
  
}

// DB Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "dbsubentgroup"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = var.common_tag
  }
}

// DB Security Group
module "db_security_group" {
  source = "../module/security_group"
  cidr_block = [module.pvt_ec2.ip]  //add pvt ip address of the private ec2 
  vpc_id =  aws_vpc.vpc-dgb.id
  tags = var.common_tag

}

// RDS  
module "rds_db" {
  source = "../module/rds_db"
  name = "sampledb"
  rds_engine = var.rds_engine
  engine_version = var.engine_version
  username = var.usernamedb
  password = var.passworddb
  allocated_storage = 10
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  instance_type = var.instance_type
  db_sg = module.db_security_group.security_group_custom_id
}

output "jump_host_ip" {
  value = aws_eip.jump_host_public_ip.public_ip
  
}

output "db_subnet_group_id" {
  value = aws_db_subnet_group.db_subnet_group.id
  
}

output "rds_db_endpoint" {
  value = module.rds_db.db_endpoint
  
}

output "rds_db_port" {
  value = module.rds_db.db_port
  
}