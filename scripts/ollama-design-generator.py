#!/usr/bin/env python3
"""
Fresh Threads LLC - Ollama Design Generator
Automated T-shirt design generation using local LLM
"""

import json
import os
import re
import subprocess
from datetime import datetime
from pathlib import Path


class OllamaDesignGenerator:
    def __init__(self):
        self.output_dir = Path("design-output")
        self.output_dir.mkdir(exist_ok=True)

        # Design collections from strategy
        self.collections = {
            "fresh_perspective": {
                "theme": "Minimalist motivational",
                "colors": ["#1e3a8a", "#10b981", "#ffffff"],
                "target": "Young professionals, entrepreneurs",
            },
            "debug_mode": {
                "theme": "Tech humor",
                "colors": ["#000000", "#00FF00", "#ffffff"],
                "target": "Developers, IT professionals",
            },
            "thread_count": {
                "theme": "Meta-humor about clothing/threads",
                "colors": ["#374151", "#fbbf24", "#ffffff"],
                "target": "Fashion-conscious, wordplay lovers",
            },
        }

    def call_ollama(self, prompt, model="llama2"):
        """Call Ollama with the given prompt"""
        try:
            cmd = ["ollama", "run", model, prompt]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)

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

    def create_design_prompt(self, collection_name, design_text, style_notes=""):
        """Create a comprehensive design prompt for Ollama"""
        collection = self.collections.get(collection_name, {})

        prompt = f"""
You are a professional T-shirt designer for Fresh Threads LLC. Create an SVG design with these specifications:

DESIGN REQUIREMENTS:
- Text: "{design_text}"
- Collection: {collection_name.replace('_', ' ').title()}
- Theme: {collection.get('theme', 'Modern')}
- Target Audience: {collection.get('target', 'General')}
- Colors: {', '.join(collection.get('colors', ['#000000', '#ffffff']))}
- Style Notes: {style_notes}

TECHNICAL SPECIFICATIONS:
- Format: Clean SVG code
- Print Area: 10" x 12" (300 x 360 pixels)
- Font: Use web-safe fonts appropriate for the theme
- Readability: Text must be readable from 6 feet away
- Print-ready: CMYK-compatible colors

OUTPUT FORMAT:
1. SVG CODE (wrapped in ```svg tags)
2. Design explanation (2-3 sentences)
3. Recommended placement on T-shirt
4. Print specifications

Create a professional, marketable T-shirt design that captures the essence of Fresh Threads LLC.
"""
        return prompt

    def extract_svg_from_response(self, response):
        """Extract SVG code from Ollama response"""
        if not response:
            return None

        # Look for SVG code blocks
        svg_pattern = r"```svg\s*(.*?)\s*```"
        match = re.search(svg_pattern, response, re.DOTALL | re.IGNORECASE)

        if match:
            return match.group(1).strip()

        # Fallback: look for SVG tags directly
        svg_tag_pattern = r"<svg.*?</svg>"
        match = re.search(svg_tag_pattern, response, re.DOTALL | re.IGNORECASE)

        if match:
            return match.group(0)

        return None

    def generate_design(self, collection_name, design_text, style_notes=""):
        """Generate a complete T-shirt design"""
        print(f"\n🎨 Generating design for '{design_text}'...")
        print(f"Collection: {collection_name.replace('_', ' ').title()}")

        # Create prompt
        prompt = self.create_design_prompt(collection_name, design_text, style_notes)

        # Call Ollama
        print("🤖 Calling Ollama LLM...")
        response = self.call_ollama(prompt)

        if not response:
            print("❌ Failed to get response from Ollama")
            return None

        # Extract SVG
        svg_code = self.extract_svg_from_response(response)

        if not svg_code:
            print("❌ No SVG code found in response")
            print("Raw response:")
            print(response[:500] + "..." if len(response) > 500 else response)
            return None

        # Save design
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{collection_name}_{timestamp}.svg"
        filepath = self.output_dir / filename

        with open(filepath, "w", encoding="utf-8") as f:
            f.write(svg_code)

        # Save metadata
        metadata = {
            "timestamp": timestamp,
            "collection": collection_name,
            "design_text": design_text,
            "style_notes": style_notes,
            "svg_file": str(filepath),
            "full_response": response,
        }

        metadata_file = self.output_dir / f"{collection_name}_{timestamp}_metadata.json"
        with open(metadata_file, "w", encoding="utf-8") as f:
            json.dump(metadata, f, indent=2)

        print(f"✅ Design saved: {filepath}")
        print(f"📄 Metadata saved: {metadata_file}")

        return {
            "svg_file": filepath,
            "metadata_file": metadata_file,
            "svg_code": svg_code,
            "metadata": metadata,
        }

    def test_ollama_connection(self):
        """Test if Ollama is working"""
        print("🔍 Testing Ollama connection...")

        test_prompt = "Respond with exactly: 'Ollama is working for Fresh Threads LLC'"
        response = self.call_ollama(test_prompt)

        if response and "Fresh Threads LLC" in response:
            print("✅ Ollama is working correctly!")
            return True
        else:
            print("❌ Ollama connection failed")
            if response:
                print(f"Response: {response}")
            return False

    def generate_sample_designs(self):
        """Generate sample designs for each collection"""
        designs = [
            {
                "collection": "fresh_perspective",
                "text": "Fresh Perspective, Fresh Success",
                "style": "Clean typography with subtle geometric elements",
            },
            {
                "collection": "debug_mode",
                "text": "Currently Debugging Life...",
                "style": "Terminal/console interface with monospace font",
            },
            {
                "collection": "thread_count",
                "text": "High Thread Count, Higher Standards",
                "style": "Sophisticated typography with textile-inspired elements",
            },
        ]

        results = []
        for design in designs:
            result = self.generate_design(
                design["collection"], design["text"], design["style"]
            )
            if result:
                results.append(result)

        return results


def main():
    """Main function to run the design generator"""
    print("🚀 Fresh Threads LLC - Ollama Design Generator")
    print("=" * 50)

    generator = OllamaDesignGenerator()

    # Test Ollama connection
    if not generator.test_ollama_connection():
        print("\n❌ Cannot connect to Ollama. Please ensure:")
        print("1. Ollama is installed and running")
        print("2. llama2 model is available (run: ollama pull llama2)")
        return

    print("\n🎯 Choose an option:")
    print("1. Generate sample designs for all collections")
    print("2. Generate custom design")
    print("3. Test single design")

    choice = input("\nEnter choice (1-3): ").strip()

    if choice == "1":
        print("\n🎨 Generating sample designs...")
        results = generator.generate_sample_designs()
        print(f"\n✅ Generated {len(results)} designs successfully!")

    elif choice == "2":
        print("\nAvailable collections:")
        for i, (key, value) in enumerate(generator.collections.items(), 1):
            print(f"{i}. {key.replace('_', ' ').title()} - {value['theme']}")

        collection_choice = input("\nChoose collection (1-3): ").strip()
        collections = list(generator.collections.keys())

        if collection_choice in ["1", "2", "3"]:
            collection = collections[int(collection_choice) - 1]
            text = input("Enter design text: ").strip()
            style = input("Enter style notes (optional): ").strip()

            result = generator.generate_design(collection, text, style)
            if result:
                print(f"\n✅ Custom design generated: {result['svg_file']}")
        else:
            print("Invalid choice")

    elif choice == "3":
        # Quick test with simple design
        result = generator.generate_design(
            "debug_mode", "Hello, World!", "Simple test design"
        )
        if result:
            print(f"\n✅ Test design generated: {result['svg_file']}")

    else:
        print("Invalid choice")


if __name__ == "__main__":
    main()
