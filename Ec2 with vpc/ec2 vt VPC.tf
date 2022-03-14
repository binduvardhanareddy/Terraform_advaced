provider "aws" {
  region = "us-east-2"
}
data "aws_vpc" "kul" {
  filter { # filter the values to make it single entry
    name = "tag:Name" # filter will be done based on tag with the name "Name"
    values = ["kul"] # will vpc which will have tag Name value as kul
  }
}
output "vpc_id" {
  value = data.aws_vpc.kul.id
}
data "aws_security_group" "kul" {
  vpc_id = data.aws_vpc.kul.id
  filter {
    name = "group-name"
    values = ["kul"]
  }
}
output "security_group_id" {
  value = data.aws_security_group.kul.id
}
data "aws_subnets" "private" {
  filter {
    name = "tag:Type"
    values = ["private"]
  }
  filter {
    name = "vpc-id"
    values = [ data.aws_vpc.kul.id ]
  }
}
output "private_subnet_ids" {
  value = data.aws_subnets.private.ids
}
data "aws_subnets" "public" {
  filter {
    name = "tag:Type"
    values = ["public"]
  }
  filter {
    name = "vpc-id"
    values = [ data.aws_vpc.kul.id ]
  }
}
output "public_subnet_ids" {
  value = data.aws_subnets.public.ids
}
provider "tls" {}  # use to generate public + private key pair
resource "tls_private_key" "ubuntu_server" { # this resource will generate public private key pair
  algorithm = "RSA"
  rsa_bits = "2048"
}
resource "aws_key_pair" "ubuntu_server" {
  key_name = "kul_1"
  public_key = tls_private_key.ubuntu_server.public_key_openssh
  tags = {
    Name = "kul"
  }
}
resource "aws_instance" "ubuntu_server_private" {
  ami = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
  tags = {
    Name = "kul_private"
  }
  key_name = aws_key_pair.ubuntu_server.key_name
  count = 1
  subnet_id = data.aws_subnets.private.ids[count.index]
}
output "private_server_id" {
  value = aws_instance.ubuntu_server_private.*.id
}
resource "aws_instance" "ubuntu_server_public" {
  ami = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
  tags = {
    Name = "kul_public"
  }
  key_name = aws_key_pair.ubuntu_server.key_name
  count = 1 
  subnet_id = data.aws_subnets.public.ids[count.index]
}
output "public_server_id" {
  value = aws_instance.ubuntu_server_public.*.id
}