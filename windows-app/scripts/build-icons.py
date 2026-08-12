#!/usr/bin/env python3
from pathlib import Path
from PIL import Image, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
SOURCE_ROOT = ROOT.parent / "desktop-app" / "Assets"
ASSETS = ROOT / "assets"
ASSETS.mkdir(parents=True, exist_ok=True)

app_icon = Image.open(SOURCE_ROOT / "app-icon-1024-v2-user.png").convert("RGBA")
app_icon.save(ASSETS / "app-icon.png")
app_icon.save(
    ASSETS / "app-icon.ico",
    format="ICO",
    sizes=[(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)],
)

template = Image.open(SOURCE_ROOT / "MenuBarIconTemplate@2x.png").convert("RGBA")
alpha = template.getchannel("A").resize((64, 64), Image.Resampling.LANCZOS)
outline_alpha = alpha.filter(ImageFilter.MaxFilter(5))
tray = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
tray.paste((244, 255, 230, 255), mask=outline_alpha)
tray.paste((24, 111, 53, 255), mask=alpha)
tray.save(ASSETS / "tray-icon.png")

print(ASSETS / "app-icon.ico")
print(ASSETS / "tray-icon.png")
