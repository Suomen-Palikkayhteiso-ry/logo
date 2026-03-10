#!/usr/bin/env python3
"""Convert <text> elements in SVG to outlined <path> elements using fontTools.

This removes the embedded @font-face from composed logo SVGs so they are
self-contained without any font dependency.

Usage:
    text_to_path.py FONT_PATH SVG_FILE [SVG_FILE ...]
"""

import re
import sys

from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont


def get_attr(attrs_str, attr):
    m = re.search(r"\b" + re.escape(attr) + r'="([^"]*)"', attrs_str)
    return m.group(1) if m else None


def convert_text_to_path(font, text_match):
    """Convert a <text ...>content</text> match to a <path .../> element."""
    attrs_str = text_match.group(1)
    text_content = text_match.group(2)

    x = float(get_attr(attrs_str, "x") or "0")
    y = float(get_attr(attrs_str, "y") or "0")
    font_size = float(get_attr(attrs_str, "font-size") or "16")
    text_length_str = get_attr(attrs_str, "textLength")
    text_length = float(text_length_str) if text_length_str else None
    fill = get_attr(attrs_str, "fill") or "#000000"

    units_per_em = font["head"].unitsPerEm
    cmap = font.getBestCmap()
    hmtx = font["hmtx"]
    # Explicitly request weight 400 (Regular) from the variable font so the
    # outlined paths match the weight rendered by rsvg-convert via font-weight="400".
    glyph_set = font.getGlyphSet(location={"wght": 400})

    scale = font_size / units_per_em

    # Collect (glyph_name, advance_width) for each character
    glyphs = []
    for char in text_content:
        glyph_name = cmap.get(ord(char))
        if glyph_name is None:
            glyph_name = ".notdef"
        aw, _ = hmtx.metrics.get(glyph_name, (0, 0))
        glyphs.append((glyph_name, aw))

    # Natural total advance in SVG pixels
    total_adv = sum(aw for _, aw in glyphs)
    natural_width = total_adv * scale

    # lengthAdjust="spacingAndGlyphs": uniform horizontal scale to fit textLength
    if text_length is not None and natural_width > 0:
        x_scale = text_length / natural_width
        effective_width = text_length
    else:
        x_scale = 1.0
        effective_width = natural_width

    # text-anchor="middle": text centered at x
    cur_x = x - effective_width / 2.0

    path_parts = []
    for glyph_name, aw in glyphs:
        if glyph_name in glyph_set:
            # Affine transform: scale glyph, flip y (font y-up → SVG y-down), translate.
            # x' = scale*x_scale * x_font + cur_x
            # y' = -scale * y_font + y  (baseline at y)
            transform = (scale * x_scale, 0, 0, -scale, cur_x, y)
            svg_pen = SVGPathPen(glyph_set)
            t_pen = TransformPen(svg_pen, transform)
            glyph_set[glyph_name].draw(t_pen)
            d = svg_pen.getCommands()
            if d:
                path_parts.append(d)
        cur_x += aw * scale * x_scale

    if not path_parts:
        return ""

    return f'<path fill="{fill}" d="{" ".join(path_parts)}"/>'


def process_svg(svg_path, font):
    with open(svg_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Replace each <text ...>...</text> with an outlined <path>
    new_content = re.sub(
        r"<text\b([^>]*)>(.*?)</text>",
        lambda m: convert_text_to_path(font, m),
        content,
        flags=re.DOTALL,
    )

    # Remove the <defs> block that contains only the embedded @font-face
    new_content = re.sub(
        r"<defs><style>@font-face[^<]*</style></defs>",
        "",
        new_content,
    )

    if new_content != content:
        with open(svg_path, "w", encoding="utf-8") as f:
            f.write(new_content)
        print(f"  Outlined text in {svg_path}")
    else:
        print(f"  No text elements found in {svg_path}", file=sys.stderr)


def main():
    if len(sys.argv) < 3:
        print(
            f"Usage: {sys.argv[0]} FONT_PATH SVG_FILE [SVG_FILE ...]",
            file=sys.stderr,
        )
        sys.exit(1)

    font_path = sys.argv[1]
    svg_paths = sys.argv[2:]

    font = TTFont(font_path)

    for svg_path in svg_paths:
        try:
            process_svg(svg_path, font)
        except Exception as e:
            print(f"Error processing {svg_path}: {e}", file=sys.stderr)
            sys.exit(1)


if __name__ == "__main__":
    main()
