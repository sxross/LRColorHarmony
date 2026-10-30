# Lightroom Classic integration

Applies to work in this directory. Read the root `AGENTS.md` and accepted ADRs before modifying Lightroom integration.

## Host and SDK

- Target Lightroom Classic 15.4.1 on macOS as the **assumed** initial test environment until verified locally.
- Use documented Lightroom Classic SDK APIs. Confirm exact parameter identifiers, value ranges, and behavior against the installed SDK and host before depending on them.
- Treat older `SplitToning...` names and newer `ColorGrade...` names as potential API identifiers, not evidence of interchangeable behavior.
- Keep host-specific APIs behind an adapter; harmony geometry and tonal mapping belong in host-independent modules.

## Develop safety

- Never modify unrelated Develop parameters.
- Read and preserve every parameter that will be changed before writing any value.
- Preserve preexisting grading; ensure explicit, reliable restoration and understandable Apply/Cancel behavior.
- Account for the Develop module, selected-photo state, history/undo semantics, and failures during multi-parameter updates.
- Do not assume SDK writes are atomic or automatically reversible. Verify actual behavior.
- Use virtual copies or disposable catalogs for experimental changes.

## Verification

- Distinguish SDK documentation claims from behavior observed in Lightroom Classic.
- Test an ungraded image and one with existing grading.
- Verify write/readback, restoration, preservation of unrelated settings, repeat invocation, and no-photo/error handling.
- Record Lightroom and SDK versions, parameter identifiers and ranges, observed behavior, and limitations.
- Measure preview responsiveness and history behavior before adding continuous interactive preview.
- Do not report host integration as tested until it has actually run inside Lightroom Classic.

## Slice 0 boundary

Build the smallest `.lrdevplugin` that can load, capture native grading values, apply a fixed complementary shadow/highlight grade, read back results, and restore the originals. Do not build a full harmony UI, Photoshop integration, or image analysis in this slice.

When additional area-specific guidance becomes necessary, propose its location and scope to the project owner before creating it.
