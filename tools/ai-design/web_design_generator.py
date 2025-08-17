#!/usr/bin/env python3
"""
Fresh Threads LLC - Web-Based Design Generator
Interactive web interface with DreamShaper model integration
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


class WebDesignGenerator:
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
            "programming": {
                "name": "Programming/Tech Humor",
                "icon": "💻",
                "prompts": [
                    "Create a funny programming joke design about debugging and sleep deprivation",
                    "Design a retro terminal-style error message with humor",
                    "Make a witty coding reference about coffee and code",
                    "Create a design about git commits and developer life"
                ]
            },
            "motivational": {
                "name": "Motivational/Lifestyle",
                "icon": "🚀",
                "prompts": [
                    "Create an inspirational design about fresh starts and new perspectives",
                    "Design a minimalist motivational quote about perseverance",
                    "Make an elegant design about growth mindset and success",
                    "Create a modern design about daily improvement and progress"
                ]
            },
            "fashion": {
                "name": "Fashion/Wordplay",
                "icon": "👔",
                "prompts": [
                    "Create a sophisticated fashion pun about thread count and quality",
                    "Design an elegant wordplay about style and substance",
                    "Make a premium aesthetic design with fabric terminology",
                    "Create a luxury-inspired design with fashion industry humor"
                ]
            },
            "seasonal": {
                "name": "Seasonal/Trending",
                "icon": "🌟",
                "prompts": [
                    "Create a current trend-inspired design with modern aesthetics",
                    "Design a seasonal concept with contemporary appeal",
                    "Make a viral-worthy design that captures current culture",
                    "Create a trending topic design with social media appeal"
                ]
            },
            "gaming": {
                "name": "Gaming/Geek Culture",
                "icon": "🎮",
                "prompts": [
                    "Create a retro gaming-inspired design with nostalgic appeal",
                    "Design a modern gaming reference with sleek aesthetics",
                    "Make a geek culture design that celebrates fandom",
                    "Create a sci-fi inspired design with futuristic elements"
                ]
            }
        }

        self.current_design = None
        self.server = None

    def generate_design_with_dreamshaper(self, prompt, category):
        """Generate SVG design using DreamShaper model"""
        print(f"\n🎨 Generating design with DreamShaper...")
        print(f"📝 Category: {category}")
        print(f"📝 Prompt: {prompt}")

        # Enhanced prompt for DreamShaper
        enhanced_prompt = f"""Create a professional T-shirt design as clean SVG code.

Design Brief:
- Theme: {prompt}
- Category: {category}
- Style: Modern, trendy, marketable design for young adults
- Format: Clean SVG with 400x300 viewBox
- Typography: Professional fonts, readable text
- Colors: Eye-catching but printable color scheme
- Composition: Centered design, balanced layout
- Target: $24.99 retail price point

Technical Requirements:
- Pure SVG format (no external dependencies)
- Web-safe fonts or system fonts
- Professional typography hierarchy
- Suitable for screen printing or DTG
- Clean, scalable vector graphics

Market Requirements:
- Design people would actually buy and wear
- Trendy aesthetic that appeals to 18-35 demographic
- Unique concept that stands out in marketplace
- High-quality look worthy of premium pricing

