# LRColorHarmony

LRColorHarmony is a Lightroom Classic plugin for photographic color grading using mathematical or perceptual color harmonies. Lightroom Classic is the first host.

## Responses

Be crisp and concise. Do not overexplain or praise ordinary work merely to keep the conversation going. Distinguish verified behavior from assumptions.

## Working agreements

- Observe SOLID principles; favor simple, cohesive, testable modules.
- Follow accepted architecture decisions in `docs/adr/`; see `docs/README.md` for ADR conventions.
- Preserve Lightroom's nondestructive workflow and existing edits.
- Define small, verifiable slices; report actual tests and unresolved risks.
- Do not silently introduce dependencies, network access, telemetry, or changes outside the requested scope.

## Progressive disclosure

Read this file first. Load more specific guidance only when working in its area:

- `docs/AGENTS.md` — ADR authorship, status lifecycle, and documentation practices (when present).
- `lightroom/AGENTS.md` — Lightroom SDK integration, Develop settings, preview/restoration, and host testing (when present).
- `tests/AGENTS.md` — testing conventions and fixture strategy (when present).
- `analysis/AGENTS.md` — future image-analysis design and evaluation (when present).
- `photoshop/AGENTS.md` — future Photoshop integration (when present).

These are **planned locations**, not instructions to create empty directories or files. Before adding a new area-specific `AGENTS.md` or other disclosure document, bring the proposed scope and location to the project owner's attention and obtain agreement. Keep the root file short; move implementation-specific instructions into the appropriate local document as those areas emerge.
