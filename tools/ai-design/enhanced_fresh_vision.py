#!/usr/bin/env python3
"""
Fresh Threads LLC - Enhanced FreshVision AI Web Interface
Multi-AI Platform Support: ComfyUI + Pollinations AI + Galaxy.ai
"""

import json
import time
import requests
import asyncio
import aiohttp
from datetime import datetime
from pathlib import Path
from http.server import HTTPServer, BaseHTTPRequestHandler
import webbrowser
import threading
import cgi
import io
import base64
from urllib.parse import quote
import hashlib

# Try to import existing ComfyUI pipeline, fallback if not available
try:
    from comfyui_advanced_pipeline import ComfyUIAdvancedPipeline
    COMFYUI_AVAILABLE = True
except ImportError:
    COMFYUI_AVAILABLE = False
    print("ComfyUI pipeline not available, using AI-only mode")


class PollinationsAI:
    """Pollinations AI integration for image generation"""

    def __init__(self):
        self.base_url = "https://image.pollinations.ai/prompt"
        self.session = requests.Session()

    def generate_image(self, prompt: str, width: int = 1024, height: int = 1024,
                       model: str = "flux", seed: int = None) -> dict:
        """Generate image using Pollinations AI"""
        try:
            # Construct URL with parameters
            params = {
                'width': width,
                'height': height,
                'model': model,
                'enhance': 'true',
                'nologo': 'true'
            }

            if seed:
                params['seed'] = seed

            # Encode prompt for URL
            encoded_prompt = quote(prompt)
            url = f"{self.base_url}/{encoded_prompt}"

            print(f"🎨 Generating with Pollinations AI: {prompt[:50]}...")

            response = self.session.get(url, params=params, timeout=60)

            if response.status_code == 200:
                # Create unique filename
                timestamp = int(time.time())
                filename = f"pollinations_{timestamp}.png"

                return {
                    'status': 'success',
                    'image_data': response.content,
                    'filename': filename,
                    'prompt': prompt,
                    'service': 'Pollinations AI',
                    'model': model,
                    'dimensions': f"{width}x{height}"
                }
            else:
                return {
                    'status': 'error',
                    'message': f'HTTP {response.status_code}: {response.text}'
                }

        except Exception as e:
            return {
                'status': 'error',
                'message': f'Pollinations AI error: {str(e)}'
            }


class GalaxyAI:
    """Galaxy.ai integration for image generation"""

    def __init__(self):
        self.base_url = "https://api.galaxy.ai/v1/images"
        self.session = requests.Session()
        # Note: Galaxy.ai typically requires API key - this is a placeholder implementation

    def generate_image(self, prompt: str, width: int = 1024, height: int = 1024,
                       style: str = "realistic", quality: str = "high") -> dict:
        """Generate image using Galaxy.ai (placeholder implementation)"""
        try:
            # This is a placeholder - actual Galaxy.ai API would require authentication
            print(f"🌌 Generating with Galaxy.ai: {prompt[:50]}...")

            # For now, create a placeholder response
            # In real implementation, this would make actual API calls
            timestamp = int(time.time())
            filename = f"galaxy_ai_{timestamp}.png"

            # Simulate Galaxy.ai generation with a delay
            time.sleep(3)

            return {
                'status': 'placeholder',
                'message': 'Galaxy.ai integration ready - requires API key setup',
                'filename': filename,
                'prompt': prompt,
                'service': 'Galaxy.ai',
                'style': style,
                'dimensions': f"{width}x{height}"
            }

        except Exception as e:
            return {
                'status': 'error',
                'message': f'Galaxy.ai error: {str(e)}'
            }


