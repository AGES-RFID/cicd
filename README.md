# 🚀 AGES RFID - CI/CD Shared Workflows

Bem-vindo ao repositório central de Workflows reutilizáveis de CI/CD do projeto **[AGES RFID](https://github.com/orgs/AGES-RFID)**.

Este repositório atua como a espinha dorsal da nossa automação, disponibilizando fluxos automatizados de integração e entrega contínuas do GitHub, que podem ser consumidos por todos os outros serviços do projeto, garantindo uma única fonte de verdade para nossas regras e padrões de **Governança, Qualidade e Segurança**.

Os serviços atualmente disponíveis e integrados à arquitetura de CI/CD do projeto são:

- 🖥️ [Frontend](https://github.com/AGES-RFID/frontend)
- ⚙️ [Backend](https://github.com/AGES-RFID/backend)
- 📡 [Gateway](https://github.com/AGES-RFID/gateway)

## 📑 Índice

1. [🧠 Glossário: Conceitos Essenciais](#1--glossário-conceitos-essenciais)
2. [🏗️ Arquitetura da Pipeline](#2-️-arquitetura-da-pipeline)
3. [📂 Estrutura de Diretórios](#3--estrutura-de-diretórios)
4. [🛡️ DevSecOps & Shift-Left](#4-️-devsecops--shift-left)
5. [🛠️ Workflows Reutilizáveis](#5-️-workflows-reutilizáveis)
6. [📖 Guia Passo a Passo: Como Integrar no seu Repositório](#6--guia-passo-a-passo-como-integrar-no-seu-repositório)

## 1. 🧠 Glossário: Conceitos Essenciais

Se você está começando agora na AGES, não se preocupe! Aqui estão os pilares que baseiam nossa esteira:

- **[CI/CD](https://resources.github.com/ci-cd/):** Integração Contínua (CI) e Implantação Contínua (CD). É a automação que testa seu código assim que você o envia e o coloca no ar com segurança.
- **[Trunk-Based Development](https://trunkbaseddevelopment.com/):** Metodologia onde todos mesclam código em uma branch central (`main`) várias vezes ao dia. Evitamos branches longas para fugir do "Merge Hell".
- **[Conventional Commits](https://www.conventionalcommits.org/pt-br/v1.0.0/):** Um padrão para mensagens de commit (ex: `feat:`, `fix:`, `docs:`). Isso permite que a pipeline gere relatórios automáticos.
- **[Semantic Versioning (SemVer)](https://semver.org/lang/pt-BR/):** Versões no formato `1.0.0`. Nossa esteira usa seus commits para decidir se a próxima versão é um ajuste pequeno ou uma grande mudança.
- **[Reusable Workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows):** Em vez de copiar e colar 100 linhas de código em cada repositório, criamos a lógica aqui e os outros repositórios apenas a "chamam".

## 2. 🏗️ Arquitetura da Pipeline

Nossa automação reage a eventos específicos no GitHub, dividindo-se em fluxos lógicos:

### Fluxo A: Validação de Pull Requests (PR)

**Objetivo:** Garantir que o código novo não quebre o que já existe.

1. **Gatekeeper:** Verifica se o nome da sua branch e o título do PR estão corretos.
2. **Qualidade:** Roda o _Lint_ (formatação) e compila o código.
3. **Testes:** Executa testes unitários e de integração (usando banco de dados real via [Testcontainers](https://testcontainers.com/)).

### Fluxo B: Push na Main (Staging)

**Objetivo:** Integrar o código e validar em ambiente de homologação.

1. Repete as validações de CI para garantir integridade.
2. Realiza o Deploy automático para o ambiente de **Staging** na AWS.

### Fluxo C: Tag de Versão (Produção)

**Objetivo:** Entregar uma versão estável para o cliente.

1. Gera o _Changelog_ e a _Release_ oficial no GitHub.
2. Realiza o Deploy para o ambiente de **Produção** na AWS.

## 3. 📂 Estrutura de Diretórios

```text
cicd/
├── .github/
│   ├── actions/
│   │   └── validate-pr/
│   │       └── action.yml       # Lógica de validação de nomenclatura e governança
│   └── workflows/
│       ├── ci-bun.yml           # CI para Frontend (Bun/React)
│       ├── ci-dotnet.yml        # CI para Backend (.NET 10)
│       ├── deployment.yml       # Lógica central de Deploy AWS
│       ├── gitlab-sync.yml      # Espelhamento para o GitLab da AGES
│       └── tag-release.yml      # Automação de Releases e Tags
```

## 4. 🛡️ DevSecOps & Shift-Left

Seguimos o princípio de **Shift-Left**, trazendo a segurança para o início do desenvolvimento:

1. **Imutabilidade:** Usamos Lock Files (`packages.lock.json` ou `bun.lockb`) para garantir que as bibliotecas instaladas na sua máquina sejam as mesmas da pipeline, evitando ataques de cadeia de suprimentos.
2. **Segurança de Segredos:** Tokens de acesso nunca ficam no código. São injetados via _GitHub Secrets_ em tempo de execução.
3. **Ambientes Isolados:** Testes de integração rodam em containers descartáveis, garantindo que um teste nunca "suje" o outro.

## 5. 🛠️ Workflows Reutilizáveis

| Workflow              | Descrição           | Principais Recursos                                    |
| :-------------------- | :------------------ | :----------------------------------------------------- |
| **`ci-dotnet.yml`**   | CI para Backend     | Restore, Format, Unit Tests, Integration Tests, Build. |
| **`ci-bun.yml`**      | CI para Frontend    | Bun Install, Lint, Coverage, Production Build.         |
| **`deployment.yml`**  | Deploy Centralizado | Validação de ambiente e promoção de versão.            |
| **`gitlab-sync.yml`** | Sync Institucional  | Mirror automático para o GitLab da AGES.               |

## 6. 📖 Guia Passo a Passo: Como Integrar no seu Repositório

Para integrar o seu serviço aos CI/CD Shared Workflows, crie os arquivos abaixo na pasta `.github/workflows/` do seu repositório cliente.

### A. Validação de PR (`pr-to-trunk.yml`)

Este arquivo bloqueia merges que não passam nos testes.

```yaml
name: PR to Trunk
on:
  pull_request:
    branches: ["main"]
jobs:
  validate:
    uses: AGES-RFID/cicd/.github/workflows/ci-dotnet.yml@main
    with:
      dotnet-version: "10.0.x"
    secrets:
      GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### B. Deploy em Staging (`push-on-trunk.yml`)

Ativado após o merge bem-sucedido.

```yaml
name: Push on Trunk
on:
  push:
    branches: ["main"]
jobs:
  validate:
    uses: AGES-RFID/cicd/.github/workflows/ci-dotnet.yml@main
    secrets:
      GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  deploy:
    needs: [validate]
    uses: AGES-RFID/cicd/.github/workflows/deployment.yml@main
    with:
      environment: "staging"
      version: ${{ github.sha }}
```

### C. Deploy em Produção (`tag-release.yml`)

Ativado quando você cria uma Tag (ex: `v1.0.0`).

```yaml
name: Tag Release
on:
  push:
    tags: ["v[0-9]+.[0-9]+.[0-9]+"]
jobs:
  release:
    uses: AGES-RFID/cicd/.github/workflows/tag-release.yml@main
  deploy:
    needs: [release]
    uses: AGES-RFID/cicd/.github/workflows/deployment.yml@main
    with:
      environment: "production"
      version: ${{ github.ref_name }}
```

### D. Sincronização GitLab (`gitlab-sync.yml`)

Mantém o repositório institucional da AGES atualizado.

```yaml
name: Sync to GitLab
on:
  push:
jobs:
  sync:
    uses: AGES-RFID/cicd/.github/workflows/gitlab-sync.yml@main
    secrets:
      gitlab_token: ${{ secrets.GITLAB_TOKEN }}
```
