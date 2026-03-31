# Як написати свій плагін для CC Plugins

Покроковий гайд для створення нового плагіна — від scaffolding до реєстрації в marketplace.

---

## Швидкий старт

```bash
# Створити новий плагін з усіма файлами
./scripts/create-plugin.sh my-plugin "My plugin — does amazing things"

# Результат:
# plugins/my-plugin/
# ├── .claude-plugin/plugin.json
# ├── .mcp.json
# ├── hooks/hooks.json
# ├── agents/example-agent.md
# ├── commands/hello.md
# ├── skills/
# ├── scripts/check-mcp-status.sh
# ├── docs/
# └── CHANGELOG.md
```

Скрипт також реєструє плагін у `marketplace.json`.

---

## Анатомія плагіна

### Обов'язкові файли

| Файл | Що робить |
|------|-----------|
| `.claude-plugin/plugin.json` | Маніфест — ім'я, версія, опис, посилання на hooks та MCP |
| `.mcp.json` | Конфігурація MCP серверів (Jira, Confluence, Sentry, GitHub) |
| `CHANGELOG.md` | Історія змін (Keep a Changelog формат) |

### Опціональні директорії

| Директорія | Що містить |
|------------|-----------|
| `commands/` | Slash-команди (`/plugin:command`) — кожна в окремому .md файлі |
| `agents/` | AI агенти (sub-agents) — персони для делегування задач |
| `skills/` | Довідкові матеріали — frameworks, templates, checklists |
| `docs/` | Документація плагіна |
| `scripts/` | Shell скрипти (MCP status check, утиліти) |
| `hooks/` | Claude Code hooks конфігурація |

---

## Ключові компоненти

### 1. plugin.json — маніфест

```json
{
  "name": "my-plugin",
  "version": "0.1.0",
  "description": "One-line description of what this plugin does.",
  "keywords": ["my-plugin", "relevant", "keywords"],
  "hooks": "./hooks/hooks.json",
  "mcpServers": "./.mcp.json"
}
```

**Правила:**
- `name` — kebab-case, унікальний в marketplace
- `version` — semver (0.1.0 → 0.2.0 → 1.0.0)
- `description` — коротко, зрозуміло для нового користувача
- `keywords` — для пошуку в marketplace

### 2. Команди (commands/)

Команда — це Markdown файл з frontmatter та інструкціями для Claude.

```markdown
---
name: analyze
description: "Analyze production issues and generate report."
allowed_tools: ["Read", "Grep", "Glob", "Write", "Agent", "mcp__sentry__*"]
triggers:
  - "analyze"
  - "аналіз"
---

# /my-plugin:analyze — Аналіз

## Usage

\`\`\`bash
/my-plugin:analyze PROJ-123
/my-plugin:analyze "описання проблеми"
\`\`\`

## Process

### Step 1 — Перевірити MCP

\`\`\`bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-mcp-status.sh"
\`\`\`

### Step 2 — Зібрати контекст

...інструкції для Claude...

### Step 3 — Згенерувати артефакт

Зберегти результат у `.workflows/{feature-id}/my-plugin/analysis.md`

## Graceful Degradation

| Source | Available | Not Available |
|--------|-----------|---------------|
| Sentry | Deep analysis | Ask user for details |
```

**Ключові поля frontmatter:**

| Поле | Обов'язкове | Опис |
|------|-------------|------|
| `name` | Так | Ім'я команди (стає `/{plugin}:{name}`) |
| `description` | Так | Для пошуку та discovery |
| `allowed_tools` | Так | Які tools Claude може використовувати |
| `triggers` | Ні | Слова що активують команду |

**Патерни allowed_tools:**
- `"mcp__jira__*"` — всі Jira MCP tools
- `"mcp__sentry__list_issues"` — конкретний tool
- `"Agent"` — можливість запускати sub-agents

### 3. Агенти (agents/)

Агент — це Markdown файл з персоною та інструкціями для sub-agent.

```markdown
---
name: data-collector
description: "Sub-agent for collecting metrics from multiple sources."
model: sonnet
maxTurns: 15
allowed_tools: ["Read", "mcp__jira__jira_get", "mcp__sentry__list_issues"]
---

# Data Collector

## Identity

You are a focused data collection agent. Your ONLY job is to
gather metrics and return structured data. No analysis, no opinions.

## MCP Tool Reference

**CRITICAL: Read before making any calls.**
Read `${CLAUDE_PLUGIN_ROOT}/docs/mcp-tool-reference.md`

## Input

You receive: task description with context.

## Process

### 1. Collect
...

### 2. Structure
...

## Output Format

\`\`\`
## Data Collection Results

### Source: Jira
- {data points}

### Source: Sentry
- {data points}
\`\`\`
```

**Ключові поля frontmatter:**

| Поле | Обов'язкове | Опис |
|------|-------------|------|
| `name` | Так | Ім'я агента |
| `description` | Так | Що робить (для вибору правильного агента) |
| `model` | Так | `sonnet` для data collection, `opus` для analysis/orchestration |
| `maxTurns` | Ні | Ліміт ітерацій (default: 10) |
| `allowed_tools` | Так | Обмежений набір tools |

**Коли який model:**

| Model | Коли використовувати | Приклади |
|-------|---------------------|----------|
| `sonnet` | Data collection, простий аналіз, пошук | jira-researcher, codebase-scanner |
| `opus` | Складний аналіз, гіпотези, оркестрація | task-refiner, challenger |

### 4. Skills (skills/)

Skill — це довідковий матеріал (framework, template, checklist) який Claude завантажує за потреби.

