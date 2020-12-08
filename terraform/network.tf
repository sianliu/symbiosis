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


# Creates a NAT GW in each public subnet
resource "aws_nat_gateway" "nat-gw-public-subnet-1" {
  allocation_id = aws_eip.eip[0].id
  subnet_id     = "subnet-0235ab71bb618266f"

  tags = {
    Name = "terraform-public-subnet-1"
  }
}

resource "aws_nat_gateway" "nat-gw-public-subnet-2" {
  allocation_id = aws_eip.eip[1].id
  subnet_id     = "subnet-0cb5600808b3dbe9e"

  tags = {
    Name = "terraform-public-subnet-2"
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
    Name = "terraform-private-rt"
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

