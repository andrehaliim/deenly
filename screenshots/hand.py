"""Renders the portfolio banner with a hand holding the phone (1920x1080).

Puts raw/<locale>/01_home on the screen of the hand mockup in
screenshots/mockup/ (exported from the "Free iPhone 18 Pro Mockup Held at
an Angle" PSD), laid out by screenshots/template_hand.html.

Usage: python screenshots/hand.py [locale]   (default: en)
Writes screenshots/framed/hand_<locale>.png.
"""

import json
import sys
import tempfile
from pathlib import Path

from banner import ICON, SIZE, find_shot
from frame import CONFIG, FONTS, OUT, ROOT, data_uri, find_chrome, render

TEMPLATE = ROOT / "template_hand.html"
MOCKUP = ROOT / "mockup"

SCREEN = (1080, 2340)

# Screen corners of the PSD smart object (top-left, top-right,
# bottom-right, bottom-left) in the PSD's 3680x2760 pixel space.
CORNERS = [
    (1869.0, 361.794),
    (2667.601, 677.723),
    (1856.081, 2368.376),
    (1081.269, 1996.819),
]


def solve(a, b):
    """Solves the linear system a x = b with Gaussian elimination."""
    n = len(b)
    m = [row[:] + [b[i]] for i, row in enumerate(a)]
    for col in range(n):
        pivot = max(range(col, n), key=lambda r: abs(m[r][col]))
        m[col], m[pivot] = m[pivot], m[col]
        for r in range(n):
            if r != col:
                f = m[r][col] / m[col][col]
                m[r] = [x - f * y for x, y in zip(m[r], m[col])]
    return [m[i][n] / m[i][i] for i in range(n)]


def matrix3d(width, height, corners):
    """CSS matrix3d that maps a width x height box onto four corners."""
    src = [(0, 0), (width, 0), (width, height), (0, height)]
    a, b = [], []
    for (x, y), (u, v) in zip(src, corners):
        a.append([x, y, 1, 0, 0, 0, -u * x, -u * y])
        b.append(u)
        a.append([0, 0, 0, x, y, 1, -v * x, -v * y])
        b.append(v)
    h0, h1, h2, h3, h4, h5, h6, h7 = solve(a, b)
    values = [h0, h3, 0, h6, h1, h4, 0, h7, 0, 0, 1, 0, h2, h5, 0, 1]
    return "matrix3d(" + ", ".join(f"{v:.10f}" for v in values) + ")"


def main():
    locale = sys.argv[1] if len(sys.argv) > 1 else "en"
    config = json.loads(CONFIG.read_text(encoding="utf-8"))

    page_html = (
        TEMPLATE.read_text(encoding="utf-8")
        .replace("{{fonts}}", FONTS.as_uri())
        .replace("{{icon}}", data_uri(ICON))
        .replace("{{scene}}", data_uri(MOCKUP / "scene.png"))
        .replace("{{mask}}", data_uri(MOCKUP / "mask.png"))
        .replace("{{shot}}", data_uri(find_shot(locale, "01_home")))
        .replace("{{matrix}}", matrix3d(*SCREEN, CORNERS))
        .replace("{{crop_top}}", str(config.get("crop_top", 0)))
    )

    with tempfile.TemporaryDirectory() as tmp:
        page = Path(tmp) / "hand.html"
        page.write_text(page_html, encoding="utf-8")
        out = OUT / f"hand_{locale}.png"
        render(find_chrome(), page, out, SIZE)
        print(f"wrote {out.relative_to(ROOT.parent)}")


if __name__ == "__main__":
    main()
