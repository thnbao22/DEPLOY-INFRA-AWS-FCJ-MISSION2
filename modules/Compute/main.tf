resource "aws_launch_template" "one_tier_web_server" {
  name                      = "Launch-Template-Web-Server"
  instance_type             = var.instance_type
  image_id                  = var.image_id
  vpc_security_group_ids    = [ var.web_server_sg_id ]
  key_name                  = var.keypair_name
  user_data                 = filebase64("${path.module}/install_apache_and_stress.sh")
  tags = {
    "Name" = "Web Server Launch Template"
  }
}


resource "aws_autoscaling_group" "one_tier_web_server" {
  name                      = "ASG-Web-Server"
  min_size                  = 2
  max_size                  = 4
  desired_capacity          = 2  
  vpc_zone_identifier       = [ var.public_subnet_1_id, var.public_subnet_2_id ]
  target_group_arns         = [ var.alb_tg_arn ]
  health_check_grace_period = 300
  health_check_type         = "ELB"
  lifecycle {
    create_before_destroy = true
  }
  launch_template {
    id      = aws_launch_template.one_tier_web_server.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "average_cpu_policy_greater" {
  name                      = "CPUAveragePolicyGreater"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = aws_autoscaling_group.one_tier_web_server.name
  # If the CPU Utilization is above 50
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}
