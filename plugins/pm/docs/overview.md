# PM Plugin — Overview

PM плагін для Claude Code. Допомагає Product Manager уточнювати задачі, оцінювати складність та верифікувати acceptance criteria — з інтеграцією Jira, Confluence, Sentry, Git.

> **Перший раз?** Дивись [Getting Started](../../../docs/getting-started.md) — встановлення через UI за 5 хвилин.

## Компоненти

| Тип | Назва | Опис |
|-----|-------|------|
| Agent | [task-refiner](../agents/task-refiner.md) | Уточнення задач через діалог з PM (Opus) |
| Agent | [estimator](../agents/estimator.md) | Оцінка складності на основі даних (Sonnet) |
| Agent | [challenger](../agents/challenger.md) | Stress-test задачі через 6 перспектив (Opus) |
| Agent | [codebase-explorer](../agents/codebase-explorer.md) | PM-friendly карта проєкту — local або GitHub (Sonnet) |
| Command | [/pm:refine](../commands/refine.md) | Уточнення задачі (включає auto-challenge) |
| Command | [/pm:challenge](../commands/challenge.md) | Глибока перевірка задачі на життєздатність |
| Command | [/pm:estimate](../commands/estimate.md) | Оцінка складності |
| Command | [/pm:accept](../commands/accept.md) | Верифікація acceptance criteria |
| Command | [/pm:codebase](../commands/codebase.md) | PM-friendly карта проєкту (local/remote) |
| Command | [/pm:setup](../commands/setup.md) | Налаштування MCP інтеграцій |
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
                    ┌──────▼──────────────┐
                    │ /pm:refine          │
                    │                     │
                    │ 0. Analysis &       │──► Show PM: tools, queries, plan
                    │    Transparency     │
                    │                     │
                    │ 1. Deep Context     │◄── Jira, Confluence, Sentry, Git, codebase
                    │    Gathering        │    (exhaust ALL sources)
                    │                     │
                    │ 2. Findings &       │──► Hypotheses PM didn't consider
                    │    Hypotheses       │    Contradictions between sources
                    │                     │
                    │ 3. Targeted         │◄── Only what sources didn't answer
                    │    Questions        │    Each with context WHY asking
                    │                     │
                    │ 4. Auto-Challenge   │──► 6 lenses quick check
                    │    (lightweight)    │    Catch obvious gaps
                    │                     │
                    │ 5. Generate with    │──► Evidence trail per requirement
                    │    Evidence Trail   │    + challenge findings included
                    └──────┬──────────────┘
                           │
                    refined-task.md (+ readiness score)
                           │
                ┌──────────┼──────────┐
                ▼                     ▼
         ┌──────────────┐     ┌──────────────┐
         │ /pm:challenge │     │ /pm:estimate │
         │ (optional,    │     │              │
         │  for L/XL)    │     │ Complexity   │◄── Jira history
         │               │     │ matrix       │
         │ Deep 6-lens   │     └──────┬───────┘
         │ stress-test   │            │
         └──────┬────────┘     estimation.md
                │                     │
         challenge-report.md          │
                │                     │
                └──────────┬──────────┘
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

# Jira (site name — subdomain від your-site.atlassian.net)
export ATLASSIAN_JIRA_SITE_NAME="your-jira-site"
export ATLASSIAN_USER_EMAIL="you@company.com"
export ATLASSIAN_API_TOKEN="your-atlassian-api-token"

# Confluence (може бути інший site ніж Jira)
export ATLASSIAN_CONFLUENCE_SITE_NAME="your-confluence-site"

# Sentry
export SENTRY_ACCESS_TOKEN="your-sentry-token"
export SENTRY_ORG="your-org"

# GitHub
export GITHUB_PERSONAL_ACCESS_TOKEN="your-github-pat"
```

### Без проєкту

PM може працювати без клонованого репозиторію. В цьому випадку:
- Codebase scan пропускається
- Контекст береться з Jira/Confluence
- Артефакти зберігаються в поточній директорії
