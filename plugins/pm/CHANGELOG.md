# Changelog

All notable changes to the PM plugin will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2026-03-30

### Added
- **Parallel context gathering** — Phase [1/5] now launches 4 sub-agents simultaneously instead of sequential MCP calls. ~3x faster context collection.
  - `jira-researcher` (Sonnet) — issue details, comments, linked issues, epic, similar tasks
  - `confluence-researcher` (Sonnet) — specs, PRDs, ADRs, meeting notes
  - `sentry-researcher` (Sonnet) — production issues, error rates, stability
  - `codebase-scanner` (Sonnet) — components, API, DB schema, tests, activity
- **MCP Tool Reference** (`docs/mcp-tool-reference.md`) — correct usage patterns for Jira, Confluence, Sentry, GitHub MCP tools. Each researcher agent has embedded reference to prevent wrong API calls.
- All 5 MCP-using commands (refine, challenge, estimate, accept, codebase) now include mandatory reference to read before first MCP call.

### Changed
- Task Refiner becomes orchestrator — delegates data collection to specialized agents, focuses on analysis, hypotheses, and PM dialogue.
- Sequential fallback preserved when Agent tool is unavailable.

### Fixed
- **Jira search**: `POST /rest/api/3/search/jql` with `fields` in body (not `GET /rest/api/3/search` which returns HTTP 410)
- **Confluence body**: `GET /wiki/api/v2/pages/{id}` + `queryParams: {"body-format": "storage"}` (not `/pages/{id}/body` which returns 404)
- **Confluence params**: `queryParams` (not `params` which is silently ignored)
- Agent path references use `${CLAUDE_PLUGIN_ROOT}` consistently (including challenger reference in task-refiner)

## [0.3.2] - 2026-03-29

### Fixed
- **Agent paths in commands** — all agent references now use `${CLAUDE_PLUGIN_ROOT}/agents/` instead of relative `agents/`. Fixes "File does not exist" when plugin runs from cache outside its own directory (e.g. PM without cloned repo). Affected: refine, challenge, estimate, codebase commands.

## [0.3.0] - 2026-03-29

### Changed
- **MCP connectors: verified working packages**
  - `jira`: stdio, npx `@aashari/mcp-server-atlassian-jira` — env: `ATLASSIAN_JIRA_SITE_NAME`, `ATLASSIAN_USER_EMAIL`, `ATLASSIAN_API_TOKEN`
  - `confluence`: stdio, npx `@aashari/mcp-server-atlassian-confluence` — env: `ATLASSIAN_CONFLUENCE_SITE_NAME`, `ATLASSIAN_USER_EMAIL`, `ATLASSIAN_API_TOKEN`
  - `sentry`: stdio, npx `@sentry/mcp-server` — env: `SENTRY_ACCESS_TOKEN`, `SENTRY_ORG`
  - `github`: stdio, npx `@modelcontextprotocol/server-github` — env: `GITHUB_PERSONAL_ACCESS_TOKEN`
- **Jira and Confluence as separate servers** — different site names supported (e.g. `amomobile` for Jira, `um-guide` for Confluence)
- **SessionStart hook** — checks `ATLASSIAN_JIRA_SITE_NAME`, `ATLASSIAN_CONFLUENCE_SITE_NAME`, `ATLASSIAN_USER_EMAIL`, `ATLASSIAN_API_TOKEN`, `SENTRY_ACCESS_TOKEN`, `SENTRY_ORG`, `GITHUB_PERSONAL_ACCESS_TOKEN`
- **`/pm:setup`** — generates env var block with correct variable names
- All plugin `.mcp.json` files updated (pm, dev, qa, ops)

### Fixed
- Replaced non-existent packages (`@anthropic/mcp-jira`, etc.) with real verified packages
- Tool names now match working system: `mcp__jira__*`, `mcp__confluence__*`, `mcp__sentry__*`, `mcp__github__*`

## [0.2.0] - 2026-03-29

### Added
- **Onboarding UX**: SessionStart hook shows MCP status table on every launch
- **`/pm:setup`**: Interactive MCP configuration wizard — generates shell profile block with token links
- **5-phase refine flow**: transparency → deep context → hypotheses → targeted questions → auto-challenge → generate
- **Hypothesis generation**: Task-refiner generates 2-3+ hypotheses per task from cross-referencing sources
- **Evidence trail**: Every requirement in refined-task.md traced to its source (Jira/Confluence/PM/hypothesis)
- **Contradictions detection**: Flags conflicts between Jira, Confluence, Sentry, and codebase
- **Auto-challenge (Phase 4/5)**: Lightweight 6-lens stress-test built into /pm:refine
- **`/pm:challenge`**: Deep challenge command — full analysis with dedicated MCP queries, readiness score (0-100), verdict
- **Challenger agent**: Skeptic persona with 6 lenses (business, scope, assumptions, user, dependencies, failure modes)
- **`/pm:codebase`**: PM-friendly codebase map — components, APIs, DB, integrations, activity heatmap
- **Codebase Explorer agent**: Dual-mode (local Glob/Grep + remote GitHub API), auto-detects best source
- **Focused mode**: `/pm:codebase --area {component}` for deep dive into one module

### Changed
- Refine flow expanded from 3 phases to 5 (was: context → questions → generate)
- Phase [0/5] now shows execution plan with specific MCP queries per tool
- Questions are targeted — each explains WHY it's being asked with context from sources
- MCP check added to all commands (refine, estimate, accept) with graceful degradation table

## [0.1.0] - 2026-03-29

### Added
- **Task Refiner agent** (Opus): Transforms fuzzy task descriptions into structured specs
- **Estimator agent** (Sonnet): Evidence-based T-shirt sizing with hour ranges
- **`/pm:refine`**: Task refinement from Jira issue, raw text, or file input
- **`/pm:estimate`**: Complexity estimation with Jira historical comparison
- **`/pm:accept`**: Acceptance criteria verification against dev/QA artifacts
- **Skills**: story-formats (User Story, Job Story, WWA, INVEST), estimation (T-shirt, hours, confidence)
- **MCP integration**: Jira, Confluence, Sentry, Git — standardized env vars across all plugins
- **Artifact contracts**: `.workflows/{feature-id}/pm/` output structure
- **Documentation**: overview.md, how-it-works.md with examples
