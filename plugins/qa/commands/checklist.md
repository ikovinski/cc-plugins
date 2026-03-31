---
name: checklist
description: "QA checklist generator — reads feature description from any format (PDF, images, text, URL, Jira issue, Confluence page) and generates a structured test checklist."
allowed_tools: ["Read", "Write", "Glob", "Grep", "Bash", "WebFetch", "Agent", "AskUserQuestion", "mcp__jira__jira_get", "mcp__jira__jira_post", "mcp__confluence__conf_get"]
triggers:
  - "checklist"
  - "qa checklist"
  - "чеклист"
  - "зроби чеклист"
---

# /qa:checklist — QA Checklist Generator

Читає опис фічі з файлів, URL, Jira або Confluence та генерує структурований QA-чеклист з використанням технік тест-дизайну.

## Usage

```bash
# Локальні файли
/qa:checklist path/to/feature.pdf
/qa:checklist spec.pdf mockup.png

# URL
/qa:checklist https://confluence.example.com/feature-description

# Inline текст
/qa:checklist "Юзер може завантажити аватар. Формати: JPG, PNG. Макс розмір: 5MB."

# Jira issue (MCP)
/qa:checklist PROJ-123

# Confluence page (MCP)
/qa:checklist --confluence "Feature Spec Page Title"

# З явним feature-id
/qa:checklist --id user-avatar path/to/spec.pdf

# Комбінація
/qa:checklist --id payment-refund spec.pdf PROJ-123

# З існуючого workflow (PM артефакт)
/qa:checklist --from .workflows/apple-health-sync/pm/refined-task.md
```

## Supported Input Formats

| Format | How | Source |
|--------|-----|--------|
| `.pdf` | Read (native Claude PDF support) | Local |
| `.png`, `.jpg`, `.jpeg`, `.webp`, `.gif` | Read (native Claude vision) | Local |
| `.md`, `.txt` | Read | Local |
| URL | WebFetch | Remote |
| Jira issue (`PROJ-123`) | MCP: `mcp__jira__jira_get` | MCP |
| Confluence page (`--confluence "Title"`) | MCP: `mcp__confluence__conf_get` | MCP |
| PM artifact (`--from path`) | Read | Local |
| Inline text | Direct from command argument | Inline |

## MCP Tool Reference

**BEFORE making any MCP calls**, read `${CLAUDE_PLUGIN_ROOT}/docs/mcp-tool-reference.md` for correct tool usage patterns.

## Execution

### Step 1: Parse Arguments

З аргументу команди визнач:
- `--id {name}` → feature-id (опціонально)
- `--from {path}` → шлях до PM артефакту
- `--confluence "Title"` → назва Confluence сторінки для пошуку
- Jira key (паттерн `[A-Z]+-\d+`) → fetch через MCP
- Шляхи до файлів (абсолютні або відносні від CWD проєкту)
- URL (рядки що починаються з `http://` або `https://`)
- Inline text (все що залишилось і не є флагом або шляхом)

Визнач `feature-id`:
- Якщо передано `--id {name}` — використовуй його
- Якщо є Jira key — використовуй його як основу (напр. `proj-123`)
- Інакше — виведи kebab-case назву з першого файлу або тексту

### Step 2: Check MCP & Read Sources

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-mcp-status.sh"
```

Прочитай всі вхідні джерела:

**Локальні файли:**
- файли → `Read`
- `--from` artifact → `Read`

**URL:**
- URL → `WebFetch`

**MCP (якщо доступний):**

Jira issue:
```
Tool:  mcp__jira__jira_get
Path:  /rest/api/3/issue/{issueKey}
```

Jira comments (часто містять критичні рішення):
```
Tool:  mcp__jira__jira_get
Path:  /rest/api/3/issue/{issueKey}/comment
```

Confluence page search:
```
Tool:  mcp__confluence__conf_get
Path:  /wiki/rest/api/search
QueryParams:  {"cql": "type=page AND text~\"Page Title\"", "limit": "5"}
```

Then read page body:
```
Tool:  mcp__confluence__conf_get
Path:  /wiki/api/v2/pages/{pageId}
QueryParams:  {"body-format": "storage"}
```

**PM артефакти (автоматично):**
- Перевір чи існує `.workflows/{feature-id}/pm/refined-task.md` → якщо так, прочитай як додаткове джерело контексту (acceptance criteria, обмеження, бізнес-контекст)

Якщо файл не знайдено або не підтримується — повідом у секції `## Warnings` в output і продовжуй з доступними даними.