class EnhancedFreshVisionInterface:
    """Enhanced FreshVision with multi-AI platform support"""

    def __init__(self):
        # Initialize AI services
        self.pollinations = PollinationsAI()
        self.galaxy = GalaxyAI()

        # Initialize ComfyUI if available
        if COMFYUI_AVAILABLE:
            self.comfyui = ComfyUIAdvancedPipeline()
        else:
            self.comfyui = None

        self.current_generation = None
        self.generation_history = []

        # T-shirt design themes optimized for AI generation
        self.design_themes = {
            'minimalist': {
                'base_concept': 'Clean, simple designs with focus on typography and basic shapes',
                'style_keywords': ['minimalist', 'clean', 'simple', 'geometric', 'typography'],
                'color_palette': 'Monochrome, black and white, single accent colors',
                'ai_prompts': {
                    'pollinations': 'minimalist design, clean typography, simple geometric shapes, black and white, high contrast',
                    'galaxy': 'minimalistic t-shirt design, clean lines, simple typography, monochrome'
                }
            },
            'vintage_retro': {
                'base_concept': 'Nostalgic designs with retro aesthetics and vintage typography',
                'style_keywords': ['vintage', 'retro', 'nostalgic', 'aged', 'classic'],
                'color_palette': 'Muted earth tones, sepia, vintage poster colors',
                'ai_prompts': {
                    'pollinations': 'vintage retro design, aged typography, nostalgic colors, classic poster style',
                    'galaxy': 'retro vintage t-shirt design, classic typography, muted colors, aged aesthetic'
                }
            },
            'nature_outdoor': {
                'base_concept': 'Nature-inspired designs for outdoor enthusiasts',
                'style_keywords': ['nature', 'outdoor', 'mountains', 'forest', 'adventure'],
                'color_palette': 'Earth tones, forest greens, sky blues, natural colors',
                'ai_prompts': {
                    'pollinations': 'nature outdoor design, mountains, forest, adventure theme, earth tones',
                    'galaxy': 'outdoor nature t-shirt design, mountain landscape, forest elements, natural colors'
                }
            },
            'urban_street': {
                'base_concept': 'Modern urban and street-style designs',
                'style_keywords': ['urban', 'street', 'modern', 'graffiti', 'city'],
                'color_palette': 'Bold contrasts, neon accents, black, white, bright colors',
                'ai_prompts': {
                    'pollinations': 'urban street design, modern graffiti style, bold colors, city aesthetics',
                    'galaxy': 'street art t-shirt design, urban graphics, bold typography, modern city style'
                }
            },
            'abstract_artistic': {
                'base_concept': 'Creative abstract designs with artistic flair',
                'style_keywords': ['abstract', 'artistic', 'creative', 'colorful', 'expressive'],
                'color_palette': 'Vibrant colors, gradients, artistic color combinations',
                'ai_prompts': {
                    'pollinations': 'abstract artistic design, colorful patterns, creative shapes, vibrant gradients',
                    'galaxy': 'abstract art t-shirt design, creative patterns, vibrant colors, artistic expression'
                }
            }
        }

    def create_enhanced_web_interface(self):
        """Generate the enhanced web interface HTML with multi-AI support"""

        themes_html = ""
        for key, theme_data in self.design_themes.items():
            themes_html += f'''
            <div class="theme-card" data-theme="{key}">
                <div class="theme-header">
                    <h3>{key.replace('_', ' ').title()}</h3>
                </div>
                <div class="theme-description">
                    <p><strong>Style:</strong> {theme_data['base_concept']}</p>
                    <p><strong>Keywords:</strong> {', '.join(theme_data['style_keywords'][:3])}...</p>
                    <p><strong>Colors:</strong> {theme_data['color_palette']}</p>
                </div>
            </div>'''

        # AI service status
        ai_services_status = f'''
        <div class="ai-services-status">
            <h3>Available AI Services</h3>
            <div class="service-status">
                <span class="status-indicator {'active' if COMFYUI_AVAILABLE else 'inactive'}"></span>
                <strong>ComfyUI</strong> - {('Available' if COMFYUI_AVAILABLE else 'Not Available')}
            </div>
            <div class="service-status">
                <span class="status-indicator active"></span>
                <strong>Pollinations AI</strong> - Available
            </div>
            <div class="service-status">
                <span class="status-indicator placeholder"></span>
                <strong>Galaxy.ai</strong> - Ready (requires API key)
            </div>
        </div>
        '''

        return f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FreshThreads LLC - Enhanced FreshVision AI Designer</title>

    <!-- Favicon -->
    <link rel="icon" type="image/png" href="assets/Fresh_ThreadsLLCLogo.png">
    <link rel="icon" type="image/png" sizes="32x32" href="assets/Fresh_ThreadsLLCLogo.png">
    <link rel="apple-touch-icon" href="assets/Fresh_ThreadsLLCLogo.png">
    <meta name="theme-color" content="#000000">

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Space+Grotesk:wght@400;500;600;700&display=swap" rel="stylesheet">

    <!-- Existing Styles -->
    <link rel="stylesheet" href="styles/minimalistic.css">

    <!-- Enhanced AI Interface Styling -->
    <style>
        :root {{
            --primary-color: #000000;
            --secondary-color: #ffffff;
            --accent-color: #4f46e5;
            --success-color: #10b981;
            --warning-color: #f59e0b;
            --error-color: #ef4444;
            --gray-50: #f9fafb;
            --gray-100: #f3f4f6;
            --gray-200: #e5e7eb;
            --gray-300: #d1d5db;
            --gray-400: #9ca3af;
            --gray-500: #6b7280;
            --gray-600: #4b5563;
            --gray-700: #374151;
            --gray-800: #1f2937;
            --gray-900: #111827;
        }}

        body {{
            background: var(--secondary-color);
            color: var(--gray-900);
            font-family: 'Inter', sans-serif;
            line-height: 1.6;
        }}

        .enhanced-ai-container {{
            max-width: 1400px;
            margin: 0 auto;
            padding: 2rem;
            min-height: 100vh;
        }}

        .enhanced-ai-header {{
            background: linear-gradient(135deg, var(--primary-color), var(--gray-800));
            color: var(--secondary-color);
            border-radius: 1rem;
            padding: 3rem 2rem;
            text-align: center;
            margin-bottom: 3rem;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
        }}

        .enhanced-ai-header h1 {{
            font-family: 'Space Grotesk', sans-serif;
            font-size: 3rem;
            font-weight: 700;
            margin-bottom: 1rem;
            text-transform: uppercase;
            letter-spacing: 2px;
            background: linear-gradient(45deg, #fff, #e5e7eb);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }}

        .ai-services-status {{
            background: var(--gray-50);
            border: 1px solid var(--gray-200);
            border-radius: 0.75rem;
            padding: 1.5rem;
            margin: 2rem 0;
        }}

        .ai-services-status h3 {{
            color: var(--gray-900);
            margin-bottom: 1rem;
            font-weight: 600;
        }}

        .service-status {{
            display: flex;
            align-items: center;
            gap: 0.75rem;
            margin-bottom: 0.5rem;
            padding: 0.5rem 0;
        }}

        .status-indicator {{
            width: 12px;
            height: 12px;
            border-radius: 50%;
            display: inline-block;
        }}

        .status-indicator.active {{
            background: var(--success-color);
            box-shadow: 0 0 0 2px rgba(16, 185, 129, 0.2);
        }}

        .status-indicator.inactive {{
            background: var(--gray-400);
        }}

        .status-indicator.placeholder {{
            background: var(--warning-color);
            box-shadow: 0 0 0 2px rgba(245, 158, 11, 0.2);
        }}

        .ai-service-selector {{
            background: var(--secondary-color);
            border: 1px solid var(--gray-200);
            border-radius: 0.75rem;
            padding: 2rem;
            margin: 2rem 0;
        }}

        .service-options {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
            margin-top: 1.5rem;
        }}

        .service-option {{
            border: 2px solid var(--gray-200);
            border-radius: 0.75rem;
            padding: 1.5rem;
            cursor: pointer;
            transition: all 0.2s ease;
            position: relative;
        }}

        .service-option:hover {{
            border-color: var(--accent-color);
            box-shadow: 0 4px 12px rgba(79, 70, 229, 0.15);
        }}

        .service-option input[type="radio"] {{
            position: absolute;
            opacity: 0;
            width: 100%;
            height: 100%;
            margin: 0;
            cursor: pointer;
        }}

        .service-option input[type="radio"]:checked + .service-content {{
            border-color: var(--accent-color);
            background: rgba(79, 70, 229, 0.05);
        }}

        .service-option.selected {{
            border-color: var(--accent-color);
            background: rgba(79, 70, 229, 0.05);
        }}

        .service-content {{
            pointer-events: none;
        }}

        .service-title {{
            font-weight: 600;
            color: var(--gray-900);
            margin-bottom: 0.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }}

        .service-description {{
            color: var(--gray-600);
            font-size: 0.875rem;
            margin-bottom: 1rem;
        }}

        .service-features {{
            list-style: none;
            padding: 0;
            margin: 0;
        }}

        .service-features li {{
            color: var(--gray-500);
            font-size: 0.75rem;
            margin-bottom: 0.25rem;
            padding-left: 1rem;
            position: relative;
        }}

        .service-features li:before {{
            content: "✓";
            position: absolute;
            left: 0;
            color: var(--success-color);
            font-weight: bold;
        }}

        .enhanced-form-section {{
            background: var(--secondary-color);
            border: 1px solid var(--gray-200);
            border-radius: 0.75rem;
            padding: 2rem;
            margin: 2rem 0;
        }}

        .enhanced-form-group {{
            margin-bottom: 1.5rem;
        }}

        .enhanced-form-label {{
            display: block;
            color: var(--gray-900);
            font-weight: 600;
            margin-bottom: 0.5rem;
        }}

        .enhanced-form-input {{
            width: 100%;
            padding: 1rem;
            border: 1px solid var(--gray-300);
            border-radius: 0.5rem;
            font-size: 1rem;
            transition: border-color 0.2s ease;
            font-family: inherit;
        }}

        .enhanced-form-input:focus {{
            outline: none;
            border-color: var(--accent-color);
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
        }}

        .enhanced-form-textarea {{
            min-height: 120px;
            resize: vertical;
        }}

        .enhanced-btn {{
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            padding: 1rem 2rem;
            border: none;
            border-radius: 0.5rem;
            font-family: 'Space Grotesk', sans-serif;
            font-weight: 600;
            font-size: 1rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            cursor: pointer;
            transition: all 0.2s ease;
            text-decoration: none;
            min-width: 140px;
        }}

        .enhanced-btn-primary {{
            background: var(--primary-color);
            color: var(--secondary-color);
        }}

        .enhanced-btn-primary:hover {{
            background: var(--gray-800);
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }}

        .enhanced-btn-secondary {{
            background: var(--secondary-color);
            color: var(--primary-color);
            border: 2px solid var(--gray-300);
        }}

        .enhanced-btn-secondary:hover {{
            border-color: var(--primary-color);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }}

        .enhanced-buttons {{
            display: flex;
            gap: 1rem;
            justify-content: center;
            margin-top: 2rem;
            flex-wrap: wrap;
        }}

        .enhanced-progress-section {{
            background: var(--gray-50);
            border: 1px solid var(--gray-200);
            border-radius: 0.75rem;
            padding: 2rem;
            margin: 2rem 0;
            text-align: center;
            display: none;
        }}

        .enhanced-progress-bar {{
            width: 100%;
            height: 12px;
            background: var(--gray-200);
            border-radius: 6px;
            margin: 1rem 0;
            overflow: hidden;
        }}

        .enhanced-progress-fill {{
            height: 100%;
            background: linear-gradient(90deg, var(--accent-color), var(--success-color));
            border-radius: 6px;
            width: 0%;
            transition: width 0.3s ease;
        }}

        .enhanced-results-section {{
            background: var(--secondary-color);
            border: 1px solid var(--gray-200);
            border-radius: 0.75rem;
            padding: 2rem;
            margin: 2rem 0;
            display: none;
        }}

        .result-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin-top: 1.5rem;
        }}

        .result-item {{
            background: var(--gray-50);
            border: 1px solid var(--gray-200);
            border-radius: 0.75rem;
            padding: 1.5rem;
            text-align: center;
        }}

        .result-image {{
            width: 100%;
            height: 200px;
            object-fit: cover;
            border-radius: 0.5rem;
            border: 1px solid var(--gray-200);
            margin-bottom: 1rem;
        }}

        .result-info {{
            text-align: left;
            margin-top: 1rem;
        }}

        .result-info h4 {{
            color: var(--gray-900);
            margin-bottom: 0.5rem;
        }}

        .result-info p {{
            color: var(--gray-600);
            font-size: 0.875rem;
            margin-bottom: 0.25rem;
        }}

        @media (max-width: 768px) {{
            .enhanced-ai-container {{
                padding: 1rem;
            }}

            .enhanced-ai-header h1 {{
                font-size: 2rem;
            }}

            .service-options {{
                grid-template-columns: 1fr;
            }}

            .enhanced-buttons {{
                flex-direction: column;
                align-items: center;
            }}
        }}
    </style>
