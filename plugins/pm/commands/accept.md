---
name: accept
description: "Acceptance criteria verification — checks implementation against PM's acceptance criteria from refined task, using Jira, code, and test results."
allowed_tools: ["Read", "Grep", "Glob", "Bash", "Write", "Agent", "AskUserQuestion", "mcp__jira__*", "mcp__confluence__*", "mcp__sentry__*"]
triggers:
  - "accept"
  - "acceptance check"
  - "verify acceptance"
---

# /pm:accept — Acceptance Criteria Verification

Verifies that implementation meets the acceptance criteria defined during refinement. Bridges PM and Dev/QA by checking real artifacts against business requirements.

## Usage

```bash
/pm:accept {feature-id}                     # Check against refined-task.md
/pm:accept {feature-id} --update-jira       # Also update Jira issue status
```

## Step 0: MCP Availability Check

Check which integrations are available. Adapt behavior:

| MCP Status | Behavior |
|-----------|----------|
| Jira connected | Load AC from Jira, update issue status after verification |
| Sentry connected | Check for new production errors post-deployment |
| Git connected | Check PR status, merge state |
| None connected | Load AC from local artifacts only |

Do NOT block execution — always proceed with what's available.

## Process

### Step 1 — Load Criteria

Read acceptance criteria from (priority order):
1. `.workflows/{feature-id}/pm/refined-task.md` → Requirements section
2. Jira issue → AC field (if Jira key in source)

### Step 2 — Gather Evidence

For each acceptance criterion, check:

| Source | What to Check |
|--------|--------------|
| Dev artifacts | `.workflows/{id}/dev/phase-*-report.md` — what was implemented |
| QA artifacts | `.workflows/{id}/qa/test-cases.md` — what was tested |
| QA results | `.workflows/{id}/qa/regression-report.md` — any failures |
| Code | Grep/Glob for implemented features |
| Sentry | New errors after deployment (if available) |

### Step 3 — Produce Verification Report

For each criterion mark:
- **PASS** — evidence found that criterion is met
- **FAIL** — evidence that criterion is NOT met
- **UNCLEAR** — cannot determine from available data, needs manual check

### Step 4 — Ask PM for Unclear Items

Present unclear items to PM for decision via AskUserQuestion.

## Output

`.workflows/{feature-id}/pm/acceptance-report.md`:

```markdown
---
plugin: pm
artifact: acceptance-report
feature: {feature-id}
created: {ISO 8601}
---

# Acceptance Report: {Task Title}

## Summary

| Status | Count |
|--------|-------|
| PASS | {N} |
| FAIL | {N} |
| UNCLEAR | {N} |

**Verdict:** {ACCEPTED / REJECTED / NEEDS REVIEW}

## Criteria Verification

### R1. {Requirement Title}

**AC 1.1:** {criterion text}
- **Status:** PASS
- **Evidence:** {what confirms it}

**AC 1.2:** {criterion text}
- **Status:** FAIL
- **Evidence:** {what contradicts it}
- **Action needed:** {what to fix}

## Recommendations

- {What to do next — fix failures, clarify unclear, or ship}
```

## After Verification

| Verdict | Suggest |
|---------|---------|
| ACCEPTED | Close Jira, proceed to release |
| REJECTED | List failures → `/dev:implement` fixes |
| NEEDS REVIEW | Ask PM to manually verify unclear items |