```
skills/
└── my-framework/
    └── SKILL.md
```

```markdown
---
name: my-framework
description: "Framework for X — dimensions, levels, templates."
---

# My Framework

## Table

| Dimension | Low | Medium | High |
|-----------|-----|--------|------|
| ...       | ... | ...    | ...  |

## Templates

\`\`\`
| Field | Value |
|-------|-------|
| ...   | ...   |
\`\`\`
```

Skills — це **пасивні довідники**, не активні інструкції. Команди та агенти посилаються на skills коли потрібен framework.

### 5. .mcp.json — MCP конфігурація

```json
{
  "mcpServers": {
    "jira": { ... },
    "confluence": { ... },
    "sentry": { ... },
    "github": { ... }
  }
}
```

**Правила:**
- Використовуй стандартні імена серверів: `jira`, `confluence`, `sentry`, `github`
- Env vars через `${VAR_NAME}` — Claude Code підставляє з `~/.claude/settings.json`
- Видали сервери які плагін не використовує (менше startup overhead)

---

## Артефакти та комунікація між плагінами

Плагіни **ізольовані**. Спілкування — через файлові артефакти:

```
.workflows/{feature-id}/
├── state.json              # Стан workflow
├── pm/refined-task.md      # PM → Dev, QA
├── dev/architecture.md     # Dev → QA
├── qa/test-plan.md         # QA артефакт
└── my-plugin/output.md     # Твій плагін
```

### Формат артефакту

```markdown
---
plugin: my-plugin
artifact: analysis-report
feature: apple-health-sync
created: 2026-03-31T10:00:00Z
source:
  jira: PROJ-123
---

# Зміст артефакту...
```

### Правила артефактів

1. **Пиши тільки у свою директорію** — `my-plugin/` тільки в `.workflows/{id}/my-plugin/`
2. **Читай будь-які артефакти** — можна читати `pm/`, `dev/`, `qa/`
3. **Не видаляй чужі артефакти**
4. **Frontmatter обов'язковий** — plugin, artifact, feature, created
5. **Graceful degradation** — якщо залежний артефакт відсутній, працюй з тим що є

---

## Патерни з PM плагіна

### Паралельний збір контексту

PM запускає 4 sub-agents одночасно:

```
Command (/pm:refine) → orchestrator
  ├── Agent: jira-researcher     (Sonnet, parallel)
  ├── Agent: confluence-researcher (Sonnet, parallel)
  ├── Agent: sentry-researcher   (Sonnet, parallel)
  └── Agent: codebase-scanner    (Sonnet, parallel)
```

Orchestrator (Opus) аналізує зібрані дані, генерує гіпотези, веде діалог.

### Graceful degradation

Кожна команда перевіряє MCP на старті та адаптується:

```
⚠️ Працюю без Confluence — не можу перевірити чи є специфікація.
   Рекомендую підключити: /pm:setup confluence
```

### ${CLAUDE_PLUGIN_ROOT}

Завжди використовуй `${CLAUDE_PLUGIN_ROOT}` для посилань на файли плагіна:

```markdown
Read `${CLAUDE_PLUGIN_ROOT}/docs/mcp-tool-reference.md`
bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-mcp-status.sh"
```

Це працює коли плагін запускається з cache, не з оригінальної директорії.

### MCP Tool Reference

**Кожен агент/команда що використовує MCP** повинен мати посилання на `docs/mcp-tool-reference.md`. Це запобігає типовим помилкам (GET замість POST для Jira search, `params` замість `queryParams` для Confluence).

---

## Checklist готовності плагіна

### Мінімум для v0.1.0

- [ ] `plugin.json` з коректним name, version, description
- [ ] `.mcp.json` — тільки потрібні сервери
- [ ] `CHANGELOG.md` — перший запис
- [ ] Хоча б одна команда в `commands/`
- [ ] `docs/overview.md` — що робить плагін
- [ ] `docs/mcp-tool-reference.md` — якщо є MCP
- [ ] `scripts/check-mcp-status.sh` — якщо є MCP
- [ ] Зареєстровано в `marketplace.json`

### Перед v1.0.0

- [ ] Всі команди мають Graceful Degradation таблицю
- [ ] Агенти мають обмежені `allowed_tools` (principle of least privilege)
- [ ] MCP Tool Reference вбудований в кожного агента
- [ ] `hooks.json` налаштований (якщо потрібен onboarding UX)
- [ ] Артефакти відповідають контракту з `docs/artifact-contracts.md`
- [ ] Тестування: кожна команда перевірена з MCP та без
- [ ] `CHANGELOG.md` актуальний

---

## FAQ

### Мій плагін не потребує всіх MCP серверів

Видали непотрібні з `.mcp.json`. Наприклад, QA плагін може потребувати тільки Jira та Sentry.

### Як додати свій MCP сервер?

Додай в `.mcp.json` під новим ім'ям. Env vars — через `${VAR_NAME}`. Задокументуй в `docs/mcp-tool-reference.md`.

### Як зв'язати команди між собою?

Через артефакти. Перша команда пише файл, друга — читає:

```
/my-plugin:collect → .workflows/{id}/my-plugin/raw-data.md
/my-plugin:analyze → reads raw-data.md → writes analysis.md
```

### Як запустити sub-agent з команди?

В команді вкажіть `"Agent"` в `allowed_tools`, потім:

```markdown
Launch agent from `${CLAUDE_PLUGIN_ROOT}/agents/my-agent.md` with task:
"Collect data for {task description}"
```

### Де зберігати env vars?

`~/.claude/settings.json` → секція `env`. Claude Code читає при кожному запуску.
