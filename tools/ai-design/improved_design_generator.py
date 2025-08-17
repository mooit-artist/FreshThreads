#!/usr/bin/env python3
"""
Fresh Threads LLC - Improved Design Generator
Focus on creating truly professional, market-ready designs
"""

import subprocess
import json
from datetime import datetime
from pathlib import Path
import webbrowser
import tempfile


class ImprovedDesignGenerator:
    def __init__(self):
        self.output_dir = Path("design-output")
        self.output_dir.mkdir(exist_ok=True)
        self.approved_dir = self.output_dir / "approved-v2"
        self.approved_dir.mkdir(exist_ok=True)

    def create_improved_404_design(self):
        """Create a much better 404 design with cleaner, more professional aesthetics"""
        svg = '''<svg width="400" height="300" viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <!-- Clean dark background gradient -->
    <linearGradient id="darkGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#1a1a2e;stop-opacity:1" />
      <stop offset="50%" style="stop-color:#16213e;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#0f3460;stop-opacity:1" />
    </linearGradient>

    <!-- Accent gradient for highlights -->
    <linearGradient id="accentGrad" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" style="stop-color:#00ff88;stop-opacity:1" />
      <stop offset="50%" style="stop-color:#00d4aa;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#00bcd4;stop-opacity:1" />
    </linearGradient>

    <!-- Glow effect for text -->
    <filter id="textGlow">
      <feGaussianBlur stdDeviation="2" result="coloredBlur"/>
      <feMerge>
        <feMergeNode in="coloredBlur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>

    <!-- Subtle grid pattern -->
    <pattern id="grid" x="0" y="0" width="40" height="40" patternUnits="userSpaceOnUse">
      <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#00ff88" stroke-width="0.5" opacity="0.1"/>
    </pattern>
  </defs>

  <!-- Background with subtle gradient -->
  <rect width="400" height="300" fill="url(#darkGrad)"/>

  <!-- Subtle grid overlay for tech feel -->
  <rect width="400" height="300" fill="url(#grid)"/>

  <!-- Main container with rounded corners -->
  <rect x="40" y="60" width="320" height="180" rx="12" fill="rgba(0,0,0,0.4)" stroke="url(#accentGrad)" stroke-width="1"/>

  <!-- Large, bold "ERROR 404" -->
  <text x="200" y="120" text-anchor="middle" font-family="Arial, sans-serif" font-size="32" font-weight="900"
        fill="url(#accentGrad)" filter="url(#textGlow)">ERROR 404</text>

  <!-- Clean separator line -->
  <line x1="80" y1="140" x2="320" y2="140" stroke="url(#accentGrad)" stroke-width="2" opacity="0.8"/>

  <!-- Secondary text with better spacing -->
  <text x="200" y="170" text-anchor="middle" font-family="Arial, sans-serif" font-size="18" font-weight="600"
        fill="#ffffff" letter-spacing="1px">Sleep Not Found</text>

  <!-- Subtle tech accent - cursor or loading indicator -->
  <rect x="320" y="190" width="12" height="2" fill="url(#accentGrad)">
    <animate attributeName="opacity" values="1;0;1" dur="1.5s" repeatCount="indefinite"/>
  </rect>

  <!-- Corner accent elements -->
  <circle cx="60" cy="80" r="2" fill="url(#accentGrad)" opacity="0.8"/>
  <circle cx="340" cy="220" r="2" fill="url(#accentGrad)" opacity="0.8"/>

  <!-- Minimal geometric accent -->
  <polygon points="200,45 205,55 195,55" fill="url(#accentGrad)" opacity="0.6"/>
</svg>'''
        return svg

    def create_alternative_404_designs(self):
        """Create several alternative 404 design variations"""

        # Design A: Minimalist approach
        design_a = '''<svg width="400" height="300" viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="minimalGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#2d3748;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#1a202c;stop-opacity:1" />
    </linearGradient>
  </defs>

  <!-- Clean background -->
  <rect width="400" height="300" fill="url(#minimalGrad)"/>

  <!-- Simple, clean layout -->
  <text x="200" y="130" text-anchor="middle" font-family="system-ui, sans-serif" font-size="36" font-weight="700"
        fill="#48bb78" letter-spacing="2px">404</text>

  <text x="200" y="170" text-anchor="middle" font-family="system-ui, sans-serif" font-size="16" font-weight="400"
        fill="#a0aec0" letter-spacing="1px">SLEEP NOT FOUND</text>

  <!-- Minimal accent line -->
  <line x1="150" y1="150" x2="250" y2="150" stroke="#48bb78" stroke-width="2" opacity="0.7"/>
</svg>'''

        # Design B: Retro console style
        design_b = '''<svg width="400" height="300" viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="retroGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#0a0e27;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#1a1a3a;stop-opacity:1" />
    </linearGradient>
  </defs>

  <!-- Retro background -->
  <rect width="400" height="300" fill="url(#retroGrad)"/>

  <!-- Console window -->
  <rect x="50" y="80" width="300" height="140" rx="8" fill="#000000" stroke="#00ffff" stroke-width="2"/>

  <!-- Console text -->
  <text x="70" y="110" font-family="Courier, monospace" font-size="12" fill="#00ffff">C:\\Users\\Developer> debug sleep.exe</text>
  <text x="70" y="140" font-family="Courier, monospace" font-size="20" font-weight="bold" fill="#ff6b6b">ERROR 404: Sleep Not Found</text>
  <text x="70" y="170" font-family="Courier, monospace" font-size="12" fill="#00ffff">Process terminated.</text>
  <text x="70" y="190" font-family="Courier, monospace" font-size="12" fill="#00ffff">Recommendation: coffee.exe</text>

  <!-- Blinking cursor -->
  <rect x="70" y="200" width="8" height="12" fill="#00ffff">
    <animate attributeName="opacity" values="1;0;1" dur="1s" repeatCount="indefinite"/>
  </rect>
</svg>'''

        # Design C: Modern tech style
        design_c = '''<svg width="400" height="300" viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="modernGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#667eea;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#764ba2;stop-opacity:1" />
    </linearGradient>

    <filter id="modernGlow">
      <feGaussianBlur stdDeviation="4" result="coloredBlur"/>
      <feMerge>
        <feMergeNode in="coloredBlur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
  </defs>

  <!-- Modern gradient background -->
  <rect width="400" height="300" fill="url(#modernGrad)"/>

  <!-- Floating card design -->
  <rect x="60" y="90" width="280" height="120" rx="16" fill="rgba(255,255,255,0.1)"
        stroke="rgba(255,255,255,0.2)" stroke-width="1" backdrop-filter="blur(10px)"/>

  <!-- Modern typography -->
  <text x="200" y="140" text-anchor="middle" font-family="SF Pro Display, system-ui, sans-serif"
        font-size="28" font-weight="800" fill="#ffffff" filter="url(#modernGlow)">Error 404</text>

  <text x="200" y="170" text-anchor="middle" font-family="SF Pro Display, system-ui, sans-serif"
        font-size="16" font-weight="500" fill="rgba(255,255,255,0.8)" letter-spacing="0.5px">Sleep Not Found</text>

  <!-- Modern accent elements -->
  <circle cx="80" cy="110" r="3" fill="rgba(255,255,255,0.6)"/>
  <circle cx="320" cy="190" r="3" fill="rgba(255,255,255,0.6)"/>
</svg>'''

        return {
            "minimalist": design_a,
            "retro_console": design_b,
            "modern_tech": design_c
        }

    def create_fresh_perspective_improved(self):
        """Create an improved Fresh Perspective design"""
        svg = '''<svg width="400" height="300" viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="freshGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#e6fffa;stop-opacity:1" />
      <stop offset="50%" style="stop-color:#81e6d9;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#2d3748;stop-opacity:1" />
    </linearGradient>

    <filter id="textShadow">
      <feDropShadow dx="2" dy="2" stdDeviation="3" flood-color="rgba(0,0,0,0.3)"/>
    </filter>
  </defs>

  <!-- Clean background -->
  <rect width="400" height="300" fill="url(#freshGrad)"/>

  <!-- Main text with better hierarchy -->
  <text x="200" y="120" text-anchor="middle" font-family="Georgia, serif" font-size="26" font-weight="bold"
        fill="#2d3748" filter="url(#textShadow)" font-style="italic">Fresh Perspective</text>

  <!-- Clean separator -->
  <line x1="120" y1="140" x2="280" y2="140" stroke="#2d3748" stroke-width="2" opacity="0.7"/>

  <!-- Secondary text -->
  <text x="200" y="170" text-anchor="middle" font-family="system-ui, sans-serif" font-size="14" font-weight="600"
        fill="#2d3748" letter-spacing="3px">FRESH SUCCESS</text>

  <!-- Subtle geometric accents -->
  <circle cx="200" cy="200" r="2" fill="#2d3748" opacity="0.6"/>
</svg>'''
        return svg

    def create_preview_html(self, svg_content, design_info, version=""):
        """Create improved HTML preview"""
        html_content = f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fresh Threads LLC - Improved Design Preview</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}

        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }}

        .preview-container {{
            max-width: 1100px;
            margin: 0 auto;
            background: rgba(255,255,255,0.98);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }}

        .header {{
            text-align: center;
            margin-bottom: 40px;
        }}

        .version-badge {{
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            padding: 8px 20px;
            border-radius: 25px;
            display: inline-block;
            font-weight: bold;
            margin-bottom: 20px;
        }}

        .design-showcase {{
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 40px;
            align-items: center;
            margin: 40px 0;
        }}

        .design-panel {{
            background: #f8f9fa;
            border-radius: 15px;
            padding: 30px;
            text-align: center;
            border: 2px solid #e9ecef;
        }}

        .mockup-container {{
            position: relative;
            width: 400px;
            height: 450px;
            margin: 0 auto;
            perspective: 1000px;
        }}

        .tshirt-3d {{
            width: 100%;
            height: 100%;
            background: #1a202c;
            border-radius: 25px;
            position: relative;
            transform: rotateY(-5deg) rotateX(5deg);
            box-shadow: 0 25px 50px rgba(0,0,0,0.3);
            overflow: hidden;
        }}

        .shirt-fabric {{
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(45deg, transparent 49%, rgba(255,255,255,0.05) 50%, transparent 51%);
            background-size: 8px 8px;
        }}

        .design-on-shirt {{
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%) scale(0.75);
            z-index: 2;
            filter: drop-shadow(0 4px 8px rgba(0,0,0,0.2));
        }}

        .quality-assessment {{
            margin: 30px 0;
            padding: 25px;
            background: linear-gradient(135deg, #f7fafc, #edf2f7);
            border-radius: 15px;
            border-left: 5px solid #48bb78;
        }}

        .rating-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin: 20px 0;
        }}

        .rating-item {{
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 15px;
            background: white;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
        }}

        .stars {{
            color: #f6ad55;
        }}

        .feedback-section {{
            margin-top: 30px;
            padding: 25px;
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            border-radius: 15px;
            text-align: center;
        }}

        .improvement-notes {{
            background: rgba(255,255,255,0.1);
            padding: 20px;
            border-radius: 10px;
            margin: 20px 0;
            text-align: left;
        }}
    </style>
