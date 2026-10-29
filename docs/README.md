# Architecture Decision Records

Architecture Decision Records (ADRs) live in [adr/](adr/).

## Naming

Use four-digit sequential identifiers followed by meaningful, lowercase, hyphen-separated English titles, for example:

`0001-lightroom-classic-first-and-nondestructive.md`

Never reuse an identifier. Preserve existing ADRs as historical records.

## Format

Each ADR contains, in this order:

```markdown
# ADR 0001: Meaningful decision title

**status**: waiting — YYYY-MM-DD

## Context

Describe the feature or problem in sufficient detail to measure implementation success.

## Decision

Document the decision, rationale, and relevant alternatives considered.

## Consequences

Describe the blast radius: affected components, workflows, benefits, risks, and performance implications.

## Implementation Notes

Document preferred or discouraged implementation approaches, if any.
```

The permitted statuses are `accepted`, `waiting`, `declined`, `amended`, and `implemented`. The date is the date of the current status, in `YYYY-MM-DD` format.

## Lifecycle conventions

- **waiting**: a proposed decision pending acceptance.
- **accepted**: the decision has been approved, but may not yet be implemented.
- **declined**: the proposal was considered and rejected.
- **implemented**: the accepted decision has been implemented and verified. This is a lifecycle milestone, not a replacement for the underlying decision.
- **amended**: a material change is documented in a new ADR; link to that superseding ADR and preserve the original historical decision.

Do not silently rewrite historical decisions. The Implementation Notes section remains present even if it simply states that no implementation approach has been chosen.