</head>
<body>
    <div class="enhanced-ai-container">
        <div class="enhanced-ai-header">
            <div class="logo-container" style="margin-bottom: 2rem;">
                <img src="assets/Fresh_ThreadsLLCLogo.png" alt="Fresh Threads LLC" style="max-height: 80px; width: auto; object-fit: contain;">
            </div>
            <h1>Enhanced FreshVision AI</h1>
            <p style="font-size: 1.25rem; opacity: 0.9; margin-bottom: 1rem;">Multi-AI Platform Design Generation</p>
            <p style="font-size: 1rem; opacity: 0.7;">ComfyUI • Pollinations AI • Galaxy.ai</p>
        </div>

        {ai_services_status}

        <!-- AI Service Selection -->
        <div class="ai-service-selector">
            <h2 style="color: var(--gray-900); margin-bottom: 1rem;">Choose AI Service</h2>
            <p style="color: var(--gray-600); margin-bottom: 1.5rem;">Select the AI service for your design generation</p>

            <div class="service-options">
                <div class="service-option {'disabled' if not COMFYUI_AVAILABLE else ''}" style="{'opacity: 0.5; pointer-events: none;' if not COMFYUI_AVAILABLE else ''}">
                    <input type="radio" name="aiService" value="comfyui" id="serviceComfyUI" {'disabled' if not COMFYUI_AVAILABLE else ''}>
                    <div class="service-content">
                        <div class="service-title">
                            <span>🎨</span> ComfyUI Advanced
                        </div>
                        <div class="service-description">
                            High-end local AI with ControlNet, DreamShaperXL, and advanced pipeline control
                        </div>
                        <ul class="service-features">
                            <li>Local processing for privacy</li>
                            <li>ControlNet reference image support</li>
                            <li>Professional quality outputs</li>
                            <li>Custom model support</li>
                        </ul>
                    </div>
                </div>

                <div class="service-option">
                    <input type="radio" name="aiService" value="pollinations" id="servicePollinations" checked>
                    <div class="service-content">
                        <div class="service-title">
                            <span>🌸</span> Pollinations AI
                        </div>
                        <div class="service-description">
                            Fast, cloud-based AI image generation with multiple models and styles
                        </div>
                        <ul class="service-features">
                            <li>Fast generation (~10 seconds)</li>
                            <li>Multiple AI models available</li>
                            <li>High resolution support</li>
                            <li>No setup required</li>
                        </ul>
                    </div>
                </div>

                <div class="service-option">
                    <input type="radio" name="aiService" value="galaxy" id="serviceGalaxy">
                    <div class="service-content">
                        <div class="service-title">
                            <span>🌌</span> Galaxy.ai
                        </div>
                        <div class="service-description">
                            Professional AI platform with advanced style controls and commercial licensing
                        </div>
                        <ul class="service-features">
                            <li>Commercial use licensing</li>
                            <li>Advanced style controls</li>
                            <li>Professional quality</li>
                            <li>API key required</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>

        <!-- Theme Selection -->
        <div class="enhanced-form-section">
            <h2 style="color: var(--gray-900); margin-bottom: 1rem;">Design Theme</h2>
            <div class="themes-grid" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1rem;">
                {themes_html}
            </div>
        </div>

        <!-- Design Configuration -->
        <div class="enhanced-form-section">
            <h2 style="color: var(--gray-900); margin-bottom: 1rem;">Design Configuration</h2>

            <div class="enhanced-form-group">
                <label class="enhanced-form-label">Design Concept</label>
                <textarea class="enhanced-form-input enhanced-form-textarea" id="enhancedDesignConcept"
                          placeholder="Describe your t-shirt design concept. The AI will create a unique design based on your description and selected theme..."></textarea>
            </div>

            <div class="enhanced-form-group">
                <label class="enhanced-form-label">Image Dimensions</label>
                <select class="enhanced-form-input" id="imageDimensions">
                    <option value="1024x1024">Square (1024x1024) - Recommended for t-shirts</option>
                    <option value="1024x1280">Portrait (1024x1280) - Tall designs</option>
                    <option value="1280x1024">Landscape (1280x1024) - Wide designs</option>
                    <option value="512x512">Small Square (512x512) - Fast generation</option>
                </select>
            </div>

            <div class="enhanced-form-group">
                <label class="enhanced-form-label">Generation Quality</label>
                <select class="enhanced-form-input" id="generationQuality">
                    <option value="high">High Quality - Best results, slower generation</option>
                    <option value="standard" selected>Standard Quality - Good balance of speed and quality</option>
                    <option value="fast">Fast Generation - Quick results, lower quality</option>
                </select>
            </div>

            <!-- AI Service Specific Options -->
            <div id="pollinationsOptions" class="ai-service-options">
                <div class="enhanced-form-group">
                    <label class="enhanced-form-label">Pollinations Model</label>
                    <select class="enhanced-form-input" id="pollinationsModel">
                        <option value="flux">Flux - Latest and most capable</option>
                        <option value="turbo">Turbo - Fast generation</option>
                        <option value="stable-diffusion">Stable Diffusion - Classic model</option>
                    </select>
                </div>
            </div>

            <div id="galaxyOptions" class="ai-service-options" style="display: none;">
                <div class="enhanced-form-group">
                    <label class="enhanced-form-label">Galaxy.ai Style</label>
                    <select class="enhanced-form-input" id="galaxyStyle">
                        <option value="realistic">Realistic</option>
                        <option value="artistic">Artistic</option>
                        <option value="cartoon">Cartoon</option>
                        <option value="abstract">Abstract</option>
                    </select>
                </div>

                <div class="enhanced-form-group">
                    <label class="enhanced-form-label">Galaxy.ai API Key</label>
                    <input type="password" class="enhanced-form-input" id="galaxyApiKey" placeholder="Enter your Galaxy.ai API key">
                    <p style="font-size: 0.875rem; color: var(--gray-500); margin-top: 0.5rem;">
                        Get your API key from <a href="https://galaxy.ai" target="_blank">galaxy.ai</a>
                    </p>
                </div>
            </div>
        </div>

        <!-- Generate Button -->
        <div class="enhanced-buttons">
            <button class="enhanced-btn enhanced-btn-primary" onclick="generateEnhancedDesign()">
                <span>🎨</span> Generate Design
            </button>
            <button class="enhanced-btn enhanced-btn-secondary" onclick="clearResults()">
                <span>🗑️</span> Clear Results
            </button>
        </div>

        <!-- Progress Section -->
        <div class="enhanced-progress-section" id="enhancedProgressSection">
            <h3 id="enhancedProgressTitle">Generating Design...</h3>
            <div class="enhanced-progress-bar">
                <div class="enhanced-progress-fill" id="enhancedProgressFill"></div>
            </div>
            <p id="enhancedProgressText">Initializing AI generation...</p>
        </div>

        <!-- Results Section -->
        <div class="enhanced-results-section" id="enhancedResultsSection">
            <h3>Generated Designs</h3>
            <div class="result-grid" id="enhancedResultsGrid">
                <!-- Results will be populated here -->
            </div>
        </div>
    </div>

    <script>
        // Enhanced JavaScript functionality
        let currentGeneration = null;
        let generationHistory = [];

        // Service option handling
        document.querySelectorAll('input[name="aiService"]').forEach(radio => {{
            radio.addEventListener('change', function() {{
                // Update UI based on selected service
                document.querySelectorAll('.service-option').forEach(option => {{
                    option.classList.remove('selected');
                }});
                this.closest('.service-option').classList.add('selected');

                // Show/hide service-specific options
                document.querySelectorAll('.ai-service-options').forEach(options => {{
                    options.style.display = 'none';
                }});

                const selectedService = this.value;
                const optionsElement = document.getElementById(selectedService + 'Options');
                if (optionsElement) {{
                    optionsElement.style.display = 'block';
                }}
            }});
        }});

        // Initialize default service selection
        document.addEventListener('DOMContentLoaded', function() {{
            const defaultRadio = document.querySelector('input[name="aiService"]:checked');
            if (defaultRadio) {{
                defaultRadio.dispatchEvent(new Event('change'));
            }}
        }});

        // Theme selection handling
        document.querySelectorAll('.theme-card').forEach(card => {{
            card.addEventListener('click', function() {{
                document.querySelectorAll('.theme-card').forEach(c => c.classList.remove('selected'));
                this.classList.add('selected');

                const theme = this.dataset.theme;
                const concept = document.getElementById('enhancedDesignConcept');

                // Auto-populate concept based on theme if empty
                if (!concept.value.trim()) {{
                    const themePrompts = {{
                        'minimalist': 'Create a clean, minimalist design with simple geometric shapes and elegant typography',
                        'vintage_retro': 'Design a vintage-style graphic with retro typography and aged aesthetic',
                        'nature_outdoor': 'Create an outdoor adventure design featuring mountains, trees, or nature elements',
                        'urban_street': 'Design a modern street art style graphic with bold typography and urban elements',
                        'abstract_artistic': 'Create an abstract artistic design with colorful patterns and creative shapes'
                    }};

                    if (themePrompts[theme]) {{
                        concept.value = themePrompts[theme];
                    }}
                }}
            }});
        }});

        async function generateEnhancedDesign() {{
            const selectedService = document.querySelector('input[name="aiService"]:checked');
            if (!selectedService) {{
                alert('Please select an AI service');
                return;
            }}

            const concept = document.getElementById('enhancedDesignConcept').value.trim();
            if (!concept) {{
                alert('Please enter a design concept');
                return;
            }}

            const selectedTheme = document.querySelector('.theme-card.selected');
            const dimensions = document.getElementById('imageDimensions').value;
            const quality = document.getElementById('generationQuality').value;

            // Show progress
            showProgress('Generating design with ' + selectedService.value + '...');

            try {{
                const formData = new FormData();
                formData.append('action', 'generate_enhanced');
                formData.append('service', selectedService.value);
                formData.append('concept', concept);
                formData.append('theme', selectedTheme ? selectedTheme.dataset.theme : '');
                formData.append('dimensions', dimensions);
                formData.append('quality', quality);

                // Add service-specific parameters
                if (selectedService.value === 'pollinations') {{
                    formData.append('model', document.getElementById('pollinationsModel').value);
                }} else if (selectedService.value === 'galaxy') {{
                    formData.append('style', document.getElementById('galaxyStyle').value);
                    formData.append('apiKey', document.getElementById('galaxyApiKey').value);
                }}

                const response = await fetch('/generate', {{
                    method: 'POST',
                    body: formData
                }});

                const result = await response.json();

                if (result.status === 'success') {{
                    displayResults([result]);
                    generationHistory.unshift(result);
                }} else {{
                    throw new Error(result.message || 'Generation failed');
                }}

            }} catch (error) {{
                hideProgress();
                alert('Error generating design: ' + error.message);
            }}
        }}

        function showProgress(message) {{
            const progressSection = document.getElementById('enhancedProgressSection');
            const progressTitle = document.getElementById('enhancedProgressTitle');
            const progressText = document.getElementById('enhancedProgressText');
            const progressFill = document.getElementById('enhancedProgressFill');

            progressTitle.textContent = 'Generating Design...';
            progressText.textContent = message;
            progressSection.style.display = 'block';

            // Simulate progress
            let progress = 0;
            const interval = setInterval(() => {{
                progress += Math.random() * 15;
                if (progress > 90) progress = 90;
                progressFill.style.width = progress + '%';
            }}, 500);

            // Store interval for cleanup
            progressSection.dataset.interval = interval;
        }}

        function hideProgress() {{
            const progressSection = document.getElementById('enhancedProgressSection');
            const interval = progressSection.dataset.interval;
            if (interval) {{
                clearInterval(interval);
            }}
            progressSection.style.display = 'none';
        }}

        function displayResults(results) {{
            hideProgress();

            const resultsSection = document.getElementById('enhancedResultsSection');
            const resultsGrid = document.getElementById('enhancedResultsGrid');

            resultsGrid.innerHTML = '';

            results.forEach((result, index) => {{
                const resultItem = document.createElement('div');
                resultItem.className = 'result-item';

                let imageHtml = '';
                if (result.image_data) {{
                    const base64Image = btoa(String.fromCharCode(...new Uint8Array(result.image_data)));
                    imageHtml = `<img src="data:image/png;base64,${{base64Image}}" alt="Generated design" class="result-image">`;
                }} else if (result.image_url) {{
                    imageHtml = `<img src="${{result.image_url}}" alt="Generated design" class="result-image">`;
                }} else {{
                    imageHtml = `<div class="result-image" style="display: flex; align-items: center; justify-content: center; background: var(--gray-100); color: var(--gray-500);">Preview not available</div>`;
                }}

                resultItem.innerHTML = `
                    ${{imageHtml}}
                    <div class="result-info">
                        <h4>${{result.service || 'AI Generated'}} Design</h4>
                        <p><strong>Prompt:</strong> ${{(result.prompt || '').substring(0, 100)}}...</p>
                        <p><strong>Dimensions:</strong> ${{result.dimensions || 'Unknown'}}</p>
                        <p><strong>Model:</strong> ${{result.model || result.style || 'Default'}}</p>
                        <p><strong>Status:</strong> ${{result.status}}</p>
                    </div>
                    <div class="enhanced-buttons">
                        <button class="enhanced-btn enhanced-btn-secondary enhanced-btn-small" onclick="downloadResult(${{index}})">
                            <span>⬇️</span> Download
                        </button>
                    </div>
                `;

                resultsGrid.appendChild(resultItem);
            }});

            resultsSection.style.display = 'block';
        }}

        function downloadResult(index) {{
            // Implementation for downloading results
            alert('Download functionality would be implemented here for result ' + index);
        }}

        function clearResults() {{
            document.getElementById('enhancedResultsSection').style.display = 'none';
            document.getElementById('enhancedResultsGrid').innerHTML = '';
            hideProgress();
        }}

        // Add some theme card styling
        const style = document.createElement('style');
        style.textContent = `
            .theme-card {{
                border: 2px solid var(--gray-200);
                border-radius: 0.75rem;
                padding: 1.5rem;
                cursor: pointer;
                transition: all 0.2s ease;
                background: var(--secondary-color);
            }}

            .theme-card:hover {{
                border-color: var(--accent-color);
                box-shadow: 0 4px 12px rgba(79, 70, 229, 0.15);
            }}

            .theme-card.selected {{
                border-color: var(--accent-color);
                background: rgba(79, 70, 229, 0.05);
            }}

            .theme-header h3 {{
                color: var(--gray-900);
                margin-bottom: 1rem;
                font-weight: 600;
            }}

            .theme-description p {{
                color: var(--gray-600);
                font-size: 0.875rem;
                margin-bottom: 0.5rem;
            }}
        `;
        document.head.appendChild(style);
    </script>
