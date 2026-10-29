# Overview

LRColorHarmony is a Lightroom Classic plugin whose purpose is to assist in color grading images using mathematical or perceptual color-harmony patterns.

Lightroom Classic is the first supported host. Photoshop integration and image-aware harmony recommendations are future goals.

# Responses

Be crisp and concise. Do not overexplain or praise ordinary work merely to keep the conversation going. State uncertainty and distinguish verified behavior from assumptions.

# Engineering principles

- Observe SOLID principles. Prefer small, cohesive modules with explicit responsibilities and interfaces.
- Keep harmony mathematics and tonal mapping independent of Adobe-specific APIs; isolate Lightroom integration behind a host adapter.
- Favor the simplest implementation that meets the current requirements. Avoid speculative abstractions and dependencies.
- Preserve Lightroom's native, nondestructive editing workflow. Do not require Photoshop or rendered intermediate files for Lightroom-only grading.
- Do not change unrelated Develop parameters. Capture the original values of every parameter changed and support exact restoration.
- Do not overwrite existing grading silently. Preview, Apply, and Cancel behavior must be explicit and tested.
- Validate SDK parameter names, ranges, read/write semantics, and UI behavior against the installed Lightroom Classic version; do not depend on undocumented behavior.
- Handle missing active photographs, unsupported API behavior, and errors without leaving partial edits.
- Do not introduce network access, image uploads, telemetry, or external processing without an explicit architectural decision.

# Development workflow

1. Read relevant source, tests, `docs/README.md`, and applicable ADRs before making changes.
2. Define the smallest verifiable slice and acceptance criteria.
3. Write deterministic tests for pure harmony logic and run local Lightroom integration tests for host behavior.
4. Report what was actually tested and what remains unverified. Never claim Lightroom integration was tested without running it in Lightroom.
5. Keep commits focused. Avoid unrelated refactors and silent dependency changes.
6. Document material architectural decisions as ADRs before implementation.

# Architecture Decision Records

ADRs live in `docs/adr/` and follow `docs/README.md`.

Use four-digit sequential identifiers and lowercase hyphen-separated English filenames, for example `0001-lightroom-classic-first-and-nondestructive.md`.

Each ADR begins with `# ADR NNNN: Title` and `**status**: <status> — YYYY-MM-DD`, then Context, Decision, Consequences, and Implementation Notes in that order.

Allowed statuses: `waiting`, `accepted`, `declined`, `amended`, `implemented`. Proposed decisions start as `waiting`; only mark them `accepted` after owner approval. `implemented` is a verified lifecycle milestone. Preserve historical decisions and link superseding ADRs when amending them.

# Testing

- Unit-test hue wrapping, harmony geometry, and tonal assignments with known fixtures.
- Integration-test grading reads, writes, restoration, and preservation of unrelated Develop settings on both ungraded and previously graded images.
- Use virtual copies or disposable catalogs for risky host experiments.
- Measure preview responsiveness and Develop history behavior before adopting continuous slider updates.

# Initial milestone

Implement the feasibility spike in ADR 0001: load a minimal `.lrdevplugin`, apply a known complementary shadow/highlight grade, read it back, and restore the original values without disturbing unrelated edits. Defer elaborate UI, Photoshop integration, and image analysis until the spike succeeds.
