#!/usr/bin/env python3
"""Crimson Black wallpapers. Kept outside backgrounds/ because omarchy-theme-bg-next cycles every file there.

3840x2160: all three outputs are 16:9, so `swaybg -m fill` never crops. OLED rules: near-black everywhere,
red only as soft low-luminance light, nothing lit in the top 6% (bar zone), +-2/255 grain so the 8-bit
DP-1 panel doesn't band. JPEG q95 with 4:4:4 chroma so thin red detail doesn't smear.
"""
import pathlib, subprocess, tempfile
import numpy as np
from PIL import Image

W, H = 3840, 2160
OUT = pathlib.Path.home() / ".config/omarchy/themes/crimson-black/backgrounds"
LOGO = pathlib.Path("/usr/share/pixmaps/archlinux-logo.svg")
CRIMSON = np.array([224, 17, 43], np.float32) / 255
GRAPHITE = np.array([46, 46, 46], np.float32) / 255
rng = np.random.default_rng(7)
yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
bar_mask = np.clip((yy / H - 0.04) / 0.06, 0, 1)[..., None]  # dark top band for the waybar zone


def radial(cx, cy, r, power=2.2):
    return (np.clip(1 - np.hypot(xx - cx, yy - cy) / r, 0, 1) ** power)[..., None]


def logo_alpha(size, stroke=None):
    """Arch mark only (the SVG's other two paths are the TM glyph), rendered as an alpha mask."""
    import re
    d = re.search(r'\bd="([^"]+)"', re.findall(r"<path\b[^>]*/>", LOGO.read_text(), re.S)[0]).group(1)
    paint = f'fill="none" stroke="#fff" stroke-width="{stroke}" stroke-linejoin="round"' if stroke else 'fill="#fff"'
    with tempfile.TemporaryDirectory() as tmp:
        svg, png = pathlib.Path(tmp, "m.svg"), pathlib.Path(tmp, "m.png")
        svg.write_text(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256"><path {paint} d="{d}"/></svg>')
        subprocess.run(["rsvg-convert", "-w", str(size), "-h", str(size), str(svg), "-o", str(png)], check=True)
        return np.asarray(Image.open(png).convert("RGBA"), np.float32)[..., 3] / 255


def place(mask, x0, y0):
    canvas = np.zeros((H, W), np.float32)
    s = mask.shape[0]
    canvas[y0:y0 + s, x0:x0 + s] = mask
    return canvas[..., None]


def save(rgb, name, grain=True):
    px = rgb * 255
    if grain:
        px = px + rng.uniform(-2, 2, (H, W, 1)).astype(np.float32)  # luma grain, no chroma noise
    img = Image.fromarray(np.clip(np.round(px), 0, 255).astype(np.uint8))
    path = OUT / name
    if path.suffix == ".jpg":
        img.save(path, quality=95, subsampling=0, optimize=True)
    else:
        img.save(path, optimize=True)
    print(f"{name}: max={int(np.clip(px, 0, 255).max())} top6%max={int(np.clip(px[: int(H * .06)], 0, 255).max())}")


# 0: Arch mark, large and faint, backlit by an ember glow that shows through its doorway (default, sorts first)
S = int(H * 0.66)
x0, y0 = (W - S) // 2, int(H * 0.90) - int(S * 0.95)
fill = place(logo_alpha(S), x0, y0)
edge = place(logo_alpha(S, stroke=round(3.2 * 256 / S, 3)), x0, y0)
door_x, door_y = x0 + S * 128 / 256, y0 + S * 190 / 256
ember = CRIMSON * (0.30 * radial(door_x, door_y, S * 0.62) + 0.12 * radial(door_x, door_y, S * 0.20, 1.8))
mark = ember * (1 - 0.9 * fill) + GRAPHITE * edge * 0.9
save(mark * bar_mask, "0-arch-mark.jpg")

# 1: ember, deep red glow rising from the bottom-left corner
save(CRIMSON * 0.30 * radial(W * 0.06, H * 1.08, W * 0.85, 2.6) * bar_mask, "1-ember.jpg")

# 2: filament, a crimson hairline at 68% height with a soft bloom, fading out at both ends
dy = yy - H * 0.68
xfade = np.clip(np.sin(np.clip((xx / W - 0.12) / 0.76, 0, 1) * np.pi), 0, 1) ** 1.5
line = (0.70 * np.exp(-dy**2 / (2 * 1.1**2)) + 0.16 * np.exp(-dy**2 / (2 * 26**2))) * xfade
save(CRIMSON * line[..., None] * bar_mask, "2-filament.jpg")

# 3: void, pixels fully off
save(np.zeros((H, W, 3), np.float32), "3-void.png", grain=False)
