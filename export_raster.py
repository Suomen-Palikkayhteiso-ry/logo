#!/usr/bin/env python3
"""
Export an SVG to PNG and WebP at a given output width.

Usage:
    python3 export_raster.py <input.svg> <output.png|.webp> <width>
"""
import io
import sys

import cairosvg
from PIL import Image

input_svg, output_path, width = sys.argv[1], sys.argv[2], int(sys.argv[3])

png_bytes = cairosvg.svg2png(url=input_svg, output_width=width)

if output_path.endswith('.webp'):
    img = Image.open(io.BytesIO(png_bytes))
    img.save(output_path, 'WEBP', quality=95)
else:
    with open(output_path, 'wb') as f:
        f.write(png_bytes)
