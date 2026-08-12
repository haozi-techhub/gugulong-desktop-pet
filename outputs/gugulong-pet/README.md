# 咕咕龙 Codex 宠物

咕咕龙是一个绿色毛绒小恐龙：粗眉、大眼、大嘴和小牙齿，性格暴躁但可爱。默认状态保持轻微皱眉；鼠标互动时可使用暴怒跺脚、哭哭、等待、执行和点赞等固定 Codex 状态。所有对话统一为“咕咕嘎嘎”。

## 一键安装

直接克隆到 Codex 的 pets 目录：

```bash
mkdir -p "${CODEX_HOME:-$HOME/.codex}/pets"
git clone https://github.com/haozi-techhub/gugulong-codex-pet.git \
  "${CODEX_HOME:-$HOME/.codex}/pets/gugulong"
```

已有安装更新：

```bash
git -C "${CODEX_HOME:-$HOME/.codex}/pets/gugulong" pull --ff-only
```

也可以在克隆后的目录执行 `sh ./install.sh`，脚本会先备份旧版本，再原子替换 `pet.json` 与 `spritesheet.webp`。安装后完全退出并重新打开 Codex，或切换宠物后再切回。

## 文件与校验

- `pet.json`：宠物元数据与 v2 atlas 声明
- `spritesheet.webp`：1536×2288、RGBA、8×11 atlas
- `ACTION-MAPPING.md`：状态、方向与气泡文案映射
- `contact-sheet.png`、`previews/`：动作预览
- `validation.json`、`direction-semantics.json` 等：公开 QA 记录

参考照片仅用于创作基准，没有随包发布。
