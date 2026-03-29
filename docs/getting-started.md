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
📋 PM Plugin — MCP Status

  Jira        ❌ not configured
  Confluence  ❌ not configured
  Sentry      ❌ not configured
  Git         ❌ not configured

Run /pm:setup to configure missing integrations
Plugin works without MCP — in dialogue mode with reduced context.
```

Це нормально — плагін працює і без інтеграцій. Але з ними — набагато ефективніше.

---

## Крок 4: Налаштування інтеграцій

Введіть у чат:

```
/pm:setup
```

Plugin проведе вас через інтерактивне налаштування:

```
Які інтеграції потрібно налаштувати?

  a) Jira — задачі, stories, sprint planning
  b) Confluence — документація, specs, PRDs
  c) Sentry — production issues, error tracking
  d) Git (GitHub) — PRs, commits, branches
  e) Всі одразу
  f) Пропустити — працювати в dialogue mode
```

Після відповідей plugin згенерує блок конфігурації:

```
✅ Готово! Додайте наступний блок у ваш ~/.zshrc:

  # === CC Plugins — MCP Configuration ===

  # Jira
  export JIRA_URL="https://your-company.atlassian.net"
  export JIRA_TOKEN="<your-jira-api-token>"
  export JIRA_USER_EMAIL="you@company.com"
  ...

Де отримати токени:
  • Jira/Confluence: https://id.atlassian.com/manage-profile/security/api-tokens
  • Sentry: https://sentry.io/settings/account/api/auth-tokens/
  • GitHub: https://github.com/settings/tokens
```

### Де отримати токени

#### Jira / Confluence (Atlassian)

1. Перейдіть: https://id.atlassian.com/manage-profile/security/api-tokens
2. Натисніть **Create API token**
3. Назва: `cc-plugins`
4. Скопіюйте токен — він підходить і для Jira, і для Confluence

#### Sentry

1. Перейдіть: https://sentry.io/settings/account/api/auth-tokens/
2. Натисніть **Create New Token**
3. Scopes: `event:read`, `issue:read`, `project:read`, `org:read`
4. Скопіюйте токен

#### GitHub

1. Перейдіть: https://github.com/settings/tokens
2. **Generate new token (classic)**
3. Scopes: `repo`, `read:org`
4. Скопіюйте токен

### Після налаштування токенів

1. Відкрийте термінал (поза Claude Code)
2. Виконайте: `source ~/.zshrc`
3. Перезапустіть Claude Code
4. Перевірте: введіть `/pm:setup` — має показати ✅ для налаштованих інтеграцій

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
| `/pm:setup` | Налаштування інтеграцій |
| `/pm:refine` | Уточнення задачі → refined-task.md |
| `/pm:estimate` | Оцінка складності → estimation.md |
| `/pm:accept` | Перевірка acceptance criteria → acceptance-report.md |

---

## FAQ

### Чи потрібен мені клонований репозиторій?

**Ні.** PM плагін працює без проєкту. Jira, Confluence, Sentry доступні через MCP глобально.

### Чи можу я працювати без Jira?

**Так.** Плагін адаптується — замість автоматичного контексту з Jira, задаватиме більше питань через діалог.

### Чи бачать інші мої налаштування?

**Ні.** Токени зберігаються у вашому `~/.zshrc` — це ваш локальний файл. При встановленні плагіна в **User** scope — конфігурація теж тільки ваша.

### Як оновити плагін?

- **Desktop:** **+** → **Plugins** → **Manage plugins** → **Update**
- **VS Code:** `/plugins` → вкладка **Installed** → **Update**
- **CLI:** `/plugin` → вкладка **Installed** → **Update**

### Як вимкнути плагін тимчасово?

- **Desktop/VS Code:** Знайдіть плагін у **Installed** → toggle switch
- **CLI:** `/plugin` → **Installed** → disable

### Де зберігаються артефакти?

В `.workflows/{feature-id}/pm/` відносно поточної директорії. Якщо ви PM без репо — в поточній робочій директорії.
