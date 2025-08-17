#!/usr/bin/env python3
"""
Fresh Threads LLC - FreshVision AI Web Interface
Advanced pipeline with DreamShaperXL Turbo + ControlNet + Dolphin Llama 3
Enhanced with Pollinations AI + Galaxy.ai
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
from comfyui_advanced_pipeline import ComfyUIAdvancedPipeline


class PollinationsAI:
    """Pollinations AI integration for image generation"""

    def __init__(self):
        self.base_url = "https://image.pollinations.ai/prompt"
        self.session = requests.Session()

    def generate_image(self, prompt: str, width: int = 512, height: int = 512,
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

            param_str = '&'.join([f'{k}={v}' for k, v in params.items()])
            encoded_prompt = quote(prompt)
            image_url = f"{self.base_url}/{encoded_prompt}?{param_str}"

            # Generate image
            response = self.session.get(image_url, timeout=30)
            response.raise_for_status()

            return {
                'success': True,
                'image_data': response.content,
                'image_url': image_url,
                'generation_time': time.time(),
                'service': 'pollinations'
            }

        except Exception as e:
            return {
                'success': False,
                'error': str(e),
                'service': 'pollinations'
            }


class GalaxyAI:
    """Galaxy.ai integration for premium image generation"""

    def __init__(self, api_key: str = None):
        self.api_key = api_key
        self.base_url = "https://api.galaxy.ai/v1"

    def generate_image(self, prompt: str, **kwargs) -> dict:
        """Generate image using Galaxy.ai"""
        if not self.api_key:
            return {
                'success': False,
                'error': 'Galaxy.ai API key required',
                'service': 'galaxy'
            }

        # Implementation would go here with actual Galaxy.ai API
        return {
            'success': False,
            'error': 'Galaxy.ai integration requires API key setup',
            'service': 'galaxy'
        }


class ComfyUIWebInterface:
    def __init__(self):
        self.pipeline = ComfyUIAdvancedPipeline()
        self.pollinations = PollinationsAI()
        self.galaxy = GalaxyAI()  # No API key by default
        self.current_generation = None

    def create_web_interface(self):
        """Generate the web interface HTML"""

        themes_html = ""
        print(f"DEBUG: Pipeline has {len(self.pipeline.design_themes)} themes")
        for key, theme_data in self.pipeline.design_themes.items():
            print(f"DEBUG: Adding theme {key}")
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

        print(f"DEBUG: Generated themes HTML length: {len(themes_html)}")

        return f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FreshThreads LLC - FreshVision AI Designer</title>

    <!-- Favicon -->
    <link rel="icon" type="image/png" href="assets/Fresh_ThreadsLLCLogo.png">
    <link rel="icon" type="image/png" sizes="32x32" href="assets/Fresh_ThreadsLLCLogo.png">
    <link rel="apple-touch-icon" href="assets/Fresh_ThreadsLLCLogo.png">
    <meta name="theme-color" content="#000000">

    <!-- Preconnect for performance -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Space+Grotesk:wght@400;500;600;700&display=swap" rel="stylesheet">

    <!-- Fresh Threads Styling -->
    <link rel="stylesheet" href="styles/minimalistic.css">

    <!-- Additional AI Interface Styling -->
    <style>
        /* Light theme for AI interface */
        body {{
            background: var(--white, #ffffff);
            color: var(--gray-900, #111111);
            font-family: var(--font-primary);
        }}

        .ai-container {{
            max-width: 1200px;
            margin: 0 auto;
            background: var(--white);
            min-height: 100vh;
            padding: var(--space-lg);
        }}

        .ai-header {{
            background: var(--white);
            border-bottom: 1px solid var(--gray-200);
            padding: var(--space-xl) 0;
            text-align: center;
            margin-bottom: var(--space-2xl);
        }}

        .ai-header h1 {{
            font-family: var(--font-secondary);
            font-size: 2.5rem;
            font-weight: 700;
            color: var(--black);
            margin-bottom: var(--space-md);
            text-transform: uppercase;
            letter-spacing: 2px;
        }}

        .ai-content {{
            padding: 0;
        }}

        .ai-section {{
            margin-bottom: var(--space-3xl);
            background: var(--white);
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-lg);
            padding: var(--space-xl);
        }}

        .ai-section-title {{
            font-family: var(--font-secondary);
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--black);
            margin-bottom: var(--space-lg);
            text-align: center;
            text-transform: uppercase;
            letter-spacing: 1px;
        }}

        .themes-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: var(--space-lg);
            margin-bottom: var(--space-xl);
        }}

        .theme-card {{
            background: var(--gray-50);
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-lg);
            padding: var(--space-lg);
            cursor: pointer;
            transition: all var(--transition-normal);
            position: relative;
        }}

        .theme-card:hover {{
            border-color: var(--gray-400);
            transform: translateY(-2px);
            box-shadow: var(--shadow-lg);
        }}

        .theme-card.selected {{
            border-color: var(--black);
            background: var(--gray-100);
            transform: translateY(-2px);
            box-shadow: var(--shadow-lg);
        }}

        .theme-header h3 {{
            font-family: var(--font-secondary);
            font-size: 1.125rem;
            font-weight: 600;
            margin-bottom: var(--space-md);
            color: var(--black);
        }}

        .theme-description p {{
            margin-bottom: var(--space-sm);
            font-size: 0.875rem;
            line-height: 1.5;
            color: var(--gray-600);
        }}

        .form-group {{
            margin-bottom: var(--space-lg);
        }}

        .form-label {{
            display: block;
            font-family: var(--font-secondary);
            font-weight: 600;
            color: var(--black);
            margin-bottom: var(--space-sm);
            font-size: 0.875rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }}

        .form-input, .form-select {{
            width: 100%;
            padding: var(--space-md);
            border: 1px solid var(--gray-300);
            border-radius: var(--radius-md);
            font-size: 1rem;
            transition: all var(--transition-normal);
            background: var(--white);
            color: var(--gray-900);
        }}

        .form-input:focus, .form-select:focus {{
            outline: none;
            border-color: var(--black);
            box-shadow: 0 0 0 3px rgba(0, 0, 0, 0.1);
        }}

        .form-textarea {{
            min-height: 120px;
            resize: vertical;
            font-family: inherit;
        }}

        .file-upload {{
            position: relative;
            display: inline-block;
            margin-top: var(--space-sm);
        }}

        .file-upload input[type=file] {{
            position: absolute;
            opacity: 0;
            width: 100%;
            height: 100%;
            cursor: pointer;
        }}

        .file-upload-label {{
            display: inline-block;
            padding: var(--space-md) var(--space-lg);
            background: var(--gray-100);
            color: var(--black);
            border: 1px solid var(--gray-300);
            border-radius: var(--radius-md);
            cursor: pointer;
            font-size: 0.875rem;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            transition: all var(--transition-normal);
        }}

        .file-upload-label:hover {{
            background: var(--gray-200);
            border-color: var(--black);
            transform: translateY(-1px);
        }}

        .file-preview {{
            margin-top: var(--space-md);
            text-align: center;
            display: none;
            padding: var(--space-md);
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-md);
            background: var(--gray-50);
        }}

        .file-preview img {{
            max-width: 200px;
            max-height: 150px;
            border-radius: var(--radius-md);
            border: 1px solid var(--gray-200);
        }}

        .file-preview-name {{
            margin-top: var(--space-sm);
            font-size: 0.875rem;
            color: var(--gray-600);
        }}

        .btn {{
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: var(--space-md) var(--space-xl);
            border: none;
            border-radius: var(--radius-md);
            font-family: var(--font-secondary);
            font-weight: 600;
            font-size: 0.875rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            cursor: pointer;
            transition: all var(--transition-normal);
            text-decoration: none;
        }}

        .btn-primary {{
            background: var(--black);
            color: var(--white);
        }}

        .btn-primary:hover {{
            background: var(--gray-800);
            transform: translateY(-1px);
        }}

        .btn-secondary {{
            background: var(--white);
            color: var(--black);
            border: 1px solid var(--gray-300);
        }}

        .btn-secondary:hover {{
            background: var(--gray-50);
            border-color: var(--black);
        }}

        .btn-small {{
            padding: var(--space-sm) var(--space-md);
            font-size: 0.75rem;
        }}

        .buttons {{
            display: flex;
            gap: var(--space-lg);
            justify-content: center;
            margin-top: var(--space-xl);
            flex-wrap: wrap;
        }}

        .optimization-info {{
            background: var(--gray-50);
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-md);
            padding: var(--space-lg);
            margin-top: var(--space-lg);
        }}

        .optimization-info h4 {{
            color: var(--black);
            margin-bottom: var(--space-md);
        }}

        .optimization-info ul {{
            color: var(--gray-600);
        }}

        .speed-option {{
            display: flex;
            align-items: center;
            gap: var(--space-sm);
            margin-bottom: var(--space-md);
            padding: var(--space-md);
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-md);
            transition: all var(--transition-normal);
            cursor: pointer;
        }}

        .speed-option:hover {{
            border-color: var(--gray-400);
            background: var(--gray-50);
        }}

        .speed-option input[type="radio"]:checked + label,
        .speed-option:has(input[type="radio"]:checked) {{
            border-color: var(--black);
            background: var(--gray-100);
        }}

        .speed-label {{
            font-weight: 500;
            color: var(--black);
            cursor: pointer;
            flex: 1;
        }}

        .progress-section {{
            background: var(--gray-50);
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-lg);
            padding: var(--space-xl);
            margin: var(--space-xl) 0;
            text-align: center;
            display: none;
        }}

        .progress-bar {{
            width: 100%;
            height: 8px;
            background: var(--gray-200);
            border-radius: var(--radius-md);
            margin: var(--space-lg) 0;
            overflow: hidden;
        }}

        .progress-fill {{
            height: 100%;
            background: var(--black);
            border-radius: var(--radius-md);
            width: 0%;
            transition: width var(--transition-normal);
        }}

        .results-section {{
            background: var(--gray-50);
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-lg);
            padding: var(--space-xl);
            margin: var(--space-xl) 0;
            display: none;
        }}

        .result-item {{
            background: var(--white);
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-md);
            padding: var(--space-lg);
            margin: var(--space-md) 0;
        }}

        .result-success {{
            border-color: #22c55e;
            background: #f0fdf4;
        }}

        .result-error {{
            border-color: #ef4444;
            background: #fef2f2;
        }}

        input[type="radio"] {{
            accent-color: var(--black);
        }}

        .platform-progress {{
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: var(--space-sm) 0;
            border-bottom: 1px solid var(--gray-200);
            font-size: 0.875rem;
        }}

        .platform-progress:last-child {{
            border-bottom: none;
        }}

        .platform-info {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }}

        .platform-info h3, .platform-info p {{
            color: white;
        }}

        .platform-info small {{
            color: rgba(255, 255, 255, 0.8);
        }}

        .stock-gallery {{
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
            gap: var(--space-md);
            margin-bottom: var(--space-lg);
        }}

        .stock-photo {{
            position: relative;
            aspect-ratio: 1;
            border-radius: var(--radius-md);
            overflow: hidden;
            cursor: pointer;
            transition: var(--transition-normal);
            border: 2px solid transparent;
        }}

        .stock-photo:hover {{
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.1);
        }}

        .stock-photo.selected {{
            border-color: var(--black);
            transform: translateY(-2px);
        }}

        .stock-photo img {{
            width: 100%;
            height: 100%;
            object-fit: cover;
        }}

        .stock-overlay {{
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            background: linear-gradient(transparent, rgba(0,0,0,0.8));
            color: white;
            padding: var(--space-md);
            text-align: center;
            font-size: 0.875rem;
            font-weight: 500;
            opacity: 0;
            transition: var(--transition-normal);
        }}

        .stock-photo:hover .stock-overlay {{
            opacity: 1;
        }}

        .selected-stock-info {{
            background: var(--gray-50);
            border: 1px solid var(--gray-200);
            border-radius: var(--radius-md);
            padding: var(--space-lg);
            margin-top: var(--space-md);
        }}

        .selected-stock-preview {{
            display: grid;
            grid-template-columns: 80px 1fr;
            gap: var(--space-md);
            align-items: center;
        }}

        .selected-stock-preview img {{
            width: 80px;
            height: 80px;
            object-fit: cover;
            border-radius: var(--radius-md);
        }}
    </style>
</head>
<body>
    <div class="ai-container">
        <div class="ai-header">
            <div class="logo-container" style="margin-bottom: var(--space-lg);">
                <img src="assets/Fresh_ThreadsLLCLogo.png" alt="Fresh Threads LLC" style="max-height: 60px; width: auto; object-fit: contain;">
            </div>
            <h1>FreshVision AI Designer</h1>
            <p style="color: var(--gray-500); font-size: 1.1rem; margin-bottom: var(--space-lg);">Professional AI-powered design generation for print-on-demand</p>
        </div>

        <div class="ai-content">
            <!-- Theme Selection -->
            <div class="ai-section">
                <h2 class="ai-section-title">Theme Selection</h2>
                <div class="themes-grid">
                    {themes_html}
                </div>
            </div>

            <!-- Design Configuration -->
            <div class="ai-section">
                <h2 class="ai-section-title">Design Configuration</h2>
                <div class="form-section">
                    <div class="form-group">
                        <label class="form-label">Design Concept</label>
                        <textarea class="form-input form-textarea" id="designConcept"
                                  placeholder="Describe your T-shirt design concept. Our AI will enhance this with creative precision..."></textarea>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Reference Image (Optional)</label>
                        <p style="font-size: 0.875rem; color: var(--text-secondary, #9ca3af); margin-bottom: var(--space-md);">
                            Upload reference image to guide the AI using ControlNet analysis
                        </p>
                        <div class="file-upload">
                            <input type="file" id="referenceImage" accept="image/*" onchange="handleFileUpload(this)">
                            <label for="referenceImage" class="file-upload-label">
                                Upload Image
                            </label>
                        </div>
                        <div class="file-preview" id="filePreview">
                            <img id="previewImage" src="" alt="Preview">
                            <div class="file-preview-name" id="fileName"></div>
                            <button type="button" onclick="clearFile()" class="btn btn-secondary btn-small" style="margin-top: var(--space-md);">Remove Image</button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Stock Photos Gallery -->
            <div class="ai-section">
                <h2 class="ai-section-title">📸 Stock Photos Gallery</h2>
                <p style="font-size: 0.875rem; color: var(--text-secondary, #9ca3af); margin-bottom: var(--space-lg);">
                    Select from our curated collection of free design images or upload your own above
                </p>
                <div class="stock-gallery" id="stockGallery">
                    <div class="stock-photo" onclick="selectStockPhoto('unsplash_unsplash_3cZh_6XNb_U_a_white_vase_with_a_plant_in_i.jpg')">
                        <img src="/assets/designs/free-content/downloads/unsplash_unsplash_3cZh_6XNb_U_a_white_vase_with_a_plant_in_i.jpg" alt="White vase with plant">
                        <div class="stock-overlay">
                            <span>Minimalist Plant</span>
                        </div>
                    </div>
                    <div class="stock-photo" onclick="selectStockPhoto('unsplash_unsplash_8idLYyS1G6c_a_very_tall_building_with_lots.jpg')">
                        <img src="/assets/designs/free-content/downloads/unsplash_unsplash_8idLYyS1G6c_a_very_tall_building_with_lots.jpg" alt="Tall building">
                        <div class="stock-overlay">
                            <span>Modern Architecture</span>
                        </div>
                    </div>
                    <div class="stock-photo" onclick="selectStockPhoto('unsplash_unsplash_RZcwX9khjVg_white_concrete_building_under_.jpg')">
                        <img src="/assets/designs/free-content/downloads/unsplash_unsplash_RZcwX9khjVg_white_concrete_building_under_.jpg" alt="White concrete building">
                        <div class="stock-overlay">
                            <span>Concrete Structure</span>
                        </div>
                    </div>
                    <div class="stock-photo" onclick="selectStockPhoto('unsplash_unsplash_WbvzpIFN17w_white_and_gray_concrete_buildi.jpg')">
                        <img src="/assets/designs/free-content/downloads/unsplash_unsplash_WbvzpIFN17w_white_and_gray_concrete_buildi.jpg" alt="White and gray concrete building">
                        <div class="stock-overlay">
                            <span>Urban Design</span>
                        </div>
                    </div>
                    <div class="stock-photo" onclick="selectStockPhoto('unsplash_unsplash_yBcqo9pg7Hc_a_kitchen_with_a_table_and_cha.jpg')">
                        <img src="/assets/designs/free-content/downloads/unsplash_unsplash_yBcqo9pg7Hc_a_kitchen_with_a_table_and_cha.jpg" alt="Kitchen interior">
                        <div class="stock-overlay">
                            <span>Interior Space</span>
                        </div>
                    </div>
                </div>
                <div class="selected-stock-info" id="selectedStockInfo" style="display: none;">
                    <h4>📌 Selected Stock Photo:</h4>
                    <div class="selected-stock-preview">
                        <img id="selectedStockImage" src="" alt="Selected">
                        <div class="selected-stock-details">
                            <p><strong id="selectedStockName"></strong></p>
                            <button type="button" onclick="clearStockPhoto()" class="btn btn-secondary btn-small">Remove Selection</button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Print-on-Demand Settings (Now Mandatory) -->
            <div class="ai-section">
                <h2 class="ai-section-title">🎯 Print-on-Demand Optimization (Required)</h2>
                <p style="font-size: 0.875rem; color: var(--text-secondary, #9ca3af); margin-bottom: var(--space-lg);">
                    Configure your design for professional print-on-demand production
                </p>
                <div class="form-section">
                    <div class="form-group">
                        <label class="form-label">Target Platform</label>
                        <select class="form-select" id="printPlatform" onchange="updateImageSettings()">
                            <option value="printify">Printify (PNG/JPEG/SVG)</option>
                            <option value="printful">Printful (PNG/JPEG)</option>
                            <option value="both">Both Platforms (PNG recommended)</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Product Type</label>
                        <select class="form-select" id="productType" onchange="updateImageSettings()">
                            <option value="tshirt">T-Shirts & Apparel (300 DPI PNG)</option>
                            <option value="hoodie">Hoodies & DTG (300 DPI PNG)</option>
                            <option value="photo">Photo Prints (300 DPI JPEG)</option>
                            <option value="poster">Posters & Large Items (150 DPI)</option>
                            <option value="logo">Vector Logos (SVG - Printify only)</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Image Dimensions</label>
                        <select class="form-select" id="imageDimensions">
                            <option value="4500x5400">4500×5400 (Standard T-Shirt - 300 DPI)</option>
                            <option value="4200x4800">4200×4800 (Square Design - 300 DPI)</option>
                            <option value="3600x5400">3600×5400 (Portrait Design - 300 DPI)</option>
                            <option value="5400x3600">5400×3600 (Landscape Design - 300 DPI)</option>
                            <option value="2250x2700">2250×2700 (Large Items - 150 DPI)</option>
                            <option value="custom">Custom Dimensions</option>
                        </select>
                    </div>

                    <div class="form-group" id="customDimensionsGroup" style="display: none;">
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: var(--space-md);">
                            <div>
                                <label class="form-label">Width (pixels)</label>
                                <input type="number" class="form-input" id="customWidth" placeholder="4500" min="256" max="8192">
                            </div>
                            <div>
                                <label class="form-label">Height (pixels)</label>
                                <input type="number" class="form-input" id="customHeight" placeholder="5400" min="256" max="8192">
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Output Format</label>
                        <select class="form-select" id="outputFormat">
                            <option value="png">PNG (Transparency Support - Best for Apparel)</option>
                            <option value="jpeg">JPEG (No Transparency - Best for Photos)</option>
                        </select>
                    </div>

                    <div class="optimization-info">
                        <h4 style="font-family: 'Space Grotesk', sans-serif; margin-bottom: var(--space-md); color: var(--text-primary);">
                            📐 Bryan's Optimization Tips
                        </h4>
                        <ul style="font-size: 0.875rem; color: var(--text-secondary); line-height: 1.6; margin: 0; padding-left: var(--space-lg);">
                            <li>Use PNG at 300 DPI for T-shirts, hoodies, and anything needing transparency</li>
                            <li>For vector logos or scalable designs, SVG works well on Printify (not Printful)</li>
                            <li>Always check the product-specific template for bleed and safe zones</li>
                            <li>Generated images will be optimized for your selected platform automatically</li>
                        </ul>
                    </div>
                </div>
            </div>

            <!-- Generate Design -->
            <div class="ai-section">
                <h2 class="ai-section-title">Generate Design</h2>
                <div class="buttons">
                    <button class="btn btn-primary" id="generateBtn" onclick="generateDesign()">
                        Generate Design
                    </button>
                </div>
            </div>            <!-- Batch Configuration -->
            <div class="ai-section" id="batchSection" style="display: none;">
                <h2 class="ai-section-title">Batch Generation Options</h2>
                <div class="batch-section">
                    <h3 style="font-family: 'Space Grotesk', sans-serif; text-transform: uppercase; color: var(--text-primary, #ffffff); font-weight: 700; margin-bottom: var(--space-lg);">Design Lineup</h3>
                    <div class="batch-item">
                        <h4>Tech Operator</h4>
                        <p style="color: var(--text-secondary, #9ca3af);">Error 404: Sleep Not Found - minimalist design for tech enthusiasts</p>
                    </div>
                    <div class="batch-item">
                        <h4>Digital Gaming</h4>
                        <p style="color: var(--text-secondary, #9ca3af);">Level Up Your Style - gaming culture meets vintage aesthetics</p>
                    </div>
                    <div class="batch-item">
                        <h4>Urban Style</h4>
                        <p style="color: var(--text-secondary, #9ca3af);">Fresh Threads Collection - contemporary streetwear design</p>
                    </div>
                </div>
            </div>

            <!-- Progress -->
            <div class="progress-section" id="progressSection">
                <h3 id="progressTitle" style="color: var(--text-primary, #ffffff); margin-bottom: var(--space-md);">Generating Design...</h3>
                <div class="progress-bar">
                    <div class="progress-fill" id="progressFill"></div>
                </div>
                <p id="progressStatus" style="color: var(--text-secondary, #9ca3af);">Initializing...</p>
            </div>

            <!-- Results -->
            <div class="results-section" id="resultsSection">
                <h2 class="ai-section-title">Generation Results</h2>
                <div id="resultsContainer"></div>
            </div>
        </div>
    </div>

    <script>
        let selectedTheme = null;
        let currentGeneration = null;
        let selectedStockPhoto = null;

        // Stock photo selection functions
        function selectStockPhoto(filename) {{
            // Clear uploaded file if stock photo is selected
            clearFile();

            selectedStockPhoto = filename;

            // Update visual selection
            document.querySelectorAll('.stock-photo').forEach(photo => {{
                photo.classList.remove('selected');
            }});
            event.currentTarget.classList.add('selected');

            // Show selected info
            const selectedInfo = document.getElementById('selectedStockInfo');
            const selectedImage = document.getElementById('selectedStockImage');
            const selectedName = document.getElementById('selectedStockName');

            selectedImage.src = `/assets/designs/free-content/downloads/${{filename}}`;
            selectedName.textContent = getStockPhotoDisplayName(filename);
            selectedInfo.style.display = 'block';

            console.log('Selected stock photo:', filename);
        }}

        function clearStockPhoto() {{
            selectedStockPhoto = null;
            document.querySelectorAll('.stock-photo').forEach(photo => {{
                photo.classList.remove('selected');
            }});
            document.getElementById('selectedStockInfo').style.display = 'none';
        }}

        function getStockPhotoDisplayName(filename) {{
            const names = {{
                'unsplash_unsplash_3cZh_6XNb_U_a_white_vase_with_a_plant_in_i.jpg': 'Minimalist Plant',
                'unsplash_unsplash_8idLYyS1G6c_a_very_tall_building_with_lots.jpg': 'Modern Architecture',
                'unsplash_unsplash_RZcwX9khjVg_white_concrete_building_under_.jpg': 'Concrete Structure',
                'unsplash_unsplash_WbvzpIFN17w_white_and_gray_concrete_buildi.jpg': 'Urban Design',
                'unsplash_unsplash_yBcqo9pg7Hc_a_kitchen_with_a_table_and_cha.jpg': 'Interior Space'
            }};
            return names[filename] || filename;
        }}

        // Make stock photo functions globally accessible
        window.selectStockPhoto = selectStockPhoto;
        window.clearStockPhoto = clearStockPhoto;

        // Enhanced validation function
        function validateInputs() {{
            const concept = document.getElementById('designConcept').value.trim();
            const hasUploadedImage = uploadedFileData !== null;
            const hasStockPhoto = selectedStockPhoto !== null;
            const hasReferenceImage = hasUploadedImage || hasStockPhoto;

            // At least one input is required: theme, concept, or reference image
            if (!hasReferenceImage && !selectedTheme && !concept) {{
                alert('⚠️ Please provide at least one of the following:\\n• Select a theme\\n• Enter a design concept\\n• Choose a reference image');
                return false;
            }}

            // Print-on-demand settings are always mandatory
            const printPlatform = document.getElementById('printPlatform').value;
            const productType = document.getElementById('productType').value;
            const imageDimensions = document.getElementById('imageDimensions').value;

            if (!printPlatform || !productType || !imageDimensions) {{
                alert('⚠️ Print-on-Demand optimization settings are required. Please configure your target platform, product type, and dimensions.');
                return false;
            }}

            return true;
        }}

        // Theme selection
        function initializeThemeSelection() {{
            const themeCards = document.querySelectorAll('.theme-card');
            console.log('Found theme cards:', themeCards.length);

            themeCards.forEach(function(card, index) {{
                console.log('Theme card ' + index + ':', card.dataset.theme);
                card.addEventListener('click', function() {{
                    console.log('Theme clicked:', this.dataset.theme);
                    document.querySelectorAll('.theme-card').forEach(c => c.classList.remove('selected'));
                    this.classList.add('selected');
                    selectedTheme = this.dataset.theme;
                    console.log('Selected theme set to:', selectedTheme);
                }});
            }});
        }}

        // Initialize everything when DOM is loaded
        document.addEventListener('DOMContentLoaded', function() {{
            console.log('DOM loaded, initializing...');
            console.log('selectedTheme initial value:', selectedTheme);

            // Check if elements exist
            const themeSection = document.querySelector('.themes-grid');
            console.log('Themes grid found:', !!themeSection);

            const generateBtn = document.getElementById('generateBtn');
            console.log('Generate button found:', !!generateBtn);

            initializeThemeSelection();
            updateImageSettings();

            // Add event listeners for custom dimensions
            const imageDimensions = document.getElementById('imageDimensions');
            if (imageDimensions) {{
                imageDimensions.addEventListener('change', function() {{
                    const customGroup = document.getElementById('customDimensionsGroup');
                    if (this.value === 'custom') {{
                        customGroup.style.display = 'block';
                    }} else {{
                        customGroup.style.display = 'none';
                    }}
                }});
            }}

            console.log('Initialization complete');
        }});

        let uploadedFileData = null;
        let uploadedFileName = null;

        // Ensure function is globally accessible
        function handleFileUpload(input) {{
            const file = input.files[0];
            if (!file) return;

            // Validate file type
            if (!file.type.startsWith('image/')) {{
                alert('Please upload an image file.');
                input.value = '';
                return;
            }}

            // Validate file size (max 10MB)
            if (file.size > 10 * 1024 * 1024) {{
                alert('File size must be less than 10MB.');
                input.value = '';
                return;
            }}

            const reader = new FileReader();
            reader.onload = function(e) {{
                const imageData = e.target.result;
                uploadedFileData = imageData.split(',')[1]; // Remove data:image/... prefix
                uploadedFileName = file.name;

                // Show preview
                const preview = document.getElementById('filePreview');
                const previewImg = document.getElementById('previewImage');
                const fileName = document.getElementById('fileName');

                previewImg.src = imageData;
                fileName.textContent = file.name;
                preview.style.display = 'block';

                console.log('File uploaded successfully:', file.name);
            }};
            reader.readAsDataURL(file);
        }}

        // Make sure the function is globally accessible
        window.handleFileUpload = handleFileUpload;

        function clearFile() {{
            uploadedFileData = null;
            uploadedFileName = null;
            document.getElementById('referenceImage').value = '';
            document.getElementById('filePreview').style.display = 'none';
        }}

        // Make sure functions are globally accessible
        window.clearFile = clearFile;

        function generateDesign() {{
            // Validate inputs first
            if (!validateInputs()) {{
                return;
            }}

            const concept = document.getElementById('designConcept').value.trim();

            // Get print optimization settings
            const printSettings = getPrintSettings();

            showProgress('Generating Design with AI');

            // Prepare request data for multi-platform generation
            const requestData = {{
                theme: selectedTheme,
                concept: concept,
                use_lcm_lora: true, // Default to fast generation
                print_settings: printSettings,
                ai_service: 'multi_platform' // Use all available platforms behind the scenes
            }};

            // Add reference image if uploaded or stock photo selected
            if (uploadedFileData && uploadedFileName) {{
                requestData.reference_image = {{
                    data: uploadedFileData,
                    filename: uploadedFileName
                }};
            }} else if (selectedStockPhoto) {{
                requestData.reference_image = {{
                    stock_photo: selectedStockPhoto,
                    filename: selectedStockPhoto
                }};
            }}

            // Make the API request
            fetch('/generate', {{
                method: 'POST',
                headers: {{
                    'Content-Type': 'application/json',
                }},
                body: JSON.stringify(requestData)
            }})
            .then(response => response.json())
            .then(data => {{
                hideProgress();
                if (data.multi_platform && data.results) {{
                    displayResults(data.results); // Display all results from multiple platforms
                }} else if (data.success) {{
                    displayResults([data]); // Fallback to single result
                }} else {{
                    alert('Generation failed: ' + (data.error || 'Unknown error'));
                }}
            }})
            .catch(error => {{
                hideProgress();
                console.error('Error:', error);
                alert('Network error occurred. Please try again.');
            }});
        }}

        // Make generateDesign function globally accessible
        window.generateDesign = generateDesign;

        function showMultiPlatformProgress(title) {{
            // Create multi-platform progress display
            const progressSection = document.getElementById('progressSection');
            if (!progressSection) return;

            progressSection.style.display = 'block';
            document.getElementById('progressTitle').textContent = title;

            // Create platform-specific progress indicators
            const statusDiv = document.getElementById('progressStatus');
            statusDiv.innerHTML = `
                <div style="margin-top: var(--space-md);">
                    <div class="platform-progress">
                        <span>🖥️ ComfyUI Local: </span><span id="comfyui-status">Starting...</span>
                    </div>
                    <div class="platform-progress">
                        <span>⚡ Pollinations AI: </span><span id="pollinations-status">Starting...</span>
                    </div>
                    <div class="platform-progress">
                        <span>🌌 Galaxy.ai: </span><span id="galaxy-status">Starting...</span>
                    </div>
                </div>
            `;

            // Simulate platform progress
            setTimeout(() => document.getElementById('pollinations-status').textContent = 'Generating...', 1000);
            setTimeout(() => document.getElementById('comfyui-status').textContent = 'Processing...', 2000);
            setTimeout(() => document.getElementById('galaxy-status').textContent = 'Generating...', 3000);
        }}

        function hideMultiPlatformProgress() {{
            if (currentGeneration) {{
                clearInterval(currentGeneration);
                currentGeneration = null;
            }}
            document.getElementById('progressSection').style.display = 'none';
        }}

        function displayMultiPlatformResults(data) {{
            const container = document.getElementById('resultsContainer');
            const section = document.getElementById('resultsSection');

            container.innerHTML = '<h3>🎨 Multi-Platform Generation Results</h3>';

            // Show summary
            const summaryDiv = document.createElement('div');
            summaryDiv.className = 'result-item result-success';
            summaryDiv.innerHTML = `
                <h4>Generation Summary</h4>
                <p><strong>Theme:</strong> ${{data.results[0]?.theme || selectedTheme}}</p>
                <p><strong>Concept:</strong> ${{data.results[0]?.concept}}</p>
                <p><strong>Platforms Generated:</strong> ${{data.total_generated}}/3</p>
                <p><strong>Generation Time:</strong> ${{new Date(data.timestamp).toLocaleTimeString()}}</p>
            `;
            container.appendChild(summaryDiv);

            // Display results from each platform
            data.results.forEach((result, index) => {{
                const resultDiv = document.createElement('div');
                resultDiv.className = 'result-item result-success';

                const platformName = result.ai_service || 'Unknown Platform';
                const promptUsed = result.prompt_used || 'Standard prompt';

                resultDiv.innerHTML = `
                    <h4>${{platformName}} Results</h4>
                    <div style="display: grid; grid-template-columns: 1fr 2fr; gap: var(--space-lg);">
                        <div>
                            ${{result.image_url ? `<img src="${{result.image_url}}" alt="Generated design" style="width: 100%; border-radius: var(--radius-md);">` : '<p>Image generation in progress...</p>'}}
                        </div>
                        <div>
                            <p><strong>Status:</strong> ${{result.success ? '✅ Success' : '❌ Failed'}}</p>
                            <p><strong>Filename:</strong> ${{result.filename || 'N/A'}}</p>
                            <p><strong>AI Prompt:</strong></p>
                            <div style="background: var(--gray-100); padding: var(--space-md); border-radius: var(--radius-sm); font-size: 0.875rem; margin-top: var(--space-sm);">
                                ${{promptUsed}}
                            </div>
                            ${{result.error ? `<p style="color: var(--red-600);"><strong>Error:</strong> ${{result.error}}</p>` : ''}}
                        </div>
                    </div>
                `;
                container.appendChild(resultDiv);
            }});

            // Show any errors
            if (data.generation_errors && data.generation_errors.length > 0) {{
                const errorsDiv = document.createElement('div');
                errorsDiv.className = 'result-item result-error';
                errorsDiv.innerHTML = `
                    <h4>Platform Errors</h4>
                    <ul>${{data.generation_errors.map(error => `<li>${{error}}</li>`).join('')}}</ul>
                `;
                container.appendChild(errorsDiv);
            }}

            section.style.display = 'block';
            section.scrollIntoView({{ behavior: 'smooth' }});
        }}

        function generateSingle() {{
            // Validate inputs first
            if (!validateInputs()) {{
                return;
            }}

            const concept = document.getElementById('designConcept').value.trim();

            // Get print optimization settings
            const printSettings = getPrintSettings();

            showProgress('Generating Design with AI');

            // Prepare request data - let server decide which AI service to use
            const requestData = {{
                theme: selectedTheme,
                concept: concept,
                use_lcm_lora: true, // Default to fast generation
                print_settings: printSettings,
                ai_service: 'auto' // Server will automatically choose best available service
            }};

            // Add reference image if uploaded or stock photo selected
            if (uploadedFileData && uploadedFileName) {{
                requestData.reference_image = {{
                    data: uploadedFileData,
                    filename: uploadedFileName
                }};
            }} else if (selectedStockPhoto) {{
                requestData.reference_image = {{
                    stock_photo: selectedStockPhoto,
                    filename: selectedStockPhoto
                }};
            }}

            fetch('/generate-single', {{
                method: 'POST',
                headers: {{ 'Content-Type': 'application/json' }},
                body: JSON.stringify(requestData)
            }})
            .then(response => response.json())
            .then(data => {{
                hideProgress();
                displayResults([data]);
            }})
            .catch(error => {{
                hideProgress();
                alert('Generation failed: ' + error);
            }});
        }}

        function generateBatch() {{
            document.getElementById('batchSection').style.display = 'block';

            // Get print optimization settings
            const printSettings = getPrintSettings();

            showProgress('Generating Batch (3 Designs)');

            fetch('/generate-batch', {{
                method: 'POST',
                headers: {{ 'Content-Type': 'application/json' }},
                body: JSON.stringify({{
                    batch_type: 'default',
                    print_settings: printSettings
                }})
            }})
            .then(response => response.json())
            .then(data => {{
                hideProgress();
                displayResults(data.results || []);
            }})
            .catch(error => {{
                hideProgress();
                alert('Batch generation failed: ' + error);
            }});
        }}

        function showProgress(title) {{
            document.getElementById('progressSection').style.display = 'block';
            document.getElementById('progressTitle').textContent = title;
            document.getElementById('progressStatus').textContent = 'Starting generation...';

            // Simulate progress
            let progress = 0;
            const interval = setInterval(() => {{
                progress += Math.random() * 10;
                if (progress > 90) progress = 90;
                document.getElementById('progressFill').style.width = progress + '%';

                if (progress > 80) {{
                    document.getElementById('progressStatus').textContent = 'Finalizing...';
                }} else if (progress > 60) {{
                    document.getElementById('progressStatus').textContent = 'Generating image...';
                }} else if (progress > 30) {{
                    document.getElementById('progressStatus').textContent = 'Processing prompt...';
                }}
            }}, 500);

            // Store interval to clear later
            currentGeneration = interval;
        }}

        function hideProgress() {{
            if (currentGeneration) {{
                clearInterval(currentGeneration);
                currentGeneration = null;
            }}
            document.getElementById('progressSection').style.display = 'none';
            document.getElementById('progressFill').style.width = '100%';
        }}

        function displayResults(results) {{
            const container = document.getElementById('resultsContainer');
            const section = document.getElementById('resultsSection');

            container.innerHTML = '<h3>🎨 AI Generation Results</h3>';

            // Define platform info with service mapping
            const platforms = [
                {{
                    name: 'ComfyUI Local',
                    emoji: '🖥️',
                    service: 'comfyui',
                    fallbackError: 'Local service unavailable'
                }},
                {{
                    name: 'Pollinations AI',
                    emoji: '⚡',
                    service: 'Pollinations AI',
                    fallbackError: 'Cloud service unavailable'
                }},
                {{
                    name: 'Galaxy.ai Premium',
                    emoji: '🌌',
                    service: 'galaxy',
                    fallbackError: 'Premium service coming soon!'
                }}
            ];

            // Create grid for the 3 results
            const resultsGrid = document.createElement('div');
            resultsGrid.style.cssText = 'display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: var(--space-lg); margin-top: var(--space-lg);';

            platforms.forEach((platform, i) => {{
                const resultDiv = document.createElement('div');
                resultDiv.className = 'result-item';

                // Find result for this platform
                const result = results.find(r =>
                    r && (r.ai_service === platform.service ||
                          r.service === platform.service ||
                          (platform.service === 'comfyui' && r.ai_service === 'ComfyUI') ||
                          (platform.service === 'Pollinations AI' && (r.ai_service === 'Pollinations AI' || r.ai_service === 'pollinations'))
                    ));

                if (platform.service === 'galaxy') {{
                    // Galaxy.ai placeholder (always show as coming soon)
                    resultDiv.className += ' result-error';
                    resultDiv.innerHTML = `
                        <h4>${{i + 1}}. ${{platform.name}}</h4>
                        <div style="text-align: center; padding: var(--space-xl);">
                            <div style="font-size: 3rem; margin-bottom: var(--space-md); opacity: 0.5;">${{platform.emoji}}</div>
                            <p><strong>Image not available</strong></p>
                            <p style="color: var(--gray-500); font-size: 0.875rem;">${{platform.fallbackError}}</p>
                        </div>
                    `;
                }} else if (result && result.success) {{
                    // Working platforms
                    resultDiv.className += ' result-success';
                    const imageUrl = result.image_url || (result.images && result.images[0] ? result.images[0] : '');

                    resultDiv.innerHTML = `
                        <h4>${{i + 1}}. ${{platform.name}}</h4>
                        <div style="text-align: center;">
                            ${{imageUrl ?
                                `<img src="${{imageUrl}}" alt="Generated design" style="width: 100%; max-width: 250px; border-radius: var(--radius-md); margin-bottom: var(--space-md);">` :
                                '<div style="background: var(--gray-100); width: 100%; max-width: 250px; height: 250px; margin: 0 auto var(--space-md); display: flex; align-items: center; justify-content: center; border-radius: var(--radius-md); color: var(--gray-500);">No image available</div>'
                            }}
                            <p><strong>Status:</strong> ✅ Success</p>
                            <p><strong>Theme:</strong> ${{result.theme ? result.theme.replace('_', ' ').toUpperCase() : 'Custom'}}</p>
                            <p><strong>Concept:</strong> ${{result.concept || 'Generated design'}}</p>
                            ${{result.filename ? `<p><strong>File:</strong> ${{result.filename}}</p>` : ''}}
                        </div>
                    `;
                }} else {{
                    // Failed platforms
                    resultDiv.className += ' result-error';
                    resultDiv.innerHTML = `
                        <h4>${{i + 1}}. ${{platform.name}}</h4>
                        <div style="text-align: center; padding: var(--space-xl);">
                            <div style="font-size: 3rem; margin-bottom: var(--space-md); opacity: 0.5;">❌</div>
                            <p><strong>Generation failed</strong></p>
                            <p style="color: var(--gray-500); font-size: 0.875rem;">${{result ? result.error : platform.fallbackError}}</p>
                        </div>
                    `;
                }}

                resultsGrid.appendChild(resultDiv);
            }});

            container.appendChild(resultsGrid);
            section.style.display = 'block';
            section.scrollIntoView({{ behavior: 'smooth' }});
        }}

        // Print-on-Demand optimization functions
        function updateImageSettings() {{
            const platform = document.getElementById('printPlatform').value;
            const productType = document.getElementById('productType').value;
            const dimensionsSelect = document.getElementById('imageDimensions');
            const formatSelect = document.getElementById('outputFormat');
            const customGroup = document.getElementById('customDimensionsGroup');

            // Update dimension options based on product type
            dimensionsSelect.innerHTML = '';

            if (productType === 'tshirt' || productType === 'hoodie') {{
                dimensionsSelect.innerHTML = `
                    <option value="4500x5400">4500×5400 (Standard T-Shirt - 300 DPI)</option>
                    <option value="4200x4800">4200×4800 (Square Design - 300 DPI)</option>
                    <option value="3600x5400">3600×5400 (Portrait Design - 300 DPI)</option>
                    <option value="5400x3600">5400×3600 (Landscape Design - 300 DPI)</option>
                    <option value="custom">Custom Dimensions</option>
                `;
                formatSelect.innerHTML = `
                    <option value="png">PNG (Transparency Support - Best for Apparel)</option>
                    <option value="jpeg">JPEG (No Transparency - Best for Photos)</option>
                `;
            }} else if (productType === 'photo') {{
                dimensionsSelect.innerHTML = `
                    <option value="4500x5400">4500×5400 (Standard Photo - 300 DPI)</option>
                    <option value="3600x4800">3600×4800 (Portrait Photo - 300 DPI)</option>
                    <option value="4800x3600">4800×3600 (Landscape Photo - 300 DPI)</option>
                    <option value="custom">Custom Dimensions</option>
                `;
                formatSelect.innerHTML = `
                    <option value="jpeg">JPEG (Best for Photos)</option>
                    <option value="png">PNG (Transparency Support)</option>
                `;
            }} else if (productType === 'poster') {{
                dimensionsSelect.innerHTML = `
                    <option value="2250x2700">2250×2700 (Large Items - 150 DPI)</option>
                    <option value="3000x3600">3000×3600 (Medium Poster - 150 DPI)</option>
                    <option value="1800x2400">1800×2400 (Small Poster - 150 DPI)</option>
                    <option value="custom">Custom Dimensions</option>
                `;
                formatSelect.innerHTML = `
                    <option value="jpeg">JPEG (Best for Posters)</option>
                    <option value="png">PNG (Transparency Support)</option>
                `;
            }} else if (productType === 'logo') {{
                dimensionsSelect.innerHTML = `
                    <option value="1024x1024">1024×1024 (Square Logo)</option>
                    <option value="2048x2048">2048×2048 (High-res Logo)</option>
                    <option value="custom">Custom Dimensions</option>
                `;
                if (platform === 'printify') {{
                    formatSelect.innerHTML = `
                        <option value="png">PNG (Transparency Support)</option>
                        <option value="svg">SVG (Vector - Printify Only)</option>
                        <option value="jpeg">JPEG (No Transparency)</option>
                    `;
                }} else {{
                    formatSelect.innerHTML = `
                        <option value="png">PNG (Transparency Support)</option>
                        <option value="jpeg">JPEG (No Transparency)</option>
                    `;
                }}
            }}

            // Show/hide custom dimensions
            dimensionsSelect.addEventListener('change', function() {{
                if (this.value === 'custom') {{
                    customGroup.style.display = 'block';
                }} else {{
                    customGroup.style.display = 'none';
                }}
            }});
        }}

        // Make updateImageSettings function globally accessible
        window.updateImageSettings = updateImageSettings;

        // Helper function to get print optimization settings
        function getPrintSettings() {{
            const platform = document.getElementById('printPlatform').value;
            const productType = document.getElementById('productType').value;
            const dimensions = document.getElementById('imageDimensions').value;
            const format = document.getElementById('outputFormat').value;

            let width, height;
            if (dimensions === 'custom') {{
                width = parseInt(document.getElementById('customWidth').value) || 4500;
                height = parseInt(document.getElementById('customHeight').value) || 5400;
            }} else {{
                [width, height] = dimensions.split('x').map(Number);
            }}

            return {{
                platform,
                productType,
                width,
                height,
                format,
                dpi: productType === 'poster' ? 150 : 300
            }};
        }}
    </script>
</body>
</html>'''


class ComfyUIWebHandler(BaseHTTPRequestHandler):
    def __init__(self, interface, *args, **kwargs):
        self.interface = interface
        super().__init__(*args, **kwargs)

    def _generate_with_auto_fallback(self, request_data):
        """Generate images from ALL available AI platforms simultaneously"""
        theme = request_data.get('theme', 'tech_operator')
        concept = request_data.get('concept', '')

        # Generate platform-specific prompts
        prompts = self._generate_platform_specific_prompts(theme, concept)

        results = []
        generation_errors = []

        # Generate with ComfyUI (Local)
        try:
            print(f"🎨 Generating with ComfyUI...")
            comfyui_result = self.interface.pipeline.generate_single_design(
                theme=theme,
                user_concept=concept,
                use_lcm_lora=request_data.get('use_lcm_lora', True),
                reference_image_path=request_data.get('reference_image'),
                print_settings=request_data.get('print_settings', {})
            )
            if comfyui_result.get('success', True):
                comfyui_result['ai_service'] = 'ComfyUI Local'
                comfyui_result['prompt_used'] = prompts['comfyui']
                results.append(comfyui_result)
                print(f"✅ ComfyUI generation successful")
            else:
                generation_errors.append(
                    f"ComfyUI: {comfyui_result.get('error', 'Unknown error')}")
        except Exception as e:
            generation_errors.append(f"ComfyUI: {str(e)}")
            print(f"❌ ComfyUI generation failed: {e}")

        # Generate with Pollinations AI (Cloud)
        try:
            print(f"⚡ Generating with Pollinations AI...")
            pollinations_result = self._generate_with_pollinations_custom_prompt(
                request_data, prompts['pollinations'])
            if pollinations_result['success']:
                pollinations_result['ai_service'] = 'Pollinations AI'
                pollinations_result['prompt_used'] = prompts['pollinations']
                results.append(pollinations_result)
                print(f"✅ Pollinations AI generation successful")
            else:
                generation_errors.append(
                    f"Pollinations AI: {pollinations_result['error']}")
        except Exception as e:
            generation_errors.append(f"Pollinations AI: {str(e)}")
            print(f"❌ Pollinations AI generation failed: {e}")

        # Generate with Galaxy.ai (Premium) - placeholder for now
        try:
            print(f"🌌 Attempting Galaxy.ai generation...")
            galaxy_result = self._generate_with_galaxy_custom_prompt(
                request_data, prompts['galaxy'])
            if galaxy_result['success']:
                galaxy_result['ai_service'] = 'Galaxy.ai Premium'
                galaxy_result['prompt_used'] = prompts['galaxy']
                results.append(galaxy_result)
                print(f"✅ Galaxy.ai generation successful")
            else:
                generation_errors.append(
                    f"Galaxy.ai: {galaxy_result['error']}")
        except Exception as e:
            generation_errors.append(f"Galaxy.ai: {str(e)}")
            print(f"❌ Galaxy.ai generation failed: {e}")

        # Return multi-platform results
        if results:
            return {
                'success': True,
                'multi_platform': True,
                'results': results,
                'total_generated': len(results),
                'generation_errors': generation_errors if generation_errors else None,
                'timestamp': datetime.now().isoformat()
            }
        else:
            return {
                'success': False,
                'error': 'All AI platforms failed to generate images',
                'generation_errors': generation_errors,
                'ai_service': 'multi_platform_failed',
                'timestamp': datetime.now().isoformat()
            }

    def _generate_platform_specific_prompts(self, theme, concept):
        """Generate optimized prompts for each AI platform"""

        # Base theme styles - matches the themes from ComfyUI pipeline
        theme_styles = {
            'tech_minimal': {
                'base': 'minimalist tech aesthetic, clean typography, geometric shapes, modern design',
                'colors': 'monochromatic with accent colors, tech blue, clean white, dark gray',
                'style': 'minimal design, clean lines, modern typography'
            },
            'retro_gaming': {
                'base': 'nostalgic gaming culture, pixel art elements, 8-bit style, arcade vibes',
                'colors': 'vibrant neon colors, electric blue, hot pink, acid green, dark backgrounds',
                'style': '8-bit meets modern, pixelated effects, retro gaming aesthetic'
            },
            'streetwear_urban': {
                'base': 'urban streetwear, bold graphics, street culture, contemporary design',
                'colors': 'high contrast colors, bold black and white, street art colors',
                'style': 'bold graphics, street art influence, urban contemporary'
            },
            'nature_organic': {
                'base': 'organic natural elements, flowing designs, botanical themes, earth tones',
                'colors': 'earth tones, natural greens, browns, forest colors',
                'style': 'organic flowing forms, natural textures, botanical elements'
            },
            'abstract_artistic': {
                'base': 'abstract artistic expression, creative elements, fluid forms, artistic flair',
                'colors': 'creative color combinations, artistic palette, bold artistic colors',
                'style': 'abstract composition, creative expression, artistic elements'
            },
            'cyberpunk_neon': {
                'base': 'futuristic cyberpunk, neon lighting, dark futuristic, electronic vibes',
                'colors': 'electric blues, hot pinks, acid greens, neon colors on black',
                'style': 'cyberpunk aesthetic, neon lighting effects, futuristic design'
            },
            'vintage_classic': {
                'base': 'timeless vintage design, classic typography, retro elegance, refined style',
                'colors': 'muted earth tones, vintage colors, gold accents, classic palette',
                'style': 'vintage typography, classic design elements, timeless elegance'
            },
            'space_cosmic': {
                'base': 'cosmic space themes, celestial elements, galaxy vibes, stars and planets',
                'colors': 'deep purples, cosmic blues, starlight whites, galaxy colors',
                'style': 'cosmic design, celestial elements, space-themed graphics'
            },
            'punk_rock': {
                'base': 'rebellious punk rock culture, edgy graphics, anarchic style, rock attitude',
                'colors': 'black, white, blood red, distressed colors, high contrast',
                'style': 'punk aesthetic, edgy design, rebellious graphics, distressed effects'
            },
            'kawaii_cute': {
                'base': 'adorable Japanese kawaii culture, cute characters, cheerful design, sweet aesthetics',
                'colors': 'soft pastels, cute pinks, light blues, cheerful bright colors',
                'style': 'kawaii design, cute elements, adorable graphics, pastel aesthetics'
            },
            'gothic_dark': {
                'base': 'dark gothic aesthetic, mysterious elements, ornate design, dramatic style',
                'colors': 'deep blacks, dark purples, silver accents, gothic palette',
                'style': 'gothic design, dark aesthetics, ornate elements, mysterious style'
            },
            'surf_beach': {
                'base': 'beach and surf culture, ocean vibes, tropical elements, laid-back style',
                'colors': 'ocean blues, sandy beiges, tropical colors, beach palette',
                'style': 'surf culture, beach vibes, tropical design, ocean-inspired'
            },
            'music_festival': {
                'base': 'music festival culture, concert vibes, musical elements, festival energy',
                'colors': 'festival bright colors, concert lighting, vibrant music colors',
                'style': 'music-inspired design, festival graphics, concert aesthetics'
            },
            'minimalist_zen': {
                'base': 'zen minimalism, peaceful design, simple elegance, tranquil aesthetics',
                'colors': 'zen earth tones, peaceful colors, minimalist palette, calming hues',
                'style': 'zen design, minimalist aesthetics, peaceful simplicity'
            },
            'horror_creepy': {
                'base': 'horror and creepy elements, dark themes, spooky design, eerie aesthetics',
                'colors': 'horror dark colors, blood reds, eerie blacks, spooky palette',
                'style': 'horror design, creepy elements, spooky graphics, dark aesthetics'
            }
        }

        # Fallback to tech_minimal if theme not found
        theme_data = theme_styles.get(theme, theme_styles['tech_minimal'])
        print(f"🎨 Using theme '{theme}' with style: {theme_data['base']}")

        # Platform-optimized prompts
        prompts = {
            'comfyui': f"{concept}, {theme_data['base']}, {theme_data['style']}, t-shirt design, vector art style, bold graphics, high contrast, professional apparel design, {theme_data['colors']}, minimalist composition",

            'pollinations': f"professional t-shirt design, {concept}, {theme_data['base']}, {theme_data['colors']} color palette, {theme_data['style']}, vector graphics, clean design, commercial quality, bold and striking, apparel ready",

            'galaxy': f"premium t-shirt design concept: {concept} featuring {theme_data['base']} aesthetic with {theme_data['colors']} color scheme, {theme_data['style']}, high-end apparel design, commercial ready, vector illustration style"
        }

        return prompts

    def _generate_with_pollinations_custom_prompt(self, request_data, custom_prompt):
        """Generate using Pollinations AI with custom prompt"""
        try:
            # Use the custom prompt instead of generating one
            params = {
                'width': 512,
                'height': 512,
                'model': 'flux',
                'enhance': 'true',
                'nologo': 'true'
            }

            param_str = '&'.join([f'{k}={v}' for k, v in params.items()])
            encoded_prompt = quote(custom_prompt)
            image_url = f"{self.interface.pollinations.base_url}/{encoded_prompt}?{param_str}"

            # Generate image
            response = self.interface.pollinations.session.get(
                image_url, timeout=30)
            response.raise_for_status()

            # Save image
            timestamp = int(time.time())
            filename = f"pollinations_design_{timestamp}.png"
            output_dir = Path('generated_designs')
            output_dir.mkdir(exist_ok=True)
            filepath = output_dir / filename

            with open(filepath, 'wb') as f:
                f.write(response.content)

            return {
                'success': True,
                'image_url': f'/generated_designs/{filename}',
                'filename': filename,
                'theme': request_data.get('theme'),
                'concept': request_data.get('concept'),
                'ai_service': 'pollinations',
                'generation_time': time.time(),
                'timestamp': datetime.now().isoformat()
            }

        except Exception as e:
            return {
                'success': False,
                'error': f"Pollinations AI generation failed: {str(e)}",
                'ai_service': 'pollinations',
                'timestamp': datetime.now().isoformat()
            }

    def _generate_with_galaxy_custom_prompt(self, request_data, custom_prompt):
        """Generate using Galaxy.ai with custom prompt (placeholder)"""
        # For now, return a placeholder since Galaxy.ai requires API key
        return {
            'success': False,
            'error': 'Galaxy.ai requires API key setup. Premium service coming soon!',
            'ai_service': 'galaxy',
            'placeholder': True,
            'timestamp': datetime.now().isoformat()
        }

    def _generate_with_pollinations(self, request_data):
        """Generate using Pollinations AI"""
        try:
            theme = request_data.get('theme', 'tech_operator')
            concept = request_data.get('concept', '')

            # Enhanced prompt for t-shirt design
            if theme == 'tech_operator':
                enhanced_prompt = f"{concept}, cyberpunk tech warrior, tactical gear, neon accents, military precision"
            elif theme == 'digital_combat':
                enhanced_prompt = f"{concept}, digital warfare aesthetic, retro gaming elements, combat ready"
            elif theme == 'urban_warfare':
                enhanced_prompt = f"{concept}, urban street tactical, modern warfare, city combat style"
            else:
                enhanced_prompt = concept

            enhanced_prompt += ', t-shirt design, vector art style, bold graphics, high contrast, professional apparel design'

            # Generate with Pollinations AI
            result = self.interface.pollinations.generate_image(
                enhanced_prompt, width=512, height=512)

            if result['success']:
                # Save image and return result in ComfyUI format
                timestamp = int(time.time())
                filename = f"pollinations_design_{timestamp}.png"

                # Create output directory
                output_dir = Path('generated_designs')
                output_dir.mkdir(exist_ok=True)

                # Save image
                filepath = output_dir / filename
                with open(filepath, 'wb') as f:
                    f.write(result['image_data'])

                return {
                    'success': True,
                    'image_url': f'/generated_designs/{filename}',
                    'filename': filename,
                    'theme': theme,
                    'concept': concept,
                    'ai_service': 'pollinations',
                    'generation_time': result['generation_time'],
                    'timestamp': datetime.now().isoformat()
                }
            else:
                return {
                    'success': False,
                    'error': result['error'],
                    'ai_service': 'pollinations',
                    'timestamp': datetime.now().isoformat()
                }

        except Exception as e:
            return {
                'success': False,
                'error': f"Pollinations AI generation failed: {str(e)}",
                'ai_service': 'pollinations',
                'timestamp': datetime.now().isoformat()
            }

    def _generate_with_galaxy(self, request_data):
        """Generate using Galaxy.ai"""
        return {
            'success': False,
            'error': 'Galaxy.ai requires API key setup. Please configure your API key.',
            'ai_service': 'galaxy',
            'timestamp': datetime.now().isoformat()
        }

    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(self.interface.create_web_interface().encode())
        elif self.path == '/status':
            # Handle status check via GET
            status = self.interface.pipeline.check_comfyui_status()
            response = {
                'comfyui_running': status,
                'timestamp': datetime.now().isoformat()
            }
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps(response).encode())
        elif self.path.startswith('/assets/') or self.path.startswith('/styles/') or self.path.endswith('.css'):
            # Serve static files from docs directory
            file_path = Path('docs') / self.path.lstrip('/')
            if file_path.exists() and file_path.is_file():
                self.send_response(200)
                # Set content type based on file extension
                if file_path.suffix == '.css':
                    self.send_header('Content-type', 'text/css')
                elif file_path.suffix == '.js':
                    self.send_header('Content-type', 'application/javascript')
                elif file_path.suffix == '.png':
                    self.send_header('Content-type', 'image/png')
                elif file_path.suffix == '.svg':
                    self.send_header('Content-type', 'image/svg+xml')
                else:
                    self.send_header(
                        'Content-type', 'application/octet-stream')
                self.end_headers()

                with open(file_path, 'rb') as f:
                    self.wfile.write(f.read())
            else:
                self.send_error(404)
        elif self.path.startswith('/generated_designs/'):
            # Serve generated images
            file_path = Path(self.path.lstrip('/'))
            if file_path.exists() and file_path.is_file():
                self.send_response(200)
                self.send_header('Content-type', 'image/png')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()

                with open(file_path, 'rb') as f:
                    self.wfile.write(f.read())
            else:
                self.send_error(404)
        else:
            self.send_error(404)
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        if self.path == '/generate':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)

            try:
                request_data = json.loads(post_data.decode())
                ai_service = request_data.get('ai_service', 'auto')

                # Multi-platform generation
                if ai_service == 'multi_platform':
                    result = self._generate_with_auto_fallback(request_data)
                # Auto-select best available AI service with intelligent fallback
                elif ai_service == 'auto':
                    # For single platform auto-select, use the original fallback logic
                    try:
                        result = self._generate_with_pollinations(request_data)
                        if not result['success']:
                            raise Exception("Fallback to ComfyUI")
                    except Exception:
                        result = self.interface.pipeline.generate_single_design(
                            theme=request_data.get('theme'),
                            user_concept=request_data.get('concept'),
                            use_lcm_lora=request_data.get(
                                'use_lcm_lora', True),
                            reference_image_path=request_data.get(
                                'reference_image'),
                            print_settings=request_data.get(
                                'print_settings', {})
                        )
                elif ai_service == 'pollinations':
                    result = self._generate_with_pollinations(request_data)
                elif ai_service == 'galaxy':
                    result = self._generate_with_galaxy(request_data)
                else:  # Default to ComfyUI
                    result = self.interface.pipeline.generate_single_design(
                        theme=request_data.get('theme'),
                        user_concept=request_data.get('concept'),
                        use_lcm_lora=request_data.get('use_lcm_lora', True),
                        reference_image_path=request_data.get(
                            'reference_image'),
                        print_settings=request_data.get('print_settings', {})
                    )

                response = json.dumps(result)
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(response.encode())

            except Exception as e:
                error_response = json.dumps({
                    'success': False,
                    'error': str(e),
                    'timestamp': datetime.now().isoformat()
                })
                self.send_response(500)
                self.send_header('Content-type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(error_response.encode())

        elif self.path == '/generate-single':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)

            try:
                request_data = json.loads(post_data.decode())
                ai_service = request_data.get('ai_service', 'auto')

                # Auto-select best available AI service with intelligent fallback
                if ai_service == 'auto':
                    result = self._generate_with_auto_fallback(request_data)
                elif ai_service == 'pollinations':
                    result = self._generate_with_pollinations(request_data)
                elif ai_service == 'galaxy':
                    result = self._generate_with_galaxy(request_data)
                else:  # Default to ComfyUI
                    result = self.interface.pipeline.generate_single_design(
                        theme=request_data.get('theme'),
                        user_concept=request_data.get('concept'),
                        use_lcm_lora=request_data.get('use_lcm_lora', True),
                        reference_image_path=request_data.get(
                            'reference_image'),
                        print_settings=request_data.get('print_settings', {})
                    )

                response = json.dumps(result)
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(response.encode())

            except Exception as e:
                error_response = json.dumps({
                    'success': False,
                    'error': str(e),
                    'timestamp': datetime.now().isoformat()
                })
                self.send_response(500)
                self.send_header('Content-type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(error_response.encode())

        elif self.path == '/generate-batch':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)

            try:
                request_data = json.loads(post_data.decode())
                batch_results = self.interface.pipeline.generate_batch_designs(
                    batch_type=request_data.get('batch_type', 'default'),
                    print_settings=request_data.get('print_settings', {})
                )

                response = json.dumps({
                    'success': True,
                    'results': batch_results,
                    'timestamp': datetime.now().isoformat()
                })
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(response.encode())

            except Exception as e:
                error_response = json.dumps({
                    'success': False,
                    'error': str(e),
                    'timestamp': datetime.now().isoformat()
                })
                self.send_response(500)
                self.send_header('Content-type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(error_response.encode())

    def do_OPTIONS(self):
        # Handle CORS preflight requests
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()


def run_server():
    """Run the web interface server"""
    interface = ComfyUIWebInterface()

    def handler(*args, **kwargs):
        ComfyUIWebHandler(interface, *args, **kwargs)

    server = HTTPServer(('localhost', 8080), handler)
    print(f"🎨 FreshVision AI Designer starting on http://localhost:8080")
    print(f"📐 Print-on-Demand optimization enabled")
    print(f"🚀 Ready for design generation!")

    try:
        # Try to open the browser
        threading.Timer(1.0, lambda: webbrowser.open(
            'http://localhost:8080')).start()
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n🛑 Server stopped by user")
        server.shutdown()
    except OSError as e:
        if "Address already in use" in str(e):
            print(
                f"❌ Port 8080 is already in use. Try a different port or stop the existing service.")
            print(f"💡 You can kill the existing process with: lsof -ti:8080 | xargs kill")
        else:
            print(f"❌ Server error: {e}")


if __name__ == "__main__":
    run_server()
