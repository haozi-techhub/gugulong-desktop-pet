# macOS desktop-pet target

## Product boundary

Default to Apple Silicon and macOS 13 or later unless the user asks for broader support. Prefer native AppKit for the transparent desktop window, event handling, status item, and menus. SwiftUI may host settings or information panels, but do not depend on it for behavior that AppKit handles more reliably.

Build these P0 capabilities:

- transparent, borderless pet window with no unwanted shadow
- left-drag on the visible body to move the pet
- right-click body menu
- menu-bar status item with the same control model
- explicit action selection with immediate visual response
- size presets including 50%, 75%, 100%, 150%, and 200%
- show/hide, always-on-top, settings, and quit
- position, size, toggles, and last appropriate state persisted locally
- optional compact speech-bubble window that follows the pet and ignores mouse events
- actual `.app` bundle, product icon, menu-bar template icon, zip archive, and SHA-256

Add Codex session linking only when requested. Read local files only, document the schema assumptions, ignore subagent/noise sessions, handle missing or changed data safely, and never fabricate status. Do not add quota or usage tracking unless explicitly requested.

## State model

Keep application state separate from art rows:

```text
idle, wave, cry/failure, angry, waiting, running, success/review
```

Map custom names to these semantic states. Manual menu selections must have a visible preview window and must not be immediately overwritten by hover or background automation. Track whether the pointer is currently over the pet so mouse-exit cannot restore a stale pre-menu state.

Run animation timers in common run-loop modes so opening a native menu does not make the product appear frozen. Update the first frame immediately after a state change.

## Interaction priorities

Resolve states in this order unless the product brief says otherwise:

```text
quit/hide > active manual preview > direct pointer interaction > external integration > idle
```

Use one control model to build both the body context menu and status menu. Bind every menu item to an explicit target. Do not duplicate state-changing logic across the two entry points.

Speech bubbles must be separate transparent windows or views, remain visually attached during movement and scaling, and never intercept dragging, right-click, or hover. Control frequency and duration; a bubble that appears on every minor event becomes distracting.

## Privacy and settings

Persist only necessary preferences through `NSUserDefaults` or an equivalent local store. Explain every local data source in the settings or documentation. Do not upload session content, screenshots, device data, or user files without explicit authorization.

## Build and release checks

Perform all of these before release:

1. Compile in release mode and lint `Info.plist`.
2. Verify bundle architecture and minimum system version.
3. Verify code signature. Distinguish ad-hoc signing from Developer ID signing and notarization.
4. Launch the built app from a clean location.
5. Exercise every action through the real context menu and confirm semantically different visible poses.
6. Exercise drag, every size, show/hide, always-on-top, bubble behavior, and settings persistence.
7. Quit from both body menu and menu bar; verify the process disappears.
8. Relaunch and verify position/settings restoration.
9. Zip the exact tested `.app`, extract into a temporary directory, compare contents, launch or inspect the extracted build, and verify the SHA-256.

Use Computer Use or another actual UI automation path for UI claims. Static selectors and compilation are necessary but not sufficient.

Keep only the final friend-facing app, archive, and checksum in `release/`. Keep source, screenshots, fixtures, and QA logs elsewhere.

