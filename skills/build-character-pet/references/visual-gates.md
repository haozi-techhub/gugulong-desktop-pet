# Visual and approval gates

## Character brief

Record this compact brief before generating the effect image:

```text
Name:
Subject and identity cues:
Body proportions and silhouette:
Face and expression:
Palette and material:
Clothing or props:
Personality:
Target display size:
Must preserve:
Must avoid:
```

For a real person, preserve recognizable but non-sensitive visual traits without exaggerating ethnicity, disability, body shape, or other sensitive attributes. Cartoonization should feel flattering and intentional rather than mocking.

## Effect-image prompt contract

Request one centered, complete, full-body character with a readable silhouette and enough margin around hair, ears, tail, hands, feet, and props. Specify the desired visual style, material, expression, proportions, clothing, and palette. Exclude text, UI, logos, scenery, extra characters, duplicate limbs, cropped anatomy, shadows when transparency will be required, and details too small to survive at pet size.

The approved effect image must answer these questions without relying on the original reference:

- Can a viewer recognize the intended character?
- Does the silhouette read at approximately 100–200 pixels tall?
- Are face, palette, material, clothes, and props internally consistent?
- Is the default expression compatible with long desktop use?
- Can arms, legs, face, and props support the intended actions?

## Approval record

Write `concept/approval.md`:

```markdown
# Concept approval

- Approved asset: `approved-character.png`
- Approved by: user
- Approval statement: <exact or concise paraphrase>
- Date: <ISO timestamp>
- Locked traits: <identity traits that future generations must preserve>
- Allowed variation: <pose, expression, small secondary motion>
```

## Motion design rules

- Anchor feet, base, or torso consistently unless the action intentionally travels or jumps.
- Preserve head-to-body ratio, face construction, markings, material, and prop attachment.
- Use pose and expression before detached decorative effects.
- Make idle subtle; make success, failure, waiting, and anger visually distinct.
- Avoid action rows that differ only by pupils or tiny hand movement at final size.
- Keep one animation focused on one semantic message.
- Define whether the animation loops, holds its last frame, or returns to idle.
- For opposite travel directions, mirror only when asymmetrical clothing, text, lighting, props, or handedness remain correct.

## Action mapping template

```markdown
| State | Trigger | Visual behavior | Frames/speed | Loop | Bubble | Exit/fallback |
|---|---|---|---|---|---|---|
| idle | no active event | calm breathing and blink | 6 / slow | yes | rare | remains idle |
```

Record approval in `motion/approval.md` with the same fields as concept approval.

