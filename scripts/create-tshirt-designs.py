#!/usr/bin/env python3
"""
Fresh Threads LLC - T-Shirt Design Generator
Creates the "Code Crusade" design using PIL/Pillow
Based on Ollama-generated specifications
"""

import os

from PIL import Image, ImageDraw, ImageFont


def create_code_crusade_design():
    """Create the Code Crusade T-shirt design"""

    # Design specifications from Ollama
    width, height = 3600, 3600  # 12" x 12" at 300 DPI

    # Colors (from Ollama specifications)
    navy = "#032B44"
    charcoal = "#75737A"
    neon_green = "#66CC69"
    white = "#FFFFFF"
    black = "#000000"

    # Create image with transparent background
    img = Image.new("RGBA", (width, height), (255, 255, 255, 0))
    draw = ImageDraw.Draw(img)

    # Try to use system fonts (fallback to default if not available)
    try:
        # Main title font - bold, large
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 300)
        subtitle_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 120)
    except:
        # Fallback to default font
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()

    # Main text: "CODE CRUSADE"
    main_text = "CODE CRUSADE"

    # Get text bounding box for centering
    bbox = draw.textbbox((0, 0), main_text, font=title_font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]

    # Position main text (centered horizontally, upper portion vertically)
    main_x = (width - text_width) // 2
    main_y = height // 3

    # Draw main text
    draw.text((main_x, main_y), main_text, fill=navy, font=title_font)

    # Subtitle: "Write Code, Change World"
    subtitle = "Write Code, Change World"

    # Get subtitle bounding box
    sub_bbox = draw.textbbox((0, 0), subtitle, font=subtitle_font)
    sub_width = sub_bbox[2] - sub_bbox[0]

    # Position subtitle (left-aligned under main text)
    sub_x = main_x
    sub_y = main_y + text_height + 100

    # Draw subtitle
    draw.text((sub_x, sub_y), subtitle, fill=charcoal, font=subtitle_font)

    # Add accent element (small line)
    line_start = (sub_x, sub_y - 50)
    line_end = (sub_x + 300, sub_y - 50)
    draw.line([line_start, line_end], fill=neon_green, width=8)

    return img


def create_simple_logo():
    """Create a simple chest logo version"""

    # Smaller size for chest logo (3.5" diameter = ~1050px at 300 DPI)
    size = 1050
    img = Image.new("RGBA", (size, size), (255, 255, 255, 0))
    draw = ImageDraw.Draw(img)

    # Colors
    navy = "#032B44"
    white = "#FFFFFF"

    try:
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 120)
    except:
        font = ImageFont.load_default()

    # Simple text logo
    text = "FRESH\nTHREADS"

    # Get text dimensions
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]

    # Center the text
    x = (size - text_width) // 2
    y = (size - text_height) // 2

    # Draw text
    draw.text((x, y), text, fill=navy, font=font, align="center")

    return img


def main():
    """Generate and save T-shirt designs"""

    print("🎨 Creating Fresh Threads T-Shirt Designs...")

    # Create output directory
    output_dir = "docs/assets/designs/source-files"
    os.makedirs(output_dir, exist_ok=True)

    # Generate main design
    print("📐 Creating Code Crusade main design...")
    main_design = create_code_crusade_design()
    main_path = os.path.join(output_dir, "code-crusade-main.png")
    main_design.save(main_path, "PNG")
    print(f"✅ Saved: {main_path}")

    # Generate logo version
    print("🏷️ Creating chest logo version...")
    logo_design = create_simple_logo()
    logo_path = os.path.join(output_dir, "fresh-threads-logo.png")
    logo_design.save(logo_path, "PNG")
    print(f"✅ Saved: {logo_path}")

    # Create print-ready versions (high contrast)
    print("🖨️ Creating print-ready versions...")

    # Black version for light shirts
    print_dir = "docs/assets/designs/print-ready"
    os.makedirs(print_dir, exist_ok=True)

    black_design = create_code_crusade_design()
    black_path = os.path.join(print_dir, "code-crusade-black.png")
    black_design.save(black_path, "PNG")

    print(f"✅ Print-ready saved: {black_path}")

    print("\n🚀 Design Creation Complete!")
    print("📁 Files created:")
    print(f"   • Main design: {main_path}")
    print(f"   • Logo version: {logo_path}")
    print(f"   • Print-ready: {black_path}")
    print("\n🎯 Ready for mockup generation and website integration!")


if __name__ == "__main__":
    main()
