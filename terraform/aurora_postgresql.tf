resource "random_password" "master" {
  length = 16
}

module "postgres_aurora_cluster" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name           = "so2c-gh-screening-audit-cluster-${var.environment}"
  engine         = "aurora-postgresql"
  engine_version = "13.4"
  instance_class = var.rds_instance_class
  instances = {
    one   = {}
    # two   = {}
  }
  autoscaling_enabled      = false
  storage_encrypted   = true
  kms_key_id = aws_kms_key.rds_kms.arn

  #VPC and subnet
  vpc_id  = var.vpc_id
  db_subnet_group_name   = "auditdb-subnet-group-${var.environment}"
  create_db_subnet_group = true
  subnets = var.subnets

  #security group
  create_security_group  = true
  security_group_description = "Security group for Audit DB RDS cluster"


  #Authentication
  iam_database_authentication_enabled = false
  master_username                     = "ghpguser"
  master_password                     = random_password.master.result
  create_random_password              = false

  #Performance insights
  performance_insights_enabled = false

  #Monitoring
  monitoring_interval = 0  #Disbale monitoring
  create_monitoring_role = false

  #Maintenance
  allow_major_version_upgrade = true
  auto_minor_version_upgrade = false
  apply_immediately   = true
  skip_final_snapshot = false
  deletion_protection = false


  db_parameter_group_name         = aws_db_parameter_group.auditdbpg.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.auditclusterpg.id
  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = local.frequent_tags
}

resource "aws_db_parameter_group" "auditdbpg" {
  name        = "audit-aurora-db-postgres13-parameter-group-${var.environment}"
  family      = "aurora-postgresql13"
  description = "audit-aurora-db-postgres13-parameter-group-${var.environment}"
  tags        = local.frequent_tags
}

resource "aws_rds_cluster_parameter_group" "auditclusterpg" {
  name        = "audit-aurora-postgres13-cluster-parameter-group-${var.environment}"
  family      = "aurora-postgresql13"
  description = "audit-aurora-postgres13-cluster-parameter-group-${var.environment}"
  tags        = local.frequent_tags
}

resource "aws_secretsmanager_secret" "rds_credentials" {
  name = "${var.rds_secret_name}_${var.environment}"
}

resource "aws_secretsmanager_secret_version" "rds_credentials_version" {
  secret_id     = aws_secretsmanager_secret.rds_credentials.id
  secret_string = <<EOF
  {
    "username": "ghpguser",
    "password": "${random_password.master.result}",
    "engine": "postgres",
    "host": "${module.postgres_aurora_cluster.cluster_endpoint}",
    "port": "${module.postgres_aurora_cluster.cluster_port}",
    "dbClusterIdentifier": "${module.postgres_aurora_cluster.cluster_id}"
  }
  EOF
}

resource "aws_kms_key" "rds_kms" {
  policy              = data.aws_iam_policy_document.rds.json
  tags                = local.frequent_tags
  enable_key_rotation = var.enable_key_rotation
}

# resource "aws_kms_alias" "key_name" {
#   name = "alias/so2c-gh-screening-audit-cluster-${var.environment}-KmsKey"
#   target_key_id = aws_kms_key.rds_kms.key_id
# }