provider "aws"{
    region= "us-east-1"
}

resource "aws_instance" "ubuntu-server" {
    ami="ami-0fb653ca2d3203ac1"
    instance_type = "t2.micro"

  tags = {
    Name = "Kul-Bindu"
  }    
 count = 2
  key_name = aws_key_pair.ubuntu-server.key_name #update the resource block for aws_instance to refer aws_key_pair create above as key_name attribute
}

#Generate keypair using TLS to be used for aws keypair creation

provider "tls" {}  # use to generate public + private key pair
resource "tls_private_key" "ubuntu-server" { # this resource will generate public private key pair
  algorithm = "RSA"
  rsa_bits = "2048"
}
resource "aws_key_pair" "ubuntu-server" {
  key_name = "Bindu"
  public_key = tls_private_key.ubuntu-server.public_key_openssh
  tags = {
    Name = "kul-Bindu"
  }
}

#Add new provider null to create null_resource which is used to define the provisioner block of type remote-exec for running commands on the remote machine

provider "null" {} # generally used for the provisioner blocks to perform actions post resource creation
resource "null_resource" "install_apache" {
  provisioner "remote-exec" { # execute tasks or commands on the remote machine
    connection {  # connection details for the remote machine
      type = "ssh"
      host = aws_instance.ubuntu-server[count.index].public_ip  # value will taken from the existing resource itself
      user = "ubuntu"
      private_key = tls_private_key.ubuntu-server.private_key_pem
    }
    inline = [ # these command to be executed in the remote machine connected above
      "sudo hostnamectl set-hostname kul",
      "sudo apt-get update -y",
      "sudo apt-get install -y apache2" # last command will not have "," at the end
    ]
  }
  count = 2
}

output "apche_public_IP" {

    value =[

    for server in aws_instance.ubuntu-server:"http://${server.public_ip}:80"
    ]

  }

  resource "aws_ebs_volume" "ubuntu-server" {
      availability_zone = aws_instance.ubuntu-server[count.index].availability_zone
    size = "1"
    tags = {
      "name" = "kul-bindu"
    }
    count = 2
  }

  resource "aws_volume_attachment" "ubuntu-server" {
      volume_id = aws_ebs_volume.ubuntu-server[count.index].id
      instance_id = aws_instance.ubuntu-server[count.index].id
      device_name = "/dev/sdf"
      force_detach = true
      skip_destroy= false
      count = 2
  }

