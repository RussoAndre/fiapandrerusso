#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# install-argocd.sh
# Installs ArgoCD on the EKS cluster and configures access.
# Run AFTER `terraform apply` and `aws eks update-kubeconfig`.
#
# Usage:
#   ./gitops/argocd/install-argocd.sh <cluster-name> <region>
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

CLUSTER_NAME="${1:-togglemaster-cluster}"
REGION="${2:-us-east-1}"

echo "==> Updating kubeconfig for cluster: ${CLUSTER_NAME}"
aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${REGION}"

echo "==> Creating argocd namespace"
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

echo "==> Installing ArgoCD (stable)"
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "==> Waiting for ArgoCD server to be ready..."
kubectl rollout status deployment/argocd-server -n argocd --timeout=300s

echo "==> Patching argocd-server service to LoadBalancer for demo access"
kubectl patch svc argocd-server -n argocd \
  -p '{"spec": {"type": "LoadBalancer"}}'

echo ""
echo "==> Applying ArgoCD AppProject and Applications..."
kubectl apply -f gitops/argocd/project.yaml
kubectl apply -f gitops/argocd/app-auth.yaml
kubectl apply -f gitops/argocd/app-flag.yaml
kubectl apply -f gitops/argocd/app-targeting.yaml
kubectl apply -f gitops/argocd/app-evaluation.yaml
kubectl apply -f gitops/argocd/app-analytics.yaml

echo ""
echo "==> Retrieving initial admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
echo ""
echo ""
echo "==> ArgoCD LoadBalancer URL (may take 1-2 min to provision):"
kubectl get svc argocd-server -n argocd \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
echo ""
echo "Done! Login with user: admin"
