# Codex v2 target

Use `$hatch-pet` as the authoritative implementation workflow when installed. If it is unavailable, use the bundled `vendor/hatch-pet` copy from the parent skill directory. Read the selected implementation's complete `SKILL.md` and follow its scripts, runtime dependencies, chroma handling, look-direction semantics, blind review, and packaging gates. This reference only defines the handoff and final product boundary.

## Handoff

Provide:

- approved character: `concept/approved-character.png`
- pet id: lowercase letters, digits, and hyphens
- display name and one-sentence description
- stable identity notes from concept approval
- style preset and avoidances
- user-approved action personality notes
- absolute output directory

The Codex runtime action contract remains:

```text
row 0 idle
row 1 running-right
row 2 running-left
row 3 waving
row 4 jumping
row 5 failed
row 6 waiting
row 7 running
row 8 review
rows 9–10 sixteen clockwise look directions
```

Do not rename, remove, or reorder required states to match custom wording. Express custom personality inside each required state.

## Required package

```text
<pet-id>/
  pet.json
  spritesheet.webp
```

Require:

- atlas exactly `1536×2288`
- cells `192×208`
- `spriteVersionNumber: 2`
- no text, baked speech bubbles, white/black background, cropping, slot overlap, or accidental alpha holes
- all required deterministic, semantic, continuity, blind-direction, contact-sheet, and motion-preview checks from `$hatch-pet`

Install to `${CODEX_HOME:-$HOME/.codex}/pets/<pet-id>/` only after validation and when the user requests local installation.

For sharing, archive the package with a SHA-256 file and test a fresh extraction. If publishing, include short installation instructions but keep extra documents out of the installed pet folder.
