# Roteiro do Vídeo — Tech Challenge Fase 3
## Duração alvo: 15–18 minutos

---

## ANTES DE GRAVAR — Preparação (faça isso antes de apertar REC)

**1. Renove as credenciais do AWS Academy:**
- Acesse o AWS Academy no navegador
- Clique em "Start Lab" se não estiver rodando
- Clique em "AWS Details" → "Show" ao lado de "AWS CLI"
- No terminal, cole as credenciais:

```bash
export AWS_ACCESS_KEY_ID=ASIA...
export AWS_SECRET_ACCESS_KEY=...
export AWS_SESSION_TOKEN=...
```

**2. Atualize o kubeconfig:**
```bash
aws eks update-kubeconfig --name togglemaster-cluster --region us-east-1
```

**3. Confirme que o ArgoCD está respondendo:**
Abra no navegador: http://ad09d3842935245a9acdfa770c6394f2-1370995865.us-east-1.elb.amazonaws.com
- Login: `admin`
- Senha: `5PMqK93FxOSbQdTx`

**4. Deixe estas abas abertas no navegador:**
- Aba 1: GitHub Actions → https://github.com/RussoAndre/fiapandrerusso/actions
- Aba 2: ArgoCD → http://ad09d3842935245a9acdfa770c6394f2-1370995865.us-east-1.elb.amazonaws.com
- Aba 3: Console AWS → https://console.aws.amazon.com (região us-east-1)
- Aba 4: Repositório GitHub → https://github.com/RussoAndre/fiapandrerusso

**5. Abra o VS Code com o projeto:**
```bash
code /Users/russondr/Documents/Faculdade/togglemaster
```

**6. Abra dois terminais lado a lado:**
- Terminal 1: na pasta raiz do projeto
- Terminal 2: na pasta `terraform/environments/academy`

**7. Confirme que o pipeline mais recente está verde:**
- Acesse https://github.com/RussoAndre/fiapandrerusso/actions
- Deve aparecer pelo menos um run com ✅ verde

---

## PARTE 1 — Apresentação (1 minuto)

**[CÂMERA ou TELA — mostre o repositório GitHub aberto]**

**FALE:**
> "Olá, meu nome é André Russo, RM 373828. Neste vídeo apresento o Tech Challenge da Fase 3 da POSTECH, que cobre três temas principais: Infraestrutura como Código com Terraform, pipeline de CI/CD com DevSecOps usando GitHub Actions, e entrega contínua com GitOps usando ArgoCD."

