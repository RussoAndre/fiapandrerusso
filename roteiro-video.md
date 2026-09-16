# Roteiro do Vídeo — Tech Challenge Fase 3
## Duração alvo: 15–18 minutos

---

## Antes de gravar

Deixe tudo aberto e pronto:
- Terminal na pasta `togglemaster/terraform/environments/academy`
- GitHub Actions aberto: https://github.com/RussoAndre/fiapandrerusso/actions
- ArgoCD aberto: http://ad09d3842935245a9acdfa770c6394f2-1370995865.us-east-1.elb.amazonaws.com
- Console AWS aberto em us-east-1: https://console.aws.amazon.com
- Editor de código (VS Code) com o projeto aberto

Renove as credenciais do AWS Academy antes de começar (Show → copiar).

---

## PARTE 1 — Apresentação (1 min)

**Fale:** "Olá, meu nome é André Russo, RM 373828. Neste vídeo vou demonstrar o Tech Challenge da Fase 3 da POSTECH, que cobre Infraestrutura como Código com Terraform, pipeline DevSecOps com GitHub Actions e GitOps com ArgoCD."

**Mostre:** O repositório no GitHub — https://github.com/RussoAndre/fiapandrerusso

**Fale:** "O projeto é o ToggleMaster, uma plataforma de feature flags composta por 5 microsserviços em Go: auth, flag, targeting, evaluation e analytics."

---

## PARTE 2 — IaC: Terraform (4–5 min)

### 2.1 — Mostrar o código

**Abra o VS Code** e navegue pela estrutura:

```
terraform/
  modules/
    networking/   ← VPC, subnets, IGW, NAT
    eks/          ← Cluster Kubernetes
    databases/    ← RDS, Redis, DynamoDB
    messaging/    ← SQS
    ecr/          ← Repositórios de imagem
  environments/
    academy/      ← main.tf, backend.tf, variables.tf
```

**Fale:** "O Terraform está organizado em módulos independentes. O ambiente academy referencia todos eles e usa a LabRole existente do AWS Academy, sem criar nenhuma IAM role."

Abra `terraform/environments/academy/main.tf` e mostre a linha:
```hcl
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}
```

**Fale:** "Aqui referencio a LabRole via data source — isso é necessário porque o AWS Academy não permite criar roles de IAM."

Abra `terraform/environments/academy/backend.tf` e mostre:

**Fale:** "O estado do Terraform é armazenado remotamente em um bucket S3, com criptografia habilitada. Isso garante que o estado não fique local na máquina de nenhum desenvolvedor."

### 2.2 — Mostrar o terraform plan rodando

**No terminal**, execute:
```bash
cd /Users/russondr/Documents/Faculdade/togglemaster/terraform/environments/academy
terraform plan -var='db_password=ToggleMaster2024Secure'
```

**Fale enquanto o output aparece:** "O plan mostra todos os recursos que serão criados — VPC, subnets, cluster EKS, instâncias RDS, Redis, DynamoDB, SQS e os repositórios ECR."

Quando aparecer a linha final, mostre ela na tela:
```
Plan: X to add, 0 to change, 0 to destroy.
```

**Fale:** "Como a infraestrutura já foi aplicada anteriormente, o plan confirma que está tudo sincronizado."

### 2.3 — Mostrar a infraestrutura no console AWS

**Abra o Console AWS** e mostre rapidamente:

1. **VPC** → Services → VPC → Your VPCs → mostrar `togglemaster-vpc`
2. **EKS** → Services → EKS → Clusters → mostrar `togglemaster-cluster` com status Active
3. **RDS** → Services → RDS → Databases → mostrar as 3 instâncias (auth-db, flag-db, analytics-db)
4. **ElastiCache** → Services → ElastiCache → mostrar `togglemaster-redis`
5. **DynamoDB** → Services → DynamoDB → Tables → mostrar `ToggleMasterAnalytics`
6. **SQS** → Services → SQS → mostrar `togglemaster-events`
7. **ECR** → Services → ECR → Repositories → mostrar os 5 repositórios

**Fale em cada um:** "Aqui está o [nome do recurso] criado pelo Terraform, com as tags `ManagedBy: terraform` e `Environment: academy`."

---

## PARTE 3 — Pipeline DevSecOps (5–6 min)

### 3.1 — Mostrar o pipeline passando

**Abra o GitHub Actions:** https://github.com/RussoAndre/fiapandrerusso/actions

Clique no run mais recente que passou (verde) do serviço auth ou flag.

**Mostre os 4 estágios verdes:**

**Fale:** "O pipeline tem 4 estágios. Primeiro, Build e Testes — compila o código Go e roda os testes unitários com detecção de race conditions."

Clique em **Build & Test** para expandir e mostrar os logs passando.

**Fale:** "Segundo, o Lint com golangci-lint, verificando qualidade e segurança do código."

**Fale:** "Terceiro, o Security Scan — aqui rodamos o gosec para análise estática de segurança no código-fonte, e o Trivy para verificar vulnerabilidades nas dependências."

Clique em **Security Scan** para mostrar o output do Trivy com `0 vulnerabilities`.

**Fale:** "Quarto, o Docker Build and Push — a imagem é construída, passa por um scan de container com Trivy, e é publicada no ECR com a tag do commit."

### 3.2 — Demonstrar o bloqueio por vulnerabilidade (cena principal do DevSecOps)

**Fale:** "Agora vou demonstrar o que acontece quando uma vulnerabilidade crítica é introduzida."

**No terminal**, execute:
```bash
cd /Users/russondr/Documents/Faculdade/togglemaster
git checkout -b demo/security-failure
```

