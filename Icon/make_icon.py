# SimpleBar icon: one big "<" in a thick hand-drawn marker stroke on warm paper,
# in the style of chrisqtruong's site (lopsided, smooth-edged, slightly uneven).
import sys, math, random
from PIL import Image, ImageDraw, ImageFilter

out, color = sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else "#0058a3"
ink = tuple(int(color[i:i+2], 16) for i in (1, 3, 5))
K = 4; S = 1024 * K
random.seed(7)
img = Image.new("RGBA", (S, S), (0, 0, 0, 0))

# macOS tile (824px rounded square), soft drop shadow
m, r = 100 * K, 185 * K
box = (m, m, S - m, S - m)
sh = Image.new("RGBA", (S, S), (0, 0, 0, 0))
ImageDraw.Draw(sh).rounded_rectangle((box[0], box[1] + 18*K, box[2], box[3] + 18*K), r, fill=(0, 0, 0, 70))
img.alpha_composite(sh.filter(ImageFilter.GaussianBlur(26 * K)))
ImageDraw.Draw(img).rounded_rectangle(box, r, fill=(250, 248, 244, 255))  # --paper

# the stroke's spine: top arm -> corner -> bottom arm, with a little overshoot at the corner
def spine():
    a = (660, 262); v = (352, 520); b = (676, 778)
    pts = []
    n = 160
    for i in range(n + 1):
        t = i / n
        if t < .5:
            u = t / .5; p = (a[0] + (v[0] - a[0]) * u, a[1] + (v[1] - a[1]) * u)
        else:
            u = (t - .5) / .5; p = (v[0] + (b[0] - v[0]) * u, v[1] + (b[1] - v[1]) * u)
        pts.append((t, p))
    return pts

ph = [random.random() * 6 for _ in range(4)]
lay = Image.new("L", (S, S), 0)
d = ImageDraw.Draw(lay)
for t, (x, y) in spine():
    # gentle hand wobble, never a jitter
    x += 4 * math.sin(t * 6 + ph[0]) + 2 * math.sin(t * 13 + ph[1])
    y += 3 * math.sin(t * 5 + ph[2])
    # pressure: lands heavy, eases a bit, lifts at the end
    w = 46 + 5 * math.sin(t * math.pi * 1.3 + .4) + 2.5 * math.sin(t * 11 + ph[3])
    w *= 1 - .22 * max(0, (t - .8) / .2) ** 2
    rad = w * K
    d.ellipse((x*K - rad, y*K - rad, x*K + rad, y*K + rad), fill=255)
lay = lay.filter(ImageFilter.GaussianBlur(.6 * K))  # smooth edge, not pixel-rough
fill = Image.new("RGBA", (S, S), ink + (255,))
img.paste(fill, (0, 0), lay)

img.resize((1024, 1024), Image.LANCZOS).save(out)
