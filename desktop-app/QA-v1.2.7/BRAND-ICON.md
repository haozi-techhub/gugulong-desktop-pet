# v1.2.7 品牌图标验收

## 菜单栏 Logo

- 外轮廓为紧凑圆角方形，没有突出的头部或背刺。
- 两枚背刺、粗眉、大眼、鼻孔和小牙使用镂空方式收在方形内部。
- 资源提供 `18×18` 与 `36×36` 两档，并设置为 macOS template image，可随浅色/深色菜单栏自动换色。
- `menu-bar-rounded-square-logo.png` 是 `/Applications/咕咕龙.app` 的真实菜单栏运行截图。

## Finder 应用图标

- 使用奶油色圆角方形底板与彩色毛绒咕咕龙头像。
- `AppIcon.icns` 包含 16、32、128、256、512 与 1024 像素资源及 Retina 档位。
- `Info.plist` 通过 `CFBundleIconFile=AppIcon.icns` 声明图标。

## 兼容性

- 菜单栏仍复用原控制菜单，不改变动作、缩放、额度、设置和退出行为。
- 大哭动画继续保持鼻子不发光。
