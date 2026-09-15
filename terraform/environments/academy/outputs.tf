output "vpc_id" {
  description = "VPC ID."
  value       = module.networking.vpc_id
}

output "eks_cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS API server endpoint."
  value       = module.eks.cluster_endpoint
}

output "rds_endpoints" {
  description = "RDS instance endpoints."
  value       = module.databases.rds_endpoints
}

output "redis_endpoint" {
  description = "ElastiCache Redis endpoint."
  value       = module.databases.redis_endpoint
}

output "sqs_queue_url" {
  description = "SQS events queue URL."
  value       = module.messaging.queue_url
}

output "ecr_repository_urls" {
  description = "ECR repository URLs per service."
  value       = module.ecr.repository_urls
}
