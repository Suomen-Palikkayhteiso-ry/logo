#!/usr/bin/env python3
"""
Generate design SVGs for the LEGO minifig head logo mark.

Reads brand colors from colors.py and writes source SVG files to design/.
These are processed by brick_blockify.py to produce the final brick-art logos.

Re-run whenever colors.py changes:  python3 generate_designs.py
Or via make:                         make designs
"""

import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
import colors


def minifig_svg(face_color, feature_color, highlight_color):
    """
    Generate a 200×200 SVG of a LEGO minifig head.

    Designed for rasterization at 20–30 pixels wide via brick_blockify.py.
    Each SVG unit maps to roughly 0.1–0.15 output pixels, so features must
    be at least ~10 SVG units wide/tall to survive nearest-neighbour downscaling.

    Layout (200×200 canvas):
      y   0-22   stud on top (50px wide, centred)
      y  22-190  head body (rounded rect, 180px wide)
      y  68-82   eyebrows (two rects, 48px × 14px each)
      y  81-135  eyes (ellipses, rx=22 ry=27 → ~44×54px each)
      y  92-106  eye highlights (ellipses, rx=10 ry=10 → 20px each)
      y 148-175  smile arc (quadratic bezier, stroke-width=16)
    """
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg width="200" height="200" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
  <!-- Stud on top -->
  <rect x="75" y="0" width="50" height="22" fill="{face_color}"/>
  <!-- Head body -->
  <rect x="10" y="22" width="180" height="168" rx="20" fill="{face_color}"/>
  <!-- Left eyebrow -->
  <rect x="28" y="68" width="48" height="14" fill="{feature_color}"/>
  <!-- Right eyebrow -->
  <rect x="124" y="68" width="48" height="14" fill="{feature_color}"/>
  <!-- Left eye (black oval) -->
  <ellipse cx="65" cy="108" rx="22" ry="27" fill="{feature_color}"/>
  <!-- Right eye (black oval) -->
  <ellipse cx="135" cy="108" rx="22" ry="27" fill="{feature_color}"/>
  <!-- Left eye highlight -->
  <ellipse cx="74" cy="96" rx="10" ry="10" fill="{highlight_color}"/>
  <!-- Right eye highlight -->
  <ellipse cx="144" cy="96" rx="10" ry="10" fill="{highlight_color}"/>
  <!-- Smile (quadratic bezier arc) -->
  <path d="M 60,148 Q 100,175 140,148"
        stroke="{feature_color}" stroke-width="16"
        fill="none" stroke-linecap="round"/>
</svg>
'''


def main():
    design_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'design')
    os.makedirs(design_dir, exist_ok=True)

    face  = colors.FACE_COLOR       # LEGO Yellow
    feat  = colors.FEATURE_COLOR    # LEGO Black
    hi    = colors.HIGHLIGHT_COLOR  # LEGO White

    variants = [
        ('minifig-yellow.svg', face, feat, hi),    # classic yellow head
        ('minifig-black.svg',  feat, hi,   feat),  # inverted: white features on black
        ('minifig-white.svg',  hi,   feat,  hi),   # inverted: black features on white
    ]

    for filename, f_color, ft_color, h_color in variants:
        path = os.path.join(design_dir, filename)
        with open(path, 'w') as fh:
            fh.write(minifig_svg(f_color, ft_color, h_color))
        print(f'Wrote {path}')


if __name__ == '__main__':
    main()
