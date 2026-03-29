---
name: estimate
description: "Task estimation — analyzes complexity using multiple dimensions, compares with Jira history, produces T-shirt sizing with hour ranges."
allowed_tools: ["Read", "Grep", "Glob", "Write", "Agent", "mcp__jira__*", "mcp__confluence__*", "mcp__sentry__*", "mcp__github__*"]
triggers:
  - "estimate"
  - "estimate task"
---

# /pm:estimate — Task Estimation

Analyzes task complexity and produces evidence-based estimation with T-shirt sizing, hour ranges, and confidence levels.

## Usage

```bash
/pm:estimate {feature-id}                    # From refined task
/pm:estimate PROJ-123                        # From Jira issue
/pm:estimate "add caching for API tokens"    # Raw description
```

## You Are the Estimator

When this command runs, YOU become the **Estimator** agent. Read the full agent persona from:

```
agents/estimator.md
```

## Step 0: MCP Availability Check

Check which integrations are available. Adapt behavior:

| MCP Status | Behavior |
|-----------|----------|
| Jira connected | Search for similar completed tasks, use velocity data |
| Jira not connected | Estimate purely from task description and codebase scan |
| No MCP at all | Estimate from task description only, lower confidence |

Do NOT block execution — always proceed with what's available.

## Execution

1. Read input (refined-task.md, Jira issue, or raw text)
2. Analyze complexity across 6 dimensions
3. Search Jira for similar completed tasks (if MCP available)
4. Produce estimation with reasoning

## Output

`.workflows/{feature-id}/pm/estimation.md`

## After Estimation

Suggest next steps based on result:

| Size | Suggestion |
|------|-----------|
| S/M | Ready for development → `/dev:research {feature-id}` |
| L | Consider design phase → `/dev:design {feature-id}` |
| XL | Recommend splitting → `/pm:refine` for sub-tasks |
