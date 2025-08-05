#!/usr/bin/env python3
"""
Fresh Threads LLC - Enhanced Design Generator with Feedback System
Interactive design generation with category selection, thumbs up/down feedback, and model tracking
"""

import subprocess
import json
from datetime import datetime
from pathlib import Path
import webbrowser
import tempfile
import time


class EnhancedDesignGenerator:
    def __init__(self):
        self.output_dir = Path("design-output")
        self.feedback_dir = self.output_dir / "feedback"
        self.approved_dir = self.output_dir / "approved"
        self.rejected_dir = self.output_dir / "rejected"

        # Create directories
        for dir_path in [self.output_dir, self.feedback_dir, self.approved_dir, self.rejected_dir]:
            dir_path.mkdir(exist_ok=True)

        # Design categories with prompts
        self.categories = {
            "1": {
                "name": "Programming/Tech Humor",
                "prompts": [
                    "Create a funny programming joke design about debugging and sleep deprivation",
                    "Design a retro terminal-style error message with humor",
                    "Make a witty coding reference about coffee and code",
                    "Create a design about git commits and developer life"
                ]
            },
            "2": {
                "name": "Motivational/Lifestyle",
                "prompts": [
                    "Create an inspirational design about fresh starts and new perspectives",
                    "Design a minimalist motivational quote about perseverance",
                    "Make an elegant design about growth mindset and success",
                    "Create a modern design about daily improvement and progress"
                ]
            },
            "3": {
                "name": "Fashion/Wordplay",
                "prompts": [
                    "Create a sophisticated fashion pun about thread count and quality",
                    "Design an elegant wordplay about style and substance",
                    "Make a premium aesthetic design with fabric terminology",
                    "Create a luxury-inspired design with fashion industry humor"
                ]
            },
            "4": {
                "name": "Seasonal/Trending",
                "prompts": [
                    "Create a current trend-inspired design with modern aesthetics",
                    "Design a seasonal concept with contemporary appeal",
                    "Make a viral-worthy design that captures current culture",
                    "Create a trending topic design with social media appeal"
                ]
            },
            "5": {
                "name": "Gaming/Geek Culture",
                "prompts": [
                    "Create a retro gaming-inspired design with nostalgic appeal",
                    "Design a modern gaming reference with sleek aesthetics",
                    "Make a geek culture design that celebrates fandom",
                    "Create a sci-fi inspired design with futuristic elements"
                ]
            }
        }

        # Available Ollama models (based on your collection)
        self.available_models = [
            "llama3.2:latest",
            "llama3.1:latest",
            "llama3:latest",
            "llama2:latest",
            "codegemma:latest",
            "codellama:latest",
            "phi3:latest",
            "llava:latest",
            "dolphin-llama3:latest"
        ]

    def display_categories(self):
        """Display available design categories"""
        print("\n" + "="*60)
        print("🎨 FRESH THREADS DESIGN CATEGORIES")
        print("="*60)

        for key, category in self.categories.items():
            print(f"{key}. {category['name']}")
            print(
                f"   Example prompts: {len(category['prompts'])} variations available")

        print("\n6. Custom Prompt (Enter your own idea)")
        print("="*60)

    def get_category_selection(self):
        """Get user's category selection"""
        while True:
            try:
                choice = input("\nSelect a category (1-6): ").strip()
                if choice in ["1", "2", "3", "4", "5"]:
                    return choice, self.categories[choice]
                elif choice == "6":
                    custom_prompt = input(
                        "Enter your custom design prompt: ").strip()
                    if custom_prompt:
                        return "custom", {"name": "Custom", "prompts": [custom_prompt]}
                    else:
                        print("❌ Please enter a valid custom prompt")
                else:
                    print("❌ Please select a valid option (1-6)")
            except KeyboardInterrupt:
                print("\n👋 Goodbye!")
                exit(0)

    def select_model(self):
        """Select which Ollama model to use"""
        print("\n" + "="*50)
        print("🤖 SELECT AI MODEL")
        print("="*50)

        for i, model in enumerate(self.available_models, 1):
            print(f"{i}. {model}")

        while True:
            try:
                choice = input(
                    f"\nSelect model (1-{len(self.available_models)}) or press Enter for llama3.2:latest: ").strip()
                if not choice:
                    return "llama3.2:latest"

                choice_idx = int(choice) - 1
                if 0 <= choice_idx < len(self.available_models):
                    return self.available_models[choice_idx]
                else:
                    print(f"❌ Please select 1-{len(self.available_models)}")
            except ValueError:
                print("❌ Please enter a valid number")
            except KeyboardInterrupt:
                print("\n👋 Goodbye!")
                exit(0)

    def generate_design_with_ollama(self, prompt, model):
        """Generate SVG design using Ollama"""
        print(f"\n🎨 Generating design with {model}...")
        print(f"📝 Prompt: {prompt}")

        # Enhanced prompt for better SVG generation
        enhanced_prompt = f"""Create a professional T-shirt design as an SVG.

Design Requirements:
- {prompt}
- Use a 400x300 viewBox for optimal T-shirt printing
- Create a modern, clean aesthetic that people would want to wear
- Use professional typography and color schemes
- Include gradients, shadows, or visual effects for depth
- Make it suitable for screen printing or DTG printing
- Target audience: Young adults 18-35 who appreciate quality design

Technical Requirements:
- Pure SVG format (no external images)
- Use web-safe fonts or system fonts
- Color schemes that work on both light and dark shirts
- Clean, readable typography
- Professional composition and balance

Style: Modern, trendy, market-ready design that could sell for $24.99

Please respond with ONLY the SVG code, starting with <svg and ending with </svg>."""

        try:
            # Run Ollama command
            result = subprocess.run([
                "ollama", "run", model, enhanced_prompt
            ], capture_output=True, text=True, timeout=120)

            if result.returncode == 0:
                response = result.stdout.strip()

                # Extract SVG from response
                if "<svg" in response and "</svg>" in response:
                    svg_start = response.find("<svg")
                    svg_end = response.find("</svg>") + 6
                    svg_content = response[svg_start:svg_end]
                    return svg_content
                else:
                    print("⚠️ Generated response doesn't contain valid SVG")
                    return None
            else:
                print(f"❌ Ollama error: {result.stderr}")
                return None

        except subprocess.TimeoutExpired:
            print("⏰ Generation timed out (120s)")
            return None
        except Exception as e:
            print(f"❌ Error: {e}")
            return None

    def save_design(self, svg_content, category_name, prompt, model, status="generated"):
        """Save design with metadata"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{category_name.lower().replace('/', '_').replace(' ', '_')}_{timestamp}.svg"

        # Choose directory based on status
        if status == "approved":
            filepath = self.approved_dir / filename
        elif status == "rejected":
            filepath = self.rejected_dir / filename
        else:
            filepath = self.output_dir / filename

        # Save SVG
        with open(filepath, 'w') as f:
            f.write(svg_content)

        # Save metadata
        metadata = {
            "filename": filename,
            "category": category_name,
            "prompt": prompt,
            "model": model,
            "status": status,
            "timestamp": timestamp,
            "created_at": datetime.now().isoformat(),
            "filepath": str(filepath)
        }

        metadata_file = filepath.with_suffix('.json')
        with open(metadata_file, 'w') as f:
            json.dump(metadata, f, indent=2)

        return filepath, metadata_file

    def preview_design(self, svg_filepath):
        """Open design in browser for preview"""
        try:
            # Create temporary HTML file for preview
            html_content = f"""
