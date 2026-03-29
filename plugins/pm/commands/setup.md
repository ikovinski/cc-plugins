---
name: setup
description: "Interactive MCP setup — checks which integrations are missing, asks which ones to configure, generates ready-to-paste env var blocks."
allowed_tools: ["Read", "Bash", "Write", "AskUserQuestion"]
triggers:
  - "setup"
  - "configure"
  - "налаштувати"
---

# /pm:setup — MCP Configuration

Інтерактивне налаштування інтеграцій. Перевіряє що вже підключено, питає що потрібно, генерує готовий блок для shell profile.

## Usage

```bash
/pm:setup              # Full interactive setup
/pm:setup jira         # Configure only Jira
/pm:setup confluence   # Configure only Confluence
/pm:setup sentry       # Configure only Sentry
/pm:setup git          # Configure only Git
```

## Process

### Step 1 — Check Current Status

Run the check script to see what's already configured:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-mcp-status.sh"
```

Show the status table to the user.

### Step 2 — Ask What to Configure

If specific integration not passed as argument, ask via AskUserQuestion:

```
Які інтеграції потрібно налаштувати?

  a) Jira — задачі, stories, sprint planning
  b) Confluence — документація, specs, PRDs
  c) Sentry — production issues, error tracking
  d) Git (GitHub) — PRs, commits, branches
  e) Всі одразу
  f) Пропустити — працювати в dialogue mode
```

### Step 3 — Collect Configuration (per integration)

For each selected integration, ask NON-SENSITIVE information via AskUserQuestion. **NEVER ask for tokens directly** — they will be in conversation context.

#### Jira

```
Яка URL вашого Jira instance?

Варіанти:
  a) https://company.atlassian.net — Atlassian Cloud
  b) https://jira.company.com — Self-hosted
  c) Інше — вкажіть URL
```

```
Яка ваша email адреса в Jira?
(Потрібна для API автентифікації разом з токеном)
```

#### Confluence

```
Confluence зазвичай на тому ж домені що й Jira.
URL: {jira_url}/wiki — це вірно?

  a) Так
  b) Ні, інший URL — вкажіть
```

#### Sentry

```
Яка назва вашої організації в Sentry?
(Видно в URL: https://sentry.io/organizations/{org-name}/)
```

#### Git

```
Який Git provider використовуєте?

  a) GitHub.com
  b) GitHub Enterprise — вкажіть URL
  c) GitLab — (потрібен інший MCP server, покажу налаштування)
```

### Step 4 — Generate Configuration Block

Based on collected information, generate a ready-to-paste block.

**Output format:**

```
✅ Готово! Додайте наступний блок у ваш ~/.zshrc (або ~/.bashrc):

┌─────────────────────────────────────────────────────────
│
│  # === CC Plugins — MCP Configuration ===
│
│  # Jira
│  export JIRA_URL="https://company.atlassian.net"
│  export JIRA_TOKEN="<your-jira-api-token>"
│  export JIRA_USER_EMAIL="user@company.com"
│
│  # Confluence
│  export CONFLUENCE_URL="https://company.atlassian.net/wiki"
│  export CONFLUENCE_TOKEN="<your-confluence-api-token>"
│  export CONFLUENCE_USER_EMAIL="user@company.com"
│
│  # Sentry
│  export SENTRY_TOKEN="<your-sentry-auth-token>"
│  export SENTRY_ORG="company-org"
│
│  # Git (GitHub)
│  export GITHUB_TOKEN="<your-github-token>"
│
└─────────────────────────────────────────────────────────

Де отримати токени:
  • Jira/Confluence: https://id.atlassian.com/manage-profile/security/api-tokens
  • Sentry: https://sentry.io/settings/account/api/auth-tokens/
  • GitHub: https://github.com/settings/tokens (scope: repo, read:org)

Після додавання:
  1. Виконайте: source ~/.zshrc
  2. Перезапустіть Claude Code
  3. Перевірте: /pm:setup (має показати ✅ для всіх)
```

### Step 5 — Offer to Write Automatically

```
Хочете щоб я автоматично додав цей блок у ваш shell profile?

  a) Так, додай в ~/.zshrc
  b) Так, додай в ~/.bashrc
  c) Ні, я додам сам
```

If user chooses a) or b):
1. Read the current shell profile
2. Check if `# === CC Plugins` block already exists
3. If exists — ask to overwrite or skip
4. If not — append the block at the end
5. Remind user to run `source ~/.zshrc` and restart Claude Code

**SECURITY NOTE:** When writing to shell profile, use placeholder `<your-xxx-token>` for token values. NEVER write actual tokens collected via conversation. The user must replace placeholders manually.

### Step 6 — Verify

After user confirms they've set up tokens:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-mcp-status.sh"
```

Show updated status table.

## Idempotency

Running `/pm:setup` multiple times is safe:
- Shows current status first
- Only asks about unconfigured integrations
- Won't duplicate entries in shell profile (checks for existing block)
