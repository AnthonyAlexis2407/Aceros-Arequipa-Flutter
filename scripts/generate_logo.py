import os
from PIL import Image, ImageDraw, ImageFont

root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
assets_dir = os.path.join(root, 'assets', 'images')
os.makedirs(assets_dir, exist_ok=True)

size = 1024
bg = (0, 42, 130)
icon = Image.new('RGB', (size, size), bg)
d = ImageDraw.Draw(icon)
w, h = size, size

triangle = [(w * 0.18, h * 0.62), (w * 0.5, h * 0.17), (w * 0.82, h * 0.62)]
subtriangle = [(w * 0.30, h * 0.62), (w * 0.5, h * 0.30), (w * 0.70, h * 0.62)]
d.polygon(triangle, fill=(255, 255, 255))
d.polygon(subtriangle, fill=bg)
d.rectangle([w * 0.35, h * 0.62, w * 0.65, h * 0.74], fill=(255, 255, 255))

try:
    font_bold = ImageFont.truetype('arialbd.ttf', 80)
    font_regular = ImageFont.truetype('arial.ttf', 56)
except OSError:
    font_bold = ImageFont.load_default()
    font_regular = ImageFont.load_default()

texts = [('ACEROS', font_bold, int(h * 0.78)), ('AREQUIPA', font_regular, int(h * 0.84))]
for text, font, y in texts:
    try:
        bbox = font.getbbox(text)
        tw = bbox[2] - bbox[0]
    except AttributeError:
        tw, _ = font.getsize(text)
    d.text(((w - tw) / 2, y), text, font=font, fill=(255, 255, 255))

logo_path = os.path.join(assets_dir, 'logo.png')
icon.save(logo_path)
print('Created', logo_path)

mipmap_sizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}

for folder, size_px in mipmap_sizes.items():
    path = os.path.join(root, 'android', 'app', 'src', 'main', 'res', folder)
    if not os.path.isdir(path):
        print('Skipping missing folder:', path)
        continue
    output_path = os.path.join(path, 'ic_launcher.png')
    icon.resize((size_px, size_px), Image.LANCZOS).save(output_path)
    print('Updated', output_path)