<!DOCTYPE html>
<html>
<head>
    <title>Fresh Threads Design Preview</title>
    <style>
        body {{
            font-family: system-ui, -apple-system, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }}
        .preview-container {{
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 600px;
        }}
        .design-preview {{
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
            border: 2px solid #e9ecef;
        }}
        .controls {{
            margin-top: 30px;
        }}
        .feedback-btn {{
            font-size: 24px;
            padding: 15px 30px;
            margin: 0 10px;
            border: none;
            border-radius: 50px;
            cursor: pointer;
            transition: all 0.3s ease;
        }}
        .thumbs-up {{
            background: linear-gradient(135deg, #4CAF50, #45a049);
            color: white;
        }}
        .thumbs-down {{
            background: linear-gradient(135deg, #f44336, #da190b);
            color: white;
        }}
        .feedback-btn:hover {{
            transform: scale(1.05);
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }}
        h1 {{
            color: #2c3e50;
            margin-bottom: 10px;
        }}
        .metadata {{
            background: #f8f9fa;
            border-radius: 10px;
            padding: 15px;
            margin: 20px 0;
            text-align: left;
        }}
    </style>
</head>
<body>
    <div class="preview-container">
        <h1>🎨 Fresh Threads Design Preview</h1>
        <div class="design-preview">
            {svg_filepath.read_text()}
        </div>
        <div class="controls">
            <button class="feedback-btn thumbs-up" onclick="giveFeedback('👍')">
                👍 Approve Design
            </button>
            <button class="feedback-btn thumbs-down" onclick="giveFeedback('👎')">
                👎 Reject Design
            </button>
        </div>
        <p>Close this window and return to terminal to continue...</p>
    </div>

    <script>
        function giveFeedback(type) {{
            if (type === '👍') {{
                alert('✅ Design approved! Close this window and return to terminal.');
            }} else {{
                alert('❌ Design rejected! Close this window and return to terminal.');
            }}
        }}
    </script>
</body>
</html>"""

            with tempfile.NamedTemporaryFile(mode='w', suffix='.html', delete=False) as f:
                f.write(html_content)
                html_file = f.name

            webbrowser.open(f'file://{html_file}')
            return True

        except Exception as e:
            print(f"❌ Preview error: {e}")
            return False

    def get_feedback(self):
        """Get thumbs up/down feedback from user"""
        print("\n" + "="*50)
        print("👍👎 DESIGN FEEDBACK")
        print("="*50)
        print("1. 👍 Approve (Thumbs Up)")
        print("2. 👎 Reject (Thumbs Down)")
        print("3. 🔄 Generate Another Variation")
        print("4. 📝 Provide Custom Feedback")

        while True:
            try:
                choice = input("\nYour feedback (1-4): ").strip()
                if choice == "1":
                    return "approved", "User approved design"
                elif choice == "2":
                    reason = input("Optional: Why reject? ").strip()
                    return "rejected", reason or "User rejected design"
                elif choice == "3":
                    return "retry", "Generate another variation"
                elif choice == "4":
                    custom_feedback = input("Enter your feedback: ").strip()
                    return "custom", custom_feedback
                else:
                    print("❌ Please select 1-4")
            except KeyboardInterrupt:
                print("\n👋 Goodbye!")
                exit(0)

    def save_feedback(self, metadata, feedback_type, feedback_text):
        """Save user feedback for learning"""
        feedback_data = {
            "design_metadata": metadata,
            "feedback_type": feedback_type,
            "feedback_text": feedback_text,
            "timestamp": datetime.now().isoformat()
        }

        feedback_file = self.feedback_dir / \
            f"feedback_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(feedback_file, 'w') as f:
            json.dump(feedback_data, f, indent=2)

        print(f"💾 Feedback saved to {feedback_file}")

    def run_design_session(self):
        """Run interactive design generation session"""
        print("\n" + "🎨" * 20)
        print("   FRESH THREADS ENHANCED DESIGN GENERATOR")
        print("🎨" * 20)

        while True:
            try:
                # Category selection
                self.display_categories()
                category_key, category_data = self.get_category_selection()

                # Model selection
                selected_model = self.select_model()

                # Prompt selection/generation
                if category_key == "custom":
                    selected_prompt = category_data["prompts"][0]
                else:
                    print(
                        f"\n📝 Available prompts for {category_data['name']}:")
                    for i, prompt in enumerate(category_data["prompts"], 1):
                        print(f"{i}. {prompt}")

                    while True:
                        try:
                            prompt_choice = input(
                                f"\nSelect prompt (1-{len(category_data['prompts'])}): ").strip()
                            prompt_idx = int(prompt_choice) - 1
                            if 0 <= prompt_idx < len(category_data["prompts"]):
                                selected_prompt = category_data["prompts"][prompt_idx]
                                break
                            else:
                                print(
                                    f"❌ Please select 1-{len(category_data['prompts'])}")
                        except ValueError:
                            print("❌ Please enter a valid number")

                # Generate design
                svg_content = self.generate_design_with_ollama(
                    selected_prompt, selected_model)

                if svg_content:
                    # Save design
                    svg_file, metadata_file = self.save_design(
                        svg_content,
                        category_data["name"],
                        selected_prompt,
                        selected_model
                    )

                    print(f"✅ Design saved: {svg_file}")

                    # Preview design
                    print("\n🔍 Opening design preview...")
                    self.preview_design(svg_file)

                    # Wait for user to review
                    input("\nPress Enter after reviewing the design in your browser...")

                    # Get feedback
                    feedback_type, feedback_text = self.get_feedback()

                    # Load metadata for feedback
                    with open(metadata_file, 'r') as f:
                        metadata = json.load(f)

                    # Handle feedback
                    if feedback_type == "approved":
                        # Move to approved directory
                        approved_file, approved_metadata = self.save_design(
                            svg_content,
                            category_data["name"],
                            selected_prompt,
                            selected_model,
                            "approved"
                        )
                        print(
                            f"🎉 Design approved and moved to: {approved_file}")

                    elif feedback_type == "rejected":
                        # Move to rejected directory
                        rejected_file, rejected_metadata = self.save_design(
                            svg_content,
                            category_data["name"],
                            selected_prompt,
                            selected_model,
                            "rejected"
                        )
                        print(
                            f"❌ Design rejected and moved to: {rejected_file}")

                    elif feedback_type == "retry":
                        print("🔄 Generating another variation...")
                        continue

                    # Save feedback for learning
                    self.save_feedback(metadata, feedback_type, feedback_text)

                else:
                    print("❌ Failed to generate design")

                # Continue or exit
                continue_choice = input(
                    "\n🔄 Generate another design? (y/n): ").strip().lower()
                if continue_choice not in ['y', 'yes']:
                    break

            except KeyboardInterrupt:
                print("\n👋 Design session ended!")
                break

        print("\n✨ Thanks for using Fresh Threads Enhanced Design Generator!")
        print("📁 Check the output directories for your designs:")
        print(f"   📝 All designs: {self.output_dir}")
        print(f"   ✅ Approved: {self.approved_dir}")
        print(f"   ❌ Rejected: {self.rejected_dir}")
        print(f"   💬 Feedback: {self.feedback_dir}")


def main():
    generator = EnhancedDesignGenerator()
    generator.run_design_session()


if __name__ == "__main__":
    main()