Abra `services/auth/go.mod` no VS Code e adicione no final:
```
require golang.org/x/crypto v0.0.0-20190308221718-c2843e01d9a2
```

**No terminal:**
```bash
git add services/auth/go.mod
git commit -m "feat: add crypto dependency"
git push origin demo/security-failure
```

**Abra o GitHub Actions** e aguarde o workflow `Demo — Security Block` aparecer.

**Fale enquanto aguarda:** "Adicionei uma versão antiga e vulnerável da biblioteca `golang.org/x/crypto`, que contém CVEs conhecidos. O pipeline está rodando agora."

Quando o job **Security Gate** ficar vermelho, clique nele e mostre o log do Trivy com a vulnerabilidade CRÍTICA detectada.

**Fale:** "O pipeline falhou exatamente no estágio de segurança, como esperado. A imagem não foi publicada no ECR e o deploy foi bloqueado automaticamente. Agora vou reverter a mudança."

**No terminal:**
```bash
git revert HEAD --no-edit
git push origin demo/security-failure
```

Mostre o pipeline passando novamente.

**Fale:** "Com a dependência vulnerável removida, o pipeline passa e a imagem é liberada para deploy."

Volte para main:
```bash
git checkout main
```

### 3.3 — Mostrar a imagem publicada no ECR

**No Console AWS**, vá em ECR → togglemaster/auth → mostrar a imagem com a tag `v1.0.0-xxxxxxxx`.

**Fale:** "A imagem foi publicada com a tag baseada no hash do commit, garantindo rastreabilidade total."

---

## PARTE 4 — GitOps com ArgoCD (3–4 min)

### 4.1 — Mostrar o ArgoCD com os 5 serviços

**Abra o ArgoCD:** http://ad09d3842935245a9acdfa770c6394f2-1370995865.us-east-1.elb.amazonaws.com

Login: `admin` / `5PMqK93FxOSbQdTx`

**Fale:** "O ArgoCD está instalado no cluster EKS e gerencia os 5 microsserviços do ToggleMaster. Cada serviço tem sua própria Application configurada."

Mostre a tela principal com os 5 cards: auth, flag, targeting, evaluation, analytics.

**Fale:** "O status Synced significa que o estado do cluster está sincronizado com o repositório Git."

Clique em um dos apps, por exemplo **togglemaster-auth**, e mostre a árvore de recursos (Deployment, Service, HPA).

### 4.2 — Mostrar o GitOps em ação

**Fale:** "Vou demonstrar o fluxo completo de GitOps. Faço uma mudança no código, o pipeline CI atualiza a tag da imagem no repositório, e o ArgoCD detecta e sincroniza automaticamente."

**No VS Code**, abra `services/flag/main.go` e faça uma mudança pequena — por exemplo, adicione uma flag nova no map:

```go
"analytics-v2": {Key: "analytics-v2", Enabled: false},
```

**No terminal:**
```bash
git add services/flag/main.go
git commit -m "feat(flag): add analytics-v2 flag"
git push origin main
```

**Abra o GitHub Actions** e mostre o pipeline do `flag` rodando.

**Fale:** "O pipeline está rodando — build, lint, security scan, docker build e push."

Quando chegar no estágio **Update GitOps**, mostre ele rodando.

**Fale:** "Nesse último estágio, o pipeline atualiza automaticamente o arquivo `gitops/apps/flag/deployment.yaml` com a nova tag da imagem e faz um commit no repositório."

Abra o repositório no GitHub e mostre o commit feito pelo `github-actions[bot]` no arquivo `gitops/apps/flag/deployment.yaml`.

**Volte ao ArgoCD** e aguarde aparecer a notificação de sync (pode levar 1–3 minutos).

**Fale:** "O ArgoCD detectou a mudança no repositório Git e está sincronizando automaticamente a nova versão no cluster."

Mostre o app `togglemaster-flag` com status **Syncing** e depois **Synced**.

---

## PARTE 5 — Encerramento (30 seg)

**Fale:** "Para finalizar, toda a infraestrutura foi provisionada via Terraform com estado remoto em S3, o pipeline DevSecOps garante que vulnerabilidades críticas bloqueiam o deploy automaticamente, e o GitOps com ArgoCD mantém o cluster sempre sincronizado com o repositório. Obrigado."

---

## Comandos de referência rápida

```bash
# Entrar na pasta correta
cd /Users/russondr/Documents/Faculdade/togglemaster

# Terraform plan
cd terraform/environments/academy
terraform plan -var='db_password=ToggleMaster2024Secure'

# Demo vulnerabilidade
git checkout -b demo/security-failure
# (editar services/auth/go.mod)
git add services/auth/go.mod && git commit -m "test: dep vulneravel" && git push origin demo/security-failure

# Demo GitOps
git checkout main
# (editar services/flag/main.go)
git add services/flag/main.go && git commit -m "feat(flag): nova flag" && git push origin main

# Ver nodes do cluster
aws eks update-kubeconfig --name togglemaster-cluster --region us-east-1
kubectl get nodes
kubectl get pods -n togglemaster
```

## URLs importantes

| Recurso | URL |
|---|---|
| GitHub Actions | https://github.com/RussoAndre/fiapandrerusso/actions |
| ArgoCD | http://ad09d3842935245a9acdfa770c6394f2-1370995865.us-east-1.elb.amazonaws.com |
| Console AWS | https://console.aws.amazon.com |
| ECR | https://us-east-1.console.aws.amazon.com/ecr/repositories |

## ArgoCD login

- Usuário: `admin`
- Senha: `5PMqK93FxOSbQdTx`
