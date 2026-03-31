# MCP Tool Reference — Correct Usage Patterns

**CRITICAL: Always use ToolSearch to load tool schemas before first MCP call in a session.**

This reference prevents common mistakes when calling MCP tools. Claude MUST follow these patterns exactly.

---

## Jira

### Search issues (JQL)

```
Tool:  mcp__jira__jira_post
Path:  /rest/api/3/search/jql
Body:  {"jql": "project=MB ORDER BY created DESC", "maxResults": 10, "fields": ["summary", "status", "assignee", "priority"]}
```

- **POST, not GET** — `/rest/api/3/search/jql` is POST-only
- **Always include `fields`** — without it, response contains only `id`
- `/rest/api/3/search` is **REMOVED** (HTTP 410) — never use it

### Get single issue

```
Tool:  mcp__jira__jira_get
Path:  /rest/api/3/issue/{issueKey}
JQ:    {key: key, summary: fields.summary, status: fields.status.name, description: fields.description}
```

### Get issue comments

```
Tool:  mcp__jira__jira_get
Path:  /rest/api/3/issue/{issueKey}/comment
```

### List projects

```
Tool:  mcp__jira__jira_get
Path:  /rest/api/3/project
JQ:    [*].{key: key, name: name}
```

---

## Confluence

### Search content (CQL)

```
Tool:  mcp__confluence__conf_get
Path:  /wiki/rest/api/search
QueryParams:  {"cql": "type=page AND space=PROJ AND text~\"search term\"", "limit": "10"}
```

### List spaces

```
Tool:  mcp__confluence__conf_get
Path:  /wiki/api/v2/spaces
QueryParams:  {"limit": "25"}
JQ:    results[*].{id: id, key: key, name: name}
```

### Get page with body

```
Tool:  mcp__confluence__conf_get
Path:  /wiki/api/v2/pages/{pageId}
QueryParams:  {"body-format": "storage"}
```

- **Use `queryParams`, NOT `params`** — `params` is silently ignored
- **Body is on the page endpoint itself** — `/wiki/api/v2/pages/{id}/body` returns 404
- **`body-format`** options: `storage` (raw), `atlas_doc_format`, `view` (HTML)

### List pages in space

```
Tool:  mcp__confluence__conf_get
Path:  /wiki/api/v2/pages
QueryParams:  {"space-id": "12345", "limit": "25"}
JQ:    results[*].{id: id, title: title}
```

---

## Sentry

### List issues

```
Tool:  mcp__sentry__list_issues
Query: "is:unresolved"
ProjectSlug: "project-name"
```

### List events for issue

```
Tool:  mcp__sentry__list_issue_events
IssueId: "12345"
```

---

## GitHub

### Use via mcp__github__* tools

GitHub MCP provides high-level tools — use ToolSearch to discover available operations.

---

## Common Mistakes to Avoid

| Mistake | Correct |
|---------|---------|
| `jira_get /rest/api/3/search` | `jira_post /rest/api/3/search/jql` with body |
| `jira_post` without `fields` in body | Always include `"fields": ["summary", "status", ...]` |
| `conf_get` with `params: {...}` | Use `queryParams: {...}` |
| `conf_get /wiki/api/v2/pages/{id}/body` | `conf_get /wiki/api/v2/pages/{id}` + `queryParams: {"body-format": "storage"}` |
| Calling MCP tools without ToolSearch first | Always load schemas: `ToolSearch("select:mcp__jira__jira_get,mcp__jira__jira_post,mcp__confluence__conf_get")` |
