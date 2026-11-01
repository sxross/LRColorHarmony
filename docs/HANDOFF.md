# LRColorHarmony — Project Handoff

**Status:** Slice 0 — Lightroom SDK feasibility testing  
**As of:** October 31, 2026  
**Repository:** https://github.com/sxross/LRColorHarmony  
**Branch:** `main`  
**Baseline before this handoff:** `8aebe0f`  
**Target host:** Adobe Lightroom Classic 15.4.1, macOS (version assumed pending local confirmation)

## 1. Executive summary

LRColorHarmony is a photographic color-grading tool intended to help photographers apply mathematically and perceptually meaningful color harmonies. Lightroom Classic is the first host; Photoshop integration and image-aware suggestions are future possibilities.

The central architectural principle is **native, nondestructive Lightroom Color Grading**, without requiring Photoshop or rendered intermediate files.

The project is in Slice 0, a feasibility phase before building a production interface or harmony engine.

The first probe succeeded: Lightroom accepted programmatic shadow/highlight grading, rendered changes visibly, and restored original values, including on a photograph with preexisting grading. However, temporary operations remained in Develop history. A second set of experiments addressing history grouping and Undo has been committed but not yet tested in Lightroom.

**Immediate task:** Run the three History Probe commands and determine whether an acceptable Preview / Apply / Cancel / Undo model is feasible.

## 2. Product vision

### The problem

Lightroom Classic offers detailed Color Grading controls, but photographers must largely work out harmonious relationships and their tonal assignments manually. LRColorHarmony should make it easier to explore deliberate color relationships while retaining creative control.

### Intended workflow

A photographer selects an image, invokes LRColorHarmony, chooses or explores a color harmony, adjusts its tonal treatment, previews the result, and applies it. The resulting edits remain accessible through Lightroom's native Color Grading controls.

The product should **assist artistic decisions**, not impose a supposedly correct look.

### Candidate capabilities (not yet accepted requirements)

- Complementary, split-complementary, analogous, triadic, and tetradic harmonies.
- Adjustable hue relationships and rotation.
- Assignment of colors to shadows, midtones, and highlights.
- Strength, saturation, luminance, and balance controls.
- Perceptually informed calculations and potentially image-aware recommendations.

The color model, precise feature set, and UI remain undecided.

### Longer-term direction

1. **Lightroom Classic:** Useful standalone native-grading plugin.
2. **More sophisticated harmony assistance:** Evaluate perceptual color models and image-aware recommendations.
3. **Photoshop:** Investigate UXP integration, sharing host-independent harmony logic where practical.

Photoshop is not a prerequisite for the Lightroom product.

## 3. Accepted architecture and working conventions

### ADR 0001

`docs/adr/0001-lightroom-classic-first-and-nondestructive.md`  
**Status:** accepted — 2026-10-28

This decision establishes Lightroom-first delivery, native nondestructive grading, an SDK feasibility gate before substantial UI development, and separation of harmony calculations from Adobe host integration. Do not mark it `implemented` merely because the initial probe succeeded.

### Engineering guidance

- `AGENTS.md`: Concise project-wide guidance, SOLID principles, small verifiable slices, and progressive-disclosure navigation.
- `lightroom/AGENTS.md`: Lightroom SDK constraints, Develop safety, restoration, and host testing.
- `docs/README.md`: ADR format and lifecycle.

**Progressive-disclosure rule:** Before creating any new area-specific `AGENTS.md` or other disclosure document, propose its location and scope to the project owner and obtain approval. Do not prepopulate speculative guidance files. This handoff is a project-status document, not an agent instruction file.

ADR filenames use four-digit sequential numbers and hyphenated English slugs. Each ADR contains Context, Decision, Consequences, and Implementation Notes, in that order. Valid statuses: `waiting`, `accepted`, `declined`, `amended`, `implemented`.

### Architectural separation (conceptual, not yet fully implemented)

- **Harmony engine:** Host-independent harmony mathematics and tonal mapping.
- **Lightroom adapter:** SDK parameter reads/writes, preservation, and host behavior.
- **Interaction layer:** Preview, Apply, Cancel, and Undo workflows.

