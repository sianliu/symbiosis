#----- symbiosis/compute.tf -----#

# Use this data source when working with multiple AMIs ie. Packer
data "aws_ami_ids" "crud-app" {
  owners = ["342372301491"]

  filter {
    name   = "name"
    values = ["symbiosis-crud-app-*"]
  }
}

//data "aws_ami" "crud-app" {
//  owners      = ["self"]
//  most_recent = true
//}

# Creates a target group for web servers
resource "aws_lb_target_group" "web-servers-tg" {
  name     = "web-servers-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id
}

# NLB listens on port 80
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-servers-tg.arn
  }
}

# For autoscaling group
resource "aws_launch_template" "symbiosis" {
  name_prefix = "symbiosis"
  image_id    = "ami-0fdd6231271034d0e"
  //  image_id               = data.aws_ami.crud-app.id
  key_name               = "my-govtech-aws"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web-tier-sg.id]

  tags = {
    Name = "terraform-launch-template"
  }
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

# EIP for NAT gateway
resource "aws_eip" "eip" {
  count = 2
  vpc   = true
}

# Creates an application load balancer
resource "aws_lb" "lb" {
  name               = "lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web-tier-sg.id]
  subnets            = ["subnet-0235ab71bb618266f", "subnet-0cb5600808b3dbe9e"]

  access_logs {
    bucket  = aws_s3_bucket.symbiosis-lb-access-logs-bucket.id
    enabled = true
  }

  tags = {
    Name = "terraform-lb"
  }
}

# Creates web tier security group resource
resource "aws_security_group" "web-tier-sg" {
  name        = "web-tier-sg"
  description = "Web security group"
  vpc_id      = aws_default_vpc.default.id

  ingress = [
    {
      description      = "Allow HTTP traffic from internet"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
      security_groups  = []
    },
    {
      description      = "SSH MGMT"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
      security_groups  = []
    },
    {
      description      = "crud app access"
      from_port        = 3000
      to_port          = 3000
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
      security_groups  = []
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-web-tier-sg"
  }
}

# Creates database tier security group resource
resource "aws_security_group" "db-tier-sg" {
  name        = "db-tier-sg"
  description = "DB security group"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description     = "MySQL Access for App"
    from_port       = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web-tier-sg.id]
    to_port         = 3306
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-db-tier-sg"
  }
}
