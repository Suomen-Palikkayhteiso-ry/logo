#!/usr/bin/env python3
"""
Compose a full logo by appending a subtitle text element to a brick SVG.

The canvas is widened with horizontal padding so the subtitle text has room.
The brick art is centred inside the wider canvas.

Usage:
    python3 compose_logo.py <input-brick.svg> <output-full.svg>
"""

import os
import sys
import xml.etree.ElementTree as ET

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import colors

FONT_REL_PATH      = 'fonts/Outfit-VariableFont_wght.ttf'
SUBTITLE_FONT_SIZE = 18    # SVG units
H_PAD              = 80    # horizontal padding each side (widens canvas)
GAP                = 24    # gap between bottom of brick art and text baseline
BOTTOM_PAD         = 20    # space below text baseline

ET.register_namespace('', 'http://www.w3.org/2000/svg')


def compose(input_svg: str, output_svg: str) -> None:
    tree = ET.parse(input_svg)
    root = tree.getroot()

    ns = 'http://www.w3.org/2000/svg'

    brick_w = float(root.get('width'))
    brick_h = float(root.get('height'))

    # New canvas is wider so the subtitle text fits
    canvas_w = brick_w + 2 * H_PAD
    canvas_h = brick_h + GAP + SUBTITLE_FONT_SIZE + BOTTOM_PAD

    # Pick subtitle color from the explicit per-variant mapping in colors.py.
    # Strip directory and extension; also strip a trailing '-full' suffix so
    # compose_logo.py works regardless of whether the input already has '-full'.
    stem = os.path.splitext(os.path.basename(input_svg))[0].removesuffix('-full')
    subtitle_color = colors.SUBTITLE_COLOR.get(stem, colors.SUBTITLE_ON_LIGHT)

    # Update root SVG canvas
    root.set('width',   str(int(canvas_w)))
    root.set('height',  str(int(canvas_h)))
    root.set('viewBox', f'0 0 {int(canvas_w)} {int(canvas_h)}')

    # Wrap all existing brick content in a <g> that shifts it right by H_PAD
    g = ET.Element(f'{{{ns}}}g')
    g.set('transform', f'translate({H_PAD}, 0)')
    for child in list(root):
        root.remove(child)
        g.append(child)
    root.insert(0, g)

    # Compute font path relative to the output file's directory
    project_root = os.path.dirname(os.path.abspath(__file__))
    out_dir      = os.path.dirname(os.path.abspath(output_svg))
    font_abs     = os.path.join(project_root, FONT_REL_PATH)
    font_path    = os.path.relpath(font_abs, out_dir)

    # Prepend <defs> with @font-face
    defs  = ET.Element(f'{{{ns}}}defs')
    style = ET.SubElement(defs, f'{{{ns}}}style')
    style.text = (
        "@font-face {"
        f" font-family: 'Outfit';"
        f" src: url('{font_path}') format('truetype');"
        " font-weight: 100 900; }"
    )
    root.insert(0, defs)

    # Append subtitle <text>, centred in the wider canvas
    text = ET.SubElement(root, f'{{{ns}}}text')
    text.set('x',           str(canvas_w / 2))
    text.set('y',           str(brick_h + GAP + SUBTITLE_FONT_SIZE))
    text.set('font-family', 'Outfit, sans-serif')
    text.set('font-size',   str(SUBTITLE_FONT_SIZE))
    text.set('font-weight', '400')
    text.set('text-anchor', 'middle')
    text.set('fill',        subtitle_color)
    text.text = colors.ASSOCIATION_NAME

    os.makedirs(os.path.dirname(os.path.abspath(output_svg)), exist_ok=True)
    tree.write(output_svg, encoding='unicode', xml_declaration=True)
    print(f'Composed {output_svg}  ({int(canvas_w)}×{int(canvas_h)})')


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print(f'Usage: {sys.argv[0]} <input-brick.svg> <output-full.svg>')
        sys.exit(1)
    compose(sys.argv[1], sys.argv[2])
