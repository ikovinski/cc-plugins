# QA Plugin — Overview

QA плагін для Claude Code. Генерує структуровані тест-чеклісти з опису фічі будь-якого формату — PDF, зображення, текст, URL, Jira, Confluence.

> **Перший раз?** Дивись [Getting Started](../../../docs/getting-started.md) — встановлення через UI.

## Компоненти

| Тип | Назва | Опис |
|-----|-------|------|
| Command | [/qa:checklist](../commands/checklist.md) | Генерація QA чеклисту з будь-якого формату |
| Agent | [qa-engineer](../agents/qa-engineer.md) | QA Engineer — аналіз фічі, вибір технік, генерація перевірок (Sonnet) |
| Skill | [test-design-techniques](../skills/test-design-techniques/SKILL.md) | 7 технік тест-дизайну з прикладами та pre-defined checklists |
| MCP | Jira, Confluence, Sentry, Git | Зовнішні інтеграції ([.mcp.json](../.mcp.json)) |

## Flow

```
                    ┌─────────────────┐
                    │  Вхід: джерела  │
                    └──────┬──────────┘
                           │
              ┌────────────┼────────────┬──────────┐
              ▼            ▼            ▼          ▼
         Файли        Jira issue   Confluence    PM artifact
     PDF/PNG/MD...    PROJ-123     --confluence   --from
              └────────────┬────────────┴──────────┘
                           │
                    ┌──────▼──────────────┐
                    │ /qa:checklist       │
                    │                     │
                    │ 1. Parse & Read     │◄── All sources
                    │    Sources          │
                    │                     │
                    │ 2. Detect Platform  │──► iOS / Android / Backend
                    │                     │
                    │ 3. QA Engineer      │──► Analyse feature
                    │    Agent            │    Select techniques
                    │                     │    Generate checks
                    │                     │
                    │ 4. Quality Gate     │──► QA Team Lead review
                    │                     │    Concrete? Actionable?
                    │                     │
                    │ 5. Save & Report    │──► .workflows/{id}/qa/checklist.md
                    └─────────────────────┘
```

## Техніки тест-дизайну

| Техніка | Коли застосовувати |
|---------|-------------------|
| Equivalence Partitioning (EP) | Групи інпутів з однаковим результатом |
| Boundary Value Analysis (BVA) | Діапазони з лімітами |
| Decision Table | Кілька умов → різні результати |
| State Transition | Багатокроковий flow зі статусами |
| Pairwise | Багато параметрів з багатьма значеннями |
| Error Guessing | Завжди (інтуїція + досвід) |
| Checklist-based | Завжди (pre-defined per platform) |

## Артефакти

Всі артефакти зберігаються в `.workflows/{feature-id}/qa/`:

| Артефакт | Створює | Читає |
|----------|---------|-------|
| `checklist.md` | /qa:checklist | QA (manual testing), Dev (self-check) |

## Інтеграція з іншими плагінами

### PM → QA

`refined-task.md` — автоматично читається як додаткове джерело контексту (acceptance criteria, обмеження).

### Dev → QA

`architecture.md`, `phase-{N}-report.md` — контекст для regression аналізу (планується).

## Вимоги

### MCP (опціонально)

Плагін працює і без MCP — з локальними файлами, URL та inline текстом. З MCP отримує контекст з Jira/Confluence автоматично.

Запустіть `/pm:setup` для налаштування MCP конекторів.
