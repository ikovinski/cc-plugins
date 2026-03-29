# PM Plugin — Overview

PM плагін для Claude Code. Допомагає Product Manager уточнювати задачі, оцінювати складність та верифікувати acceptance criteria — з інтеграцією Jira, Confluence, Sentry, Git.

## Компоненти

| Тип | Назва | Опис |
|-----|-------|------|
| Agent | [task-refiner](../agents/task-refiner.md) | Уточнення задач через діалог з PM (Opus) |
| Agent | [estimator](../agents/estimator.md) | Оцінка складності на основі даних (Sonnet) |
| Command | [/pm:refine](../commands/refine.md) | Точка входу для refinement |
| Command | [/pm:estimate](../commands/estimate.md) | Точка входу для estimation |
| Command | [/pm:accept](../commands/accept.md) | Верифікація acceptance criteria |
| Skill | [story-formats](../skills/story-formats/SKILL.md) | User Story, Job Story, WWA, INVEST, AC patterns |
| Skill | [estimation](../skills/estimation/SKILL.md) | T-shirt sizing, hour ranges, confidence levels |
| MCP | Jira, Confluence, Sentry, Git | Зовнішні інтеграції ([.mcp.json](../.mcp.json)) |

## Flow

```
                    ┌─────────────┐
                    │  Вхід задачі │
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
        Jira issue    Raw text    Sentry triage
        PROJ-123      "add X"    --from file.md
              └────────────┬────────────┘
                           │
                    ┌──────▼──────┐
                    │ /pm:refine  │
                    │             │
                    │ 1. Context  │◄── Jira, Confluence, Sentry, Git, codebase
                    │ 2. Questions│◄── Interactive dialogue with PM
                    │ 3. Generate │
                    └──────┬──────┘
                           │
                    refined-task.md
                           │
                    ┌──────▼───────┐
                    │ /pm:estimate │
                    │              │
                    │ Complexity   │◄── Jira history, codebase scan
                    │ matrix       │
                    └──────┬───────┘
                           │
                    estimation.md
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
        /dev:research  /qa:test-plan   Save
        (Dev плагін)   (QA плагін)     for later
              │            │
              ▼            ▼
        ... development cycle ...
              │            │
              └────────┬───┘
                       │
                ┌──────▼──────┐
                │ /pm:accept  │
                │             │
                │ Check AC vs │◄── Dev artifacts, QA results, Sentry
                │ implementation│
                └──────┬──────┘
                       │
                acceptance-report.md
                       │
              ┌────────┼────────┐
              ▼        ▼        ▼
           ACCEPTED  REJECTED  NEEDS REVIEW
```

## Артефакти

Всі артефакти зберігаються в `.workflows/{feature-id}/pm/`:

| Артефакт | Створює | Читає |
|----------|---------|-------|
| `refined-task.md` | /pm:refine | Dev (/dev:research), QA (/qa:test-plan) |
| `estimation.md` | /pm:estimate | Dev (для планування), PM (для sprint planning) |
| `acceptance-report.md` | /pm:accept | PM (фінальне рішення) |

## Вимоги

### MCP (опціонально, але рекомендовано)

Плагін працює і без MCP — в режимі pure dialogue. З MCP отримує контекст автоматично.

```bash
# Environment variables для MCP
export JIRA_URL="https://company.atlassian.net"
export JIRA_TOKEN="your-token"
export JIRA_USER_EMAIL="you@company.com"
export CONFLUENCE_URL="https://company.atlassian.net/wiki"
export CONFLUENCE_TOKEN="your-token"
export CONFLUENCE_USER_EMAIL="you@company.com"
export SENTRY_TOKEN="your-token"
export SENTRY_ORG="your-org"
export GITHUB_TOKEN="your-token"
```

### Без проєкту

PM може працювати без клонованого репозиторію. В цьому випадку:
- Codebase scan пропускається
- Контекст береться з Jira/Confluence
- Артефакти зберігаються в поточній директорії
