---
name: build-character-pet
description: Turn one or more reference images into a confirmed character design, an approved animation plan, and either a Codex v2 pet, a distributable macOS desktop-pet app, or both. Use when a user asks to make a pet, mascot, companion, animated character, Codex pet, menu-bar pet, or desktop pet from a person, animal, object, brand cue, illustration, screenshot, or generated image and expects visual concept generation, explicit approval gates, motion design, implementation, QA, packaging, installation, or sharing.
---

# Build Character Pet

Create pets through explicit stage gates. Treat the approved character image as the visual source of truth. Never skip directly from a reference image to bulk animation or application packaging.

## Start a project

Run:

```bash
python3 scripts/init_pet_project.py --name "<pet name>" --output "<absolute project directory>" --target undecided
```

Copy or record every user-supplied reference in `source/`. Preserve originals; do not overwrite them.

Maintain these stages in `pet-project.json`:

```text
intake -> concept -> concept-approved -> motion -> motion-approved -> build -> qa -> released
```

Do not advance past `concept` without explicit user approval of one effect image. Do not advance past `motion` without explicit user approval of the action list or an unambiguous instruction to implement it.

## 1. Clarify the outcome

Inspect the supplied images before asking questions. Ask no more than three consolidated questions, and only for decisions that materially change the result:

1. Output target: Codex pet, macOS desktop app, both, or decide after concept approval.
2. Character direction: style, personality, age/energy, clothing/material, signature features, and avoidances.
3. Interaction direction: required actions, trigger conditions, speech, props, size, and distribution needs.

If enough information already exists, state reasonable assumptions and proceed. Separate confirmed facts, design inferences, and assumptions.

## 2. Create the character effect image

Read [references/visual-gates.md](references/visual-gates.md). Use `$imagegen` for generation or editing when available.

Build a concise character brief from the references. Preserve identity cues that matter at pet size: head shape, face, silhouette, palette, material, signature clothing or prop, and personality. Simplify small details that will disappear at desktop scale.

Generate one strong full-body effect image first. Generate a second direction only when the references are ambiguous or two materially different directions would help the decision. Avoid spending animation effort on an unapproved design.

Show the selected image and ask for an explicit decision:

```text
是否确认这张图作为后续所有动作与产品图标的唯一角色基准？
如果要改，请直接指出：脸、体型、颜色、材质、服装、配件、气质或画风。
```

Save the approved image to `concept/approved-character.png`, set `approvals.concept=true`, and record the approval note. If the user requests changes, revise the concept and ask again. Do not generate action rows yet.

## 3. Design the action system

Read [references/visual-gates.md](references/visual-gates.md) again for motion rules. Derive actions from user value and product events, not from animation novelty.

For every action, specify:

- state id and user-facing name
- trigger and exit condition
- visible pose, expression, and prop behavior
- loop or one-shot behavior
- frame count and speed intent
- speech-bubble behavior
- fallback state

Keep the default state calm and low-distraction. Reserve large emotional gestures for meaningful events. Speech bubbles are UI overlays for desktop apps; do not bake readable text into Codex spritesheets.

Show the action mapping to the user before bulk generation. Save the approved mapping to `motion/action-mapping.md`, set `approvals.motion=true`, and record the approval note.

## 4. Choose the build branch

### Codex v2 pet

Read [references/codex-target.md](references/codex-target.md). Prefer the installed `$hatch-pet` when available. Otherwise read and follow the bundled [vendor/hatch-pet/SKILL.md](vendor/hatch-pet/SKILL.md) completely and treat `vendor/hatch-pet` as `HATCH_SKILL_DIR`. Follow its full generation, direction, transparency, QA, and packaging contract. Give it `concept/approved-character.png` as the canonical reference plus the approved personality and action notes.

Do not weaken the Codex contract to accommodate a difficult design. Simplify the character or repair the failing coherent row.

### macOS desktop pet

Read [references/macos-target.md](references/macos-target.md) completely before implementation. Build a real `.app`, not only an animation preview. Reuse an existing desktop-pet project when present; otherwise create the smallest native AppKit-based application that closes the full interaction loop.

### Both

Finish and validate the Codex visual package first. Reuse its approved identity and animations in the desktop app when suitable, while keeping the two runtime contracts separate.

## 5. Validate before claiming completion

Run:

```bash
python3 scripts/validate_pet_project.py "<absolute project directory>"
```

Also run the target-specific tests in the relevant reference. Validation is not complete until both deterministic checks and real visual or UI checks pass.

Required evidence:

- approved effect image and approval note
- approved action mapping and approval note
- identity-consistent motion preview or contact sheet
- target artifacts with correct metadata
- actual install or clean-extraction test
- distributable archive and SHA-256
- concise QA record listing what was genuinely tested

Never claim a menu item, drag behavior, animation, install, exit flow, or archive works without exercising it. Do not use screenshot hashes alone as proof of semantic correctness; inspect the actual visible pose.

## 6. Deliver cleanly

Keep working files outside `release/`. Put only friend-facing artifacts in the final release folder.

Recommended final contents:

```text
release/<pet>-<version>/
  <pet>.app or pet.json + spritesheet.webp
  <pet>-macOS.zip or <pet>-codex.zip
  SHA256SUMS.txt
```

Install locally only when the user requests it. Publish to GitHub or another external destination only when explicitly authorized. For macOS ad-hoc builds, clearly explain first-launch Gatekeeper behavior; do not present an unsigned or unnotarized build as generally trusted software.

## Working rules

- Lead with visible progress and concrete artifacts.
- Preserve user-provided files and unrelated workspace changes.
- Use the approved concept as the canonical reference for every motion image.
- Prefer one coherent strip per animation over unrelated individual poses.
- Repair the smallest failing unit without breaking already approved work.
- Keep dialogue, menus, triggers, and state transitions in the application layer.
- Treat accessibility, privacy, exit, resizing, dragging, persistence, and failure states as product requirements, not optional polish.
- Stop and ask when a missing choice would materially change identity, output target, signing, publishing, or data access.
