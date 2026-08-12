# 咕咕龙 v1.2.8 图标验收

## 顶部菜单栏 Logo

- 使用圆角方形咕咕龙脸模板图。
- 逻辑尺寸：`20pt × 20pt`。
- Retina 资源：`40px × 40px`。
- 已收紧透明留白，使可见面积与相邻原生菜单栏应用图标处于同一等级。
- 从应用包中的 `MenuBarIconTemplate@2x.png` 显式加载，避免同名图片缓存干扰。
- Codex 正在执行任务时，其旋转进度图标会临时占用最左菜单栏槽位；任务结束后咕咕龙 Logo 会恢复显示。

## Finder 产品图标

- 图标源文件直接使用用户提供的彩色毛绒咕咕龙头像。
- 仅去除洋红键色背景，并封装为 macOS 所需的 16–1024px 多尺寸 `AppIcon.icns`；不改变咕咕龙造型。
- `iconutil` 已成功反解全部 10 个标准尺寸。
- Finder/Launch Services 缓存刷新后，`/Applications/咕咕龙.app` 已真实显示彩色咕咕龙头像。

## 证据

- `finder-installed-color-icon.png`：Finder“应用程序”目录实机截图。
- `finder-app-icon-roundtrip.png`：从最终 `AppIcon.icns` 反解出的 1024px 图标，SHA-256 与构建源 PNG 一致。
- `menu-bar-size-match.png`：构建期间菜单栏实机截图；其中 Codex 任务进度图标临时占据最左槽位。

## 一致性与回归

- 版本：`1.2.8`（build `128`）。
- 鼻子闪光相关代码不存在。
- 状态 fixture：执行中、等待、完成、失败、损坏、过期均已通过。
- 最终应用、Zip 解压应用和本机安装应用的文件内容一致。
