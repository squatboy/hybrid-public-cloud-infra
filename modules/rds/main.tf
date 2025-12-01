#------------------------------------------------------------------------------
# RDS Module - Main Configuration
# Aurora Serverless v2 (MySQL)
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# DB Subnet Group
#------------------------------------------------------------------------------

resource "aws_db_subnet_group" "this" {
  name        = "${var.env_name}-aurora-subnet-group"
  description = "Subnet group for Aurora Serverless v2"
  subnet_ids  = var.private_subnet_ids

  tags = merge(var.tags, { Name = "${var.env_name}-aurora-subnet-group" })
}

#------------------------------------------------------------------------------
# Aurora Cluster
#------------------------------------------------------------------------------

resource "aws_rds_cluster" "this" {
  cluster_identifier = "${var.env_name}-aurora-cluster"

  engine         = "aurora-mysql"
  engine_mode    = "provisioned"
  engine_version = var.engine_version

  database_name   = var.database_name
  master_username = var.master_username
  master_password = var.master_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.security_group_ids

  # Serverless v2 Scaling Configuration
  serverlessv2_scaling_configuration {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }

  # Backup and Maintenance
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection

  # Encryption
  storage_encrypted = true

  tags = merge(var.tags, { Name = "${var.env_name}-aurora-cluster" })
}

#------------------------------------------------------------------------------
# Aurora Instance (Serverless v2)
#------------------------------------------------------------------------------

resource "aws_rds_cluster_instance" "this" {
  count = var.instance_count

  identifier         = "${var.env_name}-aurora-instance-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version

  db_subnet_group_name = aws_db_subnet_group.this.name

  tags = merge(var.tags, { Name = "${var.env_name}-aurora-instance-${count.index + 1}" })
}
