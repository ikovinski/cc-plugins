---
name: estimation
description: "T-shirt sizing framework — complexity dimensions, hour estimation ranges, confidence levels, historical comparison patterns."
---

# Estimation Frameworks

## T-Shirt Sizing

### Size Table

| Size | Indicators | Typical Scope | Examples |
|------|-----------|---------------|----------|
| **S** | 1-3 files, 1 component, no new API, no DB changes | Config change, UI tweak, copy update | Change error text, add field to existing form |
| **M** | 4-10 files, 2-3 components, minor API change | New endpoint, new field, simple feature | Add filter to list, new profile field |
| **L** | 10-20 files, 3-5 components, new integration or DB migration | Feature with multiple stories | PDF export, Stripe integration |
| **XL** | 20+ files, cross-domain, external deps, migration | Epic — needs decomposition | Notification system, new auth |

### Complexity Dimensions

| Question | S | M | L | XL |
|----------|---|---|---|-----|
| Components affected? | 1 | 2-3 | 3-5 | 5+ |
| DB changes needed? | No | Add field | New tables | Data migration |
| New API endpoints? | No | 1 | 2-3 | 4+ |
| External dependencies? | No | No | 1 | 2+ |
| New UI screen needed? | No | No | Partial | Full |
| Unknown factors? | None | 1 | 2-3 | Many |

### Hour Estimation

| Size | Development | Testing | Total |
|------|-------------|---------|-------|
| **S** | 1-4h | 0.5-2h | 1.5-6h |
| **M** | 4-12h | 2-4h | 6-16h |
| **L** | 12-30h | 4-10h | 16-40h |
| **XL** | 30-60h+ | 10-20h+ | 40-80h+ |

Adjust based on:
- Existing pattern in project (reduces time)
- Undocumented external integration (increases time)
- Data migration needed (increases testing)

### Confidence Levels

| Level | When |
|-------|------|
| **High** | Clear scope, familiar domain, clear AC |
| **Medium** | Scope clear, but unknowns exist (external API, performance) |
| **Low** | Unclear scope, many Open Questions, unfamiliar integration |

---

## Success Metrics Templates

| Task Type | Metrics |
|-----------|---------|
| Performance | Latency (p50, p99), error rate, throughput |
| Caching | Cache hit ratio, TTL effectiveness |
| Bug fix | Reproduction rate → 0%, affected users count |
| New feature | Adoption rate, completion rate |
| Integration | Success rate, retry rate, fallback rate |

### Format

```
| Metric | Current | Target | How to Measure |
|--------|---------|--------|----------------|
| {what} | {now}   | {goal} | {tool/method}  |
```

---

## Clarifying Question Templates

### Categories (prioritized)

#### Who
- "Who will use this? E.g.: end users, admins, or both?"
- "Are there different access levels? E.g.: free vs premium?"

#### Trigger
- "What triggers the need? What situation is the user in?"
- "How often will this be used? Daily, weekly, rarely?"

#### Behavior
- "How should this work from the user's perspective? Step by step."
- "Is there an example from another product that works how you imagine?"

#### Edge Cases
- "What should happen if something goes wrong? E.g.: no internet, invalid data."
- "Are there limits? E.g.: max count, file size."

#### Priority
- "How urgent is this? Is there a deadline?"
- "What happens if we don't do this soon?"

#### Dependencies
- "Does this depend on another task or feature that's not ready yet?"
- "Do we need info from another team or external service?"

### Dialogue Rules

1. Max 2-3 questions per round
2. Max 3 rounds — then synthesize, gaps → Open Questions
3. Always give examples/options
4. Confirm understanding between rounds
5. "Don't know" is fine — record as Open Question
