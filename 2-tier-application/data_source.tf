data "aws_vpc" "default" {
  default = true
}
data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "tag:Name"
    values = ["default"]
  }
}

data "template_file" "user_data" {
  template = <<EOF
#!/bin/bash
apt-get update -y
apt-get install -y nodejs npm postgresql-client
npm install -g forever
export DB_USER=${aws_db_instance.database.username}
export DB_PWD=${aws_db_instance.database.password}
export DB_URL=${aws_db_instance.database.address}
export DB_NAME=${aws_db_instance.database.db_name}
export PGPASSWORD=${aws_db_instance.database.password}
git clone https://github.com/kul-samples/nodejs.git /opt/app
cd /opt/app
psql -h $DB_URL -U $DB_USER -d $DB_NAME < create_table.sql
npm install
forever start app.js
  EOF
}

data "aws_sns_topic" "asg_notification" {
  name = "kul"
}
