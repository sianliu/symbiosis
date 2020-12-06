#----- symbiosis/compute.tf -----#

# Creates a target group for web servers
resource "aws_lb_target_group" "web-servers-tg" {
  name     = "web-servers-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id
}

# For autoscaling group
resource "aws_launch_template" "symbiosis" {
  name_prefix   = "symbiosis"
  image_id      = "ami-0d728fd4e52be968f"
  key_name      = "my-govtech-aws"
  instance_type = "t3.micro"
}

resource "aws_autoscaling_group" "bar" {
  availability_zones = ["ap-southeast-1a", "ap-southeast-1b"]
  desired_capacity   = 2
  max_size           = 4
  min_size           = 2
  target_group_arns  = [aws_lb_target_group.web-servers-tg.arn]

  launch_template {
    id      = aws_launch_template.symbiosis.id
    version = "$Latest"
  }
}