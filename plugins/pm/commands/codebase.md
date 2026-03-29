---
name: codebase
description: "PM-friendly codebase overview — components, APIs, DB, integrations, activity. Works locally (in project) or remotely (GitHub MCP). Auto-detects best source."
allowed_tools: ["Read", "Grep", "Glob", "Bash", "Write", "Agent", "AskUserQuestion", "mcp__jira__*", "mcp__confluence__*", "mcp__sentry__*"]
triggers:
  - "codebase"
  - "explore code"
  - "show project"
  - "project map"
  - "кодова база"
---

# /pm:codebase — Codebase Explorer

Builds a PM-friendly map of the project: components, API endpoints, DB entities, integrations, and activity — without reading raw code. Works with local project, GitHub API, or both.

## Usage

```bash
/pm:codebase                                    # Auto-detect (local project or ask for repo)
/pm:codebase owner/repo                         # Remote repo via GitHub MCP
/pm:codebase --area health                      # Focus on one component/module
/pm:codebase owner/repo --area billing          # Remote + focused
/pm:codebase --refresh                          # Re-scan (update existing context)
```

## You Are the Codebase Explorer

When this command runs, YOU become the **Codebase Explorer** agent. Read the full agent persona from:

```
agents/codebase-explorer.md
```

## Step 0: Source Resolution

Auto-detect what's available and show PM:

```bash
# Check if in a git repo
git rev-parse --git-dir 2>/dev/null

# Check MCP status
bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-mcp-status.sh"
```

### Decision Matrix

| In project? | GitHub MCP? | Repo arg? | Mode | What happens |
|-------------|------------|-----------|------|-------------|
| ✅ | ✅ | — | **Combined** | Local deep scan + GitHub activity/PRs |
| ✅ | ❌ | — | **Local** | Full local scan, no remote data |
| ❌ | ✅ | ✅ | **Remote** | GitHub API for everything |
| ❌ | ✅ | ❌ | **Ask** | Ask PM for repo: "Which repository?" |
| ❌ | ❌ | — | **Blocked** | Cannot explore. Suggest: `/pm:setup git` or `cd` to project |

**Show resolution:**

```
📦 Codebase Explorer

Sources:
  Local     ✅ /Users/ivan/repo/bodyfit-api
  GitHub    ✅ Connected → acme/bodyfit-api (auto-detected from git remote)
  Sentry    ✅ Connected → will check error hotspots
  Mode:     Combined

Scanning...
  Phase 1/6: Project identity
  Phase 2/6: Component map
  Phase 3/6: API surface
  Phase 4/6: Data model
  Phase 5/6: Integration map
  Phase 6/6: Activity & health
```

### Remote Repository Resolution

When `owner/repo` argument provided — use it directly.

When in a local git project — auto-detect remote:
```bash
git remote get-url origin
# Parse: https://github.com/{owner}/{repo}.git → owner/repo
# Parse: git@github.com:{owner}/{repo}.git → owner/repo
```

## Execution

Follow the 6-phase scan strategy from `agents/codebase-explorer.md`.

**Parallel execution where possible:**
- Phase 1 (identity) + Phase 6 (activity) can run in parallel
- Phase 2 (components) must complete before Phase 3-5

### Local Scan Strategy

```
Glob patterns (adapted to detected framework):

Symfony/PHP:
  src/*/               → components
  src/Controller/       → API controllers
  src/Entity/           → data model
  src/MessageHandler/   → async processing
  config/routes/        → route configuration
  migrations/           → DB changes

Laravel/PHP:
  app/Http/Controllers/ → API
  app/Models/           → data model
  routes/               → route definitions
  database/migrations/  → DB changes

Express/Node:
  src/routes/ OR routes/  → API
  src/models/ OR models/  → data model
  src/services/           → business logic

Django/Python:
  */views.py              → API
  */models.py             → data model
  */urls.py               → routes

Go:
  internal/*/             → components
  cmd/*/                  → entry points
  **/handler*.go          → API handlers
```

### Remote Scan Strategy (GitHub API)

```
Step 1: GET /repos/{owner}/{repo}
  → language, description, default branch

Step 2: GET /repos/{owner}/{repo}/git/trees/{branch}?recursive=1
  → full file tree → identify framework → select scan patterns

Step 3: Read key files (max 15-20 file reads):
  → Package manifest (composer.json, package.json, etc.)
  → Route config files
  → Entity/model directory listing
  → Config files (.env.example, docker-compose.yml)
  → README

Step 4: Search code (max 5-10 searches):
  → Route definitions
  → Entity/model declarations
  → External service client usage
  → Test file patterns

Step 5: GET /repos/{owner}/{repo}/commits?since={2 weeks ago}
  → Recent activity per path

Step 6: GET /repos/{owner}/{repo}/pulls?state=open
  → Active work in progress
```

## Output

### Default: save as artifact

`.workflows/{feature-id}/pm/codebase-context.md` — if inside a workflow

OR

`codebase-context.md` in current directory — if standalone

### --refresh flag

Re-run scan and update existing `codebase-context.md`. Show diff:

```
📦 Codebase Context Updated

Changes since last scan (3 days ago):
  + New component: Notifications (3 files)
  ~ Health module: 5 new commits, 1 new endpoint
  ~ Billing module: PR #489 merged (subscription refactor)
  - Deprecated: OldAuthMiddleware removed
```

## Integration with Other Commands

### Auto-loaded by /pm:refine

Task-refiner checks for existing codebase-context.md:

```
1. .workflows/{feature-id}/pm/codebase-context.md  → use
2. codebase-context.md in CWD                      → use
3. Neither exists + local project available         → run quick local scan
4. Neither exists + GitHub MCP only                 → run remote scan
5. Nothing available                                → skip, flag as "no codebase context"
```

### Focused scan for task-refiner

When task-refiner identifies relevant components from the task description, it can request a focused re-scan:

```
Task mentions "health sync" →
  Found in codebase-context: Health component (15 files, 4 endpoints)
  → Auto-run focused scan on Health component for deeper context
```

## PM-Friendly Output Rules

1. **No code snippets** — describe WHAT things do, not HOW they're implemented
2. **Business descriptions** — "Handles user subscriptions and payments" not "SubscriptionController with 12 action methods"
3. **Activity = priority signal** — 🔥 active / 🟢 stable / 💤 dormant helps PM understand where team is focused
4. **Risk = PM actionable** — "No tests in billing module" means PM should allocate testing time
5. **Numbers for context** — file counts, endpoint counts, error rates — but not line counts
