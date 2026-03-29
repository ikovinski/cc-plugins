---
name: story-formats
description: "PM story formats — User Story (3C's + INVEST), Job Story (JTBD), WWA, Bug Description. Includes format selection guide, acceptance criteria patterns, and non-goals framework."
---

# Story Formats & PM Frameworks

## Story Format Selection

| Signal | Format | Why |
|--------|--------|-----|
| Clear user role + specific action | **User Story** | Role defines context |
| Situation/trigger is key, role irrelevant | **Job Story** | JTBD focuses on context |
| Strategic initiative with business "why" | **WWA** | Needs strategic context |
| Bug fix | **Bug Description** | Observed vs expected format |
| Tech debt / refactoring | **WWA** | Needs justification |

---

## User Story (3 C's + INVEST)

**Format:**
```
As a [role], I want to [action], so that [benefit].
```

**3 C's:** Card (title + one sentence) → Conversation (detailed intent) → Confirmation (AC)

**INVEST Criteria:**
| Criterion | Check |
|-----------|-------|
| **I**ndependent | Can be implemented separately? |
| **N**egotiable | Room for discussion with team? |
| **V**aluable | Gives value to end user or business? |
| **E**stimable | Can estimate the work? |
| **S**mall | Fits in one sprint? |
| **T**estable | Can verify without reading code? |

---

## Job Story (JTBD)

**Format:**
```
When [situation], I want to [motivation], so I can [outcome].
```

**Focus:** user context, not role. What happens → what they want → what result.

---

## WWA (Why-What-Acceptance)

**Format:**
```
Why: [1-2 sentences — link to strategy]
What: [description + design reference]
Acceptance: [verifiable outcomes]
```

---

## Bug Description

```
## Bug: {Title}

**Observed:** {What happens now}
**Expected:** {What should happen}
**Steps to Reproduce:** {How to reproduce}
**Frequency:** {Always / Sometimes / Rarely}
**Impact:** {Who is affected and how}
```

---

## Acceptance Criteria Rules

1. **Testable** — QA can verify without reading code
2. **3-6 criteria** — forces precision
3. **Coverage:** happy path + error case + edge case
4. **Language:** observable behavior, not technical implementation

### Given/When/Then Format

```
Given [precondition/context],
When [user action],
Then [expected result].
```

### Good vs Bad AC

| Good | Bad |
|------|-----|
| "User sees error message on wrong password" | "System throws ValidationException" |
| "Export completes in under 30s for 1000 records" | "Use batch processing" |
| "After payment user receives confirmation email" | "Send event to RabbitMQ" |

---

## Non-Goals Framework

Explicitly list what is NOT in scope:

1. **From dialogue:** PM said "maybe later", "nice to have" → Non-Goal
2. **Adjacent work:** things someone might assume are included but aren't
3. **Technical decisions:** what we consciously don't change

```
## Non-Goals
- {Non-goal} — {reason or "can be follow-up"}
```

---

## Requirements Prioritization

### Must-Have (P0)
Without these the task is not done. Usually 2-4 requirements.

### Nice-to-Have (P1)
Improvements that add value but can be follow-up PR. Usually 1-3 requirements.

```
**R{N}. {Title}**
- {1-2 sentence description}
- Acceptance criteria:
  - [ ] {Testable criterion}
  - [ ] {Testable criterion}
```

---

## Risk Flag Patterns

| Pattern in Task | Risk | Severity |
|----------------|------|----------|
| "payment", "billing", "subscription" | **SECURITY:** payment data handling | high |
| "export", "import", "data migration" | **DATA:** large volumes, performance | medium |
| "external API", "integration", "webhook" | **DEPENDENCY:** external service availability | medium |
| "auth", "permissions" | **SECURITY:** access control | high |
| "health data", "medical", "PHI" | **COMPLIANCE:** personal data protection | high |
| Affects shared component | **COORDINATION:** other teams may be involved | medium |
| No clear AC after dialogue | **SCOPE:** requirements still ambiguous | high |
