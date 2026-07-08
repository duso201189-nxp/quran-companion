---
id: PROJ-P-005
name: non-commercial-translation-license
tier: constraint
scope: project
status: active
supersedes: null
version_introduced: 0.1.0
owner_role: release-owner
review_by: 2027-01-08
---

## Rule

Tanzil's translation and transliteration data (English Sahih
International, transliteration) is licensed non-commercial. This app may
not introduce paid features, ads, or any commercial model without either
securing separate permission from Tanzil or replacing those data sources.

## Rationale

Already flagged in `docs/DATA_PIPELINE.md` and `TODO.md`'s legal section
as a pre-release blocker if monetization is ever introduced. Elevated to
a Constitution-level constraint — not just a TODO line — because it's
exactly the kind of easy-to-forget legal fact `CORE-P-009`-style
Engineering Memory categories exist to prevent silently dropping. A
`review_by` date is set (unlike most other entries here) specifically
because licensing terms are the kind of fact that can change upstream
without this project noticing unless someone deliberately re-checks it.

## Applies To

Any future decision to monetize this app in any form. Should be checked
again before any release that introduces payment, ads, or a paid tier.
