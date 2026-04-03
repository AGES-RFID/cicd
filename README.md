# Workflow de Desenvolvimento 🤠

Este documento descreve o **fluxo completo de desenvolvimento** adotado nos repositórios de **front-end**, **back-end** e **gateway**.  
Todo o processo utiliza **reusable workflows** do GitHub Actions, pre-commit, pre-push, linter e boas práticas de código.

Siga exatamente esta sequência para garantir que sua contribuição seja aprovada rapidamente.

---

## 1. Selecionar Task

- Acesse o **board do projeto** no GitHub Projects
- Escolha uma task na coluna **To Do**
- Clique em **Assign** e atribua a si mesmo (e a quem mais estiver fazendo a task com você)
- Arraste a task para a coluna **In Progress**

---

## 2. Criar Branch

Crie a branch seguindo o padrão:
```bash
<tipo>/<número-da-issue>-<descrição-em-kebab-case>
```

**Tipos de branch:**
- `feat`: nova funcionalidade
- `fix`: correção de bug
- `docs`: documentação
- `style`: formatação
- `refactor`: refatoração
- `test`: testes
- `chore`: manutenção

**Exemplo:**

```bash
feat/123-criar-tela-login
```

## 3. Sincronizar Repositório

```bash
git pull origin main          # atualiza sua main local
git branch -r                 # verifica branches remotas (opcional)
git checkout <nome-da-branch> # troca para sua branch
```

## 4. Desenvolvimento

- Implemente POR COMPLETO a funcionalidade descrita na task
- Siga as boas práticas de código do projeto (clean code, SOLID)
- Mantenha o código organizado e legível

## 5. Testes
**Obrigatório:** toda feature deve ter testes desenvolvidos (unitários e/ou integração, conforme a stack).

⚠️ Não serão aceitos PRs sem testes e sem lint validado.

**Para a Stack Bun (Front-end):**
```bash
bun check          # Verifica tipos e formatação
bun check:fix      # Corrige formatação automaticamente (quando possível)
bun run test:cov   # Executa os testes e gera o relatório de coverage
```

**Para a Stack .NET (Back-end / Gateway):**
```bash
dotnet format --verify-no-changes           # Valida formatação do código (.editorconfig)
dotnet test Backend.Tests.Unit/             # Executa testes unitários
dotnet test Backend.Tests.Integration/      # Executa testes de integração
```

**Requisitos mínimos:**

- ✅ Todos os testes devem passar
- ✅ Coverage mínimo de **80%** (verifique a tabela de coverage gerada)

## 6. Commit
Use o padrão de **Conventional Commits:**

```text
<tipo>: <descrição curta e imperativa>
```

**Exemplo:**
```text
feat: adiciona tela de login
fix: corrige validação de e-mail
```

## 7. Push

```bash
git push origin <nome-da-branch>
```
O push passa automaticamente pelo **pre-push** (validações adicionais).

## 8. Verificar CI (GitHub Actions)

1. Acesse a aba **Actions** do repositório
2. Confirme que os workflows executaram com sucesso. O CI automatizado engloba:
   - **Validação e Lint:** Verifica pull request rules e estilos de código (ex: `bun check` ou `dotnet format`).
   - **Testes (Unitários/Integração):** Garante a execução completa sem quebrar regras e com cobertura.
   - **Build:** Compila as aplicações (garantia de artefato viável).

## 9. Abrir Pull Request (PR)

- Crie um PR da sua branch para main (Trunk-Based Development)
- Título claro e descritivo
- Descrição do que foi feito (use bullet points se houver muitas alterações)
- Inclua **evidências obrigatórias**:

| Tipo de repositório | Evidências obrigatórias |
|:---|:---|
| **Front-end** | 📸 Prints da tela/feature (pode necessitar de logs dependendo da task) |
| **Back-end** | 📄 Logs ou outputs da API |
| **Gateway** | 📄 Logs ou outputs da rota |
| **Todos** | 📊 Screenshot do coverage (80%+) |

- Após criar o PR, mova o card no board para **Ready for Review**

## 10. Solicitar Review

- Atribua um revisor (qualquer AGES III)
- Avise no Discord, no canal `#pull-requests` marcando os AGES III (@AGESIII)

## 11. Code Review
Os revisores (AGES III) irão analisar o PR.

### ✅ Aprovado

- O AGES III move o card para **Done**
- O AGES III realiza o merge na `main`

### ❌ Reprovado

- Comentários serão deixados diretamente no PR
- O card volta para **In Progress**
- Você será notificado no Discord (canal `#review`)

**Se reprovado:**
- Corrija **todos** os pontos levantados
- Repita o fluxo a partir do passo 5 (Testes) até a aprovação (é chato, eu sei 😓)


## 12. Pós-Merge (Integração e Deploy Contínuo)

Após o merge na `main`, a infraestrutura de Actions cuida do processo de adoção dessa nova versão com workflows em background:
- **GitLab Sync:** O código mais atualizado do GitHub é sincronizado e espelhado automaticamente para os repositórios da AGES (GitLab).
- **Tag & Release:** Se aplicável, é gerada via automação uma Tag e os devidos Release Notes para a versão concluída.
- **Deploy:** O workflow envia as adições para implantação em seu respectivo ambiente como **staging** ou **production**.

### Pronto! 🥳
Seguindo este documento, sua contribuição será integrada com qualidade, rapidez e sem surpresas.

ps: <u>qualquer dúvida, favor acionar os AGES III</u> 😊