**[Mostre a tela do repositório: https://github.com/RussoAndre/fiapandrerusso]**

**FALE:**
> "O projeto se chama ToggleMaster, uma plataforma de feature flags composta por cinco microsserviços em Go: auth, flag, targeting, evaluation e analytics. Vou mostrar cada parte funcionando."

**[No VS Code, clique na pasta `services/` para expandir e mostrar os 5 serviços]**

---

## PARTE 2 — Infraestrutura como Código com Terraform (4–5 minutos)

### 2.1 — Mostrar a estrutura do código Terraform

**[No VS Code, clique na pasta `terraform/` para expandir]**

**FALE:**
> "A infraestrutura está organizada em módulos independentes dentro da pasta terraform. Cada módulo é responsável por um conjunto de recursos."

**[Clique para expandir `terraform/modules/`]**

**FALE enquanto aponta para cada pasta:**
> "O módulo networking cria a VPC, as subnets públicas e privadas, o Internet Gateway e o NAT Gateway. O módulo eks provisiona o cluster Kubernetes. O módulo databases cria as três instâncias RDS PostgreSQL, o ElastiCache Redis e a tabela DynamoDB. O módulo messaging cria a fila SQS com dead-letter queue. E o módulo ecr cria os repositórios de imagens Docker."

**[Clique em `terraform/environments/academy/main.tf` para abrir o arquivo]**

**FALE:**
> "O ambiente academy conecta todos os módulos. Uma decisão importante aqui foi a questão do IAM no AWS Academy."

**[Role o arquivo até a linha com `data "aws_iam_role"`]**

**FALE:**
> "O AWS Academy não permite criar IAM roles. A solução foi usar um data source do Terraform para referenciar a LabRole já existente na conta, e passá-la tanto para o cluster EKS quanto para os node groups. Nenhuma role nova é criada."

**[Clique em `terraform/environments/academy/backend.tf`]**

**FALE:**
> "O estado do Terraform não fica local. Ele é armazenado remotamente em um bucket S3 com criptografia habilitada. Isso é fundamental para trabalho em equipe — qualquer pessoa pode rodar o Terraform e vai trabalhar com o estado atualizado."

### 2.2 — Rodar o terraform plan

**[Mude para o Terminal 2, que está em `terraform/environments/academy`]**

**FALE:**
> "Vou rodar o terraform plan para mostrar o estado atual da infraestrutura."

**Digite e execute:**
```bash
terraform plan -var='db_password=ToggleMaster2024Secure'
```

**[Aguarde o output aparecer — leva cerca de 10 segundos]**

**FALE enquanto o output aparece:**
> "O Terraform lê o estado remoto no S3, consulta a AWS para ver o que já existe, e compara com o código. Como a infraestrutura já foi aplicada, ele confirma que tudo está sincronizado."

**[Quando aparecer a linha final, aponte para ela na tela:]**
```
No changes. Your infrastructure matches the configuration.
```

**FALE:**
> "Perfeito. Nenhuma mudança necessária — o que está no código é exatamente o que está rodando na AWS."

### 2.3 — Mostrar os recursos no Console AWS

**[Troque para o navegador, abra o Console AWS na região us-east-1]**

**[Acesse VPC: clique em Services → VPC → Your VPCs]**

**FALE:**
> "Aqui está a VPC criada pelo Terraform, a togglemaster-vpc, com o CIDR 10.0.0.0/16."

**[Clique em Subnets no menu lateral]**

**FALE:**
> "Quatro subnets criadas — duas públicas e duas privadas, distribuídas em duas zonas de disponibilidade para alta disponibilidade."

**[Acesse EKS: clique em Services, pesquise EKS, clique em Clusters]**

**FALE:**
> "O cluster EKS togglemaster-cluster, rodando Kubernetes 1.32, com status Active."

**[Clique no cluster para abrir os detalhes, depois em Compute → Node groups]**

**FALE:**
> "O node group com duas instâncias t3.medium rodando. Esses nós são onde os pods dos microsserviços vão rodar."

**[Acesse RDS: clique em Services → RDS → Databases]**

**FALE:**
> "Três instâncias PostgreSQL 17.5 criadas — uma para cada microsserviço que precisa de banco relacional: auth, flag e analytics."

**[Acesse ElastiCache: clique em Services → ElastiCache → Redis caches]**

**FALE:**
> "O cluster Redis para cache distribuído."

**[Acesse DynamoDB: clique em Services → DynamoDB → Tables]**

**FALE:**
> "A tabela ToggleMasterAnalytics no DynamoDB, com billing PAY_PER_REQUEST, para armazenar eventos de analytics sem precisar provisionar capacidade."

**[Acesse SQS: clique em Services → SQS]**

**FALE:**
> "A fila SQS togglemaster-events para comunicação assíncrona entre os serviços, com uma dead-letter queue para mensagens que falham."

**[Acesse ECR: clique em Services → ECR → Repositories]**

**FALE:**
> "E os cinco repositórios ECR, um para cada microsserviço. Todos com scan automático de vulnerabilidades habilitado no push."

---

## PARTE 3 — Pipeline DevSecOps com GitHub Actions (5–6 minutos)

### 3.1 — Mostrar a estrutura do pipeline

**[No VS Code, expanda `.github/workflows/`]**

**FALE:**
> "O pipeline está definido em GitHub Actions. Existe um template reutilizável que é chamado pelos cinco workflows — um por microsserviço. Isso evita duplicação de código."

**[Clique em `_ci-template.yml` para abrir]**

**FALE:**
> "O pipeline tem quatro estágios em sequência. Primeiro o build e testes, depois o lint, depois o security scan, e por último o docker build e push. Cada estágio depende do anterior — se um falha, os seguintes não rodam."

**[Role até o job `sast-sca` e mostre as linhas do Trivy]**

**FALE:**
> "No estágio de segurança, rodamos dois scanners. O gosec faz análise estática do código-fonte Go, procurando padrões inseguros. O Trivy verifica vulnerabilidades nas dependências. E aqui está a regra mais importante: exit-code 1 com severidade CRITICAL. Se o Trivy encontrar qualquer CVE crítico, o pipeline para aqui e a imagem não é publicada."

### 3.2 — Mostrar um pipeline passando

**[Troque para o navegador, abra GitHub Actions: https://github.com/RussoAndre/fiapandrerusso/actions]**

**FALE:**
> "Aqui estão os runs do pipeline. Vou abrir o run mais recente que passou com sucesso."

**[Clique no run mais recente com ✅ verde]**

**FALE:**
> "Podemos ver os quatro jobs: Build and Test, Lint, Security Scan e Docker Build and Push."

**[Clique em "Build & Test (auth)" para expandir]**

**FALE:**
> "No build, o código é compilado e os testes unitários são executados com a flag race para detectar condições de corrida."

**[Clique em "Security Scan (auth)" para expandir, role até o output do Trivy]**

**FALE:**
> "No security scan, o Trivy fez a varredura do código e das dependências e não encontrou vulnerabilidades críticas. O pipeline continuou."

**[Clique em "Docker Build & Push (auth)" para expandir]**

**FALE:**
> "No último estágio, a imagem Docker foi construída, passou pelo scan de container, e foi publicada no ECR com a tag baseada no hash do commit — aqui vemos o hash exato, garantindo rastreabilidade completa."

### 3.3 — Demonstrar o bloqueio por vulnerabilidade CRÍTICA

**FALE:**
> "Agora vou mostrar o que acontece quando uma vulnerabilidade crítica é introduzida no código. Isso simula um cenário real onde um desenvolvedor adiciona uma dependência comprometida."

**[Troque para o Terminal 1, na raiz do projeto]**

**Digite e execute:**
```bash
git checkout -b demo/security-failure
```

**[No VS Code, abra o arquivo `services/auth/go.mod`]**

O arquivo atual se parece com isso:
```
module github.com/togglemaster/auth

go 1.24
```

**Adicione uma linha no final do arquivo:**
```
require golang.org/x/crypto v0.0.0-20190308221718-c2843e01d9a2
```

**FALE enquanto digita:**
> "Vou adicionar uma versão muito antiga da biblioteca crypto do Go — de 2019 — que contém vulnerabilidades conhecidas e catalogadas."

**[Salve o arquivo com Cmd+S]**

**[No terminal, execute:]**
```bash
git add services/auth/go.mod
git commit -m "feat: add crypto dependency"
git push origin demo/security-failure
```

**[Troque para o navegador, abra GitHub Actions]**

**FALE enquanto aguarda:**
> "O workflow demo-security-block foi disparado automaticamente. Ele vai rodar o mesmo processo de security scan na branch de demo. Aguardando o resultado..."

**[Quando o job "Security Gate" ficar vermelho — clique nele]**

**[Role até o output do Trivy no log]**

**FALE apontando para a tabela de vulnerabilidades:**
> "O Trivy encontrou uma vulnerabilidade classificada como CRÍTICA na dependência que adicionamos. O pipeline falhou com exit code 1 exatamente no estágio de segurança. A imagem não foi construída, não foi publicada no ECR, e nenhum deploy aconteceu. O sistema bloqueou automaticamente."

**[Mostre na tela o job vermelho com a mensagem de falha]**

**FALE:**
> "Agora vou reverter a mudança e mostrar o pipeline passando novamente."

**[No terminal, execute:]**
```bash
git revert HEAD --no-edit
git push origin demo/security-failure
```

**[No GitHub Actions, aguarde o novo run aparecer e ficar verde]**

**FALE:**
> "Com a dependência vulnerável removida, o pipeline passou em todos os estágios. Isso é o DevSecOps funcionando — segurança integrada ao fluxo de desenvolvimento, não como uma etapa manual depois."

**[Volte para a branch main:]**
```bash
git checkout main
```

---

## PARTE 4 — GitOps com ArgoCD (3–4 minutos)

### 4.1 — Mostrar o ArgoCD com os 5 microsserviços

**[Troque para o navegador, abra o ArgoCD]**

URL: http://ad09d3842935245a9acdfa770c6394f2-1370995865.us-east-1.elb.amazonaws.com

Login: `admin` / `5PMqK93FxOSbQdTx`

**FALE:**
> "O ArgoCD está instalado dentro do próprio cluster EKS e gerencia todos os microsserviços via GitOps."

**[Mostre a tela principal com os 5 cards de aplicações]**

**FALE:**
> "Aqui estão as cinco Applications do ArgoCD — uma por microsserviço. Cada uma monitora uma pasta específica do repositório Git e mantém o cluster sincronizado com o que está no código."

**[Clique em "togglemaster-auth" para abrir os detalhes]**

**FALE:**
> "Dentro de cada Application, o ArgoCD mostra todos os recursos Kubernetes que ela gerencia: o Deployment, o Service e o HorizontalPodAutoscaler."

**[Mostre a árvore de recursos na tela]**

**FALE:**
> "O status Synced significa que o que está rodando no cluster é exatamente o que está no repositório Git. Se alguém fizer uma mudança manual no cluster — como um kubectl apply direto — o ArgoCD detecta o drift e reverte automaticamente."

### 4.2 — Demonstrar o fluxo GitOps completo

**FALE:**
> "Vou demonstrar o fluxo completo do GitOps. Faço uma mudança no código, o pipeline CI processa e atualiza a tag da imagem no repositório, e o ArgoCD detecta e sincroniza no cluster — tudo automaticamente, sem nenhum kubectl apply manual."

**[No VS Code, abra `services/flag/main.go`]**

**[Encontre o map de flags e adicione uma linha nova:]**

Antes:
```go
flags = map[string]Flag{
    "new-ui":      {Key: "new-ui", Enabled: true},
    "dark-mode":   {Key: "dark-mode", Enabled: false},
    "beta-search": {Key: "beta-search", Enabled: false},
}
```

Depois (adicione a última linha):
```go
flags = map[string]Flag{
    "new-ui":        {Key: "new-ui", Enabled: true},
    "dark-mode":     {Key: "dark-mode", Enabled: false},
    "beta-search":   {Key: "beta-search", Enabled: false},
    "analytics-v2":  {Key: "analytics-v2", Enabled: false},
}
```

**[Salve com Cmd+S]**

**[No terminal:]**
```bash
git add services/flag/main.go
git commit -m "feat(flag): add analytics-v2 feature flag"
git push origin main
```

**[Troque para o navegador, abra GitHub Actions]**

**FALE:**
> "O push disparou o pipeline do serviço flag. Vou acompanhar os estágios."

**[Clique no run que acabou de aparecer]**

**FALE:**
> "Build passando... Lint passando... Security scan passando... Docker build e push."

**[Quando chegar no job "Update GitOps", clique nele para expandir]**

**FALE:**
> "Esse é o estágio final do pipeline. Depois de publicar a imagem no ECR, o pipeline atualiza automaticamente o arquivo deployment.yaml no repositório Git com a nova tag da imagem, e faz um commit."

**[Aguarde o job terminar, depois vá para a aba do repositório GitHub]**

**[Clique em "gitops" → "apps" → "flag" → "deployment.yaml"]**

**[Clique em "History" ou veja os commits recentes do arquivo]**

**FALE:**
> "Aqui está o commit feito automaticamente pelo github-actions bot, atualizando a tag da imagem para a versão que acabou de ser publicada."

**[Volte ao ArgoCD]**

**FALE:**
> "O ArgoCD monitora o repositório a cada 3 minutos por padrão. Vou forçar uma sincronização para mostrar em tempo real."

**[Clique em "togglemaster-flag"]**

**[Clique no botão "SYNC" no topo da página]**

**[Clique em "SYNCHRONIZE" na confirmação]**

**FALE enquanto sincroniza:**
> "O ArgoCD está aplicando o novo deployment com a imagem atualizada no cluster. Esse é o GitOps em ação — o repositório Git é a única fonte de verdade, e o cluster sempre converge para o estado definido no código."

**[Mostre o status mudando para Synced com o ícone verde]**

**FALE:**
> "Sincronizado. A nova versão está rodando no cluster."

---

## PARTE 5 — Encerramento (30 segundos)

**[Mostre rapidamente as quatro abas abertas: VS Code, Actions, ArgoCD, Console AWS]**

**FALE:**
> "Para resumir: toda a infraestrutura é provisionada e versionada com Terraform, com estado remoto no S3. O pipeline DevSecOps garante que nenhuma imagem com vulnerabilidade crítica chega ao ambiente. E o GitOps com ArgoCD mantém o cluster sempre sincronizado com o repositório, sem deploys manuais. Obrigado."

---

## COMANDOS DE REFERÊNCIA RÁPIDA

Cole esses comandos no terminal durante a gravação:

```bash
# Antes de gravar — renovar credenciais
export AWS_ACCESS_KEY_ID=ASIA...
export AWS_SECRET_ACCESS_KEY=...
export AWS_SESSION_TOKEN=...
aws eks update-kubeconfig --name togglemaster-cluster --region us-east-1

# Terraform plan
cd /Users/russondr/Documents/Faculdade/togglemaster/terraform/environments/academy
terraform plan -var='db_password=ToggleMaster2024Secure'

# Demo vulnerabilidade
cd /Users/russondr/Documents/Faculdade/togglemaster
git checkout -b demo/security-failure
# (editar services/auth/go.mod — adicionar a linha require)
git add services/auth/go.mod
git commit -m "feat: add crypto dependency"
git push origin demo/security-failure
# (aguardar pipeline falhar, mostrar o log)
git revert HEAD --no-edit
git push origin demo/security-failure
git checkout main

# Demo GitOps
# (editar services/flag/main.go — adicionar analytics-v2 flag)
git add services/flag/main.go
git commit -m "feat(flag): add analytics-v2 feature flag"
git push origin main
# (acompanhar pipeline e depois ArgoCD)
```

## URLs IMPORTANTES

| | URL |
|---|---|
| GitHub Actions | https://github.com/RussoAndre/fiapandrerusso/actions |
| Repositório | https://github.com/RussoAndre/fiapandrerusso |
| ArgoCD | http://ad09d3842935245a9acdfa770c6394f2-1370995865.us-east-1.elb.amazonaws.com |
| Console AWS | https://us-east-1.console.aws.amazon.com |

## ArgoCD

- Usuário: `admin`
- Senha: `5PMqK93FxOSbQdTx`

## DICAS PARA A GRAVAÇÃO

- Use o OBS ou QuickTime (Cmd+Shift+5 no Mac) para gravar a tela
- Grave em resolução mínima 1080p
- Fale devagar e claramente — é avaliação acadêmica
- Se errar uma fala, pause, respire e continue — você pode editar depois
- Não precisa mostrar o rosto, só a tela
- Deixe os terminais com fonte maior (Cmd+= no Terminal) para facilitar a leitura
- Antes de gravar a cena do Trivy falhando, confirme que o run anterior passou para ter contraste claro
