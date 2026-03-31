#!/usr/bin/env bash
# CC Plugins — New Plugin Scaffolding
# Usage: ./scripts/create-plugin.sh <plugin-name> [description]
# Example: ./scripts/create-plugin.sh analytics "Analytics plugin — dashboards, metrics, A/B test analysis"

set -euo pipefail

GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BOLD="\033[1m"
RESET="\033[0m"

# --- Validate input ---

if [ $# -lt 1 ]; then
  echo -e "${BOLD}Usage:${RESET} $0 <plugin-name> [description]"
  echo ""
  echo "  plugin-name   kebab-case name (e.g., analytics, data-eng)"
  echo "  description   One-line description (optional)"
  echo ""
  echo -e "${BOLD}Examples:${RESET}"
  echo "  $0 analytics"
  echo '  $0 analytics "Analytics plugin — dashboards, metrics, A/B test analysis"'
  exit 1
fi

PLUGIN_NAME="$1"
PLUGIN_DESC="${2:-"${PLUGIN_NAME} plugin for Claude Code teams."}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PLUGIN_DIR="${ROOT_DIR}/plugins/${PLUGIN_NAME}"

# Validate name: lowercase, kebab-case
if [[ ! "$PLUGIN_NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
  echo "Error: plugin name must be kebab-case (e.g., my-plugin)"
  exit 1
fi

if [ -d "$PLUGIN_DIR" ]; then
  echo "Error: plugin '${PLUGIN_NAME}' already exists at ${PLUGIN_DIR}"
  exit 1
fi

# --- Create directory structure ---

echo -e "${BOLD}Creating plugin: ${PLUGIN_NAME}${RESET}"
echo ""

mkdir -p "${PLUGIN_DIR}/.claude-plugin"
mkdir -p "${PLUGIN_DIR}/agents"
mkdir -p "${PLUGIN_DIR}/commands"
mkdir -p "${PLUGIN_DIR}/skills"
mkdir -p "${PLUGIN_DIR}/docs"
mkdir -p "${PLUGIN_DIR}/scripts"
mkdir -p "${PLUGIN_DIR}/hooks"

# --- plugin.json ---

cat > "${PLUGIN_DIR}/.claude-plugin/plugin.json" << EOF
{
  "name": "${PLUGIN_NAME}",
  "version": "0.1.0",
  "description": "${PLUGIN_DESC}",
  "keywords": ["${PLUGIN_NAME}"],
  "hooks": "./hooks/hooks.json",
  "mcpServers": "./.mcp.json"
}
EOF

# --- .mcp.json (common MCP servers) ---

cat > "${PLUGIN_DIR}/.mcp.json" << 'EOF'
{
  "mcpServers": {
    "jira": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@aashari/mcp-server-atlassian-jira"],
      "env": {
        "ATLASSIAN_SITE_NAME": "${ATLASSIAN_JIRA_SITE_NAME}",
        "ATLASSIAN_USER_EMAIL": "${ATLASSIAN_USER_EMAIL}",
        "ATLASSIAN_API_TOKEN": "${ATLASSIAN_API_TOKEN}"
      }
    },
    "confluence": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@aashari/mcp-server-atlassian-confluence"],
      "env": {
        "ATLASSIAN_SITE_NAME": "${ATLASSIAN_CONFLUENCE_SITE_NAME}",
        "ATLASSIAN_USER_EMAIL": "${ATLASSIAN_USER_EMAIL}",
        "ATLASSIAN_API_TOKEN": "${ATLASSIAN_API_TOKEN}"
      }
    },
    "sentry": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@sentry/mcp-server"],
      "env": {
        "SENTRY_ACCESS_TOKEN": "${SENTRY_ACCESS_TOKEN}",
        "SENTRY_ORG": "${SENTRY_ORG}"
      }
    },
    "github": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}"
      }
    }
  }
}
EOF

# --- hooks.json ---

cat > "${PLUGIN_DIR}/hooks/hooks.json" << 'EOF'
{
  "hooks": {}
}
EOF

# --- CHANGELOG.md ---

TODAY=$(date +%Y-%m-%d)
cat > "${PLUGIN_DIR}/CHANGELOG.md" << EOF
# Changelog

