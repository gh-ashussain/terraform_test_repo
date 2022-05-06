resource "aws_sqs_queue" "gh_so2c_audit_logs_dlq" {
  name                      = "${var.gh_sqs_queue}-dlq-${var.environment}"
  delay_seconds             = 90    # defaulted to 0 seconds
  max_message_size          = 262144  # defaulted to 256 KiB
  message_retention_seconds = 345600 # defaulted to 4 days
  receive_wait_time_seconds = 1     # defaulted to 0 seconds
  sqs_managed_sse_enabled   = true
  tags = local.frequent_tags
}


resource "aws_sqs_queue" "gh_so2c_audit_logs_queue" {
  name                      = "${var.gh_sqs_queue}-${var.environment}"
  delay_seconds             = 0    # defaulted to 0 seconds
  max_message_size          = 262144  # defaulted to 256 KiB
  message_retention_seconds = 345600 # defaulted to 4 days
  receive_wait_time_seconds = 1    # defaulted to 0 seconds
  sqs_managed_sse_enabled   = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.gh_so2c_audit_logs_dlq.arn
    maxReceiveCount     = 3
  })

  tags = local.frequent_tags
}
