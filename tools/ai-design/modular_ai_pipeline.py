#!/usr/bin/env python3
"""
Fresh Threads LLC - Modular AI Design Pipeline
LLM (Dolphin) → Prompt Generation → SVG/Design Creation → GitHub/Printify Output
"""

import subprocess
import json
from datetime import datetime
from pathlib import Path
import webbrowser
import tempfile
import time
from http.server import HTTPServer, BaseHTTPRequestHandler
import urllib.parse
import threading
import os
import base64
import requests


class ModularDesignPipeline:
    def __init__(self):
        self.output_dir = Path("design-output")
        self.feedback_dir = self.output_dir / "feedback"
        self.approved_dir = self.output_dir / "approved"
        self.rejected_dir = self.output_dir / "rejected"
        self.github_ready_dir = self.output_dir / "github-ready"
        self.printify_ready_dir = self.output_dir / "printify-ready"

        # Create directories
        for dir_path in [self.output_dir, self.feedback_dir, self.approved_dir,
                         self.rejected_dir, self.github_ready_dir, self.printify_ready_dir]:
            dir_path.mkdir(exist_ok=True)

        # Design themes for LLM prompt generation
        self.themes = {
            "programming": {
                "name": "Programming/Developer",
                "icon": "💻",
                "base_concepts": [
                    "debugging humor", "coding jokes", "terminal aesthetics",
                    "git workflows", "coffee and code", "sleep deprivation",
                    "stack overflow references", "404 errors", "syntax errors"
                ]
            },
            "motivational": {
                "name": "Motivational/Success",
                "icon": "🚀",
                "base_concepts": [
                    "growth mindset", "fresh starts", "daily progress",
                    "success quotes", "minimalist inspiration", "goal achievement",
                    "positive mindset", "breakthrough moments", "level up"
                ]
            },
            "fashion": {
                "name": "Fashion/Luxury",
                "icon": "👔",
                "base_concepts": [
                    "thread count wordplay", "fabric terminology", "style puns",
                    "luxury aesthetics", "fashion industry humor", "premium quality",
                    "sophisticated wordplay", "textile references", "haute couture"
                ]
            },
            "gaming": {
                "name": "Gaming/Geek",
                "icon": "🎮",
                "base_concepts": [
                    "retro gaming", "pixel art", "boss battles", "level up",
                    "respawn humor", "achievement unlocked", "easter eggs",
                    "console wars", "speedrun references", "game over"
                ]
            },
            "seasonal": {
                "name": "Seasonal/Trending",
                "icon": "🌟",
                "base_concepts": [
                    "current trends", "viral memes", "social media culture",
                    "seasonal events", "holiday themes", "pop culture",
                    "trending hashtags", "internet culture", "zeitgeist"
                ]
            }
        }

        # Available models for different tasks
        self.llm_models = {
            "dolphin-llama3:latest": "Creative prompt generation",
            "llama3.2:latest": "Balanced creativity and structure",
            "codegemma:latest": "Technical/programming themes",
            "llama3.1:latest": "High-quality detailed prompts"
        }

    def generate_enhanced_prompt_with_llm(self, theme, user_input, model="dolphin-llama3:latest"):
        """Step 1: Use LLM to generate enhanced design prompt"""
        print(f"🧠 Generating enhanced prompt with {model}...")

        theme_concepts = ", ".join(self.themes[theme]["base_concepts"])

        llm_prompt = f"""You are a professional T-shirt design consultant. Generate a detailed, creative design prompt for a T-shirt.

Theme: {self.themes[theme]['name']}
User Input: {user_input}
Theme Concepts: {theme_concepts}

Create a detailed design prompt that includes:
1. Main concept/message
2. Visual style and aesthetics
3. Typography recommendations
4. Color palette suggestions
5. Composition layout
6. Target audience appeal

The design should be:
- Marketable and trendy for young adults (18-35)
- Suitable for screen printing or DTG
- Unique enough to stand out in marketplace
- Professional quality worth $24.99 retail price

Format your response as a clear, detailed design brief that could be used by a designer or AI image generator.

Design Brief:"""

        try:
            result = subprocess.run([
                "ollama", "run", model, llm_prompt
            ], capture_output=True, text=True, timeout=120)

            if result.returncode == 0:
                enhanced_prompt = result.stdout.strip()
                print(
                    f"✅ Enhanced prompt generated ({len(enhanced_prompt)} chars)")
                return enhanced_prompt
            else:
                print(f"❌ LLM error: {result.stderr}")
                return self.create_fallback_prompt(theme, user_input)

        except subprocess.TimeoutExpired:
            print("⏰ LLM timeout, using fallback prompt")
            return self.create_fallback_prompt(theme, user_input)
        except Exception as e:
            print(f"❌ LLM error: {e}")
            return self.create_fallback_prompt(theme, user_input)

    def create_fallback_prompt(self, theme, user_input):
        """Fallback prompt if LLM fails"""
        return f"Create a professional T-shirt design for {self.themes[theme]['name']} theme. Concept: {user_input}. Use modern typography, appealing colors, and trendy aesthetics suitable for young adults."

    def generate_svg_design(self, enhanced_prompt, theme):
        """Step 2: Generate SVG design using local models"""
        print("🎨 Creating SVG design...")

        svg_prompt = f"""Create a professional T-shirt design as clean SVG code.

Design Brief: {enhanced_prompt}

Technical Requirements:
- Pure SVG format with 400x300 viewBox
- Professional typography (system fonts)
- Modern color schemes that print well
- Centered composition for T-shirt placement
- Clean, scalable vector graphics
- No external dependencies

Output only the SVG code, starting with <svg and ending with </svg>."""

        try:
            # Try multiple models for best results
            models_to_try = ["llama3.2:latest", "dolphin-llama3:latest"]

            for model in models_to_try:
                print(f"  Trying {model}...")
                result = subprocess.run([
                    "ollama", "run", model, svg_prompt
                ], capture_output=True, text=True, timeout=120)

                if result.returncode == 0:
                    response = result.stdout.strip()

                    # Extract SVG
                    if "<svg" in response and "</svg>" in response:
                        svg_start = response.find("<svg")
                        svg_end = response.find("</svg>") + 6
                        svg_content = response[svg_start:svg_end]
                        print(f"✅ SVG generated with {model}")
                        return svg_content, model

            # Fallback design
            print("⚠️ Using fallback design")
            return self.create_fallback_svg(theme), "fallback"

        except Exception as e:
            print(f"❌ SVG generation error: {e}")
            return self.create_fallback_svg(theme), "fallback"

    def create_fallback_svg(self, theme):
        """Fallback SVG design"""
        theme_colors = {
            "programming": {"bg": "#0f172a", "accent": "#00ff88", "text": "#ffffff"},
            "motivational": {"bg": "#667eea", "accent": "#764ba2", "text": "#ffffff"},
            "fashion": {"bg": "#1a202c", "accent": "#fbbf24", "text": "#ffffff"},
            "gaming": {"bg": "#2d1b69", "accent": "#f093fb", "text": "#ffffff"},
            "seasonal": {"bg": "#ff6b6b", "accent": "#4ecdc4", "text": "#ffffff"}
        }

        colors = theme_colors.get(theme, theme_colors["motivational"])
        theme_name = self.themes[theme]["name"]

        return f'''<svg width="400" height="300" viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bgGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:{colors["bg"]};stop-opacity:1" />
      <stop offset="100%" style="stop-color:{colors["accent"]};stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="400" height="300" fill="url(#bgGrad)"/>
  <text x="200" y="140" text-anchor="middle" font-family="system-ui, sans-serif"
        font-size="20" font-weight="bold" fill="{colors["text"]}">Fresh Threads</text>
  <text x="200" y="170" text-anchor="middle" font-family="system-ui, sans-serif"
        font-size="14" fill="{colors["text"]}">{theme_name} Collection</text>
</svg>'''

    def save_design_with_outputs(self, svg_content, enhanced_prompt, theme, model_used):
        """Step 3: Save design and prepare for multiple outputs"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        base_filename = f"{theme}_{timestamp}"

        # Save main SVG
        svg_file = self.output_dir / f"{base_filename}.svg"
        with open(svg_file, 'w') as f:
            f.write(svg_content)

        # Save metadata
        metadata = {
            "filename": f"{base_filename}.svg",
            "theme": theme,
            "enhanced_prompt": enhanced_prompt,
            "model_used": model_used,
            "timestamp": timestamp,
            "created_at": datetime.now().isoformat(),
            "status": "generated",
            "outputs": {
                "svg_file": str(svg_file),
                "github_ready": False,
                "printify_ready": False
            }
        }

        metadata_file = svg_file.with_suffix('.json')
        with open(metadata_file, 'w') as f:
            json.dump(metadata, f, indent=2)

        return svg_file, metadata_file, metadata

    def prepare_github_output(self, svg_file, metadata):
        """Step 4A: Prepare design for GitHub integration"""
        print("📁 Preparing GitHub-ready output...")

        # Create GitHub-ready version with documentation
        github_file = self.github_ready_dir / svg_file.name

        # Copy SVG
        github_file.write_text(svg_file.read_text())

        # Create README for this design
        readme_content = f"""# {metadata['theme'].title()} Design - {metadata['timestamp']}

