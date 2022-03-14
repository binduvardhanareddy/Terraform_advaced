data "aws_vpc" "default" {
  default = true
}
data "aws_subnets" "public_subnets" {

  filter {
    name   = "tag:Name"
    values = ["default"]
  }
}

data "aws_iam_role" "cluster_role"{
    name = "eks_cluster_role_1"
}

data "aws_iam_role" "node_group_role" {
    name= "eks_node_group_role"
}
