#!/usr/bin/env python3
"""
Generate Fresh Threads LLC designs automatically
"""

from pathlib import Path
from datetime import datetime
import json
import re
import subprocess
import sys
import os
sys.path.append(
    '/Users/bryanjorgensen/Documents/GitHub/CodeProjects/WEB/FreshThreads')


def call_ollama(prompt, model="llama2"):
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


def create_design_prompt(collection_name, design_text, colors, theme):
    """Create a comprehensive design prompt for Ollama"""

    prompt = f"""
You are a professional T-shirt designer for Fresh Threads LLC. Create an SVG design with these specifications:

DESIGN REQUIREMENTS:
- Text: "{design_text}"
- Collection: {collection_name}
- Theme: {theme}
- Colors: {', '.join(colors)}

TECHNICAL SPECIFICATIONS:
- Format: Clean SVG code only
- Size: 300x200 pixels (10" x 6.7" print area)
- Font: Use appropriate web-safe fonts
- Readability: Text readable from 6 feet away
- Professional quality for retail T-shirts

IMPORTANT:
- Respond with ONLY the SVG code
- Start with <svg and end with </svg>
- No explanations, just the SVG code
- Use the specified colors
- Make it production-ready

Create the SVG now:
"""
    return prompt


def extract_svg_from_response(response):
    """Extract SVG code from Ollama response"""
    if not response:
        return None

    # Clean up the response
    response = response.strip()

    # Find SVG boundaries
    svg_start = response.find('<svg')
    svg_end = response.find('</svg>')

    if svg_start != -1 and svg_end != -1:
        return response[svg_start:svg_end + 6]

    # If no proper SVG found, return the whole response if it looks like SVG
    if '<svg' in response and '</svg>' in response:
        return response

    return None


def generate_design(collection_name, design_text, colors, theme):
    """Generate a T-shirt design"""
    print(f"\n🎨 Generating: {design_text}")
    print(f"Collection: {collection_name}")

    # Create output directory
    output_dir = Path("design-output")
    output_dir.mkdir(exist_ok=True)

    # Create prompt
    prompt = create_design_prompt(collection_name, design_text, colors, theme)

    # Call Ollama
    print("🤖 Calling Ollama...")
    response = call_ollama(prompt)

    if not response:
        print("❌ Failed to get response from Ollama")
        return None

    # Extract SVG
    svg_code = extract_svg_from_response(response)

    if not svg_code:
        print("❌ No valid SVG found in response")
        print("Response preview:")
        print(response[:200] + "..." if len(response) > 200 else response)
        return None

    # Save the design
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    safe_name = collection_name.lower().replace(' ', '_')
    filename = f"{safe_name}_{timestamp}.svg"
    filepath = output_dir / filename

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(svg_code)

    print(f"✅ Design saved: {filepath}")
    return str(filepath)


def main():
    """Generate the designs from the T-shirt strategy"""
    print("🚀 Fresh Threads LLC - Design Generation")
    print("=" * 50)

    # Designs from the strategy document
    designs = [
        {
            "collection": "Fresh Perspective",
            "text": "Fresh Perspective, Fresh Success",
            "colors": ["#1e3a8a", "#10b981", "#ffffff"],
            "theme": "Minimalist motivational with clean typography and subtle geometric elements"
        },
        {
            "collection": "Debug Mode",
            "text": "Currently Debugging Life...",
            "colors": ["#000000", "#00FF00", "#ffffff"],
            "theme": "Tech humor with terminal/console aesthetics and monospace font"
        },
        {
            "collection": "Thread Count",
            "text": "High Thread Count, Higher Standards",
            "colors": ["#374151", "#fbbf24", "#ffffff"],
            "theme": "Meta-humor about clothing with sophisticated typography and textile patterns"
        }
    ]

    results = []

    for design in designs:
        result = generate_design(
            design["collection"],
            design["text"],
            design["colors"],
            design["theme"]
        )

        if result:
            results.append(result)
            print(f"✅ Success: {result}")
        else:
            print(f"❌ Failed: {design['collection']}")

    print(f"\n🎯 Generated {len(results)} designs successfully!")
    print("Files saved in ./design-output/")

    return results


if __name__ == "__main__":
    main()
