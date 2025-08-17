#!/usr/bin/env python3
"""
Fresh Threads LLC - Interactive Design Generator with Review System
Generates designs and allows user to review, accept, or decline each one
"""

import subprocess
import json
from datetime import datetime
from pathlib import Path
import webbrowser
import tempfile


class InteractiveDesignGenerator:
    def __init__(self):
        self.output_dir = Path("design-output")
        self.output_dir.mkdir(exist_ok=True)
        self.approved_dir = self.output_dir / "approved"
        self.approved_dir.mkdir(exist_ok=True)
        self.rejected_dir = self.output_dir / "rejected"
        self.rejected_dir.mkdir(exist_ok=True)

    def call_ollama(self, prompt, model="llama2"):
        """Call Ollama with the given prompt"""
        try:
            cmd = ["ollama", "run", model, prompt]
            result = subprocess.run(
                cmd, capture_output=True, text=True, timeout=120)

            if result.returncode == 0:
                return result.stdout.strip()
            else:
                print(f"Ollama error: {result.stderr}")
                return None
        except subprocess.TimeoutExpired:
            print("Ollama request timed out")
            return None
        except Exception as e:
            print(f"Error calling Ollama: {e}")
            return None

    def create_design_prompt(self, collection_name, design_text, colors, theme):
        """Create a comprehensive design prompt for Ollama"""
        prompt = f"""
You are a professional T-shirt designer for Fresh Threads LLC. Create an SVG design with these specifications:

DESIGN REQUIREMENTS:
- Text: "{design_text}"
- Collection: {collection_name}
- Theme: {theme}
- Colors: {', '.join(colors)}

TECHNICAL SPECIFICATIONS:
- Format: Clean, valid SVG code only
- Size: 400x300 pixels (print-friendly ratio)
- Font: Use web-safe fonts appropriate for the theme
- Readability: Text must be readable and well-positioned
- Professional quality for retail T-shirts

DESIGN GUIDELINES:
- Center the design well within the canvas
- Use proper font sizes (minimum 16px for readability)
- Ensure good contrast between text and background
- Add subtle design elements that enhance the theme
- Keep it clean and printable

IMPORTANT:
- Respond with ONLY the SVG code
- Start with <svg and end with </svg>
- Include proper xmlns and viewBox attributes
- No explanations, just the SVG code
- Make it production-ready

Create the SVG now:
"""
        return prompt

    def extract_svg_from_response(self, response):
        """Extract SVG code from Ollama response"""
        if not response:
            return None

        response = response.strip()

        # Find SVG boundaries
        svg_start = response.find('<svg')
        svg_end = response.find('</svg>')

        if svg_start != -1 and svg_end != -1:
            svg_content = response[svg_start:svg_end + 6]
            # Clean up any extra content
            return svg_content.strip()

        return None

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
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }}
        .preview-container {{
            background: white;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            text-align: center;
        }}
        .design-preview {{
            background: #f8f9fa;
            border: 2px dashed #dee2e6;
            border-radius: 8px;
            padding: 40px;
            margin: 20px 0;
            display: inline-block;
        }}
        .tshirt-mockup {{
            width: 300px;
            height: 350px;
            background: #ffffff;
            border-radius: 20px;
            margin: 20px auto;
            position: relative;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            display: flex;
            align-items: center;
            justify-content: center;
        }}
        .design-on-shirt {{
            width: 200px;
            height: 150px;
            display: flex;
            align-items: center;
            justify-content: center;
        }}
        .info-section {{
            text-align: left;
            margin: 20px 0;
            background: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
        }}
        h1 {{ color: #1e3a8a; }}
        h2 {{ color: #374151; }}
        .collection-tag {{
            background: #10b981;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            display: inline-block;
            margin: 10px 0;
        }}
    </style>
</head>
<body>
    <div class="preview-container">
        <h1>🎨 Fresh Threads LLC Design Preview</h1>

        <div class="collection-tag">{design_info['collection']}</div>

        <h2>"{design_info['text']}"</h2>

        <div class="design-preview">
            <h3>Raw Design:</h3>
            {svg_content}
        </div>

        <div class="tshirt-mockup">
            <div class="design-on-shirt">
                {svg_content}
            </div>
        </div>

        <div class="info-section">
            <h3>Design Details:</h3>
            <p><strong>Collection:</strong> {design_info['collection']}</p>
            <p><strong>Theme:</strong> {design_info['theme']}</p>
            <p><strong>Colors:</strong> {', '.join(design_info['colors'])}</p>
            <p><strong>Target:</strong> {design_info.get('target', 'General audience')}</p>
            <p><strong>Generated:</strong> {datetime.now().strftime('%B %d, %Y at %I:%M %p')}</p>
        </div>

        <div style="margin-top: 30px; padding: 20px; background: #e3f2fd; border-radius: 5px;">
            <h3>🔍 Review Instructions:</h3>
            <p>Return to your terminal to approve or decline this design!</p>
            <p>You can also regenerate with different parameters if needed.</p>
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
        print("3. 🔄 Regenerate with same parameters")
        print("4. ✏️  Regenerate with modified prompt")
        print("5. ⏭️  Skip to next design")

        while True:
            choice = input("\nEnter your choice (1-5): ").strip()

            if choice in ["1", "2", "3", "4", "5"]:
                return choice
            else:
                print("❌ Invalid choice. Please enter 1, 2, 3, 4, or 5.")

    def save_design(self, svg_content, design_info, status="pending"):
        """Save design with appropriate status"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        safe_name = design_info['collection'].lower().replace(' ', '_')
        filename = f"{safe_name}_{timestamp}.svg"

        if status == "approved":
            filepath = self.approved_dir / filename
        elif status == "rejected":
            filepath = self.rejected_dir / filename
        else:
            filepath = self.output_dir / filename

        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(svg_content)

        # Save metadata
        metadata = {
            **design_info,
            "timestamp": timestamp,
            "status": status,
            "svg_file": str(filepath)
        }

        metadata_file = filepath.with_suffix('.json')
        with open(metadata_file, 'w', encoding='utf-8') as f:
            json.dump(metadata, f, indent=2)

        return filepath

    def generate_design_with_review(self, collection_name, design_text, colors, theme, target=""):
        """Generate a design and handle the review process"""
        design_info = {
            "collection": collection_name,
            "text": design_text,
            "colors": colors,
            "theme": theme,
            "target": target
        }

        max_attempts = 3
        attempt = 1

        while attempt <= max_attempts:
            print(f"\n🎨 Generating design (Attempt {attempt}/{max_attempts})")
            print(f"Design: {design_text}")

            # Create prompt
            prompt = self.create_design_prompt(
                collection_name, design_text, colors, theme)

            # Generate with Ollama
            print("🤖 Calling Ollama LLM...")
            response = self.call_ollama(prompt)

            if not response:
                print("❌ Failed to get response from Ollama")
                attempt += 1
                continue

            # Extract SVG
            svg_content = self.extract_svg_from_response(response)

            if not svg_content:
                print("❌ No valid SVG found in response")
                print("Response preview:", response[:200] + "...")
                attempt += 1
                continue

            # Show preview
            print("🖼️  Opening design preview in browser...")
            preview_file = self.show_design_preview(svg_content, design_info)

            # Get user decision
            decision = self.get_user_decision(design_info)

            if decision == "1":  # Accept
                filepath = self.save_design(
                    svg_content, design_info, "approved")
                print(f"✅ Design approved and saved: {filepath}")
                return {"status": "approved", "file": filepath}

            elif decision == "2":  # Decline
                filepath = self.save_design(
                    svg_content, design_info, "rejected")
                print(f"❌ Design declined and archived: {filepath}")
                return {"status": "declined", "file": filepath}

            elif decision == "3":  # Regenerate same
                print("🔄 Regenerating with same parameters...")
                attempt += 1
                continue

            elif decision == "4":  # Modify prompt
                print("✏️  Current theme:", theme)
                new_theme = input("Enter modified theme/style notes: ").strip()
                if new_theme:
                    theme = new_theme
                    design_info["theme"] = theme
                print("🔄 Regenerating with modified prompt...")
                attempt += 1
                continue

            elif decision == "5":  # Skip
                print("⏭️  Skipping this design")
                return {"status": "skipped"}

        print(f"❌ Max attempts ({max_attempts}) reached for this design")
        return {"status": "failed"}


def main():
    """Main interactive design generation"""
    print("🚀 Fresh Threads LLC - Interactive Design Generator")
    print("=" * 60)

    generator = InteractiveDesignGenerator()

    # Designs from strategy
    designs = [
        {
            "collection": "Fresh Perspective",
            "text": "Fresh Perspective, Fresh Success",
            "colors": ["#1e3a8a", "#10b981", "#ffffff"],
            "theme": "Minimalist motivational with clean typography and subtle geometric elements",
            "target": "Young professionals, entrepreneurs"
        },
        {
            "collection": "Debug Mode",
            "text": "Currently Debugging Life...",
            "colors": ["#000000", "#00FF00", "#ffffff"],
            "theme": "Tech humor with terminal/console aesthetics and monospace font",
            "target": "Developers, IT professionals"
        },
        {
            "collection": "Thread Count",
            "text": "High Thread Count, Higher Standards",
            "colors": ["#374151", "#fbbf24", "#ffffff"],
            "theme": "Meta-humor about clothing with sophisticated typography and textile patterns",
            "target": "Fashion-conscious, wordplay lovers"
        }
    ]

    print(f"📋 Processing {len(designs)} designs from your strategy...")
    print("🔍 Each design will open in your browser for review")

    results = {
        "approved": [],
        "declined": [],
        "skipped": [],
        "failed": []
    }

    for i, design in enumerate(designs, 1):
        print(f"\n{'='*20} DESIGN {i}/{len(designs)} {'='*20}")

        result = generator.generate_design_with_review(
            design["collection"],
            design["text"],
            design["colors"],
            design["theme"],
            design["target"]
        )

        results[result["status"]].append(result)

    # Summary
    print(f"\n🎯 GENERATION COMPLETE!")
    print("=" * 40)
    print(f"✅ Approved: {len(results['approved'])}")
    print(f"❌ Declined: {len(results['declined'])}")
    print(f"⏭️  Skipped: {len(results['skipped'])}")
    print(f"❌ Failed: {len(results['failed'])}")

    if results['approved']:
        print(f"\n🎉 Approved designs saved in: design-output/approved/")
        for result in results['approved']:
            print(f"   📁 {result['file'].name}")

    print(f"\n💼 Ready for production: {len(results['approved'])} designs")


if __name__ == "__main__":
    main()
