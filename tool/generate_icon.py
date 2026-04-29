from PIL import Image, ImageDraw, ImageFont
import os
size = 1024
bg = (0x1B, 0x5E, 0x20, 255)
white = (255, 255, 255, 255)
subtle = (255, 255, 255, 190)
os.makedirs('assets/icon', exist_ok=True)
img = Image.new('RGBA', (size, size), bg)
d = ImageDraw.Draw(img)
cx = size // 2
stem_top = int(size * 0.23)
stem_bottom = int(size * 0.66)
d.line([(cx, stem_bottom), (cx, stem_top)], fill=white, width=24)
grain_w = 92
grain_h = 42
left_x = cx - 110
right_x = cx + 110
for y in [stem_top + i * 55 for i in range(0, 7)]:
    d.ellipse([left_x - grain_w//2, y - grain_h//2, left_x + grain_w//2, y + grain_h//2], fill=white)
    d.ellipse([right_x - grain_w//2, y - grain_h//2, right_x + grain_w//2, y + grain_h//2], fill=white)
    left_x += 18
    right_x -= 18
d.ellipse([cx - 54, stem_top - 64, cx + 54, stem_top + 2], fill=white)
font = None
for candidate in [
    'C:/Windows/Fonts/segoeuib.ttf',
    'C:/Windows/Fonts/arialbd.ttf',
    'C:/Windows/Fonts/arial.ttf',
]:
    if os.path.exists(candidate):
        font = ImageFont.truetype(candidate, 116)
        break
if font is None:
    font = ImageFont.load_default()
text = 'AP'
bbox = d.textbbox((0, 0), text, font=font)
tw = bbox[2] - bbox[0]
d.text(((size - tw) // 2, int(size * 0.73)), text, fill=subtle, font=font)
img.save('assets/icon/app_icon.png', 'PNG')
fg = Image.new('RGBA', (size, size), (0, 0, 0, 0))
df = ImageDraw.Draw(fg)
cx = size // 2
stem_top = int(size * 0.20)
stem_bottom = int(size * 0.72)
df.line([(cx, stem_bottom), (cx, stem_top)], fill=white, width=28)
left_x = cx - 130
right_x = cx + 130
for y in [stem_top + i * 60 for i in range(0, 7)]:
    df.ellipse([left_x - 56, y - 28, left_x + 56, y + 28], fill=white)
    df.ellipse([right_x - 56, y - 28, right_x + 56, y + 28], fill=white)
    left_x += 22
    right_x -= 22
df.ellipse([cx - 64, stem_top - 74, cx + 64, stem_top + 4], fill=white)
df.text(((size - tw)//2, int(size * 0.77)), text, fill=(255, 255, 255, 170), font=font)
fg.save('assets/icon/app_icon_foreground.png', 'PNG')
print('Generated app_icon.png and app_icon_foreground.png')