</body>
</html>'''

    def generate_with_service(self, service: str, prompt: str, **kwargs) -> dict:
        """Generate design with specified AI service"""

        if service == 'pollinations':
            return self.pollinations.generate_image(
                prompt=prompt,
                width=kwargs.get('width', 1024),
                height=kwargs.get('height', 1024),
                model=kwargs.get('model', 'flux')
            )

        elif service == 'galaxy':
            return self.galaxy.generate_image(
                prompt=prompt,
                width=kwargs.get('width', 1024),
                height=kwargs.get('height', 1024),
                style=kwargs.get('style', 'realistic')
            )

        elif service == 'comfyui' and self.comfyui:
            # Use existing ComfyUI pipeline
            return {
                'status': 'success',
                'message': 'ComfyUI generation would be handled by existing pipeline',
                'service': 'ComfyUI'
            }

        else:
            return {
                'status': 'error',
                'message': f'Service {service} not available'
            }


class EnhancedWebHandler(BaseHTTPRequestHandler):
    """Enhanced HTTP handler with multi-AI support"""

    def __init__(self, *args, interface=None, **kwargs):
        self.interface = interface
        super().__init__(*args, **kwargs)

    def do_GET(self):
        """Handle GET requests"""
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(
                self.interface.create_enhanced_web_interface().encode())
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        """Handle POST requests for AI generation"""
        if self.path == '/generate':
            try:
                # Parse form data
                content_type = self.headers['content-type']
                if content_type and content_type.startswith('multipart/form-data'):
                    form = cgi.FieldStorage(fp=self.rfile, headers=self.headers, environ={
                                            'REQUEST_METHOD': 'POST'})

                    action = form.getvalue('action')
                    if action == 'generate_enhanced':
                        service = form.getvalue('service', 'pollinations')
                        concept = form.getvalue('concept', '')
                        theme = form.getvalue('theme', '')
                        dimensions = form.getvalue('dimensions', '1024x1024')
                        quality = form.getvalue('quality', 'standard')

                        # Parse dimensions
                        width, height = map(int, dimensions.split('x'))

                        # Build enhanced prompt
                        theme_data = self.interface.design_themes.get(
                            theme, {})
                        ai_prompts = theme_data.get('ai_prompts', {})
                        base_prompt = ai_prompts.get(service, concept)

                        enhanced_prompt = f"{concept}, {base_prompt}, t-shirt design, high quality, professional"

                        # Generate with selected service
                        kwargs = {
                            'width': width,
                            'height': height,
                            'model': form.getvalue('model', 'flux'),
                            'style': form.getvalue('style', 'realistic'),
                        }

                        result = self.interface.generate_with_service(
                            service, enhanced_prompt, **kwargs)

                        # Return JSON response
                        self.send_response(200)
                        self.send_header('Content-type', 'application/json')
                        self.end_headers()
                        self.wfile.write(json.dumps(result).encode())

                    else:
                        self.send_response(400)
                        self.end_headers()
                        self.wfile.write(b'Invalid action')

                else:
                    self.send_response(400)
                    self.end_headers()
                    self.wfile.write(b'Invalid content type')

            except Exception as e:
                self.send_response(500)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                error_response = {
                    'status': 'error',
                    'message': f'Server error: {str(e)}'
                }
                self.wfile.write(json.dumps(error_response).encode())

        else:
            self.send_response(404)
            self.end_headers()


def run_enhanced_server():
    """Run the enhanced FreshVision server"""
    interface = EnhancedFreshVisionInterface()

    def handler(*args, **kwargs):
        EnhancedWebHandler(*args, interface=interface, **kwargs)

    server = HTTPServer(('localhost', 8081), handler)

    print(f"🚀 Enhanced FreshVision AI Designer starting on http://localhost:8081")
    print(f"📡 Available AI Services:")
    print(
        f"  • ComfyUI: {'✅ Available' if COMFYUI_AVAILABLE else '❌ Not Available'}")
    print(f"  • Pollinations AI: ✅ Available")
    print(f"  • Galaxy.ai: ⚠️ Ready (requires API key)")

    # Open browser
    webbrowser.open('http://localhost:8081')

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n👋 Shutting down Enhanced FreshVision AI Designer...")
        server.shutdown()


if __name__ == '__main__':
    run_enhanced_server()
