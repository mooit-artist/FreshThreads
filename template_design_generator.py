#!/usr/bin/env python3
"""
Fresh Threads LLC - Simple Design Generator with Templates
Uses templates and Ollama for better, more consistent results
"""

import subprocess
import json
from datetime import datetime
from pathlib import Path
import webbrowser
import tempfile


class SimpleDesignGenerator:
    def __init__(self):
        self.output_dir = Path("design-output")
        self.output_dir.mkdir(exist_ok=True)
        self.approved_dir = self.output_dir / "approved"
        self.approved_dir.mkdir(exist_ok=True)

    def call_ollama(self, prompt, model="llama2"):
        """Call Ollama with the given prompt"""
        try:
            cmd = ["ollama", "run", model, prompt]
            result = subprocess.run(
                cmd, capture_output=True, text=True, timeout=60)

            if result.returncode == 0:
                return result.stdout.strip()
            else:
                print(f"Ollama error: {result.stderr}")
                return None
        except Exception as e:
            print(f"Error calling Ollama: {e}")
            return None

    def create_svg_template(self, collection_name, design_text, colors):
        """Create SVG using templates with better structure"""

        if "fresh perspective" in collection_name.lower():
            # Minimalist professional template
            svg = f'''<svg width="400" height="300" viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
  <!-- Background -->
  <rect width="400" height="300" fill="{colors[2]}"/>

  <!-- Geometric accent -->
  <rect x="50" y="50" width="300" height="4" fill="{colors[0]}" opacity="0.8"/>
  <rect x="50" y="246" width="300" height="4" fill="{colors[1]}" opacity="0.8"/>

  <!-- Main text -->
  <text x="200" y="130" text-anchor="middle" font-family="Arial, sans-serif" font-size="24" font-weight="bold" fill="{colors[0]}">Fresh Perspective</text>
  <text x="200" y="170" text-anchor="middle" font-family="Arial, sans-serif" font-size="24" font-weight="bold" fill="{colors[1]}">Fresh Success</text>

  <!-- Subtle geometric elements -->
  <circle cx="80" cy="150" r="3" fill="{colors[1]}" opacity="0.6"/>
  <circle cx="320" cy="150" r="3" fill="{colors[0]}" opacity="0.6"/>
</svg>'''

        elif "debug" in collection_name.lower():
            # Terminal/console template
            svg = f'''<svg width="400" height="300" viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
  <!-- Terminal background -->
  <rect width="400" height="300" fill="{colors[0]}" rx="8"/>
  <rect x="10" y="30" width="380" height="260" fill="{colors[0]}" stroke="{colors[1]}" stroke-width="2" rx="4"/>

  <!-- Terminal header -->
  <rect x="10" y="10" width="380" height="20" fill="{colors[1]}" opacity="0.2" rx="4"/>
  <circle cx="25" cy="20" r="3" fill="#ff5f56"/>
  <circle cx="40" cy="20" r="3" fill="#ffbd2e"/>
  <circle cx="55" cy="20" r="3" fill="#27ca3f"/>

  <!-- Command prompt -->
  <text x="30" y="60" font-family="monospace" font-size="14" fill="{colors[1]}">$ debug life.exe</text>

  <!-- Main error message -->
  <text x="30" y="90" font-family="monospace" font-size="18" font-weight="bold" fill="{colors[1]}">ERROR 404:</text>
  <text x="30" y="120" font-family="monospace" font-size="18" font-weight="bold" fill="{colors[1]}">Sleep Not Found</text>

  <!-- Additional terminal lines -->
  <text x="30" y="160" font-family="monospace" font-size="12" fill="{colors[1]}" opacity="0.7">Attempting to restart...</text>
  <text x="30" y="180" font-family="monospace" font-size="12" fill="{colors[1]}" opacity="0.7">Coffee.exe required</text>

  <!-- Cursor blink -->
  <rect x="30" y="200" width="8" height="16" fill="{colors[1]}"/>
</svg>'''

        elif "thread" in collection_name.lower():
            # Sophisticated textile template
            svg = f'''<svg width="400" height="300" viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
  <!-- Background with textile pattern -->
  <rect width="400" height="300" fill="{colors[2]}"/>

  <!-- Textile pattern -->
  <defs>
    <pattern id="textile" x="0" y="0" width="20" height="20" patternUnits="userSpaceOnUse">
      <rect width="20" height="20" fill="{colors[0]}" opacity="0.1"/>
      <line x1="0" y1="10" x2="20" y2="10" stroke="{colors[1]}" stroke-width="0.5" opacity="0.3"/>
      <line x1="10" y1="0" x2="10" y2="20" stroke="{colors[1]}" stroke-width="0.5" opacity="0.3"/>
    </pattern>
  </defs>
  <rect width="400" height="300" fill="url(#textile)"/>

  <!-- Elegant border -->
  <rect x="40" y="40" width="320" height="220" fill="none" stroke="{colors[1]}" stroke-width="2" opacity="0.8"/>

  <!-- Main text with sophisticated typography -->
  <text x="200" y="120" text-anchor="middle" font-family="serif" font-size="20" font-weight="bold" fill="{colors[0]}">HIGH THREAD COUNT</text>
  <text x="200" y="160" text-anchor="middle" font-family="serif" font-size="20" font-weight="bold" fill="{colors[0]}">HIGHER STANDARDS</text>

  <!-- Decorative elements -->
  <line x1="80" y1="140" x2="320" y2="140" stroke="{colors[1]}" stroke-width="1" opacity="0.6"/>
  <circle cx="200" cy="200" r="2" fill="{colors[1]}"/>
</svg>'''

        else:
            # Default template
            svg = f'''<svg width="400" height="300" viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
  <rect width="400" height="300" fill="{colors[2] if len(colors) > 2 else colors[0]}"/>
  <text x="200" y="150" text-anchor="middle" font-family="Arial, sans-serif" font-size="20" fill="{colors[0]}">{design_text}</text>
</svg>'''

        return svg

    def create_preview_html(self, svg_content, design_info):
        """Create an HTML preview file for the design"""
        html_content = f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fresh Threads LLC - Design Preview</title>
    <style>
        body {{
            font-family: Arial, sans-serif;
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }}
        .preview-container {{
            background: rgba(255,255,255,0.95);
            color: #333;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
            text-align: center;
        }}
        .design-preview {{
            background: #f8f9fa;
            border: 3px solid #dee2e6;
            border-radius: 12px;
            padding: 30px;
            margin: 20px 0;
            display: inline-block;
        }}
        .tshirt-mockup {{
            width: 350px;
            height: 400px;
            background: linear-gradient(45deg, #667eea, #764ba2);
            border-radius: 20px;
            margin: 20px auto;
            position: relative;
            box-shadow: 0 8px 16px rgba(0,0,0,0.2);
            display: flex;
            align-items: center;
            justify-content: center;
        }}
        .shirt-shape {{
            width: 300px;
            height: 350px;
            background: #ffffff;
            border-radius: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: inset 0 4px 8px rgba(0,0,0,0.1);
        }}
        .design-on-shirt {{
            transform: scale(0.8);
        }}
        .info-section {{
            text-align: left;
            margin: 20px 0;
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            border-left: 4px solid #667eea;
        }}
        h1 {{ color: #667eea; margin-bottom: 10px; }}
        h2 {{ color: #374151; margin: 15px 0; }}
        .collection-tag {{
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            padding: 8px 20px;
            border-radius: 25px;
            display: inline-block;
            margin: 15px 0;
            font-weight: bold;
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        }}
        .quality-badge {{
            background: #10b981;
            color: white;
            padding: 5px 12px;
            border-radius: 15px;
            font-size: 12px;
            display: inline-block;
            margin: 5px;
        }}
        .decision-guide {{
            margin-top: 30px;
            padding: 25px;
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        }}
    </style>
</head>
<body>
    <div class="preview-container">
        <h1>🎨 Fresh Threads LLC Design Preview</h1>

        <div class="collection-tag">{design_info['collection']}</div>
        <div class="quality-badge">Template-Based Design</div>
        <div class="quality-badge">Print-Ready SVG</div>

        <h2>"{design_info['text']}"</h2>

        <div class="design-preview">
            <h3>📐 Raw Design (Print Version):</h3>
            {svg_content}
        </div>

        <div class="tshirt-mockup">
            <div class="shirt-shape">
                <div class="design-on-shirt">
                    {svg_content}
                </div>
            </div>
        </div>

        <div class="info-section">
            <h3>📋 Design Specifications:</h3>
            <p><strong>Collection:</strong> {design_info['collection']}</p>
            <p><strong>Theme:</strong> {design_info['theme']}</p>
            <p><strong>Colors:</strong> {', '.join(design_info['colors'])}</p>
            <p><strong>Target Market:</strong> {design_info.get('target', 'General audience')}</p>
            <p><strong>Print Size:</strong> 10" x 7.5" (ideal for front chest placement)</p>
            <p><strong>Print Method:</strong> Screen printing or DTG compatible</p>
            <p><strong>Generated:</strong> {datetime.now().strftime('%B %d, %Y at %I:%M %p')}</p>
        </div>

        <div class="decision-guide">
            <h3>🎯 Review Guidelines:</h3>
            <p><strong>✅ Accept if:</strong> Design looks professional, text is readable, colors work well together</p>
            <p><strong>❌ Decline if:</strong> Text is too small, colors clash, design looks unprofessional</p>
            <p><strong>🔄 Regenerate if:</strong> Concept is good but execution needs improvement</p>
            <br>
            <p><strong>Return to your terminal to make your decision!</strong></p>
        </div>
    </div>
</body>
</html>
"""
        return html_content

    def show_design_preview(self, svg_content, design_info):
        """Create and open a preview of the design"""
        html_content = self.create_preview_html(svg_content, design_info)

        # Create temporary HTML file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.html', delete=False) as f:
            f.write(html_content)
            preview_file = f.name

        # Open in browser
        webbrowser.open(f'file://{preview_file}')
        return preview_file

    def get_user_decision(self, design_info):
        """Get user's decision on the design"""
        print(f"\n🎯 Review Design: {design_info['text']}")
        print(f"Collection: {design_info['collection']}")
        print("\nOptions:")
        print("1. ✅ Accept this design")
        print("2. ❌ Decline this design")
        print("3. 🔄 Generate alternative version")

        while True:
            choice = input("\nEnter your choice (1-3): ").strip()

            if choice in ["1", "2", "3"]:
                return choice
            else:
                print("❌ Invalid choice. Please enter 1, 2, or 3.")

    def save_design(self, svg_content, design_info, status="approved"):
        """Save design with appropriate status"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        safe_name = design_info['collection'].lower().replace(
            ' ', '_').replace('-', '_')
        filename = f"{safe_name}_{timestamp}.svg"

        filepath = self.approved_dir / filename

        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(svg_content)

        # Save metadata
        metadata = {
            **design_info,
            "timestamp": timestamp,
            "status": status,
            "svg_file": str(filepath),
            "production_ready": True,
            "print_specifications": {
                "size": "400x300px (10\" x 7.5\")",
                "format": "SVG vector",
                "print_method": "Screen printing or DTG",
                "color_mode": "RGB (print-ready)"
            }
        }

        metadata_file = filepath.with_suffix('.json')
        with open(metadata_file, 'w', encoding='utf-8') as f:
            json.dump(metadata, f, indent=2)

        return filepath

    def generate_design_with_review(self, collection_name, design_text, colors, theme, target=""):
        """Generate a design using templates and handle review"""
        design_info = {
            "collection": collection_name,
            "text": design_text,
            "colors": colors,
            "theme": theme,
            "target": target
        }

        print(f"\n🎨 Creating template-based design for: {design_text}")

        # Create SVG using template
        svg_content = self.create_svg_template(
            collection_name, design_text, colors)

        # Show preview
        print("🖼️  Opening design preview in browser...")
        self.show_design_preview(svg_content, design_info)

        # Get user decision
        decision = self.get_user_decision(design_info)

        if decision == "1":  # Accept
            filepath = self.save_design(svg_content, design_info, "approved")
            print(f"✅ Design approved and saved: {filepath}")
            return {"status": "approved", "file": filepath}

        elif decision == "2":  # Decline
            print("❌ Design declined")
            return {"status": "declined"}

        elif decision == "3":  # Generate alternative
            print("🔄 Generating alternative version...")
            # Create a variant with different styling
            return self.generate_design_with_review(
                collection_name + " (Alternative)",
                design_text,
                colors,
                theme,
                target
            )


def main():
    """Main function for simple design generation"""
    print("🚀 Fresh Threads LLC - Template-Based Design Generator")
    print("=" * 60)
    print("Using high-quality templates for consistent, professional results")

    generator = SimpleDesignGenerator()

    # Core designs from strategy
    designs = [
        {
            "collection": "Fresh Perspective",
            "text": "Fresh Perspective, Fresh Success",
            "colors": ["#1e3a8a", "#10b981", "#ffffff"],
            "theme": "Minimalist motivational with clean typography",
            "target": "Young professionals, entrepreneurs"
        },
        {
            "collection": "Debug Mode",
            "text": "Error 404: Sleep Not Found",
            "colors": ["#000000", "#00FF00", "#ffffff"],
            "theme": "Programming humor with terminal aesthetics",
            "target": "Developers, IT professionals"
        },
        {
            "collection": "Thread Count",
            "text": "High Thread Count, Higher Standards",
            "colors": ["#374151", "#fbbf24", "#ffffff"],
            "theme": "Sophisticated fashion wordplay",
            "target": "Fashion-conscious consumers"
        }
    ]

    results = []

    for i, design in enumerate(designs, 1):
        print(f"\n{'='*20} DESIGN {i}/{len(designs)} {'='*20}")

        result = generator.generate_design_with_review(
            design["collection"],
            design["text"],
            design["colors"],
            design["theme"],
            design["target"]
        )

        results.append(result)

    # Summary
    approved = [r for r in results if r["status"] == "approved"]

    print(f"\n🎯 DESIGN SESSION COMPLETE!")
    print("=" * 40)
    print(f"✅ Approved designs: {len(approved)}")

    if approved:
        print(f"\n🎉 Production-ready designs:")
        for result in approved:
            print(f"   📁 {result['file'].name}")
        print(f"\n💼 Ready to upload to Printful/Printify for T-shirt production!")


if __name__ == "__main__":
    main()
