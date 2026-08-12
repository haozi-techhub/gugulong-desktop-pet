# 咕咕龙桌宠 Windows 版 v1.3.2

这是与 macOS 版使用同一套角色和动作图集的 Windows 桌宠。

## 支持范围

- Windows 10/11，64 位 x86 电脑
- 不支持 Windows ARM、Windows 7/8
- Windows 版本是免安装便携版：解压后运行 `咕咕龙桌宠.exe`

## 功能

- 左键拖动宠物
- 右键打开控制菜单
- Windows 系统托盘入口
- 默认、挥爪、大哭、暴怒跺脚、等待、执行中、点赞七种动作
- 50%、75%、100%、150%、200% 五档尺寸
- 显示/隐藏、始终置顶、设置和退出
- 设置、尺寸和位置自动保存
- 鼠标悬停大哭
- “咕咕嘎嘎”气泡：每六次互动最多出现一次，并有 10 秒冷却
- 可选 Codex 状态联动，只读取本机 `%USERPROFILE%\.codex\sessions`，不上传数据
- 不包含 Codex 额度功能

## 首次启动

当前版本没有购买 Windows 代码签名证书。若 Windows SmartScreen 提示“已保护你的电脑”，请点击“更多信息”，核对文件来源后选择“仍要运行”。

## 本地开发

```bash
npm install
npm test
npm start
npm run package:windows
```

Windows 分发目录生成在 `dist/`。