</head>
<body>
    <div class="preview-container">
        <div class="header">
            <div class="version-badge">Improved Design {version}</div>
            <h1 style="color: #2d3748; margin: 20px 0;">Fresh Threads LLC</h1>
            <h2 style="color: #4a5568;">"{design_info['text']}"</h2>
        </div>

        <div class="design-showcase">
            <div class="design-panel">
                <h3 style="margin-bottom: 20px; color: #2d3748;">📐 Design File</h3>
                {svg_content}
                <p style="margin-top: 15px; color: #718096; font-size: 14px;">SVG Vector Format - Production Ready</p>
            </div>

            <div class="mockup-container">
                <div class="tshirt-3d">
                    <div class="shirt-fabric"></div>
                    <div class="design-on-shirt">
                        {svg_content}
                    </div>
                </div>
            </div>
        </div>

        <div class="quality-assessment">
            <h3 style="color: #2d3748; margin-bottom: 20px;">📊 Design Quality Assessment</h3>
            <div class="rating-grid">
                <div class="rating-item">
                    <span>Visual Impact</span>
                    <span class="stars">★★★★☆</span>
                </div>
                <div class="rating-item">
                    <span>Typography</span>
                    <span class="stars">★★★★☆</span>
                </div>
                <div class="rating-item">
                    <span>Print Quality</span>
                    <span class="stars">★★★★★</span>
                </div>
                <div class="rating-item">
                    <span>Market Appeal</span>
                    <span class="stars">★★★★☆</span>
                </div>
                <div class="rating-item">
                    <span>Brand Consistency</span>
                    <span class="stars">★★★★☆</span>
                </div>
                <div class="rating-item">
                    <span>Production Ready</span>
                    <span class="stars">★★★★★</span>
                </div>
            </div>
        </div>

        <div class="feedback-section">
            <h3>🎯 Your Feedback Matters</h3>
            <div class="improvement-notes">
                <h4>What to look for:</h4>
                <ul style="text-align: left; margin: 10px 0; padding-left: 20px;">
                    <li>Is the text easily readable from 6 feet away?</li>
                    <li>Do the colors work well together?</li>
                    <li>Does it look professional and marketable?</li>
                    <li>Would you wear this design?</li>
                    <li>Does it capture the intended audience?</li>
                </ul>
            </div>
            <p style="margin: 20px 0; font-size: 16px;">
                <strong>Return to your terminal to approve, decline, or request improvements!</strong>
            </p>
        </div>
    </div>
