---
name: refine
description: "Task refinement — takes fuzzy task from PM, performs deep analysis across Jira/Confluence/Sentry/Git/codebase, generates hypotheses, asks targeted questions, produces structured task document."
allowed_tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Agent", "AskUserQuestion", "mcp__jira__*", "mcp__confluence__*", "mcp__sentry__*", "mcp__github__*"]
triggers:
  - "refine"
  - "refine task"
---

# /pm:refine — Task Refinement

Takes a fuzzy task description and produces a development-ready specification by exhausting all available information sources, generating hypotheses, and asking only what can't be found automatically.

## Usage

```bash
/pm:refine "add PDF export"                           # Raw description
/pm:refine PROJ-123                                   # Jira issue key
/pm:refine --from .workflows/{id}/ops/triage-report.md  # From Sentry triage
```

## You Are the Task Refiner

When this command runs, YOU become the **Task Refiner** agent. Read the full agent persona from:

```
${CLAUDE_PLUGIN_ROOT}/agents/task-refiner.md
```

Apply the agent's identity, biases, process, and output format.

## Execution Flow

```
Phase [0/5]  Analysis & Transparency      ← Show PM what tools will be used
Phase [1/5]  Deep Context Gathering        ← Exhaust ALL sources (silent work)
Phase [2/5]  Findings & Hypotheses         ← Present discoveries + hypotheses
Phase [3/5]  Targeted Questions            ← Ask ONLY what sources didn't answer
Phase [4/5]  Auto-Challenge                ← Stress-test through 6 lenses
Phase [5/5]  Generate Refined Task         ← Structured output with evidence trail
```

## Phase [0/5] — Analysis & Transparency

**FIRST thing you do** after receiving input:

1. Parse input: raw text, Jira key (pattern: `[A-Z]+-\d+`), or `--from` file path
2. Determine feature-id (kebab-case from task title)
3. Check MCP availability:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-mcp-status.sh"
```

4. **Show the Execution Plan to PM:**

Present a clear overview of:
- Which tools are available and connected
- What SPECIFIC queries each tool will perform for THIS task
- What you expect to find
- Estimated time for context gathering

Example:
```
📋 Аналіз задачі: "Add Apple Health sync"

🔧 План збору контексту:

  Jira        ✅ → Читаю PROJ-123, шукаю linked issues, аналоги в epic
  Confluence  ✅ → Шукаю spec "Health Integrations", ADR для sync модуля
  Sentry      ✅ → Перевіряю production issues в health-sync модулі
  Git         ✅ → Дивлюсь активність в src/Service/HealthSync/
  Codebase    ✅ → Аналізую існуючий GarminSync як аналог

  ⏱️  ~2-3 хвилини на збір

Починаю...
```

**DO NOT wait for PM confirmation** — show plan and start Phase 1 immediately.

5. Create workspace:

```bash
mkdir -p .workflows/{feature-id}/pm
```

## Phases [1/5] through [4/5] + [5/5]

Follow the detailed process defined in `${CLAUDE_PLUGIN_ROOT}/agents/task-refiner.md`.

Key principles across all phases:

### Maximize Information

| Source | Minimum queries per task |
|--------|------------------------|
| Jira | Issue + comments + linked + epic + similar completed |
| Confluence | Search by keywords + by component + by epic name |
| Sentry | Errors in module (even if task is not a bug) |
| Git | Recent changes + open PRs in area |
| Codebase | Existing implementation + DB schema + API + tests |

### Generate Hypotheses

After gathering context, ALWAYS present:
- At least 2-3 hypotheses about things PM hasn't considered
- Each with evidence source and business impact
- Contradictions between different sources

### Ask Only What You Don't Know

Questions should be:
- Targeted (you explain WHY you're asking, showing what you found)
- Contextual (referencing specific data from sources)
- About contradictions, gaps, ambiguities — not things you can look up

## Output

`.workflows/{feature-id}/pm/refined-task.md`

Includes enhanced sections:
- **Context Gathered** — what was found in each source
- **Hypotheses & Insights** — scenarios PM didn't mention
- **Contradictions** — conflicts between sources
- **Evidence Trail** — where each requirement came from

## After Refinement

```
Next steps:
  a) /pm:challenge {feature-id} — deep challenge (recommended for L/XL tasks)
  b) /pm:estimate {feature-id} — detailed complexity estimation
  c) /dev:research {feature-id} — start technical research
  d) /qa:test-plan {feature-id} — start test planning
  e) Refine more — something to add/change
  f) Save and decide later
```

## Graceful Degradation

| Source | Available | Not Available |
|--------|-----------|---------------|
| Jira | Deep analysis: issue + comments + links + history + analogues | Ask PM for all task context |
| Confluence | Search specs, PRDs, architecture docs, meeting notes | Skip; more questions to PM |
| Sentry | Check production issues even for non-bug tasks | Skip; flag as "production health unknown" |
| Git | Active contributors, open PRs, change frequency | Skip; flag as "team activity unknown" |
| Codebase | Full scan: implementation, DB, API, tests, patterns | Pure PM mode; flag as "no technical context" |

**When degraded:** explicitly tell PM what context is missing and how it affects confidence:

```
⚠️ Працюю без Confluence — не можу перевірити чи є специфікація.
   Це знижує впевненість в повноті вимог.
   Рекомендую підключити: /pm:setup confluence
```
