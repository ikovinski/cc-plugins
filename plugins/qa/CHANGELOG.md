# Changelog

All notable changes to the QA plugin will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-03-31

### Added
- **`/qa:checklist`** — QA checklist generator from any format: PDF, images, text, URL, Jira issue, Confluence page
- **QA Engineer agent** (Sonnet) — applies test design techniques, generates structured checklists
- **Test Design Techniques skill** — EP, BVA, Decision Table, State Transition, Pairwise, Error Guessing, Checklist-based Testing with pre-defined checklists (iOS/Android, API, A/B testing)
- **MCP integration** — fetch feature descriptions directly from Jira issues and Confluence pages
- **PM artifact integration** — auto-reads `refined-task.md` for acceptance criteria and business context
- **Quality Gate** — QA Team Lead review step before saving checklist
- **Graceful degradation** — works without MCP in dialogue mode
- **Platform detection** — generates platform-specific checklists (iOS / Android / Backend)
- MCP tool reference (`docs/mcp-tool-reference.md`) for correct Jira/Confluence API usage
- Plugin overview documentation (`docs/overview.md`)

## [0.1.0] - 2026-03-29

### Added
- Initial plugin scaffold: plugin.json, .mcp.json
- Placeholder directories: agents/, commands/, skills/
