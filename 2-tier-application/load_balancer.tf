resource "aws_lb_target_group" "tg_4000" {
  target_type = "instance"
  name = "${var.name}-4000"
  protocol = "TCP"
  port = "4000"
  vpc_id = data.aws_vpc.default.id
  tags = {
    Name = var.name
  }
}
resource "aws_lb" "bindu" {
  name = var.name
  internal = false
  load_balancer_type = "network"
  subnets = data.aws_subnets.public_subnets.ids
  tags = {
    Name = var.name
  }
}
resource "aws_lb_listener" "listener_4000" {
  load_balancer_arn = aws_lb.bindu.arn
  protocol = aws_lb_target_group.tg_4000.protocol
  port = aws_lb_target_group.tg_4000.port
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg_4000.arn
  }
}