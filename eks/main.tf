variable "vpc_id" {}

data "aws_availability_zone" "available" {
  all_availability_zones = true
}

data "aws_vpc" "my_vpc" {
  id = var.vpc_id
}

data "aws_subnets" "eks_subnets" {

  tags = {
    Name = "eks-subnet"
  }
}

resource "aws_iam_role" "eks_role" {
  name = "eks_iam_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


resource "aws_eks_cluster" "terraform-eks-cluster" {
  name = "terraform-eks"
  role_arn = aws_iam_role.eks_role.arn
  vpc_config {
    subnet_ids = data.aws_subnets.eks_subnets.ids
    endpoint_private_access = true
  }
  enabled_cluster_log_types = ["api","audit"]
 kubernetes_network_config {
   service_ipv4_cidr = "172.16.0.0/24"
   ip_family = "ipv4"
 }

 depends_on = [
  aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
  aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly

  ]
  
}

output "arn" {
  value = aws_eks_cluster.terraform-eks-cluster.arn
}

output "cluster_id" {
  value = aws_eks_cluster.terraform-eks-cluster.cluster_id
  
}

output "endpoint" {
  value = aws_eks_cluster.terraform-eks-cluster.endpoint
  
}

output "id" {
  value = aws_eks_cluster.terraform-eks-cluster.id
  description = "Name of the cluster"
}

resource "aws_iam_role" "eks-workernode" {
  name = "eks_worker_node"
  
    assume_role_policy = jsonencode({
   Statement = [{
    Action = "sts:AssumeRole"
    Effect = "Allow"
    Principal = {
     Service = "ec2.amazonaws.com"
    }
   }]
   Version = "2012-10-17"
  })
 }
  

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.eks-workernode.name
}

 resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role    = aws_iam_role.eks-workernode.name
 }
 
 resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role    = aws_iam_role.eks-workernode.name
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role    = aws_iam_role.eks-workernode.name
 }


resource "aws_eks_node_group" "workernode" {
  cluster_name = aws_eks_cluster.terraform-eks-cluster.name
  node_group_name = "eks_worker_node"
  node_role_arn = aws_iam_role.eks-workernode.arn
  subnet_ids = data.aws_subnets.eks_subnets.ids
  instance_types = var.instance_types
  ami_type = var.ami_type
  scaling_config {
    
  desired_size = 1
  max_size = 1
  min_size = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [ 
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.EC2InstanceProfileForImageBuilderECRContainerBuilds
    
   ]
}

output "workernode_arn" {
  value = aws_eks_node_group.workernode.arn
}

output "eks_cluster_id" {
  value = aws_eks_node_group.workernode.id
}

output "workernode_status" {
  value = aws_eks_node_group.workernode.status
}


resource "aws_eks_addon" "cni_addon" {
  cluster_name = aws_eks_cluster.terraform-eks-cluster.name
  addon_name = "vpc-cni"
  addon_version = "v1.12.6-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.terraform-eks-cluster.name
  addon_name = "coredns"
  addon_version = "v1.9.3-eksbuild.2"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "kubeproxy" {
    cluster_name = aws_eks_cluster.terraform-eks-cluster.name
    addon_name = "kube-proxy"
    addon_version = "v1.20.4-eksbuild.2"
    resolve_conflicts_on_create = "OVERWRITE"
}