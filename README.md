# ToggleMaster

Plataforma de feature flags com infraestrutura na AWS, pipeline CI/CD e GitOps.

## Microsserviços

| Serviço | Porta | Descrição |
|---|---|---|
| auth | 8080 | Autenticação e geração de tokens |
| flag | 8081 | Gerenciamento de feature flags |
| targeting | 8082 | Regras de segmentação de usuários |
| evaluation | 8083 | Avaliação de flags por contexto |
| analytics | 8084 | Coleta e agregação de eventos |

Todos escritos em Go, usando apenas stdlib.

## Infraestrutura (Terraform)

```
terraform/
├── modules/
│   ├── networking/   VPC, subnets, IGW, NAT
│   ├── eks/          Cluster Kubernetes
│   ├── databases/    RDS PostgreSQL, ElastiCache Redis, DynamoDB
│   ├── messaging/    SQS
│   └── ecr/          Repositórios de imagens
└── environments/
    └── academy/      Ambiente AWS Academy
```

Estado remoto armazenado em S3.

## Pré-requisitos

- Terraform >= 1.7
- AWS CLI v2
- kubectl
- Go 1.21+

## Deploy

**1. Criar bucket S3 para o estado:**
```bash
cd terraform/environments/academy
bash bootstrap.sh
```

**2. Provisionar infraestrutura:**
```bash
terraform init
terraform plan -var='db_password=SuaSenha' -out=tfplan
terraform apply "tfplan"
```

**3. Configurar kubectl e instalar ArgoCD:**
```bash
aws eks update-kubeconfig --name togglemaster-cluster --region us-east-1
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f gitops/argocd/
```

**4. Secrets necessários no GitHub (Settings → Secrets → Actions):**

| Secret | Descrição |
|---|---|
| AWS_ACCESS_KEY_ID | Credencial AWS |
| AWS_SECRET_ACCESS_KEY | Credencial AWS |
| AWS_SESSION_TOKEN | Token de sessão (AWS Academy) |
| AWS_ACCOUNT_ID | ID da conta AWS |
| AWS_REGION | Região (us-east-1) |
| TF_VAR_DB_PASSWORD | Senha do banco RDS |

## Pipeline CI/CD

O pipeline roda a cada PR ou push na `main` e passa pelos estágios:

1. Build e testes unitários
2. Lint com golangci-lint
3. Scan de segurança — SAST (gosec) e SCA (Trivy). Vulnerabilidade CRÍTICA bloqueia o pipeline.
4. Build da imagem Docker, scan do container, push para ECR
5. Atualização da tag da imagem nos manifestos GitOps

O ArgoCD detecta a mudança e sincroniza automaticamente no cluster.

## Demonstração de falha de segurança

Para mostrar o pipeline bloqueando:

```bash
git checkout -b demo/security-failure
# Adicionar dependência vulnerável no go.mod do auth
echo 'require golang.org/x/crypto v0.0.0-20190308221718-c2843e01d9a2' >> services/auth/go.mod
git add services/auth/go.mod
git commit -m "test: dependencia vulneravel"
git push origin demo/security-failure
```

O workflow `demo-security-block.yml` vai falhar no estágio de scan.

## Destruir infraestrutura

```bash
cd terraform/environments/academy
terraform destroy -var='db_password=SuaSenha'
```
