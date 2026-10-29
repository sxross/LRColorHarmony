# ADR 0001: Lightroom Classic first and nondestructive

**status**: accepted — 2026-10-28

## Context

LRColorHarmony will help photographers choose color harmonies and map them to shadow, midtone, and highlight grading. Many images require no Photoshop work; requiring a Photoshop round-trip would add unnecessary friction and rendered intermediate files.

The first milestone must establish whether Lightroom Classic can apply, read back, and restore its native Color Grading settings through supported plugin APIs. Success is measured on both an ungraded photograph and a photograph with existing grading: apply a known harmony, retain native editable grading, restore the original values, and leave all unrelated Develop settings unchanged.

Photoshop support and image-aware recommendations remain longer-term goals, not prerequisites for Lightroom usefulness.

## Decision

Prioritize Lightroom Classic as the first host. Apply harmony choices as native, nondestructive Lightroom Color Grading settings wherever supported by the SDK. Do not require exporting a TIFF/PSD or opening Photoshop for the initial workflow.

Gate UI development on a small SDK feasibility spike verifying the exact grading parameters, their ranges, write/read behavior, preview responsiveness, and reversible edits. Keep harmony calculations independent of host integration so a future Photoshop adapter can implement the same behavior contract.

Alternatives considered: Photoshop-first UXP development (richer UI but unnecessary round-trips); rendered-image processing (greater pixel-level control but breaks native Develop editability); a cross-host runtime before feasibility is established (premature complexity).

## Consequences

The Lightroom SDK's API and UI limits shape the first implementation. The plugin must modify only intended grading values, preserve unrelated edits, and provide reliable apply/cancel semantics. SDK integration tests must run in Lightroom; pure harmony calculations can be tested independently.

Repeated parameter updates may affect responsiveness or Develop history, so interactive performance and undo behavior require measurement. Lightroom and Photoshop may render similar harmony specifications differently; identical numeric settings do not guarantee identical visual output.

This decision improves the Lightroom-native RAW workflow while constraining interface design to what the host actually supports.

## Implementation Notes

Start with a minimal `.lrdevplugin` and menu command. Capture the original grading parameters, apply a complementary shadow/highlight treatment, read back values, and restore originals. Test on virtual copies, including one with existing grading, and verify that unrelated Develop adjustments remain unchanged.

Do not build a full harmony UI or image-analysis pipeline until this proof succeeds. Avoid undocumented SDK behavior and assumptions of visual equivalence with Photoshop adjustment layers.
