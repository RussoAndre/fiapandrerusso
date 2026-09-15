output "rds_endpoints" {
  description = "Map of RDS instance name => endpoint address."
  value       = { for k, v in aws_db_instance.postgres : k => v.endpoint }
}

output "redis_endpoint" {
  description = "ElastiCache Redis primary endpoint."
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "redis_port" {
  description = "ElastiCache Redis port."
  value       = aws_elasticache_cluster.redis.port
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB analytics table."
  value       = aws_dynamodb_table.analytics.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB analytics table."
  value       = aws_dynamodb_table.analytics.arn
}
