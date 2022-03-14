provider "aws" {
  region = "us-east-2"

}

resource "aws_vpc" "bindu" {
  cidr_block       = "91.10.0.0/16"
  instance_tenancy = "default"

  tags = {
    name = "bindu"
  }

}

data "aws_availability_zones" "aws_availability_zones" {} # retrive the list of AZ in the current region
output "aws_availability_zones" {
  value = data.aws_availability_zones.aws_availability_zones.names
}

resource "aws_subnet" "public" {
  count                   = length(data.aws_availability_zones.aws_availability_zones.names) # function to get the number of items in the list
  vpc_id                  = aws_vpc.bindu.id
  availability_zone       = data.aws_availability_zones.aws_availability_zones.names[count.index]
  cidr_block              = "91.10.${count.index}.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "bindu_subnet_public_${data.aws_availability_zones.aws_availability_zones.names[count.index]}"
    Type = "public"
  }
}
resource "aws_subnet" "private" {
  count                   = length(data.aws_availability_zones.aws_availability_zones.names) # function to get the number of items in the list
  vpc_id                  = aws_vpc.bindu.id
  availability_zone       = data.aws_availability_zones.aws_availability_zones.names[count.index]
  cidr_block              = "91.10.${10 + count.index}.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "bindu_subnet_private_${data.aws_availability_zones.aws_availability_zones.names[count.index]}"
    Type = "private"
  }
}
output "public_subnet_ids" {
  value = aws_subnet.public.*.id # * will help to print all the attribute values for the different resources created from the single resource block
}
output "private_subnet_ids" {
  value = aws_subnet.private.*.id # * will help to print all the attribute values for the different resources created from the single resource block
}

resource "aws_internet_gateway" "bindu" { # block will create the IGW & attach the same with VPC
  vpc_id = aws_vpc.bindu.id               # attach the same with VPC
  tags = {
    name = "bindu"
  }

}

output "internet_gateway_id" {
  value = aws_internet_gateway.bindu.id
}

# Creating NAT Gateway
resource "aws_eip" "nat_eip" {
  tags = {
    Name = "bindu"
  }
}
resource "aws_nat_gateway" "bindu" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "bindu"
  }
}
output "nat_gateway_id" {
  value = aws_nat_gateway.bindu.id
}

#Associating NAT Gateway with Main Route Table

resource "aws_route" "nat_route" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.bindu.id
  route_table_id         = aws_vpc.bindu.default_route_table_id
}

output "main_route_table_id" {
  value = aws_vpc.bindu
}
output "nat_route_id" {
  value = aws_route.nat_route.id
}

# Creating route table for Internet Gateway & Public Subnets Associations
resource "aws_route_table" "internet_gateway" {
  vpc_id = aws_vpc.bindu.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bindu.id
  }
  tags = {
    Name = "bindu"
  }
}
resource "aws_route_table_association" "public_subnets" {
  count          = length(aws_subnet.public.*.id)
  route_table_id = aws_route_table.internet_gateway.id
  subnet_id      = aws_subnet.public[count.index].id
}
output "internet_gateway_route_table_id" {
  value = aws_route_table.internet_gateway.id
}

resource "aws_security_group" "bindu" {
  vpc_id      = aws_vpc.bindu.id
  name        = "bindu"
  description = "security group for ${aws_vpc.bindu.id} managed by terraform"
  tags = {
    name = "bindu"
  }

  egress = [{ # Out bound access open to all destination, all ports & all protocols
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "all open"
    from_port        = 0
    to_port          = 0
    protocol         = "-1" # all protocols
    self             = false
    security_groups  = []
    prefix_list_ids  = []
    ipv6_cidr_blocks = []
  }]
  dynamic "ingress" {
    for_each = var.aws_security_group_ingress
    content {
      cidr_blocks = lookup(ingress.value, "cidr_blocks", ["0.0.0.0/0"])
      description = lookup(ingress.value, "description", null)
      from_port   = lookup(ingress.value, "from_port", 0)
      to_port     = lookup(ingress.value, "to_port", 0)
      protocol    = lookup(ingress.value, "protocol", "TCP")
      self        = lookup(ingress.value, "self", null)
    }
  }

}

variable "aws_security_group_ingress" {
  description = "Details about port to be opened for inbound traffic"
  default = [
    {
      from_port = "22"
      to_port   = "22"
    },
    {
      from_port = "80"
      to_port   = "80"
    }
  ]

}

output "security_group_id" {
  value = aws_security_group.bindu.id
}