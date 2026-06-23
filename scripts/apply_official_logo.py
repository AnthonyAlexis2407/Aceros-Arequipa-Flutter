from pathlib import Path
from PIL import Image

root = Path(__file__).resolve().parent.parent
source = root / 'assets' / 'images' / 'Aceros_Logo.png'
if not source.exists():
    raise FileNotFoundError(source)
logo = Image.open(source).convert('RGBA')

android_sizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}
for folder, size in android_sizes.items():
    target_dir = root / 'android' / 'app' / 'src' / 'main' / 'res' / folder
    target_dir.mkdir(parents=True, exist_ok=True)
    target_path = target_dir / 'ic_launcher.png'
    logo.resize((size, size), Image.LANCZOS).save(target_path)
    print('Written', target_path)

# Create Android launch image from the same logo (large square) to be used if needed.
android_launch_dir = root / 'android' / 'app' / 'src' / 'main' / 'res' / 'mipmap'
# no dedicated launch_image folder; use ic_launcher for splash.
for folder, size in android_sizes.items():
    target_dir = root / 'android' / 'app' / 'src' / 'main' / 'res' / folder
    target_path = target_dir / 'launch_image.png'
    logo.resize((size, size), Image.LANCZOS).save(target_path)
    print('Written', target_path)

ios_icons = {
    'Icon-App-20x20@1x.png': 20,
    'Icon-App-20x20@2x.png': 40,
    'Icon-App-20x20@3x.png': 60,
    'Icon-App-29x29@1x.png': 29,
    'Icon-App-29x29@2x.png': 58,
    'Icon-App-29x29@3x.png': 87,
    'Icon-App-40x40@1x.png': 40,
    'Icon-App-40x40@2x.png': 80,
    'Icon-App-40x40@3x.png': 120,
    'Icon-App-60x60@2x.png': 120,
    'Icon-App-60x60@3x.png': 180,
    'Icon-App-76x76@1x.png': 76,
    'Icon-App-76x76@2x.png': 152,
    'Icon-App-83.5x83.5@2x.png': 167,
    'Icon-App-1024x1024@1x.png': 1024,
}
appicon_dir = root / 'ios' / 'Runner' / 'Assets.xcassets' / 'AppIcon.appiconset'
for filename, size in ios_icons.items():
    target_path = appicon_dir / filename
    logo.resize((size, size), Image.LANCZOS).save(target_path)
    print('Written', target_path)

launch_dir = root / 'ios' / 'Runner' / 'Assets.xcassets' / 'LaunchImage.imageset'
launch_sizes = {
    'LaunchImage.png': 1080,
    'LaunchImage@2x.png': 2160,
    'LaunchImage@3x.png': 3240,
}
for filename, size in launch_sizes.items():
    target_path = launch_dir / filename
    logo.resize((size, size), Image.LANCZOS).save(target_path)
    print('Written', target_path)
