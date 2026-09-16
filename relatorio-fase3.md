# POSTECH — Tech Challenge Fase 3

---

## Dados do Participante

| Campo | Valor |
|---|---|
| **Nome** | André Pereira Russo |
| **RM** | 373828 |
| **Discord** | russo_discorouboumeunome |

---

## Links de Entrega

| Recurso | Link |
|---|---|
| **Repositório GitHub** | https://github.com/RussoAndre/fiapandrerusso |
| **Vídeo de Apresentação** | ⚠️ _PREENCHER APÓS GRAVAÇÃO_ |

---

## Resumo da Arquitetura Implementada

### Microsserviços (Go)

O sistema é composto por **5 microsserviços** independentes, todos escritos em Go, cada um com seu próprio módulo, Dockerfile, testes unitários e pipeline de CI/CD:

| Serviço | Responsabilidade |
|---|---|
| **auth** | Autenticação e emissão de tokens JWT |
| **flag** | Gerenciamento de feature flags |
| **targeting** | Regras de segmentação de usuários |
| **evaluation** | Avaliação de flags em tempo real |
| **analytics** | Coleta e processamento de eventos |

---

### Infraestrutura como Código (Terraform)

A infraestrutura é provisionada com **Terraform modular**, organizada por ambiente (`academy`), com **backend remoto em S3** para armazenamento do estado.

#### Recursos Provisionados

| Recurso | Detalhes |
|---|---|
| **VPC** | Rede privada com subnets públicas e privadas |
| **EKS** | Kubernetes 1.32 gerenciado pela AWS |
| **RDS PostgreSQL** | 3 instâncias — PostgreSQL 17.5 (auth, flag, targeting) |
| **ElastiCache** | Redis 7.0 para cache distribuído |
| **DynamoDB** | Tabela `ToggleMasterAnalytics` para eventos de analytics |
| **SQS + DLQ** | Fila principal e Dead Letter Queue para resiliência |
| **ECR** | 5 repositórios de imagens de container (um por serviço) |
| **S3 (Terraform State)** | Backend remoto para estado Terraform com locking via DynamoDB |

---

### Pipeline CI/CD (GitHub Actions)

Cada serviço possui um workflow dedicado com as seguintes etapas:

| Etapa | Ferramenta | Descrição |
|---|---|---|
| **Build & Test** | `go build` / `go test` | Compilação e execução dos testes unitários |
| **Lint** | `golangci-lint` | Análise estática de qualidade de código |
| **SAST** | `gosec` | Análise de segurança estática do código-fonte Go |
| **SCA / Container Scan** | `Trivy` | Varredura de vulnerabilidades em dependências e imagens |
| **Push ECR** | `docker push` | Publicação da imagem no Amazon Elastic Container Registry |
| **Update GitOps** | `git commit` | Atualização do manifesto Kubernetes com a nova tag de imagem |

> **Política de segurança:** O pipeline interrompe automaticamente a entrega em caso de vulnerabilidades classificadas como **CRÍTICAS**.

---

### GitOps (ArgoCD)

O cluster EKS é gerenciado via **ArgoCD** com o modelo GitOps:

- **5 Applications** — uma por microsserviço
- **Auto-sync habilitado** — o ArgoCD reconcilia automaticamente o estado do cluster com o repositório Git
- Manifestos Kubernetes organizados em `gitops/apps/<serviço>/`: `deployment.yaml`, `service.yaml`, `hpa.yaml`

---

## Desafios e Decisões Técnicas

### 1. IAM Roles — AWS Academy

O ambiente AWS Academy **não permite a criação de IAM Roles** por restrições da sandbox. A solução adotada foi referenciar a **`LabRole` existente** via `data source` do Terraform, evitando qualquer tentativa de criação de role durante o `terraform apply`.

```hcl
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}
```

### 2. Versões Disponíveis no Academy

As versões de serviços gerenciados são limitadas pelo ambiente Academy. As versões utilizadas foram as disponíveis no momento da implementação:

- **EKS:** `1.32`
- **PostgreSQL (RDS):** `17.5`

### 3. Bloqueio Automático por Vulnerabilidades Críticas

O pipeline de CI/CD foi configurado para **bloquear automaticamente** (exit code != 0) quando o Trivy ou o gosec identificam vulnerabilidades de severidade **CRÍTICA**, garantindo que imagens comprometidas não sejam publicadas no ECR.

### 4. Senha do RDS — Caracteres Especiais

O RDS PostgreSQL rejeita senhas contendo os caracteres `@`, `/`, `"` e espaço. As senhas configuradas para os bancos de dados foram ajustadas para usar apenas caracteres alfanuméricos e símbolos compatíveis, evitando erros de conexão na string de conexão da aplicação.

---

## Estimativa de Custos AWS

> Estimativa para uso durante a gravação do vídeo (~2 horas com infraestrutura ativa).

| Serviço | Custo Estimado (2h) |
|---|---|
| EKS (Control Plane) | ~$0.20 |
| EC2 (Worker Nodes) | ~$0.50–$1.00 |
| RDS PostgreSQL (3x) | ~$0.30–$0.60 |
| ElastiCache Redis | ~$0.15–$0.25 |
| NAT Gateway + transferência | ~$0.20–$0.40 |
| DynamoDB, SQS, ECR | ~$0.05 |
| **Total estimado** | **~$2–$3** |

> ⚠️ Lembrar de executar `terraform destroy` ao final da gravação para evitar custos contínuos.

---

## Como Converter este Arquivo em PDF

1. Abra o arquivo no navegador (ex: via extensão Markdown Preview no VS Code ou diretamente em `chrome://` com extensão)
2. Use **Imprimir → Salvar como PDF** (`Cmd+P` → `Save as PDF`)
3. Ou utilize a extensão **Markdown PDF** no VS Code: botão direito → _Export (pdf)_

---

_Relatório gerado para entrega do Tech Challenge Fase 3 — POSTECH / FIAP_