## Design Details
- **Theme**: {self.themes[metadata['theme']]['name']}
- **Created**: {metadata['created_at'][:10]}
- **Model Used**: {metadata['model_used']}
- **Status**: Ready for production

## Enhanced Prompt
{metadata['enhanced_prompt']}

## Files
- `{svg_file.name}` - Production SVG
- `{svg_file.stem}_metadata.json` - Design metadata

## Integration
This design is ready for:
- ✅ GitHub repository integration
- ✅ Version control tracking
- ✅ Collaborative review
- ✅ Automated deployment

## Next Steps
1. Review design quality
2. Get team feedback
3. Approve for production
4. Upload to print platforms
"""

        readme_file = self.github_ready_dir / f"{svg_file.stem}_README.md"
        readme_file.write_text(readme_content)

        # Copy metadata
        github_metadata = self.github_ready_dir / \
            f"{svg_file.stem}_metadata.json"
        github_metadata.write_text(json.dumps(metadata, indent=2))

        print(f"✅ GitHub-ready files created in {self.github_ready_dir}")
        return github_file, readme_file

    def prepare_printify_output(self, svg_file, metadata):
        """Step 4B: Prepare design for Printify integration"""
        print("🖨️ Preparing Printify-ready output...")

        # Create Printify-ready version with specs
        printify_file = self.printify_ready_dir / svg_file.name

        # Copy SVG (could add print-specific optimizations here)
        printify_file.write_text(svg_file.read_text())

        # Create Printify specifications
        printify_specs = {
            "design_info": {
                "title": f"{self.themes[metadata['theme']]['name']} - {metadata['timestamp']}",
                "description": "Professional T-shirt design created with AI assistance",
                "tags": [metadata['theme'], "ai-generated", "fresh-threads", "trendy"],
                "category": self.themes[metadata['theme']]['name']
            },
            "print_specifications": {
                "format": "SVG",
                "dimensions": "400x300px",
                "placement": "Front Center",
                "recommended_size": "10x7.5 inches",
                "print_area": "Front chest placement",
                "colors": "Full color",
                "background": "Transparent recommended"
            },
            "pricing": {
                "suggested_retail": "$24.99",
                "target_margin": "65%",
                "market_position": "Premium casual"
            },
            "target_audience": {
                "age_range": "18-35",
                "interests": self.themes[metadata['theme']]['base_concepts'][:5],
                "style_preference": "Modern, trendy, unique"
            }
        }

        specs_file = self.printify_ready_dir / \
            f"{svg_file.stem}_printify_specs.json"
        with open(specs_file, 'w') as f:
            json.dump(printify_specs, f, indent=2)

        print(f"✅ Printify-ready files created in {self.printify_ready_dir}")
        return printify_file, specs_file

    def create_web_interface(self):
        """Generate beautiful web interface"""
        themes_html = ""
        for key, theme in self.themes.items():
            themes_html += f'''
            <div class="theme-card" data-theme="{key}">
                <div class="theme-icon">{theme["icon"]}</div>
                <h3>{theme["name"]}</h3>
                <p>{len(theme["base_concepts"])} concepts available</p>
            </div>'''

        models_html = ""
        for model, description in self.llm_models.items():
            models_html += f'''
            <option value="{model}">{model.split(':')[0]} - {description}</option>'''

        return f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fresh Threads - Modular AI Design Pipeline</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}

        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }}

        .pipeline-container {{
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
        }}

        .header {{
            background: linear-gradient(135deg, #2d3748 0%, #1a202c 100%);
            color: white;
            padding: 40px;
            text-align: center;
        }}

        .header h1 {{
            font-size: 2.8rem;
            margin-bottom: 15px;
        }}

        .header p {{
            font-size: 1.2rem;
            opacity: 0.9;
            margin-bottom: 20px;
        }}

        .pipeline-steps {{
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-top: 20px;
            flex-wrap: wrap;
        }}

        .pipeline-step {{
            background: rgba(255,255,255,0.1);
            padding: 10px 20px;
            border-radius: 20px;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            gap: 8px;
        }}

        .content {{
            padding: 50px;
        }}

        .step {{
            display: none;
            animation: fadeIn 0.5s ease-in;
        }}

        .step.active {{
            display: block;
        }}

        @keyframes fadeIn {{
            from {{ opacity: 0; transform: translateY(20px); }}
            to {{ opacity: 1; transform: translateY(0); }}
        }}

        .step-header {{
            text-align: center;
            margin-bottom: 40px;
        }}

        .step-number {{
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            width: 60px;
            height: 60px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            font-weight: bold;
            margin: 0 auto 20px;
        }}

        .step-title {{
            font-size: 2rem;
            color: #2d3748;
            margin-bottom: 10px;
        }}

        .step-subtitle {{
            color: #718096;
            font-size: 1.1rem;
        }}

        .themes-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 25px;
            margin-bottom: 40px;
        }}

        .theme-card {{
            border: 3px solid #e2e8f0;
            border-radius: 15px;
            padding: 30px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
            background: #f8f9fa;
        }}

        .theme-card:hover {{
            border-color: #667eea;
            transform: translateY(-5px);
            box-shadow: 0 15px 35px rgba(102, 126, 234, 0.15);
        }}

        .theme-card.selected {{
            border-color: #667eea;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            transform: translateY(-5px);
        }}

        .theme-icon {{
            font-size: 3rem;
            margin-bottom: 15px;
        }}

        .theme-card h3 {{
            font-size: 1.3rem;
            margin-bottom: 10px;
        }}

        .form-group {{
            margin-bottom: 30px;
        }}

        .form-label {{
            display: block;
            font-weight: 600;
            color: #2d3748;
            margin-bottom: 10px;
            font-size: 1.1rem;
        }}

        .form-input, .form-select {{
            width: 100%;
            padding: 15px;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            font-size: 1rem;
            transition: border-color 0.3s ease;
        }}

        .form-input:focus, .form-select:focus {{
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }}

        .form-textarea {{
            min-height: 120px;
            resize: vertical;
        }}

        .buttons {{
            display: flex;
            gap: 20px;
            justify-content: center;
            margin-top: 40px;
            flex-wrap: wrap;
        }}

        .btn {{
            padding: 15px 35px;
            border: none;
            border-radius: 50px;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 10px;
        }}

        .btn-primary {{
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
        }}

        .btn-secondary {{
            background: #e2e8f0;
            color: #4a5568;
        }}

        .btn:hover {{
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.15);
        }}

        .btn:disabled {{
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
        }}

        .progress-indicator {{
            background: #f8f9fa;
            border-radius: 10px;
            padding: 30px;
            text-align: center;
            margin: 30px 0;
        }}

        .spinner {{
            border: 4px solid #f3f3f3;
            border-top: 4px solid #667eea;
            border-radius: 50%;
            width: 60px;
            height: 60px;
            animation: spin 1s linear infinite;
            margin: 0 auto 20px;
        }}

        @keyframes spin {{
            0% {{ transform: rotate(0deg); }}
            100% {{ transform: rotate(360deg); }}
        }}

        .design-preview {{
            background: #f8f9fa;
            border-radius: 15px;
            padding: 40px;
            text-align: center;
            margin: 30px 0;
        }}

        .design-container {{
            background: white;
            border-radius: 10px;
            padding: 30px;
            margin: 0 auto;
            max-width: 500px;
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
        }}

        .feedback-section {{
            background: #f8f9fa;
            border-radius: 15px;
            padding: 30px;
            margin: 30px 0;
        }}

        .feedback-buttons {{
            display: flex;
            gap: 20px;
            justify-content: center;
            margin: 30px 0;
            flex-wrap: wrap;
        }}

        .feedback-btn {{
            padding: 15px 30px;
            border: none;
            border-radius: 50px;
            font-size: 1.2rem;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 10px;
            min-width: 150px;
            justify-content: center;
        }}

        .thumbs-up {{
            background: linear-gradient(135deg, #48bb78, #38a169);
            color: white;
        }}

        .thumbs-down {{
            background: linear-gradient(135deg, #f56565, #e53e3e);
            color: white;
        }}

        .feedback-btn:hover {{
            transform: scale(1.05);
            box-shadow: 0 8px 25px rgba(0,0,0,0.2);
        }}

        .output-options {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 25px;
            margin: 30px 0;
        }}

        .output-card {{
            border: 2px solid #e2e8f0;
            border-radius: 15px;
            padding: 25px;
            text-align: center;
            background: white;
        }}

        .output-icon {{
            font-size: 2.5rem;
            margin-bottom: 15px;
        }}

        .status-message {{
            padding: 20px;
            border-radius: 10px;
            margin: 20px 0;
            text-align: center;
            font-weight: 500;
        }}

        .success {{
            background: #f0fff4;
            color: #22543d;
            border: 2px solid #9ae6b4;
        }}

        .error {{
            background: #fed7d7;
            color: #742a2a;
            border: 2px solid #feb2b2;
        }}

        .info {{
            background: #ebf8ff;
            color: #2a4365;
            border: 2px solid #90cdf4;
        }}
    </style>
</head>
<body>
    <div class="pipeline-container">
        <div class="header">
            <h1>🎨 Fresh Threads AI Design Pipeline</h1>
            <p>Modular workflow: LLM → Prompt Enhancement → Design Creation → Multi-Platform Output</p>
            <div class="pipeline-steps">
                <div class="pipeline-step">🧠 LLM Prompt Generation</div>
                <div class="pipeline-step">🎨 SVG Design Creation</div>
                <div class="pipeline-step">📁 GitHub Integration</div>
                <div class="pipeline-step">🖨️ Printify Output</div>
            </div>
        </div>

        <div class="content">
            <!-- Step 1: Theme & Input Selection -->
            <div class="step active" id="step1">
                <div class="step-header">
                    <div class="step-number">1</div>
                    <h2 class="step-title">Choose Theme & Concept</h2>
                    <p class="step-subtitle">Select a theme and describe your design idea</p>
                </div>

                <div class="themes-grid">
                    {themes_html}
                </div>

                <div class="form-group">
                    <label class="form-label">🤖 Select LLM Model for Prompt Enhancement</label>
                    <select class="form-select" id="modelSelect">
                        {models_html}
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label">💡 Describe Your Design Idea</label>
                    <textarea class="form-input form-textarea" id="userInput"
                              placeholder="Describe your T-shirt design concept. The AI will enhance this into a detailed design brief..."></textarea>
                </div>

                <div class="buttons">
                    <button class="btn btn-primary" onclick="startPipeline()">
                        🚀 Start AI Pipeline
                    </button>
                </div>
            </div>

            <!-- Step 2: Processing -->
            <div class="step" id="step2">
                <div class="step-header">
                    <div class="step-number">2</div>
                    <h2 class="step-title">AI Pipeline Processing</h2>
                    <p class="step-subtitle">Creating your enhanced design</p>
                </div>

                <div class="progress-indicator">
                    <div class="spinner"></div>
                    <h3 id="processStatus">🧠 Enhancing prompt with LLM...</h3>
                    <p id="processDetails">This may take a few moments</p>
                </div>
            </div>

            <!-- Step 3: Design Preview -->
            <div class="step" id="step3">
                <div class="step-header">
                    <div class="step-number">3</div>
                    <h2 class="step-title">Design Created!</h2>
                    <p class="step-subtitle">Review your AI-generated design</p>
                </div>

                <div class="design-preview">
                    <div class="design-container" id="designContainer">
                        <!-- Design will appear here -->
                    </div>
                </div>

                <div class="feedback-section">
                    <h3>📝 Enhanced Prompt Used:</h3>
                    <div id="enhancedPromptDisplay" style="background: white; padding: 20px; border-radius: 10px; text-align: left; margin: 20px 0;"></div>

                    <div class="feedback-buttons">
                        <button class="feedback-btn thumbs-up" onclick="approveDesign()">
                            👍 <span>Approve & Process</span>
                        </button>
                        <button class="feedback-btn thumbs-down" onclick="rejectDesign()">
                            👎 <span>Try Again</span>
                        </button>
                    </div>
                </div>
            </div>

            <!-- Step 4: Output Generation -->
            <div class="step" id="step4">
                <div class="step-header">
                    <div class="step-number">4</div>
                    <h2 class="step-title">Multi-Platform Output</h2>
                    <p class="step-subtitle">Preparing files for GitHub and Printify</p>
                </div>

                <div class="output-options">
                    <div class="output-card">
                        <div class="output-icon">📁</div>
                        <h3>GitHub Ready</h3>
                        <p>Version control integration</p>
                        <div id="githubStatus" class="status-message info">Preparing...</div>
                    </div>

                    <div class="output-card">
                        <div class="output-icon">🖨️</div>
                        <h3>Printify Ready</h3>
                        <p>Print-on-demand specifications</p>
                        <div id="printifyStatus" class="status-message info">Preparing...</div>
                    </div>
                </div>

                <div id="outputResults"></div>

                <div class="buttons">
                    <button class="btn btn-primary" onclick="startOver()">
                        🔄 Create Another Design
                    </button>
                    <button class="btn btn-secondary" onclick="viewOutputs()">
                        📂 View All Outputs
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
        let selectedTheme = null;
        let currentDesign = null;

        // Theme selection
        document.querySelectorAll('.theme-card').forEach(card => {{
            card.addEventListener('click', function() {{
                document.querySelectorAll('.theme-card').forEach(c => c.classList.remove('selected'));
                this.classList.add('selected');
                selectedTheme = this.dataset.theme;
            }});
        }});

        function startPipeline() {{
            if (!selectedTheme) {{
                alert('Please select a theme first.');
                return;
            }}

            const userInput = document.getElementById('userInput').value.trim();
            if (!userInput) {{
                alert('Please describe your design idea.');
                return;
            }}

            const model = document.getElementById('modelSelect').value;

            showStep('step2');

            // Start the pipeline
            fetch('/pipeline', {{
                method: 'POST',
                headers: {{ 'Content-Type': 'application/json' }},
                body: JSON.stringify({{
                    theme: selectedTheme,
                    user_input: userInput,
                    model: model
                }})
            }})
            .then(response => response.json())
            .then(data => {{
                if (data.success) {{
                    currentDesign = data;
                    displayResults(data);
                    showStep('step3');
                }} else {{
                    alert('Pipeline error: ' + data.error);
                    showStep('step1');
                }}
            }})
            .catch(error => {{
                console.error('Error:', error);
                alert('Pipeline failed. Please try again.');
                showStep('step1');
            }});
        }}

        function displayResults(data) {{
            document.getElementById('designContainer').innerHTML = data.svg_content;
            document.getElementById('enhancedPromptDisplay').innerHTML =
                '<strong>Model Used:</strong> ' + data.model_used + '<br><br>' +
                data.enhanced_prompt.replace(/\\n/g, '<br>');
        }}

        function approveDesign() {{
            if (!currentDesign) return;

            showStep('step4');

            // Generate outputs
            fetch('/generate-outputs', {{
                method: 'POST',
                headers: {{ 'Content-Type': 'application/json' }},
                body: JSON.stringify({{
                    design_id: currentDesign.design_id
                }})
            }})
            .then(response => response.json())
            .then(data => {{
                updateOutputStatus(data);
            }})
            .catch(error => {{
                console.error('Error:', error);
                document.getElementById('githubStatus').className = 'status-message error';
                document.getElementById('githubStatus').textContent = 'Generation failed';
                document.getElementById('printifyStatus').className = 'status-message error';
                document.getElementById('printifyStatus').textContent = 'Generation failed';
            }});
        }}

        function rejectDesign() {{
            if (!currentDesign) return;

            fetch('/feedback', {{
                method: 'POST',
                headers: {{ 'Content-Type': 'application/json' }},
                body: JSON.stringify({{
                    design_id: currentDesign.design_id,
                    feedback_type: 'rejected',
                    feedback_text: 'User rejected design and wants to try again'
                }})
            }});

            startOver();
        }}

        function updateOutputStatus(data) {{
            if (data.github_success) {{
                document.getElementById('githubStatus').className = 'status-message success';
                document.getElementById('githubStatus').textContent = '✅ GitHub files ready';
            }} else {{
                document.getElementById('githubStatus').className = 'status-message error';
                document.getElementById('githubStatus').textContent = '❌ GitHub generation failed';
            }}

            if (data.printify_success) {{
                document.getElementById('printifyStatus').className = 'status-message success';
                document.getElementById('printifyStatus').textContent = '✅ Printify files ready';
            }} else {{
                document.getElementById('printifyStatus').className = 'status-message error';
                document.getElementById('printifyStatus').textContent = '❌ Printify generation failed';
            }}

            let resultsHtml = '<div class="status-message success">';
            resultsHtml += '<h3>🎉 Pipeline Complete!</h3>';
            resultsHtml += '<p>Your design has been processed and is ready for production.</p>';
            if (data.github_success) {{
                resultsHtml += '<p>📁 GitHub files: design-output/github-ready/</p>';
            }}
            if (data.printify_success) {{
                resultsHtml += '<p>🖨️ Printify files: design-output/printify-ready/</p>';
            }}
            resultsHtml += '</div>';

            document.getElementById('outputResults').innerHTML = resultsHtml;
        }}

        function startOver() {{
            selectedTheme = null;
            currentDesign = null;

            document.querySelectorAll('.theme-card').forEach(c => c.classList.remove('selected'));
            document.getElementById('userInput').value = '';
            document.getElementById('modelSelect').selectedIndex = 0;

            showStep('step1');
        }}

        function viewOutputs() {{
            window.open('/outputs', '_blank');
        }}

        function showStep(stepId) {{
            document.querySelectorAll('.step').forEach(step => step.classList.remove('active'));
            document.getElementById(stepId).classList.add('active');
        }}
    </script>
</body>
</html>'''


class PipelineWebHandler(BaseHTTPRequestHandler):
    def __init__(self, pipeline, *args, **kwargs):
        self.pipeline = pipeline
        super().__init__(*args, **kwargs)

    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(self.pipeline.create_web_interface().encode())
        elif self.path == '/outputs':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(self.generate_outputs_page().encode())
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        data = json.loads(post_data.decode('utf-8'))

        if self.path == '/pipeline':
            # Run the full pipeline
            theme = data.get('theme')
            user_input = data.get('user_input')
            model = data.get('model', 'dolphin-llama3:latest')

            try:
                # Step 1: Generate enhanced prompt
                enhanced_prompt = self.pipeline.generate_enhanced_prompt_with_llm(
                    theme, user_input, model
                )

                # Step 2: Generate SVG design
                svg_content, model_used = self.pipeline.generate_svg_design(
                    enhanced_prompt, theme
                )

                # Step 3: Save design
                svg_file, metadata_file, metadata = self.pipeline.save_design_with_outputs(
                    svg_content, enhanced_prompt, theme, model_used
                )

                response = {
                    'success': True,
                    'svg_content': svg_content,
                    'enhanced_prompt': enhanced_prompt,
                    'model_used': model_used,
                    'design_id': metadata['timestamp'],
                    'metadata': metadata
                }

            except Exception as e:
                response = {
                    'success': False,
                    'error': str(e)
                }

        elif self.path == '/generate-outputs':
            # Generate GitHub and Printify outputs
            design_id = data.get('design_id')

            try:
                # Find the design files
                svg_files = list(
                    self.pipeline.output_dir.glob(f"*{design_id}.svg"))
                metadata_files = list(
                    self.pipeline.output_dir.glob(f"*{design_id}.json"))

                if svg_files and metadata_files:
                    svg_file = svg_files[0]
                    with open(metadata_files[0], 'r') as f:
                        metadata = json.load(f)

                    # Generate outputs
                    github_file, readme_file = self.pipeline.prepare_github_output(
                        svg_file, metadata)
                    printify_file, specs_file = self.pipeline.prepare_printify_output(
                        svg_file, metadata)

                    response = {
                        'success': True,
                        'github_success': True,
                        'printify_success': True,
                        'github_files': [str(github_file), str(readme_file)],
                        'printify_files': [str(printify_file), str(specs_file)]
                    }
                else:
                    response = {
                        'success': False,
                        'error': 'Design files not found'
                    }

            except Exception as e:
                response = {
                    'success': False,
                    'github_success': False,
                    'printify_success': False,
                    'error': str(e)
                }

        elif self.path == '/feedback':
            # Save feedback
            design_id = data.get('design_id')
            feedback_type = data.get('feedback_type')
            feedback_text = data.get('feedback_text')

            try:
                # Find metadata file
                metadata_files = list(
                    self.pipeline.output_dir.glob(f"*{design_id}.json"))
                if metadata_files:
                    with open(metadata_files[0], 'r') as f:
                        metadata = json.load(f)

                    # Save feedback
                    feedback_data = {
                        "design_metadata": metadata,
                        "feedback_type": feedback_type,
                        "feedback_text": feedback_text,
                        "timestamp": datetime.now().isoformat()
                    }

                    feedback_file = self.pipeline.feedback_dir / \
                        f"feedback_{design_id}.json"
                    with open(feedback_file, 'w') as f:
                        json.dump(feedback_data, f, indent=2)

                    response = {'success': True}
                else:
                    response = {'success': False, 'error': 'Design not found'}

            except Exception as e:
                response = {'success': False, 'error': str(e)}

        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(response).encode())

    def generate_outputs_page(self):
        return '''<!DOCTYPE html>
<html>
<head>
    <title>Design Outputs - Fresh Threads Pipeline</title>
    <style>
        body { font-family: system-ui; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; }
        .output-section { background: white; border-radius: 10px; padding: 30px; margin: 20px 0; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .folder-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; }
        .folder-card { background: #f8f9fa; border-radius: 10px; padding: 20px; text-align: center; border: 2px solid #e9ecef; }
        .folder-icon { font-size: 3rem; margin-bottom: 15px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎨 Fresh Threads Design Pipeline Outputs</h1>

        <div class="output-section">
            <h2>📁 Output Directories</h2>
            <div class="folder-grid">
                <div class="folder-card">
                    <div class="folder-icon">📁</div>
                    <h3>GitHub Ready</h3>
                    <p>design-output/github-ready/</p>
                    <small>Version control integration files</small>
                </div>
                <div class="folder-card">
                    <div class="folder-icon">🖨️</div>
                    <h3>Printify Ready</h3>
                    <p>design-output/printify-ready/</p>
                    <small>Print-on-demand specifications</small>
                </div>
                <div class="folder-card">
                    <div class="folder-icon">✅</div>
                    <h3>Approved Designs</h3>
                    <p>design-output/approved/</p>
                    <small>Production-ready designs</small>
                </div>
                <div class="folder-card">
                    <div class="folder-icon">💬</div>
                    <h3>Feedback Data</h3>
                    <p>design-output/feedback/</p>
                    <small>User feedback for learning</small>
                </div>
            </div>
        </div>

        <div class="output-section">
            <h2>🚀 Next Steps</h2>
            <ol>
                <li><strong>Review GitHub files:</strong> Check the generated README and metadata</li>
                <li><strong>Upload to Printify:</strong> Use the specs file for accurate product setup</li>
                <li><strong>Version control:</strong> Commit approved designs to your repository</li>
                <li><strong>Production:</strong> Begin marketing and sales</li>
            </ol>
        </div>
    </div>
</body>
</html>'''

    def log_message(self, format, *args):
        pass


def create_pipeline_handler(pipeline):
    return lambda *args, **kwargs: PipelineWebHandler(pipeline, *args, **kwargs)


def main():
    pipeline = ModularDesignPipeline()

    # Start web server
    port = 8080
    handler = create_pipeline_handler(pipeline)

    try:
        server = HTTPServer(('localhost', port), handler)
        print("\n" + "🎨" * 50)
        print("   FRESH THREADS MODULAR AI DESIGN PIPELINE")
        print("🎨" * 50)
        print(f"\n🌐 Web Interface: http://localhost:{port}")
        print(f"🧠 LLM Models: {', '.join(pipeline.llm_models.keys())}")
        print(f"📁 Output Directory: {pipeline.output_dir}")
        print(f"\n🔄 Pipeline Flow:")
        print(f"   1. 🧠 LLM enhances user prompt → detailed design brief")
        print(f"   2. 🎨 SVG generation → professional T-shirt design")
        print(f"   3. 📁 GitHub output → version control ready")
        print(f"   4. 🖨️ Printify output → print-on-demand ready")
        print(f"\n💡 Open your browser and start the AI pipeline!")
        print(f"⏹️  Press Ctrl+C to stop the server")

        # Open browser
        webbrowser.open(f'http://localhost:{port}')

        # Start server
        server.serve_forever()

    except KeyboardInterrupt:
        print(
            f"\n👋 Pipeline stopped. All outputs saved in {pipeline.output_dir}")
    except Exception as e:
        print(f"❌ Server error: {e}")


if __name__ == "__main__":
    main()