Please respond with ONLY the SVG code, starting with <svg and ending with </svg>."""

        try:
            # Run DreamShaper via Ollama
            result = subprocess.run([
                "ollama", "run", "dreamshaper", enhanced_prompt
            ], capture_output=True, text=True, timeout=180)

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
                    # Fallback: create a basic design
                    return self.create_fallback_design(prompt, category)
            else:
                print(f"❌ DreamShaper error: {result.stderr}")
                return self.create_fallback_design(prompt, category)

        except subprocess.TimeoutExpired:
            print("⏰ Generation timed out (180s)")
            return self.create_fallback_design(prompt, category)
        except Exception as e:
            print(f"❌ Error: {e}")
            return self.create_fallback_design(prompt, category)

    def create_fallback_design(self, prompt, category):
        """Create a fallback design if DreamShaper fails"""
        # Create a professional fallback design based on category
        if "programming" in category.lower() or "tech" in category.lower():
            return '''<svg width="400" height="300" viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="techGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#0f172a;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#1e293b;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="400" height="300" fill="url(#techGrad)"/>
  <text x="200" y="120" text-anchor="middle" font-family="monospace" font-size="24" font-weight="bold" fill="#00ff88">ERROR 404</text>
  <text x="200" y="160" text-anchor="middle" font-family="sans-serif" font-size="16" fill="#ffffff">Sleep Not Found</text>
  <text x="200" y="190" text-anchor="middle" font-family="monospace" font-size="12" fill="#00ff88">Press Any Key to Continue...</text>
</svg>'''
        else:
            return '''<svg width="400" height="300" viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="defaultGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#667eea;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#764ba2;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="400" height="300" fill="url(#defaultGrad)"/>
  <text x="200" y="140" text-anchor="middle" font-family="sans-serif" font-size="20" font-weight="bold" fill="white">Fresh Threads</text>
  <text x="200" y="170" text-anchor="middle" font-family="sans-serif" font-size="14" fill="white">Premium Design</text>
</svg>'''

    def save_design(self, svg_content, category_name, prompt, status="generated"):
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
            "model": "dreamshaper",
            "status": status,
            "timestamp": timestamp,
            "created_at": datetime.now().isoformat(),
            "filepath": str(filepath)
        }

        metadata_file = filepath.with_suffix('.json')
        with open(metadata_file, 'w') as f:
            json.dump(metadata, f, indent=2)

        return filepath, metadata_file

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

        return feedback_file

    def generate_web_interface(self):
        """Generate the main web interface HTML"""
        categories_html = ""
        for key, category in self.categories.items():
            prompts_html = ""
            for i, prompt in enumerate(category["prompts"]):
                prompts_html += f'''
                <div class="prompt-option" data-category="{key}" data-prompt="{prompt}">
                    <span class="prompt-number">{i+1}</span>
                    <span class="prompt-text">{prompt}</span>
                </div>'''

            categories_html += f'''
            <div class="category-card" data-category="{key}">
                <div class="category-header">
                    <span class="category-icon">{category["icon"]}</span>
                    <h3>{category["name"]}</h3>
                </div>
                <div class="prompts-container">
                    {prompts_html}
                </div>
            </div>'''

        return f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fresh Threads Design Generator</title>
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

        .container {{
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
        }}

        .header {{
            background: linear-gradient(135deg, #2d3748 0%, #1a202c 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }}

        .header h1 {{
            font-size: 2.5rem;
            margin-bottom: 10px;
        }}

        .header p {{
            font-size: 1.1rem;
            opacity: 0.9;
        }}

        .content {{
            padding: 40px;
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
            margin-bottom: 30px;
        }}

        .step-title {{
            font-size: 1.8rem;
            color: #2d3748;
            margin-bottom: 10px;
        }}

        .step-subtitle {{
            color: #718096;
            font-size: 1.1rem;
        }}

        .categories-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }}

        .category-card {{
            border: 2px solid #e2e8f0;
            border-radius: 12px;
            padding: 20px;
            cursor: pointer;
            transition: all 0.3s ease;
            background: #f8f9fa;
        }}

        .category-card:hover {{
            border-color: #667eea;
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.15);
        }}

        .category-card.selected {{
            border-color: #667eea;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
        }}

        .category-header {{
            display: flex;
            align-items: center;
            margin-bottom: 15px;
        }}

        .category-icon {{
            font-size: 2rem;
            margin-right: 15px;
        }}

        .category-card h3 {{
            font-size: 1.2rem;
            margin: 0;
        }}

        .prompts-container {{
            display: none;
        }}

        .category-card.selected .prompts-container {{
            display: block;
        }}

        .prompt-option {{
            display: flex;
            align-items: center;
            padding: 10px;
            margin: 5px 0;
            background: rgba(255,255,255,0.1);
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s ease;
        }}

        .prompt-option:hover {{
            background: rgba(255,255,255,0.2);
            transform: translateX(5px);
        }}

        .prompt-option.selected {{
            background: rgba(255,255,255,0.3);
            border: 1px solid rgba(255,255,255,0.5);
        }}

        .prompt-number {{
            background: rgba(255,255,255,0.2);
            color: white;
            border-radius: 50%;
            width: 24px;
            height: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.8rem;
            font-weight: bold;
            margin-right: 10px;
        }}

        .prompt-text {{
            flex: 1;
            font-size: 0.9rem;
        }}

        .custom-prompt {{
            margin-top: 20px;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 12px;
            border: 2px dashed #cbd5e0;
        }}

        .custom-prompt textarea {{
            width: 100%;
            padding: 15px;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            font-size: 1rem;
            resize: vertical;
            min-height: 100px;
        }}

        .buttons {{
            display: flex;
            gap: 20px;
            justify-content: center;
            margin-top: 30px;
        }}

        .btn {{
            padding: 15px 30px;
            border: none;
            border-radius: 50px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
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
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        }}

        .btn:disabled {{
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
        }}

        .design-preview {{
            text-align: center;
            padding: 30px;
            background: #f8f9fa;
            border-radius: 12px;
            margin: 20px 0;
        }}

        .design-container {{
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin: 20px auto;
            max-width: 500px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }}

        .feedback-buttons {{
            display: flex;
            gap: 20px;
            justify-content: center;
            margin-top: 30px;
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

        .loading {{
            text-align: center;
            padding: 50px;
        }}

        .spinner {{
            border: 4px solid #f3f3f3;
            border-top: 4px solid #667eea;
            border-radius: 50%;
            width: 50px;
            height: 50px;
            animation: spin 1s linear infinite;
            margin: 0 auto 20px;
        }}

        @keyframes spin {{
            0% {{ transform: rotate(0deg); }}
            100% {{ transform: rotate(360deg); }}
        }}

        .status-message {{
            padding: 15px;
            border-radius: 8px;
            margin: 20px 0;
            text-align: center;
        }}

        .success {{
            background: #f0fff4;
            color: #22543d;
            border: 1px solid #9ae6b4;
        }}

        .error {{
            background: #fed7d7;
            color: #742a2a;
            border: 1px solid #feb2b2;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎨 Fresh Threads Design Generator</h1>
            <p>Create professional T-shirt designs with DreamShaper AI</p>
        </div>

        <div class="content">
            <!-- Step 1: Category Selection -->
            <div class="step active" id="step1">
                <div class="step-header">
                    <h2 class="step-title">Choose Your Design Category</h2>
                    <p class="step-subtitle">Select a category that matches your vision</p>
                </div>

                <div class="categories-grid">
                    {categories_html}
                </div>

                <div class="custom-prompt">
                    <h4>💡 Or create a custom design:</h4>
                    <textarea id="customPrompt" placeholder="Describe your custom T-shirt design idea..."></textarea>
                </div>

                <div class="buttons">
                    <button class="btn btn-primary" id="generateBtn" onclick="generateDesign()">
                        🎨 Generate Design
                    </button>
                </div>
            </div>

            <!-- Step 2: Design Generation -->
            <div class="step" id="step2">
                <div class="loading">
                    <div class="spinner"></div>
                    <h3>🎨 Creating your design with DreamShaper...</h3>
                    <p>This may take a few moments. Please wait.</p>
                </div>
            </div>

            <!-- Step 3: Design Preview & Feedback -->
            <div class="step" id="step3">
                <div class="step-header">
                    <h2 class="step-title">Your Fresh Design</h2>
                    <p class="step-subtitle">What do you think of this design?</p>
                </div>

                <div class="design-preview">
                    <div class="design-container" id="designContainer">
                        <!-- Generated design will appear here -->
                    </div>
                </div>

                <div class="feedback-buttons">
                    <button class="feedback-btn thumbs-up" onclick="giveFeedback('approved')">
                        👍 <span>Love It!</span>
                    </button>
                    <button class="feedback-btn thumbs-down" onclick="giveFeedback('rejected')">
                        👎 <span>Try Again</span>
                    </button>
                </div>

                <div class="buttons">
                    <button class="btn btn-secondary" onclick="startOver()">
                        🔄 Create Another Design
                    </button>
                </div>
            </div>

            <!-- Step 4: Success -->
            <div class="step" id="step4">
                <div class="step-header">
                    <h2 class="step-title">✅ Design Saved!</h2>
                    <p class="step-subtitle">Your feedback has been recorded</p>
                </div>

                <div id="statusMessage" class="status-message"></div>

                <div class="buttons">
                    <button class="btn btn-primary" onclick="startOver()">
                        🎨 Create Another Design
                    </button>
                    <button class="btn btn-secondary" onclick="viewResults()">
                        📁 View All Designs
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
        let selectedCategory = null;
        let selectedPrompt = null;
        let currentDesign = null;

        // Category selection
        document.querySelectorAll('.category-card').forEach(card => {{
            card.addEventListener('click', function() {{
                // Remove selection from other categories
                document.querySelectorAll('.category-card').forEach(c => c.classList.remove('selected'));
                // Select this category
                this.classList.add('selected');
                selectedCategory = this.dataset.category;
                selectedPrompt = null; // Reset prompt selection

                // Remove selection from all prompts
                document.querySelectorAll('.prompt-option').forEach(p => p.classList.remove('selected'));
            }});
        }});

        // Prompt selection
        document.querySelectorAll('.prompt-option').forEach(option => {{
            option.addEventListener('click', function(e) {{
                e.stopPropagation();
                // Remove selection from other prompts
                document.querySelectorAll('.prompt-option').forEach(p => p.classList.remove('selected'));
                // Select this prompt
                this.classList.add('selected');
                selectedPrompt = this.dataset.prompt;
                selectedCategory = this.dataset.category;
            }});
        }});

        function generateDesign() {{
            let prompt = selectedPrompt;
            let category = selectedCategory;

            // Check for custom prompt
            const customPrompt = document.getElementById('customPrompt').value.trim();
            if (customPrompt) {{
                prompt = customPrompt;
                category = 'custom';
            }}

            if (!prompt) {{
                alert('Please select a design category and prompt, or enter a custom prompt.');
                return;
            }}

            // Show loading step
            showStep('step2');

            // Generate design via API
            fetch('/generate', {{
                method: 'POST',
                headers: {{
                    'Content-Type': 'application/json',
                }},
                body: JSON.stringify({{
                    prompt: prompt,
                    category: category
                }})
            }})
            .then(response => response.json())
            .then(data => {{
                if (data.success) {{
                    currentDesign = data;
                    displayDesign(data.svg_content);
                    showStep('step3');
                }} else {{
                    alert('Error generating design: ' + data.error);
                    showStep('step1');
                }}
            }})
            .catch(error => {{
                console.error('Error:', error);
                alert('Failed to generate design. Please try again.');
                showStep('step1');
            }});
        }}

        function displayDesign(svgContent) {{
            document.getElementById('designContainer').innerHTML = svgContent;
        }}

        function giveFeedback(feedbackType) {{
            if (!currentDesign) return;

            fetch('/feedback', {{
                method: 'POST',
                headers: {{
                    'Content-Type': 'application/json',
                }},
                body: JSON.stringify({{
                    design_id: currentDesign.design_id,
                    feedback_type: feedbackType,
                    feedback_text: feedbackType === 'approved' ? 'User loved the design!' : 'User wants to try again'
                }})
            }})
            .then(response => response.json())
            .then(data => {{
                let message = '';
                let messageClass = '';

                if (feedbackType === 'approved') {{
                    message = '🎉 Awesome! Your design has been saved to the approved folder and is ready for production.';
                    messageClass = 'success';
                }} else {{
                    message = '👍 Thanks for the feedback! This helps us improve future designs.';
                    messageClass = 'success';
                }}

                document.getElementById('statusMessage').innerHTML = message;
                document.getElementById('statusMessage').className = 'status-message ' + messageClass;
                showStep('step4');
            }})
            .catch(error => {{
                console.error('Error:', error);
                alert('Failed to save feedback. Please try again.');
            }});
        }}

        function startOver() {{
            selectedCategory = null;
            selectedPrompt = null;
            currentDesign = null;

            // Reset selections
            document.querySelectorAll('.category-card').forEach(c => c.classList.remove('selected'));
            document.querySelectorAll('.prompt-option').forEach(p => p.classList.remove('selected'));
            document.getElementById('customPrompt').value = '';

            showStep('step1');
        }}

        function viewResults() {{
            window.open('/results', '_blank');
        }}

        function showStep(stepId) {{
            document.querySelectorAll('.step').forEach(step => step.classList.remove('active'));
            document.getElementById(stepId).classList.add('active');
        }}
    </script>
</body>
</html>'''


class WebHandler(BaseHTTPRequestHandler):
    def __init__(self, generator, *args, **kwargs):
        self.generator = generator
        super().__init__(*args, **kwargs)

    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(self.generator.generate_web_interface().encode())
        elif self.path == '/results':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(self.generate_results_page().encode())
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        data = json.loads(post_data.decode('utf-8'))

        if self.path == '/generate':
            # Generate design
            prompt = data.get('prompt')
            category = data.get('category')

            svg_content = self.generator.generate_design_with_dreamshaper(
                prompt, category)

            if svg_content:
                filepath, metadata_file = self.generator.save_design(
                    svg_content, category, prompt
                )

                # Load metadata
                with open(metadata_file, 'r') as f:
                    metadata = json.load(f)

                response = {
                    'success': True,
                    'svg_content': svg_content,
                    'design_id': metadata['timestamp'],
                    'metadata': metadata
                }
            else:
                response = {
                    'success': False,
                    'error': 'Failed to generate design'
                }

        elif self.path == '/feedback':
            # Save feedback
            design_id = data.get('design_id')
            feedback_type = data.get('feedback_type')
            feedback_text = data.get('feedback_text')

            # Find the design metadata
            metadata_files = list(
                self.generator.output_dir.glob(f"*{design_id}.json"))
            if metadata_files:
                with open(metadata_files[0], 'r') as f:
                    metadata = json.load(f)

                # Save feedback
                feedback_file = self.generator.save_feedback(
                    metadata, feedback_type, feedback_text)

                # Move design if approved/rejected
                if feedback_type in ['approved', 'rejected']:
                    svg_file = metadata_files[0].with_suffix('.svg')
                    if svg_file.exists():
                        svg_content = svg_file.read_text()
                        self.generator.save_design(
                            svg_content,
                            metadata['category'],
                            metadata['prompt'],
                            feedback_type
                        )

                response = {'success': True}
            else:
                response = {'success': False, 'error': 'Design not found'}

        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(response).encode())

    def generate_results_page(self):
        # Generate a simple results page showing all designs
        return '''<!DOCTYPE html>
<html>
<head>
    <title>Design Results - Fresh Threads</title>
    <style>
        body { font-family: system-ui; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; }
        .design-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; }
        .design-card { background: white; border-radius: 10px; padding: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .design-preview { text-align: center; margin-bottom: 15px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎨 Fresh Threads Design Gallery</h1>
        <p>All your generated designs are saved in the design-output folder.</p>
        <div class="design-grid">
            <div class="design-card">
                <h3>📁 Approved Designs</h3>
                <p>Ready for production</p>
            </div>
            <div class="design-card">
                <h3>📁 All Designs</h3>
                <p>Complete design history</p>
            </div>
            <div class="design-card">
                <h3>💬 Feedback Data</h3>
                <p>User feedback for learning</p>
            </div>
        </div>
    </div>
</body>
</html>'''

    def log_message(self, format, *args):
        # Suppress default logging
        pass


def create_handler(generator):
    return lambda *args, **kwargs: WebHandler(generator, *args, **kwargs)


def main():
    generator = WebDesignGenerator()

    # Start web server
    port = 8080
    handler = create_handler(generator)

    try:
        server = HTTPServer(('localhost', port), handler)
        print(f"\n🚀 Fresh Threads Design Generator")
        print(f"🌐 Web interface: http://localhost:{port}")
        print(f"🎨 Using DreamShaper model for generation")
        print(f"📁 Designs saved to: {generator.output_dir}")
        print(f"\n💡 Open your browser and start designing!")
        print(f"⏹️  Press Ctrl+C to stop the server")

        # Open browser
        webbrowser.open(f'http://localhost:{port}')

        # Start server
        server.serve_forever()

    except KeyboardInterrupt:
        print(f"\n👋 Server stopped. Designs saved in {generator.output_dir}")
    except Exception as e:
        print(f"❌ Server error: {e}")


if __name__ == "__main__":
    main()
