output "queue_url" {
  description = "URL of the main SQS events queue."
  value       = aws_sqs_queue.events.id
}

output "queue_arn" {
  description = "ARN of the main SQS events queue."
  value       = aws_sqs_queue.events.arn
}

output "dlq_url" {
  description = "URL of the dead-letter queue."
  value       = aws_sqs_queue.dlq.id
}

output "dlq_arn" {
  description = "ARN of the dead-letter queue."
  value       = aws_sqs_queue.dlq.arn
}
