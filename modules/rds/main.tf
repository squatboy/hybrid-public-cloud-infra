#------------------------------------------------------------------------------
# RDS Module - Main Configuration
# RDS MySQL (Free Tier: db.t3.micro - 750 hours/month)
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# DB Subnet Group
#------------------------------------------------------------------------------

resource "aws_db_subnet_group" "this" {
  name        = "${var.env_name}-rds-subnet-group"
  description = "Subnet group for RDS MySQL"
  subnet_ids  = var.private_subnet_ids

  tags = merge(var.tags, { Name = "${var.env_name}-rds-subnet-group" })
}

#------------------------------------------------------------------------------
# RDS MySQL Instance (Free Tier)
#------------------------------------------------------------------------------

resource "aws_db_instance" "this" {
  identifier = "${var.env_name}-mysql"

  engine         = "mysql"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp2"

  db_name  = var.database_name
  username = var.master_username
  password = var.master_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.security_group_ids

  # Multi-AZ (disabled for Free Tier)
  multi_az = false

  # Backup
  backup_retention_period = var.backup_retention_period
  backup_window           = var.preferred_backup_window
  maintenance_window      = "Mon:04:00-Mon:05:00"

  # Protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.env_name}-mysql-final-snapshot"
  deletion_protection       = var.deletion_protection

  # Encryption (Free Tier compatible)
  storage_encrypted = true

  # Performance Insights (disabled for Free Tier)
  performance_insights_enabled = false

  # Public accessibility
  publicly_accessible = false

  tags = merge(var.tags, { Name = "${var.env_name}-mysql" })
}
