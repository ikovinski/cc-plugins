# Контракти спільних артефактів

Плагіни ізольовані один від одного. Спілкування між ними відбувається через **файлові артефакти** зі стандартизованим форматом та розташуванням.

## Структура .workflows/

```
{project}/.workflows/{feature-id}/
├── state.json              # Стан workflow (хто що зробив, поточна фаза)
├── pm/                     # Артефакти PM плагіна
│   ├── refined-task.md     # Уточнена задача
│   └── estimation.md       # Оцінка складності
├── dev/                    # Артефакти Dev плагіна
│   ├── research-report.md  # Результати дослідження
│   ├── architecture.md     # Архітектурні рішення
│   ├── diagrams.md         # C4, dataflow, sequence діаграми
│   ├── adr/                # Architecture Decision Records
│   │   └── {NNN}-{title}.md
│   ├── api-contracts.md    # API контракти
│   ├── plan-overview.md    # Огляд плану імплементації
│   ├── phase-{N}.md        # План окремої фази
│   └── phase-{N}-report.md # Звіт по імплементації фази
├── qa/                     # Артефакти QA плагіна
│   ├── test-plan.md        # Стратегія тестування
│   ├── test-cases.md       # Тест-кейси
│   └── regression-report.md # Звіт по регресії
└── ops/                    # Артефакти Ops плагіна
    └── triage-report.md    # Звіт по Sentry triage
```

## state.json

```json
{
  "featureId": "apple-health-sync",
  "createdAt": "2026-03-29T10:00:00Z",
  "source": {
    "type": "jira",
    "key": "PROJ-123",
    "url": "https://company.atlassian.net/browse/PROJ-123"
  },
  "phases": {
    "pm:refine": { "status": "completed", "completedAt": "2026-03-29T10:15:00Z" },
    "pm:estimate": { "status": "completed", "completedAt": "2026-03-29T10:20:00Z" },
    "dev:research": { "status": "completed", "completedAt": "2026-03-29T11:00:00Z" },
    "dev:design": { "status": "in_progress" },
    "dev:plan": { "status": "pending" },
    "dev:implement": { "status": "pending" },
    "qa:test-plan": { "status": "pending" },
    "qa:test-cases": { "status": "pending" },
    "dev:pr": { "status": "pending" }
  },
  "complexity": "medium"
}
```

## Формат артефактів

Кожен артефакт — Markdown файл з YAML frontmatter:

```markdown
---
plugin: pm
artifact: refined-task
feature: apple-health-sync
created: 2026-03-29T10:15:00Z
source:
  jira: PROJ-123
  confluence: /spaces/PROJ/pages/12345
---

# Зміст артефакту...
```

### Обов'язкові поля frontmatter

| Поле | Опис |
|------|------|
| `plugin` | Який плагін створив (`pm`, `dev`, `qa`, `ops`) |
| `artifact` | Тип артефакту (`refined-task`, `research-report`, `test-plan`...) |
| `feature` | ID фічі (slug з feature-id) |
| `created` | ISO 8601 timestamp |

### Опціональні поля

| Поле | Опис |
|------|------|
| `source.jira` | Jira issue key |
| `source.confluence` | Confluence page path |
| `source.sentry` | Sentry issue ID |
| `depends_on` | Список артефактів, на основі яких створено |

## Контракти між плагінами

### PM → Dev

**refined-task.md** — вхідна точка для dev:research

```markdown
---
plugin: pm
artifact: refined-task
---

## Задача
{Що потрібно зробити}

## Контекст
{Бізнес-контекст, чому це потрібно}

## Acceptance Criteria
- [ ] AC1
- [ ] AC2

## Обмеження
{Технічні або бізнес обмеження}

## Пов'язані ресурси
- Jira: {key}
- Confluence: {url}
- Sentry issues: {list}
```

### PM → QA

**refined-task.md** (той самий файл) + **estimation.md**

QA використовує acceptance criteria для створення test plan.

### Dev → QA

**architecture.md** — контекст для тест-плану (які компоненти змінюються)

**phase-{N}-report.md** — що саме було змінено (для regression аналізу)

```markdown
---
plugin: dev
artifact: phase-report
phase: 1
---

## Змінені файли
- src/Service/AppleHealthSync.php (new)
- src/Entity/HealthRecord.php (modified)

## Нові endpoints
- POST /api/health/sync

## Нові message handlers
- SyncHealthDataHandler
```

### QA → Dev

**regression-report.md** — знайдені проблеми

```markdown
---
plugin: qa
artifact: regression-report
---

## Критичні
- [ ] {Опис проблеми} — severity: critical

## Важливі
- [ ] {Опис проблеми} — severity: major

## Незначні
- [ ] {Опис проблеми} — severity: minor
```

### Ops → PM/Dev

**triage-report.md** — production issues для пріоритезації

```markdown
---
plugin: ops
artifact: triage-report
---

## Critical (потребує негайної уваги)
| Sentry ID | Назва | Кількість | Вперше | Компонент |
|-----------|-------|-----------|--------|-----------|

## High (наступний спринт)
| ... |

## Medium (бэклог)
| ... |
```

## Правила

1. **Пиши тільки у свою директорію** — pm/ пише тільки в .workflows/{id}/pm/
2. **Читай будь-які артефакти** — qa/ може читати pm/ та dev/
3. **Не видаляй чужі артефакти** — тільки свої
4. **Frontmatter обов'язковий** — для трасування походження
5. **state.json оновлює той, хто завершив фазу** — кожен плагін оновлює свої фази
6. **Graceful degradation** — якщо артефакт-залежність відсутній, працюй з тим що є (prompt, Jira, тощо)
