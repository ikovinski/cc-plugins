# CC Plugins — Getting Started

Покроковий гайд з встановлення та першого використання. Без терміналу — все через UI.

---

## Крок 1: Додати marketplace

### Claude Code Desktop

1. Натисніть **+** біля поля вводу
2. Оберіть **Plugins**
3. Оберіть **Manage plugins**
4. Перейдіть на вкладку **Marketplaces**
5. Натисніть **Add new marketplace**
6. Введіть шлях до marketplace:

   **Для локальної копії:**
   ```
   /path/to/cc-plugins
   ```

   **Для GitHub:**
   ```
   your-org/cc-plugins
   ```

### VS Code Extension

1. Відкрийте Claude Code панель
2. Введіть `/plugins` в полі вводу
3. Перейдіть на вкладку **Marketplaces**
4. Натисніть **Add new marketplace**
5. Введіть шлях або GitHub repo

### JetBrains Extension

1. Відкрийте Claude Code панель
2. Введіть `/plugin` в полі вводу
3. Вкладка **Marketplaces** → **Add new marketplace**

### Web App (claude.ai/code)

1. Введіть `/plugin` в полі вводу
2. Вкладка **Marketplaces** → **Add new marketplace**
3. Введіть шлях або GitHub repo

---

## Крок 2: Встановити плагін

### Через UI (рекомендовано)

1. Відкрийте plugin manager:
   - **Desktop:** кнопка **+** → **Plugins** → **Add plugin**
   - **VS Code:** `/plugins` → вкладка **Discover**
   - **Web/CLI:** `/plugin` → вкладка **Discover**

2. Знайдіть потрібний плагін:

   | Плагін | Для кого | Опис |
   |--------|----------|------|
   | **pm** | Product Manager | Refinement, estimation, acceptance criteria |
   | **dev** | Developer | Research, design, plan, implement, PR |
   | **qa** | QA Engineer | Test planning, test cases, regression |
   | **ops** | DevOps / SRE | Sentry triage, incidents |
   | **stack-php-symfony** | PHP Developer | Coding standards, DB, messaging rules |

3. Натисніть **Install** на обраному плагіні

4. Оберіть scope:

   | Scope | Коли використовувати |
   |-------|---------------------|
   | **User** | Для себе, на всіх проєктах (рекомендовано для PM) |
   | **Project** | Для всієї команди (додає в `.claude/settings.json` репозиторію) |
   | **Local** | Тільки для себе, тільки в цьому репо |

   > **PM без репозиторію?** Обирайте **User** scope — працює глобально.

5. Після встановлення натисніть `/reload-plugins` або перезапустіть Claude Code

---

## Крок 3: Перший запуск

Після встановлення плагіна, при наступному запуску Claude Code ви побачите:

```
📋 PM Plugin — MCP Connectors

  Jira          ❌ not configured
              missing: ATLASSIAN_JIRA_SITE_NAME ATLASSIAN_USER_EMAIL ATLASSIAN_API_TOKEN
  Confluence    ❌ not configured
              missing: ATLASSIAN_CONFLUENCE_SITE_NAME ATLASSIAN_USER_EMAIL ATLASSIAN_API_TOKEN
  Sentry        ❌ not configured
              missing: SENTRY_ACCESS_TOKEN SENTRY_ORG
  GitHub        ❌ not configured
              missing: GITHUB_PERSONAL_ACCESS_TOKEN

Run /pm:setup to configure missing env vars
```

Це нормально — потрібно налаштувати environment variables.

---

## Крок 4: Налаштування MCP конекторів

Введіть у чат:

```
/pm:setup
```

Plugin проведе через налаштування і згенерує блок для shell profile:

```
# === CC Plugins — MCP Configuration ===

# Jira (site name — субдомен з URL https://{site}.atlassian.net)
export ATLASSIAN_JIRA_SITE_NAME="your-jira-site"
export ATLASSIAN_USER_EMAIL="you@company.com"
export ATLASSIAN_API_TOKEN="<your-atlassian-api-token>"

# Confluence (може бути інший site ніж Jira)
export ATLASSIAN_CONFLUENCE_SITE_NAME="your-confluence-site"

# Sentry
export SENTRY_ACCESS_TOKEN="<your-sentry-token>"
export SENTRY_ORG="your-org"

# GitHub
export GITHUB_PERSONAL_ACCESS_TOKEN="<your-github-pat>"
```

### Де отримати токени

| Сервіс | URL | Що створити |
|--------|-----|-------------|
| **Atlassian** | https://id.atlassian.com/manage-profile/security/api-tokens | API token (один для Jira + Confluence) |
| **Sentry** | https://sentry.io/settings/account/api/auth-tokens/ | Auth token (scopes: event:read, issue:read, project:read, org:read) |
| **GitHub** | https://github.com/settings/tokens | Personal access token (scopes: repo, read:org) |

### Після налаштування

1. Додайте блок в `~/.zshrc`
2. Замініть `<your-...-token>` на реальні значення
3. Виконайте: `source ~/.zshrc`
4. Перезапустіть Claude Code
5. Перевірте: `/pm:setup` — має показати ✅ для всіх

---

## Крок 5: Перша задача

Тепер все готово. Спробуйте:

### Варіант А: Задача з Jira

```
/pm:refine PROJ-123
```

Plugin автоматично:
- Прочитає issue з Jira
- Знайде пов'язані документи в Confluence
- Перевірить Sentry на production issues
- Задасть уточнюючі питання
- Згенерує `refined-task.md`

### Варіант Б: Задача з тексту

```
/pm:refine "додати можливість експорту звітів у PDF"
```

Plugin працює в діалоговому режимі — задає питання та уточнює вимоги.

### Варіант В: Тільки оцінка

```
/pm:estimate PROJ-456
```

Plugin порівняє з аналогічними задачами з Jira та видасть T-shirt estimate.

---

## Доступні команди PM плагіна

| Команда | Що робить |
|---------|-----------|
| `/pm:setup` | Статус конекторів та налаштування |
| `/pm:refine` | Уточнення задачі → refined-task.md |
| `/pm:challenge` | Перевірка задачі на життєздатність → challenge-report.md |
| `/pm:estimate` | Оцінка складності → estimation.md |
| `/pm:accept` | Перевірка acceptance criteria → acceptance-report.md |
| `/pm:codebase` | PM-friendly карта проєкту → codebase-context.md |

---

## FAQ

### Чи потрібен мені клонований репозиторій?

**Ні.** PM плагін працює без проєкту. Jira, Confluence, Sentry доступні через MCP глобально.

### Чи можу я працювати без Jira?

**Так.** Плагін адаптується — замість автоматичного контексту з Jira, задаватиме більше питань через діалог.

### Чи бачать інші мої налаштування?

**Ні.** OAuth токени кешуються локально. При встановленні плагіна в **User** scope — конфігурація тільки ваша.

### Як оновити плагін?

- **Desktop:** **+** → **Plugins** → **Manage plugins** → **Update**
- **VS Code:** `/plugins` → вкладка **Installed** → **Update**
- **CLI:** `/plugin` → вкладка **Installed** → **Update**

### Як вимкнути плагін тимчасово?

- **Desktop/VS Code:** Знайдіть плагін у **Installed** → toggle switch
- **CLI:** `/plugin` → **Installed** → disable

### Де зберігаються артефакти?

В `.workflows/{feature-id}/pm/` відносно поточної директорії. Якщо ви PM без репо — в поточній робочій директорії.
