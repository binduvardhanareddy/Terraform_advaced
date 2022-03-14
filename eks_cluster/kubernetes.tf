data "aws_eks_cluster_auth" "bindu" {
  name=aws_eks_cluster.bindu.name
}

provider "kubernetes" {
    host = aws_eks_cluster.bindu.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.bindu.certificate_authority[0].data)
    token = data.aws_eks_cluster_auth.bindu.token
}


resource "kubernetes_namespace" "bindu" {
  metadata {
    name = "eks-node-group-1"
  }
}
data "kubernetes_all_namespaces" "all_namespaces" {
  depends_on = [
    kubernetes_namespace.bindu
  ]
}

  
