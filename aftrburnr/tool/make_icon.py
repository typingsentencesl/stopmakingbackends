"""Renders windows/runner/resources/app_icon.ico from the design tokens.

A flame "A" in Archivo ExtraCondensed 800 on bg1, square, no rounding.
Run from the aftrburnr/ folder: python3 tool/make_icon.py
"""
from PIL import Image, ImageDraw, ImageFont

BG1 = (0x14, 0x13, 0x11, 255)
FLAME = (0xFF, 0x53, 0x20, 255)
FONT = 'assets/fonts/ArchivoXC-800.ttf'


def render(size: int) -> Image.Image:
    scale = 4  # supersample, then downscale for clean edges
    s = size * scale
    img = Image.new('RGBA', (s, s), BG1)
    d = ImageDraw.Draw(img)
    font = ImageFont.truetype(FONT, int(s * 0.86))
    box = d.textbbox((0, 0), 'A', font=font)
    w, h = box[2] - box[0], box[3] - box[1]
    d.text(((s - w) / 2 - box[0], (s - h) / 2 - box[1]), 'A', font=font, fill=FLAME)
    # Bottom rule: the progress bar, the third place flame is allowed.
    bar = max(scale, int(s * 0.06))
    d.rectangle([0, s - bar, s, s], fill=FLAME)
    return img.resize((size, size), Image.LANCZOS)


sizes = [16, 20, 24, 32, 40, 48, 64, 128, 256]
big = render(256)
big.save('windows/runner/resources/app_icon.ico',
         sizes=[(x, x) for x in sizes],
         append_images=[render(x) for x in sizes[:-1]])
big.save('docs/screens/app_icon.png')
print('ok')
