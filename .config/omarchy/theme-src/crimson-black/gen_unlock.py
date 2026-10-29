#!/usr/bin/env python3
"""Crimson Black boot unlock wordmark -> themes/crimson-black/unlock.png.

Plymouth (LUKS prompt) and SDDM center this above the password field; omarchy-plymouth-set-by-theme
installs it. Mirrors the hyprlock "Aspire" label: Monaspace Radon Bold Italic in the text-safe crimson
#ef2a42 with a faint same-hue glow (hyprlock shadow_size 4 @ 22%). 800x188 like stock unlock.png so
the entry field keeps its stock offset. Plymouth draws images 1:1 at native res, so no HiDPI variant.
"""
import pathlib
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

W, H = 800, 188
OUT = pathlib.Path.home() / ".config/omarchy/themes/crimson-black/unlock.png"
FONT = "/usr/share/fonts/truetype/monaspace/Monaspace Radon Var.ttf"
SIGNAL = (239, 42, 66)
TEXT = "Aspire"
CAP_HEIGHT = 112  # px from cap top to baseline; leaves room for the glow and the p descender

font = ImageFont.truetype(FONT, 100)
font.set_variation_by_name("Bold Italic")
cap = font.getbbox("A", anchor="ls")
font = ImageFont.truetype(FONT, round(100 * CAP_HEIGHT / (cap[3] - cap[1])))
font.set_variation_by_name("Bold Italic")

# Center the ink box, not the advance box: italics overhang to the right.
mask = Image.new("L", (W, H))
x0, y0, x1, y1 = ImageDraw.Draw(mask).textbbox((0, 0), TEXT, font=font, anchor="ls")
ImageDraw.Draw(mask).text(((W - (x1 - x0)) / 2 - x0, (H - (y1 - y0)) / 2 - y0), TEXT, font=font, fill=255, anchor="ls")

glow = mask.filter(ImageFilter.GaussianBlur(6)).point(lambda a: round(a * 0.22))

out = Image.new("RGBA", (W, H), SIGNAL + (0,))
out.putalpha(ImageChops.lighter(mask, glow))
out.save(OUT, optimize=True)
print(OUT, out.size)
