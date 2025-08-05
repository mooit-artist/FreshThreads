#!/usr/bin/env python3
"""
Fresh Threads LLC - FreshVision AI Web Interface
Advanced pipeline with DreamShaperXL Turbo + ControlNet + Dolphin Llama 3
"""

import json
import time
from datetime import datetime
from pathlib import Path
from http.server import HTTPServer, BaseHTTPRequestHandler
import webbrowser
import threading
import cgi
import io
import base64
from comfyui_advanced_pipeline import ComfyUIAdvancedPipeline


class ComfyUIWebInterface:
    def __init__(self):
        self.pipeline = ComfyUIAdvancedPipeline()
        self.current_generation = None

    def create_web_interface(self):
        """Generate the web interface HTML"""

        themes_html = ""
        for key, theme_data in self.pipeline.design_themes.items():
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
                        <label class="form-label">Generation Speed</label>
                        <div style="margin-top: var(--space-md);">
                            <div class="speed-option">
                                <input type="radio" id="speedFast" name="generationSpeed" value="fast" checked>
                                <label for="speedFast" class="speed-label">
                                    <strong>Fast Generation</strong> - ~6 seconds, high quality, rapid results
                                </label>
                            </div>
                            <div class="speed-option">
                                <input type="radio" id="speedSlow" name="generationSpeed" value="slow">
                                <label for="speedSlow" class="speed-label">
                                    <strong>Precision Generation</strong> - ~30 seconds, maximum quality, detailed output
                                </label>
                            </div>
                        </div>
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

            <!-- Print-on-Demand Settings -->
            <div class="ai-section">
                <h2 class="ai-section-title">Print-on-Demand Optimization</h2>
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

            <!-- Generation Options -->
            <div class="ai-section">
                <h2 class="ai-section-title">Generate Design</h2>
                <div class="buttons">
                    <button class="btn btn-primary" id="generateSingle" onclick="generateSingle()">
                        Single Design
                    </button>
                    <button class="btn btn-secondary" id="generateBatch" onclick="generateBatch()">
                        Batch Generation
                    </button>
                </div>
            </div>

            <!-- Batch Configuration -->
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

        // Theme selection
        document.querySelectorAll('.theme-card').forEach(card => {{
            card.addEventListener('click', function() {{
                document.querySelectorAll('.theme-card').forEach(c => c.classList.remove('selected'));
                this.classList.add('selected');
                selectedTheme = this.dataset.theme;
            }});
        }});

        let uploadedFileData = null;
        let uploadedFileName = null;

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

        function clearFile() {{
            uploadedFileData = null;
            uploadedFileName = null;
            document.getElementById('referenceImage').value = '';
            document.getElementById('filePreview').style.display = 'none';
        }}

        function generateSingle() {{
            if (!selectedTheme) {{
                alert('Please select a theme first.');
                return;
            }}

            const concept = document.getElementById('designConcept').value.trim();
            if (!concept) {{
                alert('Please enter a design concept.');
                return;
            }}

            // Get the selected speed option
            const speedFast = document.getElementById('speedFast').checked;
            const useLcm = speedFast; // Fast = true (use LCM), Slow = false (don't use LCM)

            // Get print optimization settings
            const printSettings = getPrintSettings();

            showProgress('Generating Single Design');

            // Prepare request data
            const requestData = {{
                theme: selectedTheme,
                concept: concept,
                use_lcm_lora: useLcm,
                print_settings: printSettings
            }};

            // Add reference image if uploaded
            if (uploadedFileData && uploadedFileName) {{
                requestData.reference_image = {{
                    data: uploadedFileData,
                    filename: uploadedFileName
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

            container.innerHTML = '';

            results.forEach((result, index) => {{
                const resultDiv = document.createElement('div');
                resultDiv.className = `result-item ${{result.success ? 'result-success' : 'result-error'}}`;

                if (result.success) {{
                    resultDiv.innerHTML = `
                        <h4>Success: ${{result.theme ? result.theme.replace('_', ' ').toUpperCase() : 'Design'}}</h4>
                        <p><strong>Concept:</strong> ${{result.concept || 'Generated design'}}</p>
                        <p><strong>Images:</strong> ${{result.images ? result.images.length : 0}} generated</p>
                        <p><strong>GitHub Output:</strong> ${{result.github_output ? result.github_output.folder : 'Ready'}}</p>
                        <p><strong>Prompt ID:</strong> ${{result.comfyui_prompt_id || 'N/A'}}</p>
                    `;
                }} else {{
                    resultDiv.innerHTML = `
                        <h4>Failed: ${{result.theme ? result.theme.replace('_', ' ').toUpperCase() : 'Design'}}</h4>
                        <p><strong>Error:</strong> ${{result.error || 'Unknown error'}}</p>
                    `;
                }}

                container.appendChild(resultDiv);
            }});

            section.style.display = 'block';
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

        // Initialize print settings on page load
        document.addEventListener('DOMContentLoaded', function() {{
            updateImageSettings();

            // Add event listeners for custom dimensions
            document.getElementById('imageDimensions').addEventListener('change', function() {{
                const customGroup = document.getElementById('customDimensionsGroup');
                if (this.value === 'custom') {{
                    customGroup.style.display = 'block';
                }} else {{
                    customGroup.style.display = 'none';
                }}
            }});
        }});

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
                self.end_headers()
                with open(file_path, 'rb') as f:
                    self.wfile.write(f.read())
            else:
                self.send_response(404)
                self.end_headers()
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        if self.path == '/generate-single':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)

            try:
                request_data = json.loads(post_data.decode())
                result = self.interface.pipeline.generate_design(
                    theme=request_data.get('theme'),
                    concept=request_data.get('concept'),
                    use_lcm_lora=request_data.get('use_lcm_lora', True),
                    reference_image=request_data.get('reference_image'),
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
