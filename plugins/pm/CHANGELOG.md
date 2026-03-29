# Changelog

All notable changes to the PM plugin will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
