# 咕咕龙桌宠

咕咕龙是一款本地桌面宠物，支持 macOS Apple Silicon 和 Windows x64。它包含完整动作、拖动、尺寸调整、系统菜单入口、气泡，以及对本机 Codex session 状态的只读联动。

## 功能

- 默认、挥爪、大哭、暴怒跺脚、等待、执行中、点赞动作
- 50%、75%、100%、150%、200% 尺寸
- 鼠标拖动、悬停大哭、始终置顶、显示/隐藏、退出
- “咕咕嘎嘎”紧凑气泡，每 6 次互动最多触发一次
- 本机读取 `~/.codex/sessions/**/*.jsonl`，不上传会话内容
- macOS 菜单栏入口与 Windows 系统托盘入口

## 项目结构

- `desktop-app/`：macOS 原生 AppKit 应用
- `windows-app/`：Windows Electron 应用
- `outputs/gugulong-pet/`：Codex v2 宠物资源与安装脚本
- `skills/build-character-pet/`：从参考图制作 Codex/桌面宠物的方法 Skill

## 本地构建

### macOS

```bash
sh desktop-app/build.sh
```

产物位于 `desktop-app/build/咕咕龙.app`。当前最低系统版本为 macOS 13，目标架构为 Apple Silicon。

### Windows

```bash
cd windows-app
npm install
npm test
npm run package:windows
```

Windows 产物位于 `windows-app/dist/咕咕龙桌宠-win32-x64/`。

## 安装包

Mac 与 Windows 压缩包作为 GitHub Release 附件发布，不提交进 Git 历史。这样能避免 Windows 包超过 GitHub 单文件 100MB 限制，也让源码仓库保持轻量。

## 隐私

Codex 联动只读取本机 session JSONL，用于判断执行、等待、完成和失败状态。应用不调用未公开接口，也不会上传会话内容。

