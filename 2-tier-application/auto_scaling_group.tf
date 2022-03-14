module "key_pair" {
  source = "../module/key_pair"
  name = "${var.name}_1"
}

resource "aws_launch_template" "launch_template" {
  name = var.name
  description = "Template for 2 tier application demo managed by Terraform"
  tags = {
    Name = var.name
  }
  image_id = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
  key_name = module.key_pair.key_name
  #security_group_names = [ module.security_group.security_group_name ]
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.name
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = var.name
    }
  }
  user_data = base64encode(data.template_file.user_data.rendered)
  update_default_version = true
  vpc_security_group_ids = [ module.security_group.security_group_id ]
}
resource "aws_autoscaling_group" "bindu1" {
  name = var.name
  launch_template {
    id = aws_launch_template.launch_template.id
    version = "$Default"
  }
  vpc_zone_identifier = data.aws_subnets.public_subnets.ids
  desired_capacity = 1
  min_size = 1
  max_size = 2
  tag {
    key = "Name"
    value = var.name
    propagate_at_launch = true
  }
   target_group_arns = [ aws_lb_target_group.tg_4000.arn ]
  health_check_type = "ELB"
  health_check_grace_period = 120
}

resource "aws_autoscalingplans_scaling_plan" "cpu_utilization" {
  name = "${var.name}_cpu_utilization"
  application_source {
    tag_filter {
      key = var.name
      values = [ var.name ]
    }
  }
  scaling_instruction {
    resource_id = format("autoScalingGroup/%s", aws_autoscaling_group.bindu1.name)
    scalable_dimension = "autoscaling:autoScalingGroup:DesiredCapacity"
    service_namespace  = "autoscaling"
    min_capacity = 1
    max_capacity = 3
    target_tracking_configuration {
      predefined_scaling_metric_specification {
        predefined_scaling_metric_type = "ASGAverageCPUUtilization"
      }
      target_value = 70
    }
  }
}

resource "aws_autoscaling_notification" "notification" {
  group_names = [ 
    aws_autoscaling_group.bindu1.name
  ]
  topic_arn = data.aws_sns_topic.asg_notification.arn
  notifications = [ 
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
}