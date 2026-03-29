# PM Plugin — How It Works

Покрокові приклади використання кожної команди з реальним output.

---

## /pm:refine — Уточнення задачі

### Приклад 1: З Jira issue

```bash
/pm:refine PROJ-123
```

**Що відбувається:**

```
[1/3] 📋 Збираю контекст проекту...

Jira PROJ-123: "Add Apple Health data sync"
  ├─ Epic: PROJ-100 "Health Integrations"
  ├─ Priority: High
  ├─ Sprint: Sprint 24
  └─ Linked: PROJ-111 (Garmin sync — done)

Confluence: /spaces/PROJ/pages/Health+Integrations+Spec
  └─ Знайдена специфікація з data flow діаграмою

Sentry: 3 issues в модулі health-sync за останній тиждень
  └─ BODYFIT-A3F: "HealthKit permission denied" (12 events)

Codebase: знайдено аналогічну інтеграцію src/Service/GarminSync/
  └─ Патерн: OAuth → API polling → message queue → DB

Резюме: задача про синхронізацію даних Apple Health. Є аналог (Garmin),
специфікація в Confluence, та пов'язані production issues.
```

```
[2/3] 💬 Питання 1 з ~5

Які саме дані потрібно синхронізувати з Apple Health?

Варіанти:
  а) Тільки кроки та калорії — базовий набір як у Garmin
  б) Повний набір (кроки, калорії, пульс, сон, тренування) — максимальне покриття
  в) Вибіркові дані за налаштуваннями користувача — гнучкість
  г) Інше — розкажіть своїми словами
```

*PM відповідає: "б"*

```
[2/3] 💬 Питання 2 з ~5

Як часто має відбуватись синхронізація?

Варіанти:
  а) В реальному часі (при кожній зміні в Apple Health) — миттєве оновлення
  б) Періодично (кожні 15-30 хвилин) — баланс між свіжістю та ресурсами
  в) Вручну (користувач натискає "Sync") — мінімальне навантаження
  г) Інше
```

*PM відповідає: "б, але з можливістю ручної синхронізації"*

```
[2/3] 💬 Підтверджую розуміння

Якщо я правильно зрозумів:
- Синхронізуємо повний набір даних (кроки, калорії, пульс, сон, тренування)
- Автоматично кожні 15-30 хвилин + кнопка ручного sync
- За патерном Garmin інтеграції (OAuth → polling → queue → DB)

Все вірно?
  а) Так, продовжуй
  б) Потрібно виправити
```

```
[3/3] ✅ Генерую refined task

Записано: .workflows/apple-health-sync/pm/refined-task.md

Резюме:
  📝 Story: User Story (As a fitness user, I want to sync Apple Health data...)
  ✅ 5 acceptance criteria (P0: 3, P1: 2)
  📏 Estimation hint: L (10-20 files, new integration, DB migration)
  ⚠️ Risks: DEPENDENCY (Apple HealthKit API), COMPLIANCE (health data PHI)
  ❓ Open Questions: 1 (conflict resolution strategy)

Next steps:
  a) /pm:estimate apple-health-sync — оцінити складність
  b) /dev:research apple-health-sync — почати технічне дослідження
  c) /qa:test-plan apple-health-sync — почати планування тестів
  d) Зберегти та вирішити пізніше
```

### Приклад 2: З текстового опису (без Jira)

```bash
/pm:refine "додати експорт звітів у PDF"
```

```
[1/3] 📋 Збираю контекст проекту...

Jira: ❌ не підключено (працюю в pure dialogue mode)
Confluence: ❌ не підключено
Codebase: знайдено існуючі звіти в src/Report/
  └─ 3 типи звітів: WorkoutReport, NutritionReport, ProgressReport
  └─ Поточний формат: тільки HTML (web view)

Резюме: є 3 типи звітів, зараз тільки HTML. Потрібно додати PDF експорт.
Контекст обмежений — працюю без Jira/Confluence, задаватиму більше питань.
```

*...далі діалог як у прикладі 1, але з більшою кількістю питань...*

### Приклад 3: З Sentry triage (без проєкту)

```bash
/pm:refine --from .workflows/sentry-triage-2026-03/ops/triage-report.md
```

Працює без клонованого проєкту. PM отримує triage report від Ops і уточнює пріоритети:

```
[1/3] 📋 Збираю контекст...

Triage report: 5 critical issues, 12 high, 23 medium
  └─ Найкритичніший: "Payment webhook timeout" (1,234 events, 89 users affected)

Jira: знайдено пов'язаний epic PROJ-200 "Payment Reliability"
Confluence: знайдено runbook /spaces/OPS/Payment+Webhook+Troubleshooting
```

---

