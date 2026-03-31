---
name: setup
description: "MCP setup — checks connector status, collects non-sensitive config (site names), writes env vars to ~/.claude/settings.json."
allowed_tools: ["Read", "Bash", "Write", "AskUserQuestion"]
triggers:
  - "setup"
  - "configure"
  - "налаштувати"
---

# /qa:setup — MCP Connectors Setup

QA plugin uses MCP connectors for fetching feature descriptions from external sources. This command checks what's configured and helps set up the rest.

## Connectors Used by QA

| Connector | What For | Package | Env Vars |
|-----------|----------|---------|----------|
| **Jira** | Fetch issue description, comments, AC | `@aashari/mcp-server-atlassian-jira` | `ATLASSIAN_JIRA_SITE_NAME`, `ATLASSIAN_USER_EMAIL`, `ATLASSIAN_API_TOKEN` |
| **Confluence** | Fetch feature specs, PRDs | `@aashari/mcp-server-atlassian-confluence` | `ATLASSIAN_CONFLUENCE_SITE_NAME`, `ATLASSIAN_USER_EMAIL`, `ATLASSIAN_API_TOKEN` |

> Sentry та GitHub також є в `.mcp.json` для майбутніх команд (regression analysis, test coverage від PR), але `/qa:checklist` наразі використовує тільки Jira та Confluence.

Note: `ATLASSIAN_USER_EMAIL` and `ATLASSIAN_API_TOKEN` are shared between Jira and Confluence. Site names can be different.

## Usage

```bash
/qa:setup              # Show status and guide
/qa:setup test         # Test all connectors
```

## Process

### Step 1 — Show Status

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-mcp-status.sh"
```

### Step 2 — Ask What to Configure

If specific connector not passed as argument, ask via AskUserQuestion:

```
Які конектори потрібно налаштувати?

  a) Jira — fetch issue descriptions для чеклістів
  b) Confluence — fetch feature specs та PRDs
  c) Обидва (Jira + Confluence)
  d) Пропустити — працювати з локальними файлами, URL та текстом
```

> **Без MCP плагін повністю працездатний** — просто потрібно передавати опис фічі як файл, URL або текст замість Jira key.

### Step 3 — Collect Non-Sensitive Config

Ask via AskUserQuestion. **NEVER ask for tokens directly.**

#### Jira

```
Яка назва вашого Jira site?
(Субдомен з URL: https://{site-name}.atlassian.net)

  Наприклад: якщо URL — https://mycompany.atlassian.net, то site name — "mycompany"
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

### Step 4 — Write to Claude Code Settings

Based on collected non-sensitive data + token placeholders, update `~/.claude/settings.json`.

1. Read current `~/.claude/settings.json`
2. Merge into existing `env` section (don't overwrite other vars)
3. Use real values for non-sensitive data (site names, email)
4. Use `<placeholder>` for tokens — ask user to replace manually

**Show to user before writing:**

```
Додаю в ~/.claude/settings.json → env:

  ATLASSIAN_JIRA_SITE_NAME     = "{jira_site}"
  ATLASSIAN_CONFLUENCE_SITE_NAME = "{confluence_site}"
  ATLASSIAN_USER_EMAIL         = "{email}"
  ATLASSIAN_API_TOKEN          = "<your-atlassian-api-token>"    ← замініть

Де отримати токен:
  • Atlassian: https://id.atlassian.com/manage-profile/security/api-tokens

Записати?
  a) Так, записуй (потрібно буде замінити placeholder на токен)
  b) Ні, я зроблю сам
```

### Step 5 — Write Settings

If user confirms:

1. Read `~/.claude/settings.json`
2. Parse as JSON
3. Merge new vars into `env` section (preserve existing vars)
4. Write back
5. **SECURITY:** Token placeholders ONLY. NEVER write real tokens collected via conversation.

After writing:

```
✅ Записано в ~/.claude/settings.json

⚠️ Замініть placeholder на реальний токен:
  1. Відкрийте ~/.claude/settings.json
  2. Знайдіть секцію "env"
  3. Замініть "<your-atlassian-api-token>" → токен з id.atlassian.com
  4. Перезапустіть Claude Code
  5. Перевірте: /qa:setup
```

### Step 6 — Verify

After user replaces placeholders and restarts:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-mcp-status.sh"
```

## Idempotency

Running `/qa:setup` multiple times is safe:
- Shows current status first
- Only asks about unconfigured connectors
- Merges into existing `env` (doesn't overwrite other vars)
- Skips vars that already have non-placeholder values

## Already Configured?

If user already has PM plugin configured — env vars are shared. `/qa:setup` will detect existing vars and show:

```
✅ Всі конектори вже налаштовані (env vars від PM plugin).
   Jira        ✅ ready
   Confluence  ✅ ready
```
