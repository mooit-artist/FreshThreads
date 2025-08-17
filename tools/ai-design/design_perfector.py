#!/usr/bin/env python3
"""
Fresh Threads LLC - 404 Design Perfector
Interactive tool to perfect the 404 design based on your preferences
"""

import json
from datetime import datetime
from pathlib import Path
import webbrowser
import tempfile


class DesignPerfector:
    def __init__(self):
        self.output_dir = Path("design-output")
        self.final_dir = self.output_dir / "final-approved"
        self.final_dir.mkdir(exist_ok=True)

    def create_404_variation(self, style="clean"):
        """Create 404 design variations based on style preference"""

        if style == "clean":
            # Ultra-clean, professional version
            svg = '''<svg width="400" height="300" viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="cleanGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#f7fafc;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#edf2f7;stop-opacity:1" />
    </linearGradient>
  </defs>

  <rect width="400" height="300" fill="url(#cleanGrad)"/>

  <!-- Large, bold 404 -->
  <text x="200" y="140" text-anchor="middle" font-family="system-ui, -apple-system, sans-serif"
        font-size="48" font-weight="900" fill="#2d3748" letter-spacing="4px">404</text>

  <!-- Clean subtitle -->
  <text x="200" y="175" text-anchor="middle" font-family="system-ui, -apple-system, sans-serif"
        font-size="16" font-weight="500" fill="#718096" letter-spacing="2px">SLEEP NOT FOUND</text>

  <!-- Minimal accent -->
  <line x1="160" y1="155" x2="240" y2="155" stroke="#4299e1" stroke-width="2"/>
</svg>'''

        elif style == "modern":
            # Modern, sleek version
            svg = '''<svg width="400" height="300" viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="modernGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#1a202c;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#2d3748;stop-opacity:1" />
    </linearGradient>

    <filter id="glow">
      <feGaussianBlur stdDeviation="3" result="coloredBlur"/>
      <feMerge><feMergeNode in="coloredBlur"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
  </defs>

  <rect width="400" height="300" fill="url(#modernGrad)"/>

  <!-- Glowing 404 -->
  <text x="200" y="140" text-anchor="middle" font-family="SF Pro Display, system-ui, sans-serif"
        font-size="42" font-weight="800" fill="#4fd1c7" filter="url(#glow)">404</text>

  <!-- Subtitle -->
  <text x="200" y="175" text-anchor="middle" font-family="SF Pro Display, system-ui, sans-serif"
        font-size="14" font-weight="400" fill="#a0aec0" letter-spacing="1px">Sleep Not Found</text>

  <!-- Modern accent line -->
  <line x1="150" y1="155" x2="250" y2="155" stroke="#4fd1c7" stroke-width="1" opacity="0.6"/>
</svg>'''

        elif style == "retro":
            # Retro terminal version
            svg = '''<svg width="400" height="300" viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
  <rect width="400" height="300" fill="#000000"/>

  <!-- Terminal window -->
  <rect x="60" y="80" width="280" height="140" rx="4" fill="#001100" stroke="#00ff00" stroke-width="1"/>

  <!-- Terminal text -->
  <text x="80" y="110" font-family="Courier, Monaco, monospace" font-size="11" fill="#00ff00">$ sleep</text>
  <text x="80" y="135" font-family="Courier, Monaco, monospace" font-size="20" font-weight="bold" fill="#ff4444">ERROR 404</text>
  <text x="80" y="160" font-family="Courier, Monaco, monospace" font-size="14" fill="#00ff00">Sleep Not Found</text>
  <text x="80" y="185" font-family="Courier, Monaco, monospace" font-size="11" fill="#00ff00">Try: coffee --force</text>

  <!-- Cursor -->
  <rect x="80" y="195" width="8" height="12" fill="#00ff00">
    <animate attributeName="opacity" values="1;0;1" dur="1s" repeatCount="indefinite"/>
  </rect>
</svg>'''

        elif style == "minimal":
            # Ultra minimal version
            svg = '''<svg width="400" height="300" viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
  <rect width="400" height="300" fill="#ffffff"/>

  <!-- Just the essentials -->
  <text x="200" y="130" text-anchor="middle" font-family="Helvetica, Arial, sans-serif"
        font-size="36" font-weight="300" fill="#333333">404</text>

  <text x="200" y="170" text-anchor="middle" font-family="Helvetica, Arial, sans-serif"
        font-size="14" font-weight="400" fill="#666666">Sleep Not Found</text>
</svg>'''

        return svg

    def create_quick_preview(self, svg_content, style_name):
        """Create a quick preview HTML"""
        html = f"""
<!DOCTYPE html>
<html>
<head>
    <title>404 Design - {style_name.title()}</title>
    <style>
        body {{ font-family: system-ui; margin: 0; padding: 40px; background: #f5f5f5; }}
        .container {{ max-width: 800px; margin: 0 auto; background: white; padding: 40px; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }}
        .style-badge {{ background: #4299e1; color: white; padding: 8px 16px; border-radius: 20px; display: inline-block; margin-bottom: 20px; }}
        .design-preview {{ text-align: center; margin: 30px 0; padding: 30px; background: #f8f9fa; border-radius: 10px; }}
        .mockup {{ width: 300px; height: 350px; background: #2d3748; border-radius: 15px; margin: 20px auto; display: flex; align-items: center; justify-content: center; position: relative; }}
        .design-on-mockup {{ transform: scale(0.6); }}
        h1 {{ color: #2d3748; text-align: center; }}
        .feedback {{ background: #e6fffa; padding: 20px; border-radius: 10px; margin: 20px 0; border-left: 4px solid #4fd1c7; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="style-badge">{style_name.title()} Style</div>
        <h1>Fresh Threads LLC - 404 Design</h1>

        <div class="design-preview">
            <h3>Design Preview:</h3>
            {svg_content}
        </div>

        <div class="mockup">
            <div class="design-on-mockup">{svg_content}</div>
        </div>

        <div class="feedback">
            <h3>🎯 Quick Assessment:</h3>
            <p><strong>Style:</strong> {style_name.title()}</p>
            <p><strong>Target:</strong> Developers & IT professionals</p>
            <p><strong>Vibe:</strong> {"Professional & clean" if style_name == "clean" else "Modern & sleek" if style_name == "modern" else "Retro & nostalgic" if style_name == "retro" else "Ultra minimal"}</p>
            <p>Return to terminal to approve or try next variation!</p>
        </div>
    </div>
</body>
</html>"""
        return html

    def show_variation(self, style_name):
        """Show a design variation"""
        svg = self.create_404_variation(style_name)
        html = self.create_quick_preview(svg, style_name)

        with tempfile.NamedTemporaryFile(mode='w', suffix='.html', delete=False) as f:
            f.write(html)
            preview_file = f.name

        webbrowser.open(f'file://{preview_file}')
        return svg

    def save_final_design(self, svg_content, style_name):
        """Save the final approved design"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"404_sleep_not_found_{style_name}_{timestamp}.svg"
        filepath = self.final_dir / filename

        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(svg_content)

        # Create production metadata
        metadata = {
            "design_name": "Error 404: Sleep Not Found",
            "style": style_name,
            "collection": "Debug Mode",
            "target_audience": "Developers, IT professionals, programmers",
            "final_approved": True,
            "production_ready": True,
            "print_specifications": {
                "format": "SVG vector",
                "size": "10\" x 7.5\" recommended",
                "placement": "Front chest, centered",
                "print_methods": ["Screen printing", "DTG", "Heat transfer"],
                "color_profile": "RGB optimized"
            },
            "marketing_copy": {
                "title": "Error 404: Sleep Not Found",
                "description": "Perfect for developers who debug by day and dream in code by night",
                "tags": ["developer", "programming", "humor", "404", "sleep", "tech"],
                "suggested_price": "$24.99"
            },
            "timestamp": timestamp,
            "svg_file": str(filepath)
        }

        metadata_file = filepath.with_suffix('.json')
        with open(metadata_file, 'w', encoding='utf-8') as f:
            json.dump(metadata, f, indent=2)

        return filepath


def main():
    """Interactive design perfection process"""
    print("🎯 Fresh Threads LLC - 404 Design Perfector")
    print("=" * 50)
    print("Let's find the perfect style for your 404 design!")

    perfector = DesignPerfector()

    styles = ["clean", "modern", "retro", "minimal"]
    style_descriptions = {
        "clean": "Professional, bright, corporate-friendly",
        "modern": "Sleek, tech-forward, glowing effects",
        "retro": "Classic terminal, nostalgic, authentic",
        "minimal": "Ultra-simple, Helvetica, timeless"
    }

    print("\n🎨 Available styles:")
    for i, style in enumerate(styles, 1):
        print(f"{i}. {style.title()}: {style_descriptions[style]}")

    print("\n5. Show all styles in sequence")
    print("6. Exit")

    while True:
        choice = input("\nWhich style would you like to see? (1-6): ").strip()

        if choice in ["1", "2", "3", "4"]:
            style_name = styles[int(choice) - 1]
            print(f"\n🖼️  Opening {style_name} style preview...")

            svg_content = perfector.show_variation(style_name)

            approve = input(
                f"\nApprove {style_name} style? (y/n): ").strip().lower()
            if approve == 'y':
                filepath = perfector.save_final_design(svg_content, style_name)
                print(f"\n✅ FINAL DESIGN APPROVED!")
                print(f"📁 Saved: {filepath}")
                print(f"🚀 Ready for production!")
                break

        elif choice == "5":
            print("\n🎨 Showing all styles...")
            for style in styles:
                print(f"\n--- {style.title()} Style ---")
                svg_content = perfector.show_variation(style)
                input("Press Enter to continue to next style...")

        elif choice == "6":
            print("👋 Exiting design perfector")
            break

        else:
            print("❌ Invalid choice. Please enter 1-6.")


if __name__ == "__main__":
    main()
