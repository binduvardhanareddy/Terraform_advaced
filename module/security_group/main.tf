resource "aws_security_group" "aws_security_group" {
    vpc_id = var.vpc_id
    description = "security group for vpc ${var.name} managed by terraform"
  tags={
      name= var.name
  }
  egress = [{  # Out bound access open to all destination, all ports & all protocols
    cidr_blocks = ["0.0.0.0/0"]
    description = "All Open"
    from_port = 0
    to_port = 0
    protocol = "-1" # all protocols
    self = false
    security_groups = []
    prefix_list_ids = []
    ipv6_cidr_blocks = []
  }]
  dynamic "ingress" {
    for_each = var.ingress
    content {
      cidr_blocks = lookup(ingress.value, "cidr_blocks", null)
      description = lookup(ingress.value, "description", null)
      from_port = lookup(ingress.value, "from_port", 0)
      to_port = lookup(ingress.value, "to_port", 0)
      protocol = lookup(ingress.value, "protocol", "TCP")
      self = lookup(ingress.value, "self", null)
    }
  }
}