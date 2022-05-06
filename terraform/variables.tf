variable "environment" {
  type = string
}

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "account" {
  type    = string
  default = "137219723686"
}

variable "vpc_id" {
  type    = string
}

variable "rds_instance_class" {
  type    = string
  default = "db.r6g.large"
}

variable "subnets" {
  description = "List of subnet IDs used by database subnet group created"
  type        = list(string)
  default     = []
}

variable "gh_sqs_queue" {
  type = string
  default = "so2c-audit-logs-queue"
  description = "SQS queues to be created"
}

variable "gh_rds_cluster" {
  type = string
  default = "so2c-rds-cluster"
  description = "RDS Cluster name"
}

variable "rds_secret_name" {
  type = string
  default = "gh_auditdb_rds_credentials"
  description = ""
}

variable "k8s_cluster_name" {
  type = string
  default = "dev"
  description = "Kubernetes cluster name"
}

variable "oidc_arn" {
  type = string
  default = "arn:aws:iam::137219723686:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/4C8C8B6049DA88A15B0AE23B01653B33"
  description = "OIDC provider arn"
}

variable "enable_key_rotation" {
  type        = bool
  default     = true
  description = "Specifies whether key rotation is enabled."
}