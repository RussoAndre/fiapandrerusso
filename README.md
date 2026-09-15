# ToggleMaster — Tech Challenge Fase 3

Plataforma de feature flags com infraestrutura imutável, pipeline DevSecOps e GitOps.

```
services/          → 5 microsserviços em Go
terraform/         → IaC (módulos + ambiente Academy)
gitops/            → Manifestos Kubernetes + ArgoCD Applications
.github/workflows/ → Pipelines CI/CD
```

---

## Pré-requisitos

| Ferramenta | Versão mínima |
|---|---|
| Terraform | 1.7+ |
| Go | 1.21+ |
| Docker | 24+ |
| kubectl | 1.29+ |
| AWS CLI | 2.x |
| git | 2.x |

---

## 1. Configurar o repositório no GitHub

```bash
# 1. Crie um repositório público no GitHub chamado "togglemaster"
# 2. Clone e suba este código
git init
git remote add origin https://github.com/RussoAndre/fiapandrerusso.git
git add .
git commit -m "feat: initial commit — Tech Challenge Fase 3"
git push -u origin main
```

### Secrets necessários (Settings → Secrets → Actions)

| Secret | Descrição |
|---|---|
| `AWS_ACCESS_KEY_ID` | Credencial AWS Academy |
| `AWS_SECRET_ACCESS_KEY` | Credencial AWS Academy |
| `AWS_SESSION_TOKEN` | Token de sessão AWS Academy |
| `AWS_ACCOUNT_ID` | ID da conta AWS (12 dígitos) |
| `AWS_REGION` | `us-east-1` |
| `TF_VAR_DB_PASSWORD` | Senha do banco RDS (ex: `Senha@2024!`) |

---

## 2. Bootstrap do estado remoto Terraform

Execute **uma vez** antes do `terraform init`:

```bash
cd terraform/environments/academy

# Cria o bucket S3 automaticamente
bash bootstrap.sh

# Substitua REPLACE_ACCOUNT_ID em backend.tf pelo seu Account ID
# Exemplo: togglemaster-tfstate-123456789012
```

Edite `backend.tf` com o nome do bucket criado, depois:

```bash
terraform init
terraform validate
terraform plan -var="db_password=SuaSenha123!"
terraform apply -var="db_password=SuaSenha123!"
```

---

## 3. Instalar ArgoCD e configurar GitOps

Após o `terraform apply` concluir:

```bash
# Após o apply, os arquivos gitops/argocd/*.yaml já estão configurados
# com o repositório https://github.com/RussoAndre/fiapandrerusso.git
bash gitops/argocd/install-argocd.sh togglemaster-cluster us-east-1
```

Acesse a UI do ArgoCD com a URL e senha exibidas no final do script.

---

## 4. Atualizar os deployments com o Account ID real

Antes do primeiro deploy, substitua `REPLACE_ACCOUNT_ID` nas imagens:

```bash
# Substitua 123456789012 pelo seu Account ID real
find gitops/apps -name "deployment.yaml" \
  -exec sed -i "s/REPLACE_ACCOUNT_ID/123456789012/g" {} \;

git add gitops/
git commit -m "chore: set real ECR account ID in deployments"
git push
```

O ArgoCD detecta a mudança e sincroniza automaticamente.

---

## 5. Pipeline CI/CD — como funciona

```
PR aberto ou push em main
         │
         ▼
┌─────────────────┐
│  build-test     │  go build + go test -race
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌──────┐  ┌──────────────┐
│ lint │  │  sast-sca    │  gosec + Trivy fs
│      │  │  ⚠️ CRITICAL  │  → exit 1 (bloqueia)
└──────┘  └──────┬───────┘
                 │ (apenas se passar)
                 ▼
          ┌─────────────┐
          │   docker    │  build → Trivy image → push ECR
          └──────┬──────┘
                 │ (apenas push em main)
                 ▼
          ┌──────────────┐
          │ update-gitops│  sed deployment.yaml → git commit → push
          └──────────────┘
                 │
                 ▼ (ArgoCD detecta)
          ┌──────────────┐
          │  ArgoCD sync │  kubectl apply no cluster EKS
          └──────────────┘
```

---

## 6. Demonstração de bloqueio de segurança (para o vídeo)

```bash
# 1. Criar branch de demo
git checkout -b demo/security-failure

# 2. Adicionar dependência vulnerável (versão antiga com CVE conhecida)
cat >> services/auth/go.mod << 'EOF'

require (
    golang.org/x/crypto v0.0.0-20190308221718-c2843e01d9a2
)
EOF

# 3. Push — o workflow demo-security-block.yml vai FALHAR no Trivy
git add services/auth/go.mod
git commit -m "test: add vulnerable dependency for demo"
git push origin demo/security-failure

# 4. Mostrar o pipeline falhando na UI do GitHub Actions

# 5. Reverter e mostrar passando
git revert HEAD
git push origin demo/security-failure
```

---

## 7. Destruir a infraestrutura após o vídeo

```bash
cd terraform/environments/academy
terraform destroy -var="db_password=SuaSenha123!"
```

---

## Estrutura do projeto

```
togglemaster/
├── .github/
│   └── workflows/
│       ├── _ci-template.yml       # workflow reutilizável
│       ├── ci-auth.yml
│       ├── ci-flag.yml
│       ├── ci-targeting.yml
│       ├── ci-evaluation.yml
│       ├── ci-analytics.yml
│       ├── terraform.yml
│       └── demo-security-block.yml
├── services/
│   ├── auth/                      # porta 8080
│   ├── flag/                      # porta 8081
│   ├── targeting/                 # porta 8082
│   ├── evaluation/                # porta 8083
│   └── analytics/                 # porta 8084
├── terraform/
│   ├── modules/
│   │   ├── networking/
│   │   ├── eks/
│   │   ├── databases/
│   │   ├── messaging/
│   │   └── ecr/
│   └── environments/
│       └── academy/               # backend S3 + main.tf
├── gitops/
│   ├── apps/
│   │   ├── auth/                  # deployment + service + hpa
│   │   ├── flag/
│   │   ├── targeting/
│   │   ├── evaluation/
│   │   └── analytics/
│   └── argocd/
│       ├── install-argocd.sh
│       ├── project.yaml
│       ├── app-auth.yaml
│       ├── app-flag.yaml
│       ├── app-targeting.yaml
│       ├── app-evaluation.yaml
│       └── app-analytics.yaml
├── .golangci.yml
├── .gitignore
└── report.txt
```
