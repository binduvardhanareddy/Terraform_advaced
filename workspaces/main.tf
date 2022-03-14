provider "aws" {
 region = "us-east-2"
  
}

terraform {
  backend "s3" {
    bucket = "kulbhushanmayer"
    key = "feb_terraform_b1/bindu1.tfstate"
    region = "us-east-2"
  }
}

resource "aws_instance" "ubuntu-server" {
  ami           = "ami-0fb653ca2d3203ac1"
  instance_type = terraform.workspace == "dev" ? "t2.small" : "t2.medium"

  tags = {
    Name = "Bindu-${terraform.workspace}"
  }
  
}

variable "infra_creation_inputs" {
  default = "componentName_1_clientName_env"
}
locals {
  details = split("_", var.infra_creation_inputs)
}
output "locals_and_split_demo" {
  value = "Create ${local.details[1]} instance of ${local.details[0]} component for ${local.details[2]} client to setup ${local.details[3]} environment"
}

