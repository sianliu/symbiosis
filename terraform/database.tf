#----- symbiosis/database.tf -----#

resource "aws_db_instance" "primary" {
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = "db.t2.micro"
  name                    = "mydb"
  username                = var.db_username
  password                = var.db_password
  parameter_group_name    = "default.mysql5.7"
  multi_az                = true
  skip_final_snapshot     = true
  backup_retention_period = 5
  vpc_security_group_ids  = [aws_security_group.db-tier-sg.id]
  db_subnet_group_name    = aws_db_subnet_group.default.name
}

resource "aws_db_instance" "read-replica" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = "mydb"
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql5.7"
  replicate_source_db    = aws_db_instance.primary.identifier
  vpc_security_group_ids = [aws_security_group.db-tier-sg.id]
  skip_final_snapshot    = true
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "My DB subnet group"
  }
}