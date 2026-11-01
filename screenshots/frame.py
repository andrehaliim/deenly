"""Wraps app screenshots in promo frames for the Play Store.

1. Put screenshots in screenshots/raw/<locale>/<name>.png (or .jpg), for
   example raw/id/01_home.png and raw/en/01_home.png.
2. Add a caption for each <name> and locale in screenshots/captions.json.
   Set "crop_top" to the status bar height in screenshot pixels to trim it
   ("source_width" is the screenshot width, 1080 on most phones).
   For a home screen widget shot on a green wallpaper, add
   "layout": "widget" and "crop": [top, bottom] to its entry: the green is
   keyed out and only rows top..bottom are kept (see template_widget.html).
3. Run: python screenshots/frame.py

Frames are written to screenshots/framed/<locale>/<name>.png at 1080x1920,
rendered with headless Chrome or Edge from screenshots/template.html.
"""

import base64
import html
import json
import mimetypes
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent
RAW = ROOT / "raw"
OUT = ROOT / "framed"
CONFIG = ROOT / "captions.json"
TEMPLATES = {
    "phone": ROOT / "template.html",
    "widget": ROOT / "template_widget.html",
}
FONTS = ROOT.parent / "assets" / "google_fonts"

WIDTH, HEIGHT = 1080, 1920
EXTENSIONS = {".png", ".jpg", ".jpeg", ".webp"}

CHROME_CANDIDATES = [
    r"C:\Program Files\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    "google-chrome",
    "chromium",
]


def find_chrome():
    for candidate in CHROME_CANDIDATES:
        path = shutil.which(candidate) or (candidate if Path(candidate).exists() else None)
        if path:
            return path
    raise SystemExit("Chrome or Edge not found")


def render(chrome, html_path, png_path, size=(WIDTH, HEIGHT)):
    png_path.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        [
            chrome,
            "--headless=new",
            "--disable-gpu",
            "--hide-scrollbars",
            "--force-device-scale-factor=1",
            "--allow-file-access-from-files",
            # Gives the widget template's script time to key out the green.
            "--virtual-time-budget=3000",
            f"--window-size={size[0]},{size[1]}",
            f"--screenshot={png_path}",
            html_path.as_uri(),
        ],
        check=True,
        capture_output=True,
    )


def data_uri(path):
    """Inlines the screenshot so the widget canvas is not tainted by a
    file:// image and can read its pixels."""
    mime = mimetypes.guess_type(path.name)[0] or "image/png"
    return f"data:{mime};base64,{base64.b64encode(path.read_bytes()).decode()}"


def main():
    config = json.loads(CONFIG.read_text(encoding="utf-8"))
    captions = config.get("captions", {})
    source_width = config.get("source_width", 1080)
    crop = config.get("crop_top", 0) / source_width * 100
    templates = {
        layout: path.read_text(encoding="utf-8")
        for layout, path in TEMPLATES.items()
    }
    chrome = find_chrome()

    shots = sorted(
        path
        for path in RAW.glob("*/*")
        if path.suffix.lower() in EXTENSIONS
    )
    if not shots:
        raise SystemExit(f"No screenshots in {RAW}/<locale>/")

    with tempfile.TemporaryDirectory() as tmp:
        for shot in shots:
            locale, name = shot.parent.name, shot.stem
            entry = captions.get(name, {})
            caption = entry.get(locale)
            if caption is None:
                print(f"skip {locale}/{shot.name}: no caption for '{name}' in captions.json")
                continue
            title, subtitle = caption
            crop_top, crop_bottom = entry.get("crop", [0, 100000])
            template = templates[entry.get("layout", "phone")]
            page = Path(tmp) / f"{locale}_{name}.html"
            page.write_text(
                template.replace("{{fonts}}", FONTS.as_uri())
                .replace("{{shot}}", data_uri(shot))
                .replace("{{crop}}", f"{crop:.4f}")
                .replace("{{crop_top}}", str(crop_top))
                .replace("{{crop_bottom}}", str(crop_bottom))
                .replace("{{source_width}}", str(source_width))
                .replace("{{title}}", html.escape(title))
                .replace("{{subtitle}}", html.escape(subtitle)),
                encoding="utf-8",
            )
            out = OUT / locale / f"{name}.png"
            render(chrome, page, out)
            print(f"wrote {out.relative_to(ROOT.parent)}")


if __name__ == "__main__":
    main()