## /pm:estimate — Оцінка складності

### Приклад: Estimation з Jira history

```bash
/pm:estimate apple-health-sync
```

```
Читаю refined-task.md...

Аналіз складності:
  Components: 5 (HealthKit client, sync service, message handler, entity, API endpoint)
  DB changes: New tables (health_record, sync_status)
  API endpoints: 2 (POST /sync, GET /sync/status)
  External deps: 1 (Apple HealthKit API)
  Unknown factors: 1 (HealthKit rate limits)

Пошук аналогів в Jira...
  PROJ-89 "Garmin sync" — estimated: 24h, actual: 32h (ratio: 1.33)
  PROJ-67 "Fitbit integration" — estimated: 20h, actual: 28h (ratio: 1.40)

┌──────────────┬─────────┬─────────┐
│ Phase        │ Min (h) │ Max (h) │
├──────────────┼─────────┼─────────┤
│ Development  │ 16      │ 28      │
│ Testing      │ 6       │ 12      │
│ Code Review  │ 2       │ 4       │
│ Total        │ 24      │ 44      │
└──────────────┴─────────┴─────────┘

T-Shirt Size: L
Confidence: Medium (є аналоги, але Apple HealthKit — нова інтеграція)

⚠️ Ризики до оцінки:
  +8h — якщо HealthKit має суворі rate limits (потрібен backoff strategy)
  -4h — якщо повністю повторюємо патерн Garmin (менше дослідження)

Рекомендація: Ready for sprint planning. Враховуючи historical ratio 1.33-1.40,
рекомендую планувати на верхню межу (40-44h).

Записано: .workflows/apple-health-sync/pm/estimation.md
```

---

## /pm:accept — Верифікація Acceptance Criteria

### Приклад: Після завершення розробки

```bash
/pm:accept apple-health-sync
```

```
Читаю acceptance criteria з refined-task.md...
  5 criteria (P0: 3, P1: 2)

Збираю evidence...

Dev artifacts:
  ├─ phase-1-report.md: HealthKit client + sync service implemented
  ├─ phase-2-report.md: API endpoints + message handler implemented
  └─ phase-2-quality-gate-report.md: all tests passing, 87% coverage

QA artifacts:
  ├─ test-cases.md: 18 test cases written
  └─ regression-report.md: 0 critical, 1 minor (UI alignment)

Sentry: 0 new errors since deployment to staging

┌────────┬────────────────────────────────────────────────┬────────┐
│ ID     │ Criterion                                      │ Status │
├────────┼────────────────────────────────────────────────┼────────┤
│ AC 1.1 │ User can connect Apple Health account          │ ✅ PASS │
│ AC 1.2 │ Data syncs every 15 minutes automatically      │ ✅ PASS │
│ AC 1.3 │ Manual sync button works                       │ ✅ PASS │
│ AC 2.1 │ All 5 data types synced correctly              │ ✅ PASS │
│ AC 2.2 │ Sync history visible in user profile           │ ⚠ UNCLEAR │
└────────┴────────────────────────────────────────────────┴────────┘

AC 2.2 "Sync history visible in user profile":
  ❓ Код endpoint /api/sync/history існує, але UI не знайдено в dev artifacts.
  Можливо реалізовано на фронтенді, який не покритий dev:implement.

Потрібна ваша перевірка:

Чи реалізована сторінка історії синхронізації в UI?
  а) Так, перевірив — все працює
  б) Ні, це потрібно дореалізувати
  в) Це буде в окремому PR (фронтенд)

---

Verdict: NEEDS REVIEW (4/5 PASS, 1 UNCLEAR)

Записано: .workflows/apple-health-sync/pm/acceptance-report.md
```

---

## Режими роботи

### З повним MCP (рекомендовано)

Всі 4 MCP сервери підключені. Максимальна автоматизація:
- Jira: автоматично читає issue, шукає аналоги, оновлює статус
- Confluence: читає specs, пише артефакти
- Sentry: перевіряє production issues
- Git: аналізує зміни

### Частковий MCP

Підключені тільки деякі сервери. Плагін адаптується:
- Без Jira → більше питань PM, ручний ввід задач
- Без Confluence → пропускає пошук specs
- Без Sentry → пропускає production context
- Без Git → пропускає аналіз коду

### Pure Dialogue (без MCP)

Нічого не підключено. Плагін працює як інтерактивний PM assistant:
- Всі дані від PM через діалог
- Артефакти в локальній директорії
- Підходить для початкового refinement без технічного контексту

### Без проєкту

PM не клонував репозиторій. Працює з:
- Jira/Confluence через MCP
- Діалог з PM
- Артефакти в ~/pm-workspace/ або поточній директорії
