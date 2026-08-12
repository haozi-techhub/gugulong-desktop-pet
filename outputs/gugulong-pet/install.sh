#!/bin/sh
set -eu
PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PET_ID="gugulong"
if [ -n "${CODEX_PET_INSTALL_ROOT:-}" ]; then CODEX_ROOT="$CODEX_PET_INSTALL_ROOT"; elif [ -n "${CODEX_HOME:-}" ]; then CODEX_ROOT="$CODEX_HOME"; else CODEX_ROOT="$HOME/.codex"; fi
TARGET_DIR="$CODEX_ROOT/pets/$PET_ID"
BACKUP_ROOT="$CODEX_ROOT/pets/.backups"
SOURCE_MANIFEST="$PACKAGE_DIR/pet.json"; SOURCE_ATLAS="$PACKAGE_DIR/spritesheet.webp"
TARGET_MANIFEST="$TARGET_DIR/pet.json"; TARGET_ATLAS="$TARGET_DIR/spritesheet.webp"
[ -f "$SOURCE_MANIFEST" ] && [ -f "$SOURCE_ATLAS" ] || { echo "安装失败：缺少 pet.json 或 spritesheet.webp。" >&2; exit 1; }
mkdir -p "$TARGET_DIR"
if [ -f "$TARGET_MANIFEST" ] && [ -f "$TARGET_ATLAS" ] && cmp -s "$SOURCE_MANIFEST" "$TARGET_MANIFEST" && cmp -s "$SOURCE_ATLAS" "$TARGET_ATLAS"; then echo "咕咕龙已是当前版本：$TARGET_DIR"; exit 0; fi
if [ -f "$TARGET_MANIFEST" ] || [ -f "$TARGET_ATLAS" ]; then BACKUP_DIR="$BACKUP_ROOT/${PET_ID}-$(date +%Y%m%d-%H%M%S)-$$"; mkdir -p "$BACKUP_DIR"; [ -f "$TARGET_MANIFEST" ] && cp "$TARGET_MANIFEST" "$BACKUP_DIR/pet.json"; [ -f "$TARGET_ATLAS" ] && cp "$TARGET_ATLAS" "$BACKUP_DIR/spritesheet.webp"; echo "旧版已备份：$BACKUP_DIR"; fi
TEMP_MANIFEST="$TARGET_DIR/.pet.json.installing.$$"; TEMP_ATLAS="$TARGET_DIR/.spritesheet.webp.installing.$$"
cleanup(){ rm -f "$TEMP_MANIFEST" "$TEMP_ATLAS"; }; trap cleanup EXIT HUP INT TERM
cp "$SOURCE_MANIFEST" "$TEMP_MANIFEST"; cp "$SOURCE_ATLAS" "$TEMP_ATLAS"; cmp "$SOURCE_MANIFEST" "$TEMP_MANIFEST"; cmp "$SOURCE_ATLAS" "$TEMP_ATLAS"; mv "$TEMP_ATLAS" "$TARGET_ATLAS"; mv "$TEMP_MANIFEST" "$TARGET_MANIFEST"; trap - EXIT HUP INT TERM
echo "咕咕龙安装成功：$TARGET_DIR"; echo "请完全退出并重新打开 Codex，或切换宠物后再切回。"
