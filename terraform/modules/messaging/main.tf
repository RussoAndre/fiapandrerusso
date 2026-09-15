# ──────────────────────────────────────────────────────────────────────────────
# Module: messaging
# Provisions: 1 SQS queue (standard) + Dead-Letter Queue
# ──────────────────────────────────────────────────────────────────────────────

# ── Dead-Letter Queue ─────────────────────────────────────────────────────────
resource "aws_sqs_queue" "dlq" {
  name                       = "${var.project}-events-dlq"
  message_retention_seconds  = 1209600 # 14 days
  visibility_timeout_seconds = 30

  tags = merge(var.tags, { Name = "${var.project}-events-dlq" })
}

# ── Main Events Queue ─────────────────────────────────────────────────────────
resource "aws_sqs_queue" "events" {
  name                       = "${var.project}-events"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400 # 1 day
  receive_wait_time_seconds  = 10    # long polling

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 5
  })

  tags = merge(var.tags, { Name = "${var.project}-events" })
}

# ── Queue Policy: allow services within the account to send/receive ───────────
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
