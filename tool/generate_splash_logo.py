from PIL import Image, ImageDraw, ImageFont
import os

# Text-only splash (no icon), sized for flutter_native_splash center image.
width, height = 720, 220
img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

primary = (255, 255, 255, 255)
secondary = (220, 255, 232, 255)

title_font = None
tagline_font = None
for candidate in [
    'C:/Windows/Fonts/segoeuib.ttf',
    'C:/Windows/Fonts/arialbd.ttf',
    'C:/Windows/Fonts/arial.ttf',
]:
    if os.path.exists(candidate):
        title_font = ImageFont.truetype(candidate, 86)
        tagline_font = ImageFont.truetype(candidate, 28)
        break

if title_font is None:
    title_font = ImageFont.load_default()
if tagline_font is None:
    tagline_font = ImageFont.load_default()

title = 'AgriPulse'
tagline = 'Smart Farming Insights'

title_box = draw.textbbox((0, 0), title, font=title_font)
title_w = title_box[2] - title_box[0]
title_h = title_box[3] - title_box[1]

tagline_box = draw.textbbox((0, 0), tagline, font=tagline_font)
tagline_w = tagline_box[2] - tagline_box[0]

title_x = (width - title_w) // 2
title_y = 28
tagline_x = (width - tagline_w) // 2
tagline_y = title_y + title_h + 16

draw.text((title_x, title_y), title, fill=primary, font=title_font)
draw.text((tagline_x, tagline_y), tagline, fill=secondary, font=tagline_font)

output = 'assets/splash/splash_wordmark.png'
img.save(output, 'PNG')
print(f'Generated {output}')