Avoid building speculative abstractions before the corresponding slice requires them.

## 4. Repository state

Relevant files at handoff:

```text
LRColorHarmony/
├── AGENTS.md
├── README.md
├── docs/
│   ├── README.md
│   ├── HANDOFF.md
│   └── adr/
│       └── 0001-lightroom-classic-first-and-nondestructive.md
└── lightroom/
    ├── AGENTS.md
    └── LRColorHarmony.lrdevplugin/
        ├── Info.lua
        ├── Main.lua
        ├── DevelopProbe.lua
        ├── HistoryProbe.lua
        ├── HistoryPlain.lua
        ├── HistoryGrouped.lua
        └── HistoryRestore.lua
```

Lightroom Classic provides the Lua runtime and SDK APIs required to execute the plugin; no separate Lua installation is needed. Adobe's SDK download remains useful as a documentation reference.

To run: pull `main`, open Lightroom Classic, choose **File → Plug-in Manager → Add**, and select `lightroom/LRColorHarmony.lrdevplugin`. Run commands from **Library → Plug-in Extras**. Reload the plugin or restart Lightroom if code changes appear cached.

## 5. Slice 0: initial grading feasibility probe

### Objective

Prove that native Color Grading parameters can be read, changed, visibly rendered, and restored while preserving prior grading.

### Parameters tested

| Parameter | Target | Observed range |
|---|---:|---:|
| `SplitToningShadowHue` | 210 | 0–360 |
| `SplitToningShadowSaturation` | 20 | 0–100 |
| `SplitToningHighlightHue` | 30 | 0–360 |
| `SplitToningHighlightSaturation` | 20 | 0–100 |

The probe snapshots values, validates ranges, applies fixed complementary colors, reads back, and restores originals.

### Runtime issue resolved

The first version failed with `Yielding is not allowed within C or metamethod call` because it used standard Lua `pcall()` around yield-capable SDK operations. It was corrected to use Lightroom's yield-aware `LrTasks.pcall()`.

### Actual host result

The user reported:

```text
Color Grading feasibility probe (test photo only)
Apply: completed
Restore: readback matched
SplitToningShadowHue: original=0 target=210 readback=210 range=[0,360]
SplitToningShadowSaturation: original=0 target=20 readback=20 range=[0,100]
SplitToningHighlightHue: original=0 target=30 readback=30 range=[0,360]
SplitToningHighlightSaturation: original=0 target=20 readback=20 range=[0,100]
Check Develop history and unrelated settings manually.
```

The user observed a brief visible grading change followed by a return to the original appearance. A subsequent test with existing grading confirmed that the control settings were preserved.

### What is verified

- The four tested grading parameters support read/write and numeric readback.
- Lightroom renders their changes.
- Original values can be restored.
- Preexisting grading control settings were preserved in the tested scenario.

### What is not yet verified

- Exact preservation of all unrelated Develop settings in all cases.
- Recovery from interruptions or partial failure.
- Rapid or repeated interactive preview.
- Midtone/global grading, balance, blending, and luminance support.
- Clean history and single-step Undo.
- Production-ready Apply/Cancel semantics.

These results establish feasibility for a narrow set of parameters, not a complete product.

## 6. Develop history: unresolved architectural question

After the original apply/restore probe, the user reported that Lightroom's History panel included their earlier edits plus `Shadow Hue` and `Multiple Settings` entries.

The image and controls returned to their previous state, **but temporary operations remained in history**.

Desired product behavior:

- **Apply:** A committed harmony should ideally be one coherent history/Undo operation.
- **Cancel:** Restore the original appearance without cluttering history with temporary previews.
- **Undo:** Ideally revert the entire applied harmony with one Undo.

Do not assume Lightroom's SDK provides atomic multi-parameter transactions or history removal.

## 7. Current work: History Probe

The latest implementation adds three commands to **Library → Plug-in Extras**:

| Command | Purpose |
|---|---|
| History Probe: Plain Apply (leaves changes) | Baseline history and Undo behavior |
| History Probe: Grouped Apply (leaves changes) | Evaluate SDK history grouping |
| History Probe: Grouped Apply + Restore | Evaluate history after rapid restoration |

