---
name: setup
description: "MCP setup — checks connector status, collects non-sensitive config (site names), writes env vars to ~/.claude/settings.json."
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

### Step 4 — Write to Claude Code Settings

The most reliable way to store env vars — **`~/.claude/settings.json` → `env` section**. Claude Code reads this on every startup, regardless of shell profile.

Based on collected non-sensitive data + token placeholders, update `~/.claude/settings.json`:

1. Read current `~/.claude/settings.json`
2. Merge into existing `env` section (don't overwrite other vars)
3. Use real values for non-sensitive data (site names, email, org)
4. Use `<placeholder>` for tokens — ask user to replace manually

**What to write (example):**

```json
{
  "env": {
    "ATLASSIAN_JIRA_SITE_NAME": "{jira_site}",
    "ATLASSIAN_CONFLUENCE_SITE_NAME": "{confluence_site}",
    "ATLASSIAN_USER_EMAIL": "{email}",
    "ATLASSIAN_API_TOKEN": "<your-atlassian-api-token>",
    "SENTRY_ACCESS_TOKEN": "<your-sentry-token>",
    "SENTRY_ORG": "{org}",
    "GITHUB_PERSONAL_ACCESS_TOKEN": "<your-github-pat>"
  }
}
```

**Show to PM before writing:**

```
Додаю в ~/.claude/settings.json → env:

  ATLASSIAN_JIRA_SITE_NAME     = "amomobile"
  ATLASSIAN_CONFLUENCE_SITE_NAME = "um-guide"
  ATLASSIAN_USER_EMAIL         = "ivan@amo.tech"
  ATLASSIAN_API_TOKEN          = "<your-atlassian-api-token>"    ← замініть
  SENTRY_ACCESS_TOKEN          = "<your-sentry-token>"           ← замініть
  SENTRY_ORG                   = "amomama"
  GITHUB_PERSONAL_ACCESS_TOKEN = "<your-github-pat>"             ← замініть

Де отримати токени:
  • Atlassian: https://id.atlassian.com/manage-profile/security/api-tokens
  • Sentry: https://sentry.io/settings/account/api/auth-tokens/
  • GitHub: https://github.com/settings/tokens

Записати?
  a) Так, записуй (потрібно буде замінити placeholder'и на токени)
  b) Ні, я зроблю сам
```

### Step 5 — Write Settings

If user confirms:

1. Read `~/.claude/settings.json`
2. Parse as JSON
3. Merge new vars into `env` section (preserve existing vars)
4. Write back
5. **SECURITY:** Token placeholders ONLY. NEVER write real tokens collected via conversation.

```python
# Merge logic (pseudocode):
settings = read_json("~/.claude/settings.json")
settings.setdefault("env", {})
settings["env"]["ATLASSIAN_JIRA_SITE_NAME"] = "amomobile"  # real value
settings["env"]["ATLASSIAN_API_TOKEN"] = "<your-atlassian-api-token>"  # placeholder
# ... etc
write_json("~/.claude/settings.json", settings)
```

After writing:

```
✅ Записано в ~/.claude/settings.json

⚠️ Замініть placeholder'и на реальні токени:
  1. Відкрийте ~/.claude/settings.json
  2. Знайдіть секцію "env"
  3. Замініть:
     • "<your-atlassian-api-token>" → токен з id.atlassian.com
     • "<your-sentry-token>" → токен з sentry.io
     • "<your-github-pat>" → токен з github.com/settings/tokens
  4. Перезапустіть Claude Code
  5. Перевірте: /pm:setup
```

### Step 6 — Verify

After user replaces placeholders and restarts:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-mcp-status.sh"
```

## Idempotency

Running `/pm:setup` multiple times is safe:
- Shows current status first
- Only asks about unconfigured connectors
- Merges into existing `env` (doesn't overwrite other vars)
- Skips vars that already have non-placeholder values
