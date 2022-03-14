module "security_group" {
  source  = "../module/security_group"
  vpc_id  = data.aws_vpc.default.id
  name    = var.name
  ingress = var.ingress
}

resource "aws_eks_cluster" "bindu" {
  name=var.name
  role_arn = data.aws_iam_role.cluster_role.arn

vpc_config {
  subnet_ids=data.aws_subnets.public_subnets.ids
  endpoint_public_access =true
  security_group_ids = [module.security_group.security_group_id]
}

tags = {
  Name= var.name
}
  
}

resource "aws_ec2_tag" "tag_subnet_with_eks_cluster" {
  for_each =toset( data.aws_subnets.public_subnets.ids)
  resource_id = each.value
  key = "kubernetes.io/cluster/${aws_eks_cluster.bindu.name}"
  value = "shared"

}

locals {
  node_group_name = "${var.name}_node"
}
resource "aws_eks_node_group" "bindu_node_group" {
  cluster_name = aws_eks_cluster.bindu.name
  node_group_name = local.node_group_name
  node_role_arn = data.aws_iam_role.node_group_role.arn
  labels={
    Name=local.node_group_name
  }
  tags = {
    Name = local.node_group_name
  }
  taint {
    key = "name"
    value = local.node_group_name
    effect = "NO_SCHEDULE"
  }
  instance_types = ["t3.medium"]
  disk_size = 10
  scaling_config {
    desired_size = 1
    min_size = 1
    max_size = 2
  }
  subnet_ids = data.aws_subnets.public_subnets.ids
}

