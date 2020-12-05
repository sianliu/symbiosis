#----- symbiosis/network.tf -----#

# Manages the default vpc
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

# List of available AZs in the singapore region
data "aws_availability_zones" "available" {
  state = "available"
}

# Private subnets for DB instances
# Creates a private subnets in two different availability zones in the singapore region
resource "aws_subnet" "private_subnet_1" {
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "172.31.32.0/20"
  vpc_id            = aws_default_vpc.default.id
}

resource "aws_subnet" "private_subnet_2" {
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block        = "172.31.48.0/20"
  vpc_id            = aws_default_vpc.default.id
}

# Creates web tier security group resource
resource "aws_security_group" "web-tier-sg" {
  name        = "web-tier-sg"
  description = "Web security group"
  vpc_id      = aws_default_vpc.default.id

  ingress = [
    {
      description = "Allow HTTP traffic from internet"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
      security_groups  = []
    },
    {
      description = "SSH MGMT"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
      security_groups  = []
    },
    {
      description = "crud app access"
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
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
    Name = "web-tier-sg"
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
    Name = "db-tier-sg"
  }
}

//# Public URL to access CRUD app
//resource "aws_route53_zone" "primary" {
//  name = "tbicommons.io"
//}

# Creates a NAT GW in each public subnet
resource "aws_nat_gateway" "nat-gw-public-subnet-1" {
  allocation_id = aws_eip.eip[0].id
  subnet_id     = "subnet-0235ab71bb618266f"

  tags = {
    Name = "Public subnet 1 NAT GW"
  }
}

resource "aws_nat_gateway" "nat-gw-public-subnet-2" {
  allocation_id = aws_eip.eip[1].id
  subnet_id     = "subnet-0cb5600808b3dbe9e"

  tags = {
    Name = "Public subnet 2 NAT GW"
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

  tags = {
    Environment = "test"
  }
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

# Route table to NAT GW
resource "aws_route_table" "symbiosis-private-rt" {
  vpc_id = aws_default_vpc.default.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw-public-subnet-1.id
  }

  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "symbiosis-private-subnet-1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.symbiosis-private-rt.id
}

resource "aws_route_table_association" "symbiosis-private-subnet-2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.symbiosis-private-rt.id
}