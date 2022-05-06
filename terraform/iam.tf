resource "aws_iam_policy" "gh_so2c_audit_service_policy" {
  name        = "so2c-audit-${var.environment}"
  path        = "/"
  description = "Audit Service policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid": "SQSAccess",
        "Effect": "Allow",
        "Action": "sqs:*"
        "Resource": "arn:aws:sqs:${var.region}:${var.account}:${var.gh_sqs_queue}-${var.environment}"
      },

      {
       "Sid": "ListSQSAccess",
       "Effect": "Allow",
       "Action": "sqs:ListQueues",
       "Resource": "*"
      },
      {
        "Sid": "SecretsAccess",
        "Effect": "Allow",
        "Action": [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetRandomPassword",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:ListSecretVersionIds",
          "secretsmanager:ListSecrets"
        ],
        "Resource": "*"
      },
    ]
  })
  tags = local.frequent_tags
}

module "service_account_creation" {
  source = "github.com/gh-org-screening/terraform-aws-gh-screening-eks-iam-role-serviceaccount"
  k8s_cluster_name = var.k8s_cluster_name
  namespace        = "audit-${var.environment}"
  serviceaccount   = "audit-service-account-${var.environment}"
  name             = "so2c-audit-${var.environment}-service-account-role"
  policy_arns      = ["arn:aws:iam::${var.account}:policy/so2c-audit-${var.environment}"]
  oidc_arn         = var.oidc_arn
  enabled          = true

}