Додатково прочитай вміст директорії `docs/` (якщо є) — для розуміння контексту існуючих фічей.

### Step 3: Detect Platform

Чеклист генерується для **однієї** платформи. Визнач її: iOS / Android / Backend.
Якщо невідомо — запитай через AskUserQuestion і чекай на відповідь перед продовженням.

> Якщо фіча охоплює кілька платформ — запусти `/qa:checklist` окремо для кожної.

### Step 4: QA Engineer — Generate Checklist

Прочитай агента:

```
Read ${CLAUDE_PLUGIN_ROOT}/agents/qa-engineer.md
```

Виконай його Process повністю:
1. Аналіз фічі
2. Вибір технік тест-дизайну
3. Генерація чеклисту

### Step 5: Quality Gate

Після генерації чеклисту, ТИ (Claude) виступаєш як **QA Team Lead** і перевіряєш результат:
- Правильні техніки обрані для типу фічі?
- Обов'язкові Checklist-based Testing перевірки включені?
- Кожна перевірка конкретна і actionable (не розмита)?
- Expected result присутній для кожної перевірки?

Якщо є зауваження — надай конкретний фідбек QA Engineer і запроси виправлення. Повторюй до затвердження.

### Step 6: Save File

```bash
mkdir -p .workflows/{feature-id}/qa
```

Збережи результат у `.workflows/{feature-id}/qa/checklist.md` з frontmatter:

```markdown
---
plugin: qa
artifact: checklist
feature: {feature-id}
created: {ISO 8601 timestamp}
source:
  jira: {key if applicable}
  confluence: {page id if applicable}
  files: [{list of input files}]
depends_on:
  - pm/refined-task (if used)
---
```

### Step 7: Report to User

```markdown
# QA Checklist Ready: {feature-id}

**File:** `.workflows/{feature-id}/qa/checklist.md`
**Total checks:** {N}
**Platform:** {iOS / Android / Backend}
**Test Design Techniques:** {перелік технік що були використані}

{якщо є Open Questions}
**Open Questions:** {N} — перевір секцію `## Open Questions` у файлі перед початком тестування

{якщо є Warnings}
**Warnings:** {список проблем з читанням файлів}

Next steps:
  a) Review & edit checklist manually
  b) /qa:checklist --id {feature-id} {додаткові джерела} — доповнити чеклист
  c) /dev:research {feature-id} — start technical research (Dev plugin)
```

## Graceful Degradation

| Source | Available | Not Available |
|--------|-----------|---------------|
| Jira | Fetch issue + comments як джерело опису | Ask user for task description |
| Confluence | Search & read spec pages | Skip; rely on provided files/text |
| PM artifact | Auto-read refined-task.md for AC & context | Skip; more questions to user |
| Local files | Read PDF, images, markdown | Flag in Warnings |
| URL | WebFetch page content | Flag in Warnings |

**When degraded:** explicitly tell user what context is missing:

```
⚠️ Jira не підключений — не можу автоматично прочитати issue.
   Надайте опис фічі як текст, файл або URL.
   Підключити: /qa:setup
```

## Notes

- Зображення (wireframes, mockups, screenshots) читаються нативно — Claude бачить UI і витягує сценарії
- PDF читаються нативно — включно з таблицями та схемами
- Якщо опис фічі неповний — чеклист буде з `Open Questions` замість вигаданих сценаріїв
- Можна передати кілька джерел одночасно — агент синтезує їх в єдиний чеклист
