"""Renders the landscape portfolio banner (1920x1080).

Uses raw/<locale>/03_prayers, 02_quran and 12_widget (any supported
extension) and the app icon, laid out by screenshots/template_banner.html.

Usage: python screenshots/banner.py [locale]   (default: en)
Writes screenshots/framed/banner_<locale>.png.
"""

import json
import sys
import tempfile
from pathlib import Path

from frame import CONFIG, EXTENSIONS, FONTS, OUT, RAW, ROOT, data_uri, find_chrome, render

TEMPLATE = ROOT / "template_banner.html"
ICON = ROOT.parent / "assets" / "icon" / "app_icon.png"
SIZE = (1920, 1080)


def find_shot(locale, name):
    for path in sorted((RAW / locale).glob(f"{name}.*")):
        if path.suffix.lower() in EXTENSIONS:
            return path
    raise SystemExit(f"Missing {RAW / locale / name}.*")


def main():
    locale = sys.argv[1] if len(sys.argv) > 1 else "en"
    config = json.loads(CONFIG.read_text(encoding="utf-8"))
    crop = config.get("crop_top", 0) / config.get("source_width", 1080) * 100

    page_html = (
        TEMPLATE.read_text(encoding="utf-8")
        .replace("{{fonts}}", FONTS.as_uri())
        .replace("{{icon}}", data_uri(ICON))
        .replace("{{prayers}}", data_uri(find_shot(locale, "03_prayers")))
        .replace("{{quran}}", data_uri(find_shot(locale, "02_quran")))
        .replace("{{widget}}", data_uri(find_shot(locale, "12_widget")))
        .replace("{{crop}}", f"{crop:.4f}")
    )

    with tempfile.TemporaryDirectory() as tmp:
        page = Path(tmp) / "banner.html"
        page.write_text(page_html, encoding="utf-8")
        out = OUT / f"banner_{locale}.png"
        render(find_chrome(), page, out, SIZE)
        print(f"wrote {out.relative_to(ROOT.parent)}")


if __name__ == "__main__":
    main()