</body>
</html>
"""
        return html_content

    def show_design_preview(self, svg_content, design_info, version=""):
        """Create and open improved preview"""
        html_content = self.create_preview_html(
            svg_content, design_info, version)

        with tempfile.NamedTemporaryFile(mode='w', suffix='.html', delete=False) as f:
            f.write(html_content)
            preview_file = f.name

        webbrowser.open(f'file://{preview_file}')

    def get_user_feedback(self, design_info):
        """Get detailed user feedback"""
        print(f"\n🎯 Review Improved Design: {design_info['text']}")
        print(
            "📊 Quality focus: Better typography, cleaner composition, professional appeal")
        print("\nOptions:")
        print("1. ✅ Accept - This design meets quality standards")
        print("2. ❌ Decline - Still not good enough")
        print("3. 🔄 Show alternative versions")
        print("4. 💬 Provide specific feedback for improvement")

        while True:
            choice = input("\nEnter your choice (1-4): ").strip()

            if choice in ["1", "2", "3", "4"]:
                return choice
            else:
                print("❌ Invalid choice. Please enter 1, 2, 3, or 4.")

    def save_improved_design(self, svg_content, design_info, version=""):
        """Save improved design"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        safe_name = design_info['collection'].lower().replace(' ', '_')
        filename = f"{safe_name}_improved_{version}_{timestamp}.svg"

        filepath = self.approved_dir / filename

        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(svg_content)

        metadata = {
            **design_info,
            "timestamp": timestamp,
            "version": f"Improved {version}",
            "quality_improvements": [
                "Cleaner typography",
                "Better color harmony",
                "Improved composition",
                "Professional aesthetic",
                "Enhanced readability"
            ],
            "svg_file": str(filepath),
            "production_ready": True
        }

        metadata_file = filepath.with_suffix('.json')
        with open(metadata_file, 'w', encoding='utf-8') as f:
            json.dump(metadata, f, indent=2)

        return filepath


