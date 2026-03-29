---
name: setup
description: "MCP setup — checks connector status, collects non-sensitive config (site names), generates env var block for shell profile."
allowed_tools: ["Read", "Bash", "Write", "AskUserQuestion"]
triggers:
  - "setup"
  - "configure"
  - "налаштувати"
---

# /pm:setup — MCP Connectors Setup

PM plugin uses 4 MCP connectors: Jira, Confluence, Sentry, GitHub. Each requires environment variables. This command checks what's configured and helps set up the rest.

## Usage

```bash
/pm:setup              # Show status and guide
/pm:setup test         # Test all connectors
```

## Connectors Overview

| Connector | Package | Type | Env Vars |
|-----------|---------|------|----------|
| **Jira** | `@aashari/mcp-server-atlassian-jira` | stdio | `ATLASSIAN_JIRA_SITE_NAME`, `ATLASSIAN_USER_EMAIL`, `ATLASSIAN_API_TOKEN` |
| **Confluence** | `@aashari/mcp-server-atlassian-confluence` | stdio | `ATLASSIAN_CONFLUENCE_SITE_NAME`, `ATLASSIAN_USER_EMAIL`, `ATLASSIAN_API_TOKEN` |
| **Sentry** | `@sentry/mcp-server` | stdio | `SENTRY_ACCESS_TOKEN`, `SENTRY_ORG` |
| **GitHub** | `@modelcontextprotocol/server-github` | stdio | `GITHUB_PERSONAL_ACCESS_TOKEN` |

Note: `ATLASSIAN_USER_EMAIL` and `ATLASSIAN_API_TOKEN` are shared between Jira and Confluence. Site names can be different.

## Process

### Step 1 — Show Status

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-mcp-status.sh"
```

### Step 2 — Ask What to Configure

If specific connector not passed as argument, ask via AskUserQuestion:

```
Які конектори потрібно налаштувати?

  a) Jira — задачі, stories, sprint planning
  b) Confluence — документація, specs, PRDs
  c) Sentry — production issues, error tracking
  d) GitHub — PRs, commits, code browsing
  e) Всі
  f) Пропустити — працювати в dialogue mode
```

### Step 3 — Collect Non-Sensitive Config

Ask via AskUserQuestion. **NEVER ask for tokens directly.**

#### Jira

```
Яка назва вашого Jira site?
(Субдомен з URL: https://{site-name}.atlassian.net)

  Наприклад: якщо URL — https://amomobile.atlassian.net, то site name — "amomobile"
```

#### Confluence

```
Яка назва вашого Confluence site?
(Може відрізнятись від Jira)

  a) Той самий що й Jira ({jira_site_name})
  b) Інший — вкажіть
```

#### Atlassian Email

```
Яка ваша email адреса в Atlassian?
(Потрібна для API автентифікації)
```

#### Sentry

```
Яка назва вашої організації в Sentry?
(Видно в URL: https://sentry.io/organizations/{org-name}/)
```

#### GitHub

```
Який GitHub використовуєте?

  a) github.com
  b) GitHub Enterprise — вкажіть домен
```

### Step 4 — Generate Configuration Block

**Output format:**

```
✅ Готово! Додайте наступний блок у ваш ~/.zshrc (або ~/.bashrc):

┌─────────────────────────────────────────────────────────
│
│  # === CC Plugins — MCP Configuration ===
│
│  # Jira
│  export ATLASSIAN_JIRA_SITE_NAME="{jira_site}"
│  export ATLASSIAN_USER_EMAIL="{email}"
│  export ATLASSIAN_API_TOKEN="<your-atlassian-api-token>"
│
│  # Confluence
│  export ATLASSIAN_CONFLUENCE_SITE_NAME="{confluence_site}"
│
│  # Sentry
│  export SENTRY_ACCESS_TOKEN="<your-sentry-token>"
│  export SENTRY_ORG="{org}"
│
│  # GitHub
│  export GITHUB_PERSONAL_ACCESS_TOKEN="<your-github-pat>"
│
└─────────────────────────────────────────────────────────

Де отримати токени:
  • Atlassian: https://id.atlassian.com/manage-profile/security/api-tokens
    → Create API token → назва: "cc-plugins"
    → Один токен працює для Jira і Confluence
  • Sentry: https://sentry.io/settings/account/api/auth-tokens/
    → Scopes: event:read, issue:read, project:read, org:read
  • GitHub: https://github.com/settings/tokens
    → Generate new token (classic) → Scopes: repo, read:org

Після додавання:
  1. Замініть <your-...-token> на реальні значення
  2. Виконайте: source ~/.zshrc
  3. Перезапустіть Claude Code
  4. Перевірте: /pm:setup
```

### Step 5 — Offer to Write Automatically

```
Хочете щоб я додав цей блок у ваш shell profile?
(Токени будуть placeholder'ами — замінити потрібно вручну)

  a) Так, додай в ~/.zshrc
  b) Так, додай в ~/.bashrc
  c) Ні, я додам сам
```

If user chooses a) or b):
1. Read the current shell profile
2. Check if `# === CC Plugins` block already exists
3. If exists — ask to overwrite or skip
4. If not — append the block at the end
5. **SECURITY:** Use placeholder `<your-xxx-token>` for token values. NEVER write actual tokens.

### Step 6 — Verify

After user confirms they've set up tokens:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-mcp-status.sh"
```

## Idempotency

Running `/pm:setup` multiple times is safe:
- Shows current status first
- Only asks about unconfigured connectors
- Won't duplicate entries in shell profile (checks for existing block)
