---
name: challenge
description: "Deep challenge — stress-tests refined task through 6 lenses (business viability, scope, assumptions, user, dependencies, failure modes). Uses MCP data for evidence-based findings."
allowed_tools: ["Read", "Grep", "Glob", "Write", "Bash", "Agent", "AskUserQuestion", "mcp__jira__*", "mcp__confluence__*", "mcp__sentry__*", "mcp__github__*"]
triggers:
  - "challenge"
  - "challenge task"
  - "перевірити задачу"
---

# /pm:challenge — Deep Task Challenge

Stress-tests a refined task through 6 lenses, using all available data sources. Produces a challenge report with findings, readiness score, and actionable recommendations.

**When to use:**
- L/XL tasks (high cost of getting it wrong)
- Tasks with many assumptions or external dependencies
- Tasks touching critical areas (payments, auth, health data)
- When PM wants extra confidence before handing to Dev

## Usage

```bash
/pm:challenge {feature-id}                              # Challenge refined task
/pm:challenge {feature-id} --focus business,scope       # Challenge specific lenses only
/pm:challenge PROJ-123                                   # Challenge from Jira issue directly
```

## You Are the Challenger

When this command runs, YOU become the **Challenger** agent. Read the full agent persona from:

```
${CLAUDE_PLUGIN_ROOT}/agents/challenger.md
```

Apply the agent's identity, biases, lenses, and output format.

## Step 0: MCP Availability Check

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-mcp-status.sh"
```

Challenge is MORE valuable with MCP — more data means more evidence-based findings.

| MCP Status | Challenge Quality |
|-----------|------------------|
| All connected | Full evidence-based challenge across all lenses |
| Partial | Some lenses data-backed, some opinion-based (flagged) |
| None | Opinion-based challenge only — still useful but lower confidence |

## Execution

### Step 1 — Load & Analyze

1. Read `.workflows/{feature-id}/pm/refined-task.md`
2. Parse: requirements, AC, estimation, risks, hypotheses, evidence trail

Show what you'll do:

```
🔍 Deep Challenge: {task title}

📄 Джерело: .workflows/{feature-id}/pm/refined-task.md
   {N} requirements, {N} AC, estimation: {size}

🔧 План перевірки:

  Lens 1: Бізнес-доцільність
          → Jira: пошук альтернатив, ROI аналогічних задач
          → Confluence: бізнес-метрики, OKR alignment

  Lens 2: Повнота scope
          → Jira: баг-репорти після аналогічних фіч
          → Sentry: error patterns в модулі
          → Codebase: пропущені edge cases

  Lens 3: Перевірка припущень
          → Cross-reference всіх джерел
          → Пошук суперечностей

  Lens 4: Перспектива юзера
          → Jira: user-reported issues, feature requests
          → Confluence: user research, personas

  Lens 5: Залежності та час
          → Git: open PRs, code churn, recent reverts
          → Jira: blocked issues, sprint capacity

  Lens 6: Режими відмови
          → Sentry: як ламаються аналогічні модулі
          → Codebase: error handling, test coverage

  ⏱️  ~3-5 хвилин

Починаю...
```

### Step 2 — Gather Challenge Data

For EACH lens, make specific MCP queries:

| Lens | Jira Query | Confluence Query | Sentry Query | Code Query |
|------|-----------|-----------------|-------------|-----------|
| Business | Similar resolved tasks: actual impact | OKRs, business metrics | User impact data | Existing workarounds |
| Scope | Bug reports after similar features | Edge cases in specs | Common error patterns | Missing validations |
| Assumptions | Reopened tasks (assumption failures) | Outdated specs | API stability data | Hardcoded values |
| User | Feature requests, support tickets | Personas, user research | User-facing errors | UX-related code |
| Dependencies | Blocked issues, sprint plan | Release calendar | Deploy frequency | Open PRs, churn |
| Failure | Post-mortems | Runbooks, incident docs | Error trends, alerts | Error handling, tests |

### Step 3 — Apply Lenses

Run each lens. For each finding:
1. State the finding
2. Cite evidence (source + specific data)
3. Assess severity (CRITICAL / MAJOR / MINOR / INFO)
4. Calculate impact (hours wasted / users affected / revenue at risk)
5. Recommend action

### Step 4 — Synthesize

1. Count findings by severity
2. Calculate Readiness Score
3. Determine Verdict
4. Write challenge-report.md

### Step 5 — Present to PM

```
🔍 Challenge Report: {task title}

━━━ Verdict: {READY / NEEDS WORK / HIGH RISK / NOT READY} ━━━
Readiness Score: {score}/100

Findings:
  🔴 CRITICAL: {n}
  🟡 MAJOR: {n}
  🔵 MINOR: {n}
  ℹ️  INFO: {n}

━━━ Critical ━━━

🔴 C1. {title}
   Lens: {which}
   {Finding with evidence}
   Impact: {hours/users/revenue if ignored}
   → {Recommendation}

━━━ Major ━━━

🟡 M1. {title}
   Lens: {which}
   {Finding with evidence}
   → {Recommendation}

━━━ Minor ━━━
🔵 m1. {title} — {one-liner}

━━━ Readiness ━━━

  Business case      {✅/⚠️/❌}
  Scope completeness {✅/⚠️/❌}
  Assumptions        {✅/⚠️/❌}
  User perspective   {✅/⚠️/❌}
  Dependencies       {✅/⚠️/❌}
  Failure modes      {✅/⚠️/❌}

📄 Записано: .workflows/{feature-id}/pm/challenge-report.md

Що далі?
  a) Виправити CRITICAL findings → оновити refined task
  b) Прийняти ризики → передати в розробку as-is
  c) Переробити → /pm:refine з новими інсайтами
  d) Обговорити конкретні findings
```

## Output

`.workflows/{feature-id}/pm/challenge-report.md`

Format defined in `${CLAUDE_PLUGIN_ROOT}/agents/challenger.md`.

## Comparison: Auto-Challenge vs Deep Challenge

| Aspect | Auto-Challenge (Phase 4/5 in /pm:refine) | Deep Challenge (/pm:challenge) |
|--------|------------------------------------------|-------------------------------|
| **Lenses** | 6 lenses, 1 question each | 6 lenses, full analysis each |
| **MCP queries** | Minimal (reuses refine data) | Dedicated challenge-specific queries |
| **Time** | ~1-2 minutes | ~3-5 minutes |
| **Output** | Inline findings + score | Full challenge-report.md |
| **When** | Always (built into refine) | On demand (L/XL / critical tasks) |
| **Depth** | "Is there an obvious gap?" | "Prove this task is ready" |
