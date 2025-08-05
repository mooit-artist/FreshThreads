#!/usr/bin/env python3
"""
Fresh Threads LLC - Simple T-Shirt Design Generator
Creates the "Code Crusade" design using PIL/Pillow
Based on Ollama-generated specifications
"""

from PIL import Image, ImageDraw, ImageFont
import os


def create_simple_design():
    """Create a simple Code Crusade design"""

    # Design specifications from Ollama
    width, height = 1200, 1200  # Simpler size for testing

    # Colors (from Ollama specifications)
    navy = "#032B44"
    charcoal = "#75737A"
    neon_green = "#66CC69"

    # Create image with white background
    img = Image.new('RGB', (width, height), (255, 255, 255))
    draw = ImageDraw.Draw(img)

    # Use default font (cross-platform compatible)
    try:
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
    except Exception:
        # Fallback - this should always work
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()

    # Main text: "CODE CRUSADE"
    main_text = "CODE CRUSADE"

    # Position main text (centered)
    main_x = width // 4
    main_y = height // 3

    # Draw main text
    draw.text((main_x, main_y), main_text, fill=navy, font=title_font)

    # Subtitle: "Write Code, Change World"
    subtitle = "Write Code, Change World"

    # Position subtitle
    sub_x = main_x
    sub_y = main_y + 100

    # Draw subtitle
    draw.text((sub_x, sub_y), subtitle, fill=charcoal, font=subtitle_font)

    # Add accent line
    line_start = (sub_x, sub_y - 20)
    line_end = (sub_x + 200, sub_y - 20)
    draw.line([line_start, line_end], fill=neon_green, width=3)

    return img


def main():
    """Generate and save T-shirt design"""

    print("🎨 Creating Fresh Threads T-Shirt Design...")

    # Create output directory
    output_dir = "docs/assets/designs/source-files"
    os.makedirs(output_dir, exist_ok=True)

    # Generate design
    print("📐 Creating Code Crusade design...")
    design = create_simple_design()
    design_path = os.path.join(output_dir, "code-crusade-simple.png")
    design.save(design_path, "PNG")
    print(f"✅ Saved: {design_path}")

    print("\n🚀 Design Creation Complete!")
    print(f"📁 Design file: {design_path}")
    print("\n🎯 Ready for Issue #24 completion!")


if __name__ == "__main__":
    main()
