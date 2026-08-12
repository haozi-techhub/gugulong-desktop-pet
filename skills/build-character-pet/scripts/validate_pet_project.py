#!/usr/bin/env python3
"""Validate stage gates and final artifacts for a character-pet project."""

import argparse
import json
import struct
import subprocess
import sys
from pathlib import Path


STAGES = ["intake", "concept", "concept-approved", "motion", "motion-approved", "build", "qa", "released"]
TARGETS = {"undecided", "codex", "macos", "both"}


def webp_size(path: Path):
    data = path.read_bytes()
    if len(data) < 30 or data[:4] != b"RIFF" or data[8:12] != b"WEBP":
        return None
    kind = data[12:16]
    if kind == b"VP8X":
        return 1 + int.from_bytes(data[24:27], "little"), 1 + int.from_bytes(data[27:30], "little")
    if kind == b"VP8 " and data[23:26] == b"\x9d\x01\x2a":
        width, height = struct.unpack_from("<HH", data, 26)
        return width & 0x3FFF, height & 0x3FFF
    if kind == b"VP8L" and data[20] == 0x2F:
        bits = int.from_bytes(data[21:25], "little")
        return (bits & 0x3FFF) + 1, ((bits >> 14) & 0x3FFF) + 1
    return None


def resolve(root: Path, value):
    if not value:
        return None
    path = Path(value)
    return path if path.is_absolute() else root / path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("project")
    args = parser.parse_args()
    root = Path(args.project).expanduser().resolve()
    manifest_path = root / "pet-project.json"
    errors, warnings = [], []

    if not manifest_path.exists():
        print(json.dumps({"ok": False, "errors": ["pet-project.json missing"]}, indent=2))
        return 1

    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except Exception as exc:
        print(json.dumps({"ok": False, "errors": [f"invalid manifest: {exc}"]}, indent=2))
        return 1

    stage = manifest.get("stage")
    target = manifest.get("target")
    if stage not in STAGES:
        errors.append(f"invalid stage: {stage}")
    if target not in TARGETS:
        errors.append(f"invalid target: {target}")

    stage_index = STAGES.index(stage) if stage in STAGES else 0
    approvals = manifest.get("approvals") or {}
    approved_character = resolve(root, manifest.get("approvedCharacter"))
    action_mapping = resolve(root, manifest.get("actionMapping"))

    if stage_index >= STAGES.index("concept-approved"):
        if not approvals.get("concept"):
            errors.append("concept approval is required")
        if not approvals.get("conceptNote"):
            errors.append("concept approval note is required")
        if not approved_character or not approved_character.is_file():
            errors.append("approved character asset is missing")

    if stage_index >= STAGES.index("motion-approved"):
        if not approvals.get("motion"):
            errors.append("motion approval is required")
        if not approvals.get("motionNote"):
            errors.append("motion approval note is required")
        if not action_mapping or not action_mapping.is_file():
            errors.append("action mapping is missing")

    artifacts = manifest.get("artifacts") or {}
    if stage_index >= STAGES.index("qa"):
        qa_record = resolve(root, artifacts.get("qaRecord"))
        if not qa_record or not qa_record.is_file():
            errors.append("QA record is missing")

        if target in {"codex", "both"}:
            package = resolve(root, artifacts.get("codexPackage"))
            pet_json = package / "pet.json" if package else None
            sprite = package / "spritesheet.webp" if package else None
            if not pet_json or not pet_json.is_file():
                errors.append("Codex pet.json is missing")
            else:
                try:
                    pet = json.loads(pet_json.read_text(encoding="utf-8"))
                    if pet.get("spriteVersionNumber") != 2:
                        errors.append("Codex spriteVersionNumber must be 2")
                except Exception as exc:
                    errors.append(f"invalid pet.json: {exc}")
            if not sprite or not sprite.is_file():
                errors.append("Codex spritesheet.webp is missing")
            elif webp_size(sprite) != (1536, 2288):
                errors.append(f"Codex spritesheet must be 1536x2288, got {webp_size(sprite)}")

        if target in {"macos", "both"}:
            app = resolve(root, artifacts.get("macosApp"))
            if not app or not app.is_dir() or app.suffix != ".app":
                errors.append("macOS .app bundle is missing")
            elif sys.platform == "darwin":
                result = subprocess.run(["codesign", "--verify", "--deep", "--strict", str(app)], capture_output=True, text=True)
                if result.returncode:
                    errors.append("macOS app code signature verification failed")

    if stage == "released":
        archive = resolve(root, artifacts.get("archive"))
        checksum = resolve(root, artifacts.get("sha256"))
        if not archive or not archive.is_file():
            errors.append("release archive is missing")
        if not checksum or not checksum.is_file():
            errors.append("SHA-256 checksum file is missing")

    if target == "undecided" and stage_index >= STAGES.index("build"):
        errors.append("target must be chosen before build")
    if not manifest.get("sourceImages"):
        warnings.append("no source images recorded")

    output = {"ok": not errors, "stage": stage, "target": target, "errors": errors, "warnings": warnings}
    print(json.dumps(output, ensure_ascii=False, indent=2))
    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main())
