output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "API server endpoint of the EKS cluster."
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_ca_certificate" {
  description = "Base64-encoded CA certificate of the EKS cluster."
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_oidc_issuer" {
  description = "OIDC issuer URL of the EKS cluster."
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}
