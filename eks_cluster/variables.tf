variable "name" {

}

variable "ingress" {
  description = "details port to be opened for inbound traffic"
  default = [{
    protocol = "-1"
    self      = true
  },
  { from_port = 22
    to_port   = 22
    cidr_blocks= ["0.0.0.0/0"]
  },
# ports opened for node ports
  { from_port = 30000
    to_port   = 32767
    cidr_blocks= ["0.0.0.0/0"]
  },
  { from_port = 443
    to_port   = 443
    cidr_blocks= ["0.0.0.0/0"]
  }

  ]
}