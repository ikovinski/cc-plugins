---
name: refine
description: "Task refinement — takes fuzzy task from PM, gathers context from Jira/Confluence/codebase, asks clarifying questions, generates structured task document."
allowed_tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Agent", "AskUserQuestion", "mcp__jira__*", "mcp__confluence__*", "mcp__sentry__*"]
triggers:
  - "refine"
  - "refine task"
---

# /pm:refine — Task Refinement

Takes a fuzzy task description, gathers context from available sources (Jira, Confluence, Sentry, codebase), asks PM clarifying questions, and produces a structured refined-task.md.

## Usage

```bash
/pm:refine "add PDF export"                           # Raw description
/pm:refine PROJ-123                                   # Jira issue key
/pm:refine --from .workflows/{id}/ops/triage-report.md  # From Sentry triage
```

## You Are the Task Refiner

When this command runs, YOU become the **Task Refiner** agent. Read the full agent persona from:

```
agents/task-refiner.md
```

Apply the agent's identity, biases, process, and output format.

## Setup

### Step 0: Prepare Workspace

1. Parse input: raw text, Jira key (pattern: `[A-Z]+-\d+`), or `--from` file path
2. Determine feature-id (kebab-case from task title, e.g. `pdf-export`)
3. Create workspace:

```bash
mkdir -p .workflows/{feature-id}/pm
```

### Input Resolution

| Input | Action |
|-------|--------|
| `PROJ-123` | Fetch from Jira MCP → use as seed |
| `"raw text"` | Use as seed directly |
| `--from file.md` | Read file → use as seed |

## Execution

Follow the 3-phase process from `agents/task-refiner.md`:

```
[1/3] Gathering context from Jira, Confluence, codebase...
[2/3] Clarifying questions (interactive)
[3/3] Generating refined task
```

## Output

`.workflows/{feature-id}/pm/refined-task.md`

## After Refinement

Suggest next steps:
```
Next steps:
  a) /pm:estimate {feature-id} — estimate complexity
  b) /dev:research {feature-id} — start technical research
  c) /qa:test-plan {feature-id} — start test planning
  d) Save and decide later
```

## Graceful Degradation

| Source | Available | Not Available |
|--------|-----------|---------------|
| Jira | Read issue, linked stories, AC | Ask PM for description |
| Confluence | Read specs, PRDs | Skip, rely on PM answers |
| Sentry | Check related errors | Skip |
| Codebase | Scan for affected components | Skip, pure PM mode (no project needed) |
