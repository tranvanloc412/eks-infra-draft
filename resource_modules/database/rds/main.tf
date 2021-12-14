########################################
# AWS DynamoDB resource module
#
########################################
data "aws_security_group" "rds" {
  vpc_id = var.vpc_id
  name   = "rds-sg"
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-${var.env}-rds-subnet-group"
  subnet_ids = var.database_subnets

  tags = {
    Name = "${var.project_name}-${var.env}-vnet-01-rds-subnet_group"
  }
}

resource "aws_db_instance" "this" {
  allocated_storage      = var.db_storage
  engine                 = "mysql"
  engine_version         = var.db_engine_version
  instance_class         = var.db_intance_class
  name                   = var.dbname
  username               = var.dbuser
  password               = var.dbpassword
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [data.aws_security_group.rds.id]
  identifier             = var.db_identifier
  skip_final_snapshot    = var.db_skip_db_snapshot
  multi_az               = false

  tags = {
    Name = "${var.project_name}-${var.env}-vnet-01-rds"
  }
}