resource "tls_private_key" "key_pair" { # this resource will generate public private key pair
  algorithm = "RSA"
  rsa_bits = "2048"
}
resource "aws_key_pair" "key_pair" {
  key_name = var.name
  public_key = tls_private_key.key_pair.public_key_openssh
  tags = {
    Name = var.name
  }
}