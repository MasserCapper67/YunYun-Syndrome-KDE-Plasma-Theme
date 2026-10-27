#!/usr/bin/env python3
"""Render the KDE Plasma theme SVGs into assets the Quickshell shell can use.

Plasma draws its frames as 9-slice sets of named SVG elements (topleft, top,
topright, ...), optionally with a prefix such as "focus-" or "hover-". Qt Quick's
BorderImage wants a single image plus border sizes instead, so for every frame
set we render the nine pieces, stitch them into one PNG (1x and @2x) and record
the border and content-margin sizes in theme/Frames.qml.

Plasma also recolors elements that carry a "ColorScheme-*" class with the
active KDE color scheme, so the YunYun .colors values are injected into each
SVG's stylesheet before rendering.

Only needed when the KDE theme changes; the generated files are committed.
Requires rsvg-convert and Pillow.
"""

import configparser
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image

REPO = Path(__file__).resolve().parents[2]
PLASMA = REPO / "plasma" / "desktopheme" / "YunYunSyndrome"
COLORS = REPO / "color-schemes" / "YunYunSyndrome.colors"
OUT = REPO / "hyprland" / "config" / "quickshell"
FRAMES_DIR = OUT / "assets" / "frames"
ICONS_DIR = OUT / "assets" / "icons"

PIECES = ["topleft", "top", "topright", "left", "center", "right", "bottomleft", "bottom", "bottomright"]

# name in the shell -> (svg relative to the plasma theme, element prefix)
FRAMES = {
    "dialog": ("dialogs/background", ""),
    "tooltip": ("widgets/tooltip", ""),
    "widget": ("widgets/background", ""),
    "panel": ("widgets/panel-background", ""),
    "task-normal": ("widgets/tasks", "normal-"),
    "task-focus": ("widgets/tasks", "focus-"),
    "task-hover": ("widgets/tasks", "hover-"),
    "task-attention": ("widgets/tasks", "attention-"),
    "task-minimized": ("widgets/tasks", "minimized-"),
    "button-normal": ("widgets/button", "normal-"),
    "button-hover": ("widgets/button", "hover-"),
    "button-pressed": ("widgets/button", "pressed-"),
    "toolbutton-hover": ("widgets/button", "toolbutton-hover-"),
    "toolbutton-pressed": ("widgets/button", "toolbutton-pressed-"),
    "viewitem-hover": ("widgets/viewitem", "hover-"),
    "viewitem-selected": ("widgets/viewitem", "selected-"),
    "viewitem-selected-hover": ("widgets/viewitem", "selected+hover-"),
    "tab-active": ("widgets/tabbar", "north-active-tab-"),
    "heading-header": ("widgets/plasmoidheading", "header-"),
    "heading-footer": ("widgets/plasmoidheading", "footer-"),
    "frame-plain": ("widgets/frame", "plain-"),
    "lineedit": ("widgets/lineedit", "base-"),
    "scrollbar-groove": ("widgets/scrollbar", "background-vertical-"),
    "scrollbar-slider": ("widgets/scrollbar", "slider-"),
    "scrollbar-slider-hover": ("widgets/scrollbar", "mouseover-slider-"),
    "pager-active": ("widgets/pager", "active-"),
}

# whole SVGs (or single elements of them) copied as icons
ICONS = {
    "start": ("icons/start", None),
}


def load_scheme():
    cp = configparser.ConfigParser(strict=False, interpolation=None)
    cp.optionxform = str
    cp.read(COLORS)

    def c(group, key):
        r, g, b = (int(v) for v in cp[f"Colors:{group}"][key].split(",")[:3])
        return f"#{r:02x}{g:02x}{b:02x}"

    # Same mapping Plasma uses when it recolors theme SVGs
    return {
        "Text": c("Window", "ForegroundNormal"),
        "Background": c("Window", "BackgroundNormal"),
        "Highlight": c("Selection", "BackgroundNormal"),
        "HighlightedText": c("Selection", "ForegroundNormal"),
        "PositiveText": c("Window", "ForegroundPositive"),
        "NeutralText": c("Window", "ForegroundNeutral"),
        "NegativeText": c("Window", "ForegroundNegative"),
        "ButtonText": c("Button", "ForegroundNormal"),
        "ButtonBackground": c("Button", "BackgroundNormal"),
        "ButtonHover": c("Button", "DecorationHover"),
        "ButtonFocus": c("Button", "DecorationFocus"),
        "ViewText": c("View", "ForegroundNormal"),
        "ViewBackground": c("View", "BackgroundNormal"),
        "ViewHover": c("View", "DecorationHover"),
        "ViewFocus": c("View", "DecorationFocus"),
        "TooltipText": c("Tooltip", "ForegroundNormal"),
        "TooltipBackground": c("Tooltip", "BackgroundNormal"),
        "ComplementaryText": c("Complementary", "ForegroundNormal"),
        "ComplementaryBackground": c("Complementary", "BackgroundNormal"),
    }


def recolor(svg_text, scheme):
    def repl(m):
        name = m.group(1)
        if name not in scheme:
            return m.group(0)
        return f".ColorScheme-{name} {{ color:{scheme[name]}; }}"

    return re.sub(r"\.ColorScheme-([A-Za-z]+)\s*\{[^}]*\}", repl, svg_text)


def has_id(svg_text, element_id):
    return f'id="{element_id}"' in svg_text


def render(svg_path, element_id, zoom, out_png):
    cmd = ["rsvg-convert", "-z", str(zoom), "-o", str(out_png)]
    if element_id:
        cmd[1:1] = ["-i", element_id]
    subprocess.run(cmd + [str(svg_path)], check=True, capture_output=True)
    return Image.open(out_png).convert("RGBA")


def element_size(svg_path, element_id, tmp):
    img = render(svg_path, element_id, 1, Path(tmp) / "hint.png")
    return img.size


def build_frame(svg_path, svg_text, prefix, zoom, tmp):
    imgs = {}
    for piece in PIECES:
        element_id = prefix + piece
        if not has_id(svg_text, element_id):
            return None
        imgs[piece] = render(svg_path, element_id, zoom, Path(tmp) / f"{piece}.png")

    lw = max(imgs["topleft"].width, imgs["left"].width, imgs["bottomleft"].width)
    rw = max(imgs["topright"].width, imgs["right"].width, imgs["bottomright"].width)
    cw = max(imgs["top"].width, imgs["center"].width, imgs["bottom"].width)
    th = max(imgs["topleft"].height, imgs["top"].height, imgs["topright"].height)
    bh = max(imgs["bottomleft"].height, imgs["bottom"].height, imgs["bottomright"].height)
    ch = max(imgs["left"].height, imgs["center"].height, imgs["right"].height)

    sheet = Image.new("RGBA", (lw + cw + rw, th + ch + bh), (0, 0, 0, 0))
    cells = {
        "topleft": (0, 0, lw, th), "top": (lw, 0, cw, th), "topright": (lw + cw, 0, rw, th),
        "left": (0, th, lw, ch), "center": (lw, th, cw, ch), "right": (lw + cw, th, rw, ch),
        "bottomleft": (0, th + ch, lw, bh), "bottom": (lw, th + ch, cw, bh),
        "bottomright": (lw + cw, th + ch, rw, bh),
    }
    for piece, (x, y, w, h) in cells.items():
        sheet.paste(imgs[piece].resize((w, h), Image.NEAREST), (x, y))
    return sheet, (lw, th, rw, bh)


def main():
    scheme = load_scheme()
    FRAMES_DIR.mkdir(parents=True, exist_ok=True)
    ICONS_DIR.mkdir(parents=True, exist_ok=True)
    meta = {}

    with tempfile.TemporaryDirectory() as tmp:
        for name, (svg_rel, prefix) in FRAMES.items():
            src = PLASMA / f"{svg_rel}.svg"
            svg_text = recolor(src.read_text(), scheme)
            svg_path = Path(tmp) / "src.svg"
            svg_path.write_text(svg_text)

            result = build_frame(svg_path, svg_text, prefix, 1, tmp)
            if result is None:
                print(f"skip {name}: incomplete 9-slice set", file=sys.stderr)
                continue
            sheet, (l, t, r, b) = result
            sheet.save(FRAMES_DIR / f"{name}.png")
            sheet2x, _ = build_frame(svg_path, svg_text, prefix, 2, tmp)
            sheet2x.save(FRAMES_DIR / f"{name}@2x.png")

            margins = {}
            for side in ("left", "top", "right", "bottom"):
                hint = f"{prefix}hint-{side}-margin"
                if not has_id(svg_text, hint):
                    hint = f"hint-{side}-margin"
                if has_id(svg_text, hint):
                    w, h = element_size(svg_path, hint, tmp)
                    margins[side] = w if side in ("left", "right") else h
                else:
                    margins[side] = {"left": l, "top": t, "right": r, "bottom": b}[side]
            meta[name] = {"l": l, "t": t, "r": r, "b": b,
                          "ml": margins["left"], "mt": margins["top"],
                          "mr": margins["right"], "mb": margins["bottom"]}
            print(f"{name}: borders {l},{t},{r},{b} margins {margins}")

        for name, (svg_rel, _) in ICONS.items():
            src = PLASMA / f"{svg_rel}.svg"
            (ICONS_DIR / f"{name}.svg").write_text(recolor(src.read_text(), scheme))

    qml = [
        "pragma Singleton",
        "",
        "import QtQuick",
        "import Quickshell",
        "",
        "// Generated by hyprland/tools/render-theme-assets.py - do not edit by hand.",
        "// Border (l/t/r/b) and content margin (ml/mt/mr/mb) sizes of each 9-slice frame.",
        "Singleton {",
        f"    readonly property var frames: ({json.dumps(meta, indent=4, sort_keys=True).replace(chr(10), chr(10) + '    ')})",
        "",
        "    function get(name) {",
        "        return frames[name] ?? { l: 0, t: 0, r: 0, b: 0, ml: 0, mt: 0, mr: 0, mb: 0 };",
        "    }",
        "}",
        "",
    ]
    (OUT / "theme" / "Frames.qml").parent.mkdir(parents=True, exist_ok=True)
    (OUT / "theme" / "Frames.qml").write_text("\n".join(qml))


if __name__ == "__main__":
    main()