The shared implementation is `HistoryProbe.lua`; the menu wrappers are `HistoryPlain.lua`, `HistoryGrouped.lua`, and `HistoryRestore.lua`.

Grouped experiments call `LrDevelopController.setTrackingDelay()` and `setMultipleAdjustmentThreshold()`. These controls are **not assumed to provide transactional behavior**. The probe resets them to assumed defaults afterward; it cannot preserve unknown custom values.

**No host test results have yet been reported for these three experiments.**

### Test instructions

Use **three separate disposable virtual copies**, preferably of a photo with existing shadow/highlight grading.

1. **Plain Apply:** Run, inspect the History panel, invoke Undo once, and check whether all four controls revert.
2. **Grouped Apply:** Repeat on a second copy; compare history entries and one-step Undo behavior.
3. **Grouped Apply + Restore:** Run on a third copy; verify restored grading and inspect whether history gained entries.

For each experiment record: success/error text, history entries in order, number of Undo steps needed, final values and appearance, changes to unrelated controls, and any delays or unusual behavior. Screenshots of History are useful.

The first two experiments **intentionally leave grading applied**. Do not run on valuable originals.

## 8. Risks and technical constraints

**History/cancellation:** Primary architectural uncertainty. If clean cancellation is impossible through direct Develop writes, consider an alternative preview design; none has yet been selected.

**Multi-parameter writes:** SDK calls are individual operations. Capture originals and plan for partial failure; do not assume atomic rollback.

**Host compatibility:** Lightroom Classic 15.4.1 on macOS is the assumed baseline, pending version confirmation. The tested legacy `SplitToning...` identifiers work for the four parameters above; others require host verification.

**Color science:** Mathematical hue relationships do not necessarily yield perceptually balanced or aesthetically useful results. Choice of perceptual model remains open.

**UI:** Lightroom Classic plugin UI constraints differ from Photoshop UXP. Avoid investing in elaborate interaction until SDK behavior and preview performance are established.

## 9. Recommended next steps

### Finish Slice 0

1. Run the three History Probe experiments.
2. Record history entries, one-step Undo results, restoration behavior, and unrelated-setting preservation.
3. Decide whether an acceptable Apply/Cancel/Undo model is supported.
4. Investigate only the remaining SDK issues that affect that decision.
5. Document the results and record a go/no-go or proceed-with-constraints decision.

### Then propose Slice 1

Assuming feasibility, implement the smallest useful end-to-end path: a host-neutral harmony specification, deterministic harmony calculation, translation into native Lightroom parameters, and a minimal safe interaction flow based on verified history behavior.

Defer sophisticated UI, image analysis, Photoshop, and speculative abstractions.

## 10. Decisions still open

- Preview architecture and history behavior.
- Host-neutral harmony representation.
- Mathematical/perceptual color model.
- Tonal assignment and strength controls.
- Handling existing grading: replace, blend, or offer a choice.
- Lightroom UI interaction model.
- Scope and timing of Photoshop integration.

Make these decisions when their development slices require them, using ADRs where appropriate.

## 11. Instructions for the next developer or agent

Read `AGENTS.md`, `lightroom/AGENTS.md`, `docs/README.md`, and ADR 0001. Inspect the current source and GitHub branch before editing. Do not replace the working initial probe unnecessarily. Do not assume the history experiments passed. Do not mark ADR 0001 implemented prematurely. Respect the progressive-disclosure approval requirement.

**Suggested continuation prompt:**

> Resume LRColorHarmony from the end of Slice 0. Native Color Grading read/write/restore was demonstrated in Lightroom Classic, but temporary edits remained in Develop history. Three history experiments have been implemented and await local testing. Review AGENTS.md and ADR 0001, collect and interpret the results, and determine a safe Apply/Cancel/Undo model before proposing Slice 1.

## 12. Current assessment

The Lightroom-first architecture has passed its initial technical feasibility test: the host can accept, render, and restore native Color Grading changes.

The main remaining uncertainty is **interaction quality and history behavior**, not basic parameter access.

**Status: feasible in principle; interaction architecture not yet validated.**
