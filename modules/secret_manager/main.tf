#------------------------------------------------------------------------------
# Secrets Manager Module - Main Configuration
# Database credentials storage for Aurora Serverless
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Secrets Manager Secret
# RDS 접속 정보를 JSON 형식으로 저장
#------------------------------------------------------------------------------

resource "aws_secretsmanager_secret" "db_secret" {
  name        = "/${var.project_name}/${var.env_name}/db-credentials"
  description = "Database credentials for Aurora Serverless"

  force_overwrite_replica_secret = true

  tags = merge(var.tags, { Name = "${var.env_name}-db-secret" })
}

#------------------------------------------------------------------------------
# Secrets Manager Secret Version
# 실제 비밀번호와 DB 접속 정보를 JSON으로 저장
#------------------------------------------------------------------------------

resource "aws_secretsmanager_secret_version" "db_secret_val" {
  secret_id = aws_secretsmanager_secret.db_secret.id

  secret_string = jsonencode({
    username = var.master_username
    password = var.db_password
    engine   = "aurora-mysql"
    host     = var.db_host
    port     = var.db_port
    dbname   = var.db_name
  })
}
