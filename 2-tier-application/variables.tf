variable "name" {
  default = "bindu"
}

variable "ingress" {
  description = "details port to be opened for inbound traffic"
  default = [{
    from_port = 5432
    to_port   = 5432
    self      = true
  },
  { from_port = 22
    to_port   = 22
    cidr_blocks= ["0.0.0.0/0"]
  },
 { from_port = 4000
    to_port   = 4000
    
    cidr_blocks= ["0.0.0.0/0"]
  }

  ]
}