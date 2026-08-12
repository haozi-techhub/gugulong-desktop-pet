#!/usr/bin/env python3
"""Initialize a staged character-pet project without modifying source images."""

import argparse
import hashlib
import json
import re
from datetime import datetime, timezone
from pathlib import Path


STAGES = ["intake", "concept", "concept-approved", "motion", "motion-approved", "build", "qa", "released"]
TARGETS = ["undecided", "codex", "macos", "both"]


def slugify(value: str) -> str:
    source = value
    normalized = re.sub(r"[^a-z0-9]+", "-", source.lower()).strip("-")
    if normalized:
        return normalized
    digest = hashlib.sha256(source.encode("utf-8")).hexdigest()[:8]
    return f"pet-{digest}"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--name", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--target", choices=TARGETS, default="undecided")
    parser.add_argument("--pet-id")
    args = parser.parse_args()

    root = Path(args.output).expanduser().resolve()
    if root.exists() and any(root.iterdir()):
        raise SystemExit(f"Output directory is not empty: {root}")

    for directory in ["source", "concept", "motion", "build", "qa", "release"]:
        (root / directory).mkdir(parents=True, exist_ok=True)

    manifest = {
        "schemaVersion": 1,
        "name": args.name,
        "petId": args.pet_id or slugify(args.name),
        "target": args.target,
        "stage": "intake",
        "createdAt": datetime.now(timezone.utc).isoformat(),
        "sourceImages": [],
        "approvedCharacter": None,
        "actionMapping": None,
        "approvals": {
            "concept": False,
            "conceptNote": "",
            "motion": False,
            "motionNote": "",
        },
        "artifacts": {
            "codexPackage": None,
            "macosApp": None,
            "archive": None,
            "sha256": None,
            "qaRecord": None,
        },
    }
    (root / "pet-project.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(root)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