def main():
    """Generate improved designs focusing on the 404 concept"""
    print("🚀 Fresh Threads LLC - Improved Design Generator")
    print("=" * 60)
    print("Focus: Creating better 404 design based on your feedback")

    generator = ImprovedDesignGenerator()

    # Start with improved 404 design
    print("\n🎨 Creating improved 'Error 404: Sleep Not Found' design...")

    design_info = {
        "collection": "Debug Mode Improved",
        "text": "Error 404: Sleep Not Found",
        "target": "Developers, IT professionals"
    }

    # Show improved main design
    svg_content = generator.create_improved_404_design()
    generator.show_design_preview(svg_content, design_info, "v2.0")

    decision = generator.get_user_feedback(design_info)

    if decision == "1":  # Accept
        filepath = generator.save_improved_design(
            svg_content, design_info, "v2.0")
        print(f"✅ Improved design approved: {filepath}")

    elif decision == "3":  # Show alternatives
        print("\n🔄 Generating alternative 404 design styles...")
        alternatives = generator.create_alternative_404_designs()

        for style_name, svg in alternatives.items():
            print(f"\n--- {style_name.replace('_', ' ').title()} Style ---")
            generator.show_design_preview(svg, design_info, f"{style_name}")

            alt_decision = input(
                f"Accept {style_name} style? (y/n): ").strip().lower()
            if alt_decision == 'y':
                filepath = generator.save_improved_design(
                    svg, design_info, style_name)
                print(f"✅ Alternative design approved: {filepath}")
                break

    elif decision == "4":  # Get feedback
        print("\n💬 Please provide specific feedback:")
        feedback = input("What specifically needs improvement? ")
        print(f"📝 Feedback noted: {feedback}")
        print("This will help improve future designs!")

    print(f"\n🎯 Improved design generation complete!")
    print("Next: We can refine the system based on your preferences")


if __name__ == "__main__":
    main()
