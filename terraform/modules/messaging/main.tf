resource "aws_sqs_queue" "dlq" {
  name                       = "${var.project}-events-dlq"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 30

  tags = merge(var.tags, { Name = "${var.project}-events-dlq" })
}

resource "aws_sqs_queue" "events" {
  name                       = "${var.project}-events"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 10

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 5
  })

  tags = merge(var.tags, { Name = "${var.project}-events" })
}

data "aws_caller_identity" "current" {}

resource "aws_sqs_queue_policy" "events" {
  queue_url = aws_sqs_queue.events.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAccountAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = ["sqs:SendMessage", "sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Resource = aws_sqs_queue.events.arn
      }
    ]
  })
}