All notable changes to the ${PLUGIN_NAME} plugin will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - ${TODAY}

### Added
- Initial plugin scaffold: plugin.json, .mcp.json, hooks
- Placeholder directories: agents/, commands/, skills/, docs/
- Example command: /${PLUGIN_NAME}:hello
- Example agent: example-agent
- MCP tool reference
EOF

# --- Example command ---

cat > "${PLUGIN_DIR}/commands/hello.md" << EOF
---
name: hello
description: "Example command — replace with real functionality."
allowed_tools: ["Read", "Bash", "AskUserQuestion"]
triggers:
  - "hello"
  - "test"
---

# /${PLUGIN_NAME}:hello — Example Command

This is a template command. Replace it with your plugin's first real command.

## Usage

\`\`\`bash
/${PLUGIN_NAME}:hello          # Basic usage
/${PLUGIN_NAME}:hello world    # With argument
\`\`\`

## Process

### Step 1 — Greet

Show a greeting message:

\`\`\`
👋 Hello from ${PLUGIN_NAME} plugin!
\`\`\`

### Step 2 — Show status

Check MCP status:

\`\`\`bash
bash "\${CLAUDE_PLUGIN_ROOT}/scripts/check-mcp-status.sh"
\`\`\`

## Graceful Degradation

| Source | Available | Not Available |
|--------|-----------|---------------|
| Jira | Full integration | Dialogue mode |
| Confluence | Search docs | Skip |
| Sentry | Check issues | Skip |
| GitHub | Browse code | Local only |
EOF

# --- Example agent ---

cat > "${PLUGIN_DIR}/agents/example-agent.md" << EOF
---
name: example-agent
description: "Example sub-agent — replace with real agent."
model: sonnet
maxTurns: 10
allowed_tools: ["Read", "Grep", "Glob"]
---

# Example Agent

## Identity

You are a focused research agent for the ${PLUGIN_NAME} plugin. Your job is to [describe specific task].

## MCP Tool Reference

**CRITICAL: Read before making any MCP calls.**
Read \`\${CLAUDE_PLUGIN_ROOT}/docs/mcp-tool-reference.md\` for correct tool usage patterns.

## Input

You receive:
- **Task description** — what to research/analyze
- **Context** — relevant background information

## Process

### 1. Gather Data

Collect relevant information from available sources.

### 2. Analyze

Process and structure the findings.

### 3. Return Results

Return structured summary in the output format below.

## Output Format

\`\`\`
## Example Agent Results

### Findings
- {finding 1}
- {finding 2}

### Key Insights
- {insight 1}
- {insight 2}
\`\`\`
EOF

# --- MCP tool reference (copy from PM) ---

cat > "${PLUGIN_DIR}/docs/mcp-tool-reference.md" << 'EOF'
# MCP Tool Reference — Correct Usage Patterns

**CRITICAL: Always use ToolSearch to load tool schemas before first MCP call in a session.**

---

## Jira

### Search issues (JQL)

```
Tool:  mcp__jira__jira_post
Path:  /rest/api/3/search/jql
Body:  {"jql": "project=PROJ ORDER BY created DESC", "maxResults": 10, "fields": ["summary", "status", "assignee", "priority"]}
```

- **POST, not GET** — `/rest/api/3/search/jql` is POST-only
- **Always include `fields`** — without it, response contains only `id`
- `/rest/api/3/search` is **REMOVED** (HTTP 410) — never use it

### Get single issue

```
Tool:  mcp__jira__jira_get
Path:  /rest/api/3/issue/{issueKey}
```

### Get issue comments

```
Tool:  mcp__jira__jira_get
Path:  /rest/api/3/issue/{issueKey}/comment
```

---

## Confluence

### Search content (CQL)

```
Tool:  mcp__confluence__conf_get
Path:  /wiki/rest/api/search
QueryParams:  {"cql": "type=page AND space=PROJ AND text~\"search term\"", "limit": "10"}
```

### Get page with body

```
Tool:  mcp__confluence__conf_get
Path:  /wiki/api/v2/pages/{pageId}
QueryParams:  {"body-format": "storage"}
```

- **Use `queryParams`, NOT `params`** — `params` is silently ignored
- **Body is on the page endpoint itself** — `/wiki/api/v2/pages/{id}/body` returns 404

---

## Sentry

```
Tool:  mcp__sentry__list_issues
Query: "is:unresolved"
ProjectSlug: "project-name"
```

---

## GitHub

GitHub MCP provides high-level tools — use ToolSearch to discover available operations.

---

## Common Mistakes to Avoid

| Mistake | Correct |
|---------|---------|
| `jira_get /rest/api/3/search` | `jira_post /rest/api/3/search/jql` with body |
| `jira_post` without `fields` in body | Always include `"fields": [...]` |
| `conf_get` with `params: {...}` | Use `queryParams: {...}` |
| `conf_get /wiki/api/v2/pages/{id}/body` | `conf_get /wiki/api/v2/pages/{id}` + `queryParams: {"body-format": "storage"}` |
| Calling MCP tools without ToolSearch first | Always load schemas first |
EOF

# --- MCP status check script ---

cat > "${PLUGIN_DIR}/scripts/check-mcp-status.sh" << SCRIPT
#!/usr/bin/env bash
# ${PLUGIN_NAME} Plugin — MCP Status Check

set -euo pipefail

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
BOLD="\033[1m"
RESET="\033[0m"

CONFIG_FILES=(
  "\$HOME/.claude/settings.json"
  "\$HOME/.claude/settings.local.json"
  "\$HOME/.claude.json"
)

if [ -f ".claude/settings.json" ]; then
  CONFIG_FILES+=(".claude/settings.json")
fi
if [ -f ".claude/settings.local.json" ]; then
  CONFIG_FILES+=(".claude/settings.local.json")
fi

check_var() {
  local name="\$1"
  if [ -n "\${!name:-}" ]; then echo "ok"; return; fi
  for cfg in "\${CONFIG_FILES[@]}"; do
    if [ -f "\$cfg" ]; then
      local val
      val=\$(python3 -c "
import json
try:
    d = json.load(open('\$cfg'))
    v = d.get('env', {}).get('\$name', '')
    print(v)
except:
    print('')
" 2>/dev/null)
      if [ -n "\$val" ]; then echo "ok"; return; fi
    fi
  done
  echo "missing"
}

status_icon() {
  local all_ok=true any_ok=false
  for v in "\$@"; do
    if [ "\$v" = "ok" ]; then any_ok=true; else all_ok=false; fi
  done
  if \$all_ok; then echo -e "\${GREEN}✅ ready\${RESET}"
  elif \$any_ok; then echo -e "\${YELLOW}⚠️  partial\${RESET}"
  else echo -e "\${RED}❌ not configured\${RESET}"
  fi
}

missing_list() {
  local missing=()
  for name in "\$@"; do
    local val
    val=\$(check_var "\$name")
    if [ "\$val" = "missing" ]; then missing+=("\$name"); fi
  done
  if [ \${#missing[@]} -gt 0 ]; then
    echo "              missing: \${missing[*]}"
  fi
}

jira_site=\$(check_var "ATLASSIAN_JIRA_SITE_NAME")
jira_email=\$(check_var "ATLASSIAN_USER_EMAIL")
jira_token=\$(check_var "ATLASSIAN_API_TOKEN")
conf_site=\$(check_var "ATLASSIAN_CONFLUENCE_SITE_NAME")
sentry_token=\$(check_var "SENTRY_ACCESS_TOKEN")
sentry_org=\$(check_var "SENTRY_ORG")
github_token=\$(check_var "GITHUB_PERSONAL_ACCESS_TOKEN")

jira_status=\$(status_icon "\$jira_site" "\$jira_email" "\$jira_token")
conf_status=\$(status_icon "\$conf_site" "\$jira_email" "\$jira_token")
sentry_status=\$(status_icon "\$sentry_token" "\$sentry_org")
github_status=\$(status_icon "\$github_token")

echo ""
echo -e "\${BOLD}📋 ${PLUGIN_NAME} Plugin — MCP Connectors\${RESET}"
echo ""
echo -e "  Jira          \$jira_status"
[ "\$jira_site" = "missing" ] || [ "\$jira_email" = "missing" ] || [ "\$jira_token" = "missing" ] && \\
  missing_list ATLASSIAN_JIRA_SITE_NAME ATLASSIAN_USER_EMAIL ATLASSIAN_API_TOKEN
echo -e "  Confluence    \$conf_status"
[ "\$conf_site" = "missing" ] || [ "\$jira_email" = "missing" ] || [ "\$jira_token" = "missing" ] && \\
  missing_list ATLASSIAN_CONFLUENCE_SITE_NAME ATLASSIAN_USER_EMAIL ATLASSIAN_API_TOKEN
echo -e "  Sentry        \$sentry_status"
[ "\$sentry_token" = "missing" ] || [ "\$sentry_org" = "missing" ] && \\
  missing_list SENTRY_ACCESS_TOKEN SENTRY_ORG
echo -e "  GitHub        \$github_status"
[ "\$github_token" = "missing" ] && missing_list GITHUB_PERSONAL_ACCESS_TOKEN
echo ""
SCRIPT

chmod +x "${PLUGIN_DIR}/scripts/check-mcp-status.sh"

# --- Overview doc ---

cat > "${PLUGIN_DIR}/docs/overview.md" << EOF
# ${PLUGIN_NAME} Plugin — Overview

${PLUGIN_DESC}

## Компоненти

| Тип | Назва | Опис |
|-----|-------|------|
| Command | [/${PLUGIN_NAME}:hello](../commands/hello.md) | Example command (replace) |
| Agent | [example-agent](../agents/example-agent.md) | Example agent (replace) |
| MCP | Jira, Confluence, Sentry, Git | Зовнішні інтеграції ([.mcp.json](../.mcp.json)) |

## Артефакти

Всі артефакти зберігаються в \`.workflows/{feature-id}/${PLUGIN_NAME}/\`:

| Артефакт | Створює | Читає |
|----------|---------|-------|
| \`example-output.md\` | /${PLUGIN_NAME}:hello | Other plugins |

## Вимоги

### MCP (опціонально)

Плагін працює і без MCP — в режимі pure dialogue. З MCP отримує контекст автоматично.

Запустіть \`/${PLUGIN_NAME}:setup\` або \`/pm:setup\` для налаштування MCP конекторів.
EOF

# --- Register in marketplace.json ---

MARKETPLACE="${ROOT_DIR}/.claude-plugin/marketplace.json"
if [ -f "$MARKETPLACE" ]; then
  python3 -c "
import json
with open('${MARKETPLACE}') as f:
    data = json.load(f)

# Check if already registered
for p in data.get('plugins', []):
    if p['name'] == '${PLUGIN_NAME}':
        print('Already registered in marketplace.json')
        exit(0)

data.setdefault('plugins', []).append({
    'name': '${PLUGIN_NAME}',
    'source': './plugins/${PLUGIN_NAME}',
    'description': '${PLUGIN_DESC}',
    'version': '0.1.0'
})

with open('${MARKETPLACE}', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')

print('Registered in marketplace.json')
"
fi

# --- Summary ---

echo ""
echo -e "${GREEN}✅ Plugin '${PLUGIN_NAME}' created successfully!${RESET}"
echo ""
echo -e "${BOLD}Structure:${RESET}"
echo "  plugins/${PLUGIN_NAME}/"
echo "  ├── .claude-plugin/plugin.json   # Plugin manifest"
echo "  ├── .mcp.json                    # MCP server config"
echo "  ├── hooks/hooks.json             # Hooks (empty)"
echo "  ├── agents/example-agent.md      # Example agent"
echo "  ├── commands/hello.md            # Example command"
echo "  ├── skills/                      # Skills (empty)"
echo "  ├── scripts/check-mcp-status.sh  # MCP status checker"
echo "  ├── docs/"
echo "  │   ├── overview.md              # Plugin overview"
echo "  │   └── mcp-tool-reference.md    # MCP usage patterns"
echo "  └── CHANGELOG.md                 # Version history"
echo ""
echo -e "${BOLD}Next steps:${RESET}"
echo "  1. Edit commands/hello.md → your first real command"
echo "  2. Edit agents/example-agent.md → your first real agent"
echo "  3. Remove MCP servers you don't need from .mcp.json"
echo "  4. Read docs/plugin-development-guide.md for full guide"
echo ""
