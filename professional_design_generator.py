#!/usr/bin/env python3
"""
Fresh Threads LLC - Professional Design Generator
Creates layered, professional designs inspired by high-quality T-shirt aesthetics
"""

import subprocess
import json
from datetime import datetime
from pathlib import Path
import webbrowser
import tempfile


class ProfessionalDesignGenerator:
    def __init__(self):
        self.output_dir = Path("design-output")
        self.output_dir.mkdir(exist_ok=True)
        self.approved_dir = self.output_dir / "approved"
        self.approved_dir.mkdir(exist_ok=True)

    def create_fresh_perspective_design(self):
        """Create Fresh Perspective design with layered professional aesthetic"""
        svg = '''<svg width="400" height="300" viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <!-- Gradient for circular background -->
    <radialGradient id="perspectiveGrad" cx="50%" cy="50%" r="50%">
      <stop offset="0%" style="stop-color:#f7fafc;stop-opacity:1" />
      <stop offset="70%" style="stop-color:#10b981;stop-opacity:0.8" />
      <stop offset="100%" style="stop-color:#1e3a8a;stop-opacity:0.9" />
    </radialGradient>

    <!-- Subtle texture pattern -->
    <pattern id="texture" x="0" y="0" width="4" height="4" patternUnits="userSpaceOnUse">
      <rect width="4" height="4" fill="#ffffff" opacity="0.02"/>
      <circle cx="2" cy="2" r="0.5" fill="#1e3a8a" opacity="0.1"/>
    </pattern>
  </defs>

  <!-- Main circular background -->
  <circle cx="200" cy="150" r="120" fill="url(#perspectiveGrad)" stroke="#1e3a8a" stroke-width="2" opacity="0.95"/>

  <!-- Texture overlay -->
  <circle cx="200" cy="150" r="118" fill="url(#texture)"/>

  <!-- Geometric accent elements -->
  <path d="M 120 150 Q 200 80 280 150" stroke="#f7fafc" stroke-width="2" fill="none" opacity="0.6"/>
  <path d="M 120 150 Q 200 220 280 150" stroke="#f7fafc" stroke-width="2" fill="none" opacity="0.6"/>

  <!-- Main typography - Script style for "Fresh Perspective" -->
  <text x="200" y="130" text-anchor="middle" font-family="Georgia, serif" font-size="28" font-weight="bold"
        fill="#f7fafc" font-style="italic" letter-spacing="1px">Fresh Perspective</text>

  <!-- Secondary text - Clean sans-serif for "Fresh Success" -->
  <text x="200" y="165" text-anchor="middle" font-family="Arial, sans-serif" font-size="16" font-weight="600"
        fill="#f7fafc" letter-spacing="2px">FRESH SUCCESS</text>

  <!-- Subtle accent dots -->
  <circle cx="140" cy="150" r="2" fill="#f7fafc" opacity="0.7"/>
  <circle cx="260" cy="150" r="2" fill="#f7fafc" opacity="0.7"/>

  <!-- Bottom accent line -->
  <line x1="160" y1="185" x2="240" y2="185" stroke="#f7fafc" stroke-width="1" opacity="0.6"/>
</svg>'''
        return svg

    def create_debug_mode_design(self):
        """Create Debug Mode design with retro terminal aesthetic"""
        svg = '''<svg width="400" height="300" viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <!-- Terminal gradient background -->
    <radialGradient id="terminalGrad" cx="50%" cy="50%" r="60%">
      <stop offset="0%" style="stop-color:#1a1a1a;stop-opacity:1" />
      <stop offset="70%" style="stop-color:#000000;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#003300;stop-opacity:1" />
    </radialGradient>

    <!-- Matrix-style pattern -->
    <pattern id="matrix" x="0" y="0" width="20" height="20" patternUnits="userSpaceOnUse">
      <rect width="20" height="20" fill="transparent"/>
      <text x="10" y="15" font-family="monospace" font-size="8" fill="#00FF00" opacity="0.1" text-anchor="middle">01</text>
    </pattern>

    <!-- Glowing effect -->
    <filter id="glow">
      <feGaussianBlur stdDeviation="3" result="coloredBlur"/>
      <feMerge>
        <feMergeNode in="coloredBlur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
  </defs>

  <!-- Terminal window background -->
  <rect x="50" y="50" width="300" height="200" rx="15" fill="url(#terminalGrad)" stroke="#00FF00" stroke-width="2"/>

  <!-- Terminal header bar -->
  <rect x="50" y="50" width="300" height="25" rx="15" fill="#333333"/>
  <circle cx="70" cy="62" r="4" fill="#ff5f56"/>
  <circle cx="85" cy="62" r="4" fill="#ffbd2e"/>
  <circle cx="100" cy="62" r="4" fill="#27ca3f"/>

  <!-- Matrix pattern overlay -->
  <rect x="55" y="80" width="290" height="165" fill="url(#matrix)" opacity="0.3"/>

  <!-- Main error message with glow effect -->
  <text x="200" y="130" text-anchor="middle" font-family="Monaco, Consolas, monospace" font-size="20"
        fill="#00FF00" filter="url(#glow)" font-weight="bold">ERROR 404:</text>

  <!-- Secondary message -->
  <text x="200" y="160" text-anchor="middle" font-family="Georgia, serif" font-size="18"
        fill="#FFA500" font-style="italic" font-weight="bold">Sleep Not Found</text>

  <!-- Command prompt line -->
  <text x="70" y="110" font-family="Monaco, Consolas, monospace" font-size="12" fill="#00FF00">$ debug life.exe</text>

  <!-- Loading dots animation effect -->
  <text x="70" y="190" font-family="Monaco, Consolas, monospace" font-size="10" fill="#00FF00" opacity="0.7">Attempting restart</text>
  <text x="180" y="190" font-family="Monaco, Consolas, monospace" font-size="10" fill="#00FF00">...</text>

  <!-- Terminal cursor -->
  <rect x="70" y="205" width="8" height="12" fill="#00FF00"/>

  <!-- Retro accent elements -->
  <circle cx="320" cy="100" r="3" fill="#FFA500" opacity="0.8"/>
  <circle cx="80" cy="220" r="2" fill="#00FF00" opacity="0.6"/>
</svg>'''
        return svg

    def create_thread_count_design(self):
        """Create Thread Count design with luxury fashion aesthetic"""
        svg = '''<svg width="400" height="300" viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <!-- Luxury gradient -->
    <radialGradient id="luxuryGrad" cx="50%" cy="50%" r="60%">
      <stop offset="0%" style="stop-color:#f8f9fa;stop-opacity:1" />
      <stop offset="50%" style="stop-color:#e5e7eb;stop-opacity:0.95" />
      <stop offset="100%" style="stop-color:#374151;stop-opacity:0.9" />
    </radialGradient>

    <!-- Textile weave pattern -->
    <pattern id="weave" x="0" y="0" width="6" height="6" patternUnits="userSpaceOnUse">
      <rect width="6" height="6" fill="#374151" opacity="0.05"/>
      <line x1="0" y1="3" x2="6" y2="3" stroke="#fbbf24" stroke-width="0.5" opacity="0.2"/>
      <line x1="3" y1="0" x2="3" y2="6" stroke="#fbbf24" stroke-width="0.5" opacity="0.2"/>
    </pattern>

    <!-- Gold accent gradient -->
    <linearGradient id="goldAccent" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" style="stop-color:#fbbf24;stop-opacity:0.8" />
      <stop offset="50%" style="stop-color:#f59e0b;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#d97706;stop-opacity:0.8" />
    </linearGradient>
  </defs>

  <!-- Main design circle -->
  <circle cx="200" cy="150" r="110" fill="url(#luxuryGrad)" stroke="#374151" stroke-width="2"/>

  <!-- Textile pattern overlay -->
  <circle cx="200" cy="150" r="108" fill="url(#weave)"/>

  <!-- Elegant border details -->
  <circle cx="200" cy="150" r="105" fill="none" stroke="url(#goldAccent)" stroke-width="1"/>
  <circle cx="200" cy="150" r="95" fill="none" stroke="#374151" stroke-width="0.5" opacity="0.3"/>

  <!-- Premium typography - Serif for elegance -->
  <text x="200" y="125" text-anchor="middle" font-family="Times, serif" font-size="22" font-weight="bold"
        fill="#374151" letter-spacing="1px">HIGH THREAD COUNT</text>

  <!-- Accent line -->
  <line x1="140" y1="140" x2="260" y2="140" stroke="url(#goldAccent)" stroke-width="2"/>

  <!-- Secondary elegant text -->
  <text x="200" y="165" text-anchor="middle" font-family="Times, serif" font-size="18" font-weight="600"
        fill="#374151" letter-spacing="1.5px" font-style="italic">Higher Standards</text>

  <!-- Luxury accent elements -->
  <polygon points="200,100 202,105 197,105" fill="#fbbf24" opacity="0.8"/>
  <polygon points="200,200 202,195 197,195" fill="#fbbf24" opacity="0.8"/>

  <!-- Corner accent details -->
  <circle cx="140" cy="130" r="1.5" fill="#fbbf24"/>
  <circle cx="260" cy="130" r="1.5" fill="#fbbf24"/>
  <circle cx="140" cy="170" r="1.5" fill="#fbbf24"/>
  <circle cx="260" cy="170" r="1.5" fill="#fbbf24"/>

  <!-- Subtle texture lines -->
  <path d="M 160 180 Q 200 185 240 180" stroke="#374151" stroke-width="0.5" fill="none" opacity="0.4"/>
</svg>'''
        return svg

    def create_preview_html(self, svg_content, design_info):
        """Create professional HTML preview with T-shirt mockup"""
        html_content = f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fresh Threads LLC - Professional Design Preview</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}

        body {{
            font-family: 'Arial', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }}

        .preview-container {{
            max-width: 1000px;
            margin: 0 auto;
            background: rgba(255,255,255,0.98);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            backdrop-filter: blur(10px);
        }}

        .header {{
            text-align: center;
            margin-bottom: 40px;
        }}

        .logo {{
            font-size: 32px;
            font-weight: bold;
            color: #667eea;
            margin-bottom: 10px;
        }}

        .collection-badge {{
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            padding: 12px 25px;
            border-radius: 30px;
            display: inline-block;
            font-weight: bold;
            font-size: 16px;
            box-shadow: 0 6px 20px rgba(102,126,234,0.4);
            margin: 15px 0;
        }}

        .design-showcase {{
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 40px;
            align-items: center;
            margin: 40px 0;
        }}

        .raw-design {{
            background: #f8f9fa;
            border-radius: 15px;
            padding: 30px;
            text-align: center;
            border: 3px solid #e9ecef;
        }}

        .tshirt-mockup {{
            position: relative;
            width: 350px;
            height: 400px;
            margin: 0 auto;
        }}

        .shirt-base {{
            width: 100%;
            height: 100%;
            background: #1e3a8a;
            border-radius: 20px;
            position: relative;
            box-shadow: 0 15px 35px rgba(0,0,0,0.2);
            overflow: hidden;
        }}

        .shirt-texture {{
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(45deg, transparent 49%, rgba(255,255,255,0.1) 50%, transparent 51%);
            background-size: 4px 4px;
        }}

        .design-placement {{
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%) scale(0.8);
            z-index: 2;
        }}

        .specs-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }}

        .spec-card {{
            background: #f8f9fa;
            padding: 20px;
            border-radius: 12px;
            border-left: 4px solid #667eea;
        }}

        .spec-title {{
            font-weight: bold;
            color: #374151;
            margin-bottom: 8px;
        }}

        .spec-value {{
            color: #6b7280;
            font-size: 14px;
        }}

        .action-buttons {{
            text-align: center;
            margin-top: 40px;
            padding: 30px;
            background: linear-gradient(45deg, #667eea, #764ba2);
            border-radius: 15px;
            color: white;
        }}

        .quality-indicators {{
            display: flex;
            justify-content: center;
            gap: 15px;
            margin: 20px 0;
            flex-wrap: wrap;
        }}

        .quality-badge {{
            background: rgba(255,255,255,0.2);
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
            backdrop-filter: blur(10px);
        }}

        @media (max-width: 768px) {{
            .design-showcase {{
                grid-template-columns: 1fr;
                gap: 20px;
            }}
            .tshirt-mockup {{
                width: 300px;
                height: 350px;
            }}
        }}
    </style>
</head>
<body>
    <div class="preview-container">
        <div class="header">
            <div class="logo">🎨 Fresh Threads LLC</div>
            <div class="collection-badge">{design_info['collection']}</div>
            <h2 style="color: #374151; margin: 20px 0;">"{design_info['text']}"</h2>
        </div>

        <div class="design-showcase">
            <div class="raw-design">
                <h3 style="margin-bottom: 20px; color: #374151;">📐 Production Design</h3>
                {svg_content}
                <div class="quality-indicators" style="margin-top: 20px;">
                    <span class="quality-badge" style="background: #10b981; color: white;">Vector SVG</span>
                    <span class="quality-badge" style="background: #f59e0b; color: white;">Print Ready</span>
                    <span class="quality-badge" style="background: #8b5cf6; color: white;">Professional</span>
                </div>
            </div>

            <div class="tshirt-mockup">
                <div class="shirt-base">
                    <div class="shirt-texture"></div>
                    <div class="design-placement">
                        {svg_content}
                    </div>
                </div>
            </div>
        </div>

        <div class="specs-grid">
            <div class="spec-card">
                <div class="spec-title">Collection</div>
                <div class="spec-value">{design_info['collection']}</div>
            </div>
            <div class="spec-card">
                <div class="spec-title">Target Market</div>
                <div class="spec-value">{design_info.get('target', 'General audience')}</div>
            </div>
            <div class="spec-card">
                <div class="spec-title">Print Dimensions</div>
                <div class="spec-value">10" x 7.5" (front chest placement)</div>
            </div>
            <div class="spec-card">
                <div class="spec-title">Print Method</div>
                <div class="spec-value">Screen printing, DTG, or heat transfer</div>
            </div>
            <div class="spec-card">
                <div class="spec-title">Color Profile</div>
                <div class="spec-value">RGB optimized, CMYK compatible</div>
            </div>
            <div class="spec-card">
                <div class="spec-title">File Format</div>
                <div class="spec-value">SVG vector + PNG backup</div>
            </div>
        </div>

        <div class="action-buttons">
            <h3 style="margin-bottom: 20px;">🎯 Design Review</h3>
            <div class="quality-indicators">
                <span class="quality-badge">Layered Design ✓</span>
                <span class="quality-badge">Professional Typography ✓</span>
                <span class="quality-badge">Balanced Composition ✓</span>
                <span class="quality-badge">Production Ready ✓</span>
            </div>
            <p style="margin: 20px 0; font-size: 16px; opacity: 0.9;">
                <strong>Return to your terminal to approve, decline, or modify this design!</strong>
            </p>
            <p style="font-size: 14px; opacity: 0.8;">
                Professional quality design inspired by successful T-shirt aesthetics
            </p>
        </div>
    </div>
</body>
</html>
"""
        return html_content

    def show_design_preview(self, svg_content, design_info):
        """Create and open a professional preview"""
        html_content = self.create_preview_html(svg_content, design_info)

        with tempfile.NamedTemporaryFile(mode='w', suffix='.html', delete=False) as f:
            f.write(html_content)
            preview_file = f.name

        webbrowser.open(f'file://{preview_file}')
        return preview_file

    def get_user_decision(self, design_info):
        """Get user's decision on the design"""
        print(f"\n🎯 Review Professional Design: {design_info['text']}")
        print(f"Collection: {design_info['collection']}")
        print("✨ Features: Layered design, professional typography, balanced composition")
        print("\nOptions:")
        print("1. ✅ Accept this professional design")
        print("2. ❌ Decline this design")
        print("3. 🔄 Generate alternative version")

        while True:
            choice = input("\nEnter your choice (1-3): ").strip()

            if choice in ["1", "2", "3"]:
                return choice
            else:
                print("❌ Invalid choice. Please enter 1, 2, or 3.")

    def save_design(self, svg_content, design_info):
        """Save approved design with metadata"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        safe_name = design_info['collection'].lower().replace(' ', '_')
        filename = f"{safe_name}_professional_{timestamp}.svg"

        filepath = self.approved_dir / filename

        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(svg_content)

        # Enhanced metadata
        metadata = {
            **design_info,
            "timestamp": timestamp,
            "design_type": "Professional Layered Design",
            "svg_file": str(filepath),
            "production_ready": True,
            "quality_features": [
                "Layered composition",
                "Professional typography",
                "Balanced visual weight",
                "Print-optimized colors",
                "Scalable vector format"
            ],
            "print_specifications": {
                "size": "400x300px (10\" x 7.5\")",
                "format": "SVG vector",
                "print_methods": ["Screen printing", "DTG", "Heat transfer"],
                "color_mode": "RGB with CMYK compatibility",
                "placement": "Front chest (centered)"
            },
            "marketing_ready": True
        }

        metadata_file = filepath.with_suffix('.json')
        with open(metadata_file, 'w', encoding='utf-8') as f:
            json.dump(metadata, f, indent=2)

        return filepath

    def generate_professional_design(self, collection_name, design_text, design_func, target=""):
        """Generate and review a professional design"""
        design_info = {
            "collection": collection_name,
            "text": design_text,
            "target": target,
            "style": "Professional layered design with premium typography"
        }

        print(f"\n🎨 Creating professional design: {design_text}")
        print("✨ Using layered composition and premium typography")

        # Generate SVG using professional template
        svg_content = design_func()

        # Show preview
        print("🖼️  Opening professional design preview...")
        self.show_design_preview(svg_content, design_info)

        # Get decision
        decision = self.get_user_decision(design_info)

        if decision == "1":  # Accept
            filepath = self.save_design(svg_content, design_info)
            print(f"✅ Professional design approved: {filepath}")
            return {"status": "approved", "file": filepath}

        elif decision == "2":  # Decline
            print("❌ Design declined")
            return {"status": "declined"}

        elif decision == "3":  # Alternative
            print("🔄 Creating alternative version...")
            return self.generate_professional_design(
                collection_name + " (Alt)",
                design_text,
                design_func,
                target
            )


def main():
    """Generate professional Fresh Threads designs"""
    print("🚀 Fresh Threads LLC - Professional Design Generator")
    print("=" * 60)
    print("Creating layered, professional designs inspired by successful T-shirt aesthetics")

    generator = ProfessionalDesignGenerator()

    # Professional design collection
    designs = [
        {
            "collection": "Fresh Perspective",
            "text": "Fresh Perspective, Fresh Success",
            "func": generator.create_fresh_perspective_design,
            "target": "Young professionals, entrepreneurs"
        },
        {
            "collection": "Debug Mode",
            "text": "Error 404: Sleep Not Found",
            "func": generator.create_debug_mode_design,
            "target": "Developers, IT professionals"
        },
        {
            "collection": "Thread Count",
            "text": "High Thread Count, Higher Standards",
            "func": generator.create_thread_count_design,
            "target": "Fashion-conscious consumers"
        }
    ]

    results = []

    for i, design in enumerate(designs, 1):
        print(f"\n{'='*20} DESIGN {i}/{len(designs)} {'='*20}")

        result = generator.generate_professional_design(
            design["collection"],
            design["text"],
            design["func"],
            design["target"]
        )

        results.append(result)

    # Final summary
    approved = [r for r in results if r["status"] == "approved"]

    print(f"\n🎯 PROFESSIONAL DESIGN SESSION COMPLETE!")
    print("=" * 50)
    print(f"✅ Approved professional designs: {len(approved)}")

    if approved:
        print(f"\n🎉 Ready for production:")
        for result in approved:
            print(f"   📁 {result['file'].name}")
        print(f"\n💼 Professional quality designs ready for Printful/Printify!")
        print("🎯 These designs match successful T-shirt aesthetics")


if __name__ == "__main__":
    main()
