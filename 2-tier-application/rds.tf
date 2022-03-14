resource "random_password" "db_password" {
  length           = 10
  special          = true
  override_special = "_*!"
}
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = var.name
  description = "group manage by terraform"
  subnet_ids  = data.aws_subnets.private_subnets.ids
  tags = {
    Name = var.name
  }
}

resource "aws_db_instance" "database" {
  engine = "postgres"
  engine_version = "13.6"
  identifier = var.name
  username = var.name
  password = random_password.db_password.result
  instance_class = "db.t3.micro"
  storage_type = "gp2"
  allocated_storage = "5"
  max_allocated_storage = "100"
  multi_az = false
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  publicly_accessible = false
  vpc_security_group_ids = [ module.security_group.security_group_id ]
  db_name = var.name
  skip_final_snapshot = true
}