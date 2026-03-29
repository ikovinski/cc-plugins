# PM Plugin — How It Works

Покрокові приклади використання кожної команди з реальним output.

---

## /pm:refine — Уточнення задачі

### Приклад: Повний flow з Jira issue

```bash
/pm:refine PROJ-123
```

#### Phase [0/4] — Аналіз та прозорість

Одразу після запуску plugin показує що буде робити:

```
📋 Аналіз задачі: PROJ-123

🔧 План збору контексту:

  Jira        ✅ Підключено
              → Читаю деталі PROJ-123
              → Шукаю linked issues та epic контекст
              → Шукаю аналогічні завершені задачі для estimation
              → Читаю коментарі та історію змін

  Confluence  ✅ Підключено
              → Шукаю специфікацію для модуля health-sync
              → Шукаю архітектурні рішення (ADR)
              → Перевіряю team agreements

  Sentry      ✅ Підключено
              → Перевіряю production issues в health-sync модулі
              → Аналізую частоту та вплив помилок

  Git         ✅ Підключено
              → Дивлюсь останні зміни в src/Service/HealthSync/
              → Перевіряю відкриті PR в цій зоні

  Codebase    ✅ Доступний
              → Аналізую існуючий GarminSync як аналог
              → Сканую DB schema, API endpoints
              → Перевіряю тестове покриття

  ⏱️  Орієнтовний час: ~2-3 хвилини

Починаю збір контексту...
```

#### Phase [1/4] — Глибокий збір контексту

*Plugin мовчки працює, збираючи дані з усіх джерел...*

#### Phase [2/4] — Знахідки та гіпотези

```
📊 Результати збору контексту

━━━ Що я знайшов ━━━

📌 PROJ-123: "Add Apple Health data sync"
   Epic: PROJ-100 "Health Integrations" (3/7 stories done)
   Priority: High | Sprint: Sprint 24 | Reporter: @anna.pm

📎 Пов'язані ресурси:
  • Jira: PROJ-123 + 4 linked issues (PROJ-111 Garmin done, PROJ-112 Fitbit in progress)
  • Confluence: "Health Integrations Spec v2.1" (оновлено 2 тижні тому)
  • Sentry: 3 production issues в health-sync модулі (12 events/день)
  • Кодова база: 47 файлів в зоні впливу, GarminSync як аналог

━━━ Ключові знахідки ━━━

1. 📋 В Jira коментарях Team Lead @serhiy написав: "Потрібно враховувати
   що Apple HealthKit має обмеження на частоту запитів — max 1 request/sec"

2. 📄 В Confluence специфікація описує sync кожні 30 хвилин, але в Jira
   коментарі @anna.pm згадує "хочемо real-time" — СУПЕРЕЧНІСТЬ

3. 🔴 Sentry: BODYFIT-A3F "HealthKit permission denied" — 12 events/день,
   89 users affected. Це існуюча проблема з permissions, яка може вплинути
   на нову інтеграцію

4. 💻 В коді є GarminSync (src/Service/GarminSync/) — повний патерн для
   reuse: OAuth → API polling → MessageQueue → DB. Реалізований 2 місяці тому,
   32 години фактичного часу (PROJ-111)

5. 🔀 @dmitry має відкритий PR #456 що рефакторить HealthDataProcessor —
   потенційний конфлікт

━━━ 💡 Мої гіпотези ━━━

Речі, про які ви могли не подумати:

⚡ Гіпотеза 1: Конфлікт даних між Apple Health та Garmin
   Основа: Обидва джерела відправляють кроки та калорії. Якщо юзер має
   і Apple Watch, і Garmin — дані дублюватимуться.
   Вплив: Некоректна статистика, подвійний підрахунок калорій.
   Потрібна стратегія deduplication.

⚡ Гіпотеза 2: Permission denied вже існує в production
   Основа: Sentry BODYFIT-A3F (89 users). Якщо існуюча проблема з
   permissions не вирішена, нова інтеграція наслідує ту ж проблему.
   Вплив: Частина юзерів не зможе підключити Apple Health.
   Можливо варто спочатку пофіксити existing issue.

⚡ Гіпотеза 3: PR #456 може зламати нову інтеграцію
   Основа: @dmitry рефакторить HealthDataProcessor, який буде
   використовуватись Apple Health sync.
   Вплив: Потрібна координація — або почекати merge PR, або
   працювати з новим API одразу.

⚠️ Ризики з даних:
  • Rate limiting Apple HealthKit (1 req/sec згідно коментаря @serhiy)
  • Суперечність в частоті sync (30 min vs real-time)
  • Відкритий рефакторинг в тій самій зоні коду

━━━ Що потребує уточнення ━━━

Маю 4 питання. Почнемо?
```

#### Phase [3/4] — Цілеспрямовані питання

```
[3/4] Питання 1 з 4

📎 Контекст: В Confluence специфікація (v2.1, оновлена 15.03) описує
синхронізацію кожні 30 хвилин. Але в Jira коментарі від 22.03 @anna.pm
написала: "Ідеально було б real-time". Team Lead @serhiy відповів, що
Apple HealthKit має rate limit 1 req/sec.

Як часто має відбуватись синхронізація?

Варіанти:
  а) Кожні 15-30 хвилин (як в специфікації) — перевірений підхід, працює для Garmin
  б) При кожній зміні в Apple Health (background sync) — максимальна свіжість,
     але складніша реалізація
  в) Гібрид: background events + periodic fallback — якщо Apple Health надсилає
     push, використовуємо його, інакше перевіряємо кожні 15 хв
  г) Інше
```

*PM відповідає: "в — гібрид звучить оптимально"*

```
[3/4] Питання 2 з 4

📎 Контекст: Моя гіпотеза 1 — якщо юзер має і Apple Watch, і Garmin,
дані кроків та калорій дублюватимуться. В коді GarminSync зберігає дані
в health_records з source='garmin'. Але стратегії deduplication немає.

Як обробляти дубльовані дані з різних джерел?

Варіанти:
  а) Primary source — юзер обирає один пріоритетний девайс, інші ігноруються
  б) Smart merge — алгоритм обирає найточніше значення (Apple Watch для пульсу,
     Garmin для GPS)
  в) Показувати все окремо — юзер бачить дані по кожному девайсу
  г) Не входить в scope цієї задачі — вирішимо окремо
```

*PM відповідає: "а — поки що primary source, решта в backlog"*

```
[3/4] Питання 3 з 4

📎 Контекст: В Sentry є активний issue BODYFIT-A3F "HealthKit permission
denied" (89 users, 12 events/день). Якщо ми додаємо Apple Health sync,
ті самі юзери зіткнуться з цією проблемою.

Чи потрібно вирішити existing permission issue перед або разом з цією задачею?

Варіанти:
  а) Пофіксити спочатку — інакше нова фіча зламана для 89 юзерів
  б) Включити фікс в цю задачу — одним PR
  в) Окрема задача, паралельно — хай хтось інший фіксить
  г) Ігнорувати поки що — не блокер
```

*PM відповідає: "б — включити в цю задачу"*

```
[3/4] Підтверджую розуміння

Резюме:
  • Sync: гібрид (background events + periodic fallback кожні 15 хв)
  • Дублі: primary source, юзер обирає пріоритетний девайс
  • Permission fix: включаємо в scope цієї задачі
  • Патерн: аналогічно GarminSync (OAuth → polling → queue → DB)

Оновлені гіпотези:
  ✅ H1 (дублі) — підтверджена, рішення: primary source (P0 requirement)
  ✅ H2 (permission) — підтверджена, включаємо в scope
  ⏳ H3 (PR #456) — залишається відкритою, потрібна координація з @dmitry

💡 Нова гіпотеза: Оскільки включаємо permission fix — потрібно протестувати
   на реальних iOS девайсах. Емулятор не відтворює HealthKit permissions.

Все вірно?
  а) Так, генеруй refined task
  б) Потрібно виправити
```

#### Phase [4/4] — Генерація refined task

```
✅ Refined task готовий

📄 .workflows/apple-health-sync/pm/refined-task.md

Резюме:
  📝 Story: User Story — "As a fitness user, I want to sync Apple Health data..."
  ✅ 7 acceptance criteria (P0: 5, P1: 2)
  📏 Estimation: L (24-44 годин)
  ⚡ 3 гіпотези враховано (2 стали requirements, 1 — risk)
  ⚠️ 4 ризики ідентифіковано
  ❓ 1 open question (координація з PR #456)
  📎 Джерела: Jira(5 issues), Confluence(2 pages), Sentry(3 issues), Code(47 files)

  ⚡ УВАГА: Знайдено 1 суперечність між джерелами (частота sync).
     Рішення прийнято в діалозі — гібридний підхід.

Next steps:
  a) /pm:estimate apple-health-sync — детальна оцінка складності
  b) /dev:research apple-health-sync — передати в технічне дослідження
  c) /qa:test-plan apple-health-sync — почати планування тестів
  d) Доопрацювати — є що додати/змінити
  e) Зберегти — вирішити пізніше
```

---

### Приклад: Без MCP (pure dialogue)

```bash
/pm:refine "додати експорт звітів у PDF"
```

```
📋 Аналіз задачі: "Додати експорт звітів у PDF"

🔧 План збору контексту:

  Jira        ❌ Не підключено
              → Пропускаю. Задаватиму питання про задачу напряму.
              → 💡 /pm:setup jira — щоб підключити

  Confluence  ❌ Не підключено
              → Пропускаю. Не зможу перевірити чи є специфікація.
              → 💡 /pm:setup confluence — щоб підключити

  Sentry      ❌ Не підключено
              → Не зможу перевірити production issues.

  Git         ❌ Не підключено

  Codebase    ✅ Доступний
              → Шукаю існуючі звіти та експорт функціонал
              → Аналізую DB schema для звітних даних

  ⚠️ Працюю з обмеженим контекстом — задаватиму більше питань.
  ⏱️  ~1 хвилина на збір з кодової бази

Починаю...
```

```
📊 Результати

━━━ Що я знайшов ━━━

📌 В кодовій базі:
  • 3 типи звітів: WorkoutReport, NutritionReport, ProgressReport
  • Поточний формат: HTML (web view через Twig templates)
  • ReportController з 3 endpoints: /reports/workout, /reports/nutrition, /reports/progress
  • Немає жодної PDF залежності в composer.json

━━━ 💡 Мої гіпотези ━━━

⚡ Гіпотеза 1: Потрібна нова бібліотека для PDF генерації
   Основа: composer.json не містить PDF-related пакетів (dompdf, snappy, tcpdf)
   Вплив: Вибір бібліотеки впливає на якість, performance, та складність

⚡ Гіпотеза 2: Графіки та діаграми в звітах
   Основа: ProgressReport містить chart data (JSON з тижневою статистикою).
   В HTML використовує Chart.js (client-side rendering).
   Вплив: PDF не підтримує JavaScript — потрібен server-side rendering
   графіків. Це окрема технічна задача.

⚡ Гіпотеза 3: Великі звіти можуть бути повільними
   Основа: NutritionReport може містити дані за рік (365 днів × N прийомів їжі).
   Вплив: PDF генерація для великих звітів може займати >30 секунд.
   Можливо потрібна async генерація (background job).

⚠️ Без Jira/Confluence не можу перевірити:
  • Чи є специфікація з макетами PDF
  • Чи є пов'язані задачі або попередні рішення
  • Який пріоритет та дедлайн

Маю 5 питань. Почнемо?
```

*...далі цілеспрямовані питання з контекстом з кодової бази...*

---

## /pm:challenge — Випробування задачі

### Навіщо challenge потрібен

Кожна задача, яка потрапляє в розробку, несе в собі приховані ризики — припущення, які ніхто не перевірив, сценарії, про які ніхто не подумав, залежності, які ніхто не врахував. Статистика з реальних проєктів:

| Проблема | Коли знайдена | Вартість виправлення |
|----------|--------------|---------------------|
| Пропущений edge case | На етапі refinement | 15 хвилин діалогу |
| Пропущений edge case | На етапі code review | 2-4 години рефакторингу |
| Пропущений edge case | В production | 1-3 дні hotfix + incident response |
| Хибне припущення про API | На етапі refinement | Змінити 1 речення в AC |
| Хибне припущення про API | Під час implementation | 8-16 годин переписування |
| Невраховані дублі даних | На етапі refinement | Додати 1 requirement |
| Невраховані дублі даних | Після release | 20+ годин data cleanup + migration |

**Challenge — це страховка.** 3-5 хвилин перевірки можуть зекономити дні або тижні роботи команди.

### Два рівні challenge

#### Auto-Challenge (вбудований в /pm:refine, Phase 4/5)

Запускається автоматично перед генерацією refined task. Швидкий — 1-2 хвилини. Одне ключове питання на кожну з 6 перспектив. Ловить очевидні пропуски.

```
[4/5] 🔍 Швидка перевірка задачі

✅ Бізнес-доцільність — обґрунтована (аналог Garmin приніс +12% retention)
⚠️ Повнота scope — ЗНАХІДКА:
   Не описано що відбувається при відключенні Apple Health permissions
   після активної синхронізації. Юзер втрачає доступ — а дані?
   → Рекомендую додати AC

✅ Припущення — основні валідовані
⚠️ Перспектива юзера — ЗНАХІДКА:
   "Primary source" — технічний термін, юзер не зрозуміє
   → Рекомендую "Основний пристрій" з поясненням

✅ Залежності — ідентифіковані
✅ Режими відмови — дані в безпеці

Readiness: 80/100 — READY (з рекомендаціями)

Врахувати знахідки?
  а) Так, додай обидві
  б) Тільки першу
  в) Ні, ігнорувати
```

#### Deep Challenge (/pm:challenge — окрема команда)

Для важливих задач. Повний аналіз з dedicated MCP запитами. 3-5 хвилин.

### Приклад: Deep Challenge для Apple Health Sync

```bash
/pm:challenge apple-health-sync
```

```
🔍 Deep Challenge: Apple Health Sync

📄 Джерело: refined-task.md (7 AC, estimation L, 28-48h)

🔧 План перевірки:
  Lens 1: Бізнес    → Jira: ROI аналогів, user requests
  Lens 2: Scope     → Jira: баги після Garmin/Fitbit launch
  Lens 3: Assumptions → Cross-reference всіх джерел
  Lens 4: Юзер      → Jira: скарги, feature requests
  Lens 5: Залежності → Git: PR activity, code churn
  Lens 6: Відмови   → Sentry: як ламається sync модуль

  ⏱️  ~4 хвилини

Починаю...
```

```
🔍 Challenge Report: Apple Health Sync

━━━ Verdict: NEEDS WORK ━━━
Readiness Score: 65/100

  🔴 CRITICAL: 1
  🟡 MAJOR: 2
  🔵 MINOR: 1
  ℹ️  INFO: 2

━━━ Critical ━━━

🔴 C1. Відсутня стратегія rollback для DB migration

  Lens: Режими відмови
  Finding: Задача включає нові таблиці (health_record source, sync_status).
  В refined-task немає AC для rollback scenario. Якщо після deploy
  виявиться критичний баг — відкатити migration з даними неможливо.

  Evidence:
    • Jira PROJ-95: "Rollback failed after subscription migration" — 6 годин
      downtime, 3 місяці тому. Та сама команда, та сама проблема.
    • Codebase: жодна з 12 існуючих migrations не має down() method

  Impact: 4-8 годин downtime при необхідності rollback.
          Потенційна втрата даних синхронізації.

  → Рекомендація: Додати requirement "Migration має бути reversible"
    з AC: "down() migration відтестована та повертає schema до попереднього стану"

━━━ Major ━━━

🟡 M1. Garmin launch мав 3 production bugs протягом першого тижня

  Lens: Повнота scope
  Finding: Після launch PROJ-111 (Garmin sync) було створено 3 баг-репорти:
    • PROJ-115: "Timezone mismatch in workout data" (P1, 48h to fix)
    • PROJ-118: "Sync stuck after token refresh" (P2, 8h to fix)
    • PROJ-121: "Duplicate entries on reconnect" (P2, 16h to fix)

  Жоден з цих сценаріїв не покритий AC для Apple Health.

  Evidence: Jira history для PROJ-111 linked bugs

  Impact: Ті ж баги повторяться. 72+ годин на фікси.

  → Рекомендація: Додати AC що явно покривають:
    - Timezone handling при синхронізації
    - Token refresh flow (HealthKit token expiry)
    - Reconnect scenario (що відбувається при re-enable)

🟡 M2. Rate limiting не описаний як requirement

  Lens: Перевірка припущень
  Finding: В Jira коментарі @serhiy згадав "Apple HealthKit max 1 req/sec".
  В refined-task це зафіксовано як risk, але НЕ як requirement з AC.
  Якщо dev проігнорує risk — Apple заблокує API calls.

  Evidence:
    • Jira comment від @serhiy (22.03)
    • Apple HealthKit docs: rate limiting без explicit numbers,
      але з "may throttle excessive requests"

  Impact: Blocked API → sync failure → 89+ existing users
          + all new Apple Health users affected

  → Рекомендація: Перевести з Risk в P0 Requirement:
    "Sync респектує rate limits HealthKit API.
     AC: при throttling — exponential backoff, без data loss"

━━━ Minor ━━━

🔵 m1. Estimation не враховує iOS-specific testing
   Refined task includes permission fix — тестування потребує
   реальних iOS пристроїв. +4-8h testing overhead не в estimation.

━━━ Info ━━━

ℹ️ i1. Fitbit sync (PROJ-112) in progress — potentially shared learnings
ℹ️ i2. 4 users already requested Apple Health in Jira comments (PROJ-100)

━━━ Readiness Assessment ━━━

  Business case       ✅ Обґрунтований (user requests + retention data)
  Scope completeness  ❌ 3 відомі баг-сценарії не покриті
  Assumptions         ⚠️ Rate limiting — risk замість requirement
  User perspective    ✅ Покрита (primary source flow)
  Dependencies        ✅ PR #456 ідентифікований
  Failure modes       ❌ Rollback strategy відсутня

━━━ Рекомендації ━━━

Must Do (before development):
  1. Додати rollback requirement для DB migration
  2. Покрити 3 баг-сценарії з Garmin launch як AC

Should Do:
  3. Перевести rate limiting з Risk в P0 Requirement
  4. Додати 4-8h на iOS testing в estimation

📄 .workflows/apple-health-sync/pm/challenge-report.md

Що далі?
  a) Виправити findings → оновити refined task
  b) Прийняти ризики → в розробку as-is
  c) Обговорити конкретні findings
```

### Що відбувається після challenge

PM обирає "a) Виправити findings". Plugin:
1. Оновлює `refined-task.md` — додає нові requirements та AC
2. Перераховує estimation (було 28-48h → стало 32-56h з iOS testing)
3. Оновлює `challenge-report.md` — findings позначені як addressed
4. Показує оновлений Readiness Score (було 65 → стало 90)

```
✅ Refined task оновлений

Зміни:
  + R4 (P0): "Reversible DB migration" — 1 AC
  + R5 (P0): "Rate limiting compliance" — 2 AC
  + AC 1.4: Timezone handling
  + AC 1.5: Token refresh flow
  + AC 1.6: Reconnect scenario
  - Estimation: 32-56h (was 28-48h, +4-8h iOS testing)

Readiness Score: 90/100 — READY ✅

Next steps:
  a) /dev:research apple-health-sync — передати в розробку
  b) /qa:test-plan apple-health-sync — планування тестів
```

### Реальна цінність challenge (на прикладі)

Без challenge ця задача пішла б у розробку з:
- **Відсутнім rollback** — якби після deploy знайшли критичний баг, відкат зайняв би 4-8 годин downtime (як в PROJ-95 три місяці тому)
- **3 повторними багами** — timezone, token refresh, reconnect — ті самі що були з Garmin. 72+ годин на фікси
- **Rate limiting як "risk"** — developer міг проігнорувати. Результат: заблоковані API calls для всіх users

**Вартість challenge:** 4 хвилини аналізу + 10 хвилин оновлення refined task.
**Вартість без challenge:** 80-100+ годин на фікси, downtime, та incident response.

**ROI: 1 година витрачена зараз зберігає 80+ годин пізніше.**

---

## /pm:estimate — Оцінка складності

### Приклад: Estimation з Jira history

```bash
/pm:estimate apple-health-sync
```

```
📋 Аналіз: estimation для apple-health-sync

🔧 Інструменти:
  Refined task  ✅ → Читаю .workflows/apple-health-sync/pm/refined-task.md
  Jira          ✅ → Шукаю аналогічні завершені задачі
  Codebase      ✅ → Рахую affected files та components

Починаю...
```

```
📊 Estimation: Apple Health Sync

━━━ Аналіз складності ━━━

  Components affected:     5 (HealthKit client, sync service, handler, entity, API)
  DB changes:              New tables (health_record source column, sync_status)
  API endpoints:           2 new (POST /sync, GET /sync/status)
  External dependencies:   1 (Apple HealthKit API)
  Unknown factors:         1 (HealthKit rate limits)
  Includes bug fix:        Yes (BODYFIT-A3F permission issue)

━━━ Аналоги з Jira ━━━

  PROJ-111 "Garmin sync"    — estimated: 24h, actual: 32h (ratio: 1.33)
  PROJ-112 "Fitbit sync"    — estimated: 20h, actual: 28h (ratio: 1.40)
  PROJ-98  "Permission fix" — estimated: 4h,  actual: 6h  (ratio: 1.50)

  📈 Середній ratio: 1.41 (команда систематично недооцінює на ~40%)

━━━ Estimation ━━━

  ┌──────────────┬─────────┬─────────┐
  │ Phase        │ Min (h) │ Max (h) │
  ├──────────────┼─────────┼─────────┤
  │ Development  │ 20      │ 32      │
  │ Testing      │ 6       │ 12      │
  │ Code Review  │ 2       │ 4       │
  │ Total        │ 28      │ 48      │
  └──────────────┴─────────┴─────────┘

  T-Shirt Size: L
  Confidence: Medium

  💡 З урахуванням historical ratio 1.41 рекомендую
     планувати на upper bound: 40-48 годин

Записано: .workflows/apple-health-sync/pm/estimation.md
```

---

## /pm:accept — Верифікація Acceptance Criteria

### Приклад: Після завершення розробки

```bash
/pm:accept apple-health-sync
```

```
📋 Аналіз: acceptance check для apple-health-sync

🔧 Інструменти:
  Refined task  ✅ → 7 acceptance criteria (P0: 5, P1: 2)
  Dev artifacts ✅ → 2 phase reports
  QA artifacts  ✅ → Test cases + regression report
  Jira          ✅ → Оновлю статус після верифікації
  Sentry        ✅ → Перевірю нові помилки після deploy
  Git           ✅ → Перевірю статус PR

Перевіряю...
```

```
📊 Acceptance Report: Apple Health Sync

  ┌────────┬──────────────────────────────────────────┬──────────┐
  │ ID     │ Criterion                                │ Status   │
  ├────────┼──────────────────────────────────────────┼──────────┤
  │ AC 1.1 │ User can connect Apple Health account    │ ✅ PASS   │
  │ AC 1.2 │ Background sync + 15min fallback works   │ ✅ PASS   │
  │ AC 1.3 │ Manual sync button works                 │ ✅ PASS   │
  │ AC 2.1 │ All 5 data types synced correctly        │ ✅ PASS   │
  │ AC 2.2 │ Primary source selection works           │ ✅ PASS   │
  │ AC 3.1 │ Permission fix (BODYFIT-A3F resolved)    │ ✅ PASS   │
  │ AC 3.2 │ Sync history visible in user profile     │ ⚠ UNCLEAR │
  └────────┴──────────────────────────────────────────┴──────────┘

  Sentry: 0 new errors since staging deploy (2 days)
  Git: PR #478 merged, all checks passing

  AC 3.2 "Sync history visible in user profile":
    ❓ Backend endpoint /api/sync/history реалізований (dev report).
       Але UI компонент не згадується в dev artifacts.

Чи реалізована сторінка історії синхронізації в UI?
  а) Так, перевірив — все працює
  б) Ні, потрібно дореалізувати
  в) Це окремий PR (frontend)

━━━

Verdict: NEEDS REVIEW (6/7 PASS, 1 UNCLEAR)

Записано: .workflows/apple-health-sync/pm/acceptance-report.md
```

---

## Режими роботи

### Повний MCP (максимальна ефективність)

Всі 4 MCP підключені. Plugin:
- Автоматично збирає контекст з 5+ джерел
- Генерує гіпотези на основі cross-reference даних
- Задає мінімум питань (тільки gaps та contradictions)
- Порівнює з історичними даними для estimation
- Confidence: High

### Частковий MCP

Частина серверів підключена. Plugin:
- Використовує доступні джерела
- Явно показує що недоступно та як це впливає
- Задає більше питань для компенсації
- Confidence: Medium

### Pure Dialogue (без MCP, з проєктом)

Тільки codebase доступний. Plugin:
- Сканує код для технічного контексту
- Всі бізнес-дані від PM через діалог
- Генерує гіпотези з коду (existing patterns, missing tests, etc.)
- Confidence: Medium-Low

### Без проєкту, без MCP

Нічого крім діалогу. Plugin:
- Працює як досвідчений PM assistant
- Використовує frameworks зі skills (INVEST, story formats, estimation)
- Максимум питань PM
- Confidence: Low
- Рекомендує підключити MCP для кращої якості
