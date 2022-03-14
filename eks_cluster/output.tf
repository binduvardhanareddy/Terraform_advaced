output "vpc_id" {
  value = data.aws_vpc.default.id
}
output "security_group_id" {
  value = module.security_group.security_group_id

}

output "cluster" {
  value = aws_eks_node_group.bindu_node_group.id
}

output "endpoint" {
  value = aws_eks_cluster.bindu.endpoint
  }

  output "all_namespaces" {
    value = data.kubernetes_all_namespaces.all_namespaces.namespaces
}