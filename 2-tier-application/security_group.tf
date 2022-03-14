module "security_group" {
  source  = "../module/security_group"
  vpc_id  = data.aws_vpc.default.id
  name    = var.name
  ingress = var.ingress
}