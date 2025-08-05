#!/usr/bin/env python3

# Test script to isolate the format specifier issue

test_data = {
    'base_concept': 'clean, minimalist tech aesthetic',
    'style_keywords': ['geometric', 'modern', 'professional'],
    'color_palette': 'monochrome, black and white'
}

user_concept = "Error 404: Sleep Not Found"
theme = "tech_minimal"

try:
    # Test the f-string that might be causing issues
    dolphin_prompt = f"""You are an expert AI art director specializing in T-shirt design for ComfyUI image generation.

User Concept: {user_concept}
Design Theme: {theme}
Base Concept: {test_data['base_concept']}
Style Keywords: {', '.join(test_data['style_keywords'])}
Color Palette: {test_data['color_palette']}

Format your response as a JSON object with these exact keys:
{{
    "main_prompt": "detailed positive prompt here",
    "negative_prompt": "negative prompt here",
    "steps": 6,
    "cfg_scale": 1.5,
    "sampler": "euler_a",
    "width": 768,
    "height": 768,
    "controlnet_strength": 0.8,
    "preprocessing": "depth_midas"
}}

Respond with ONLY the JSON object, no other text."""

    print("✅ F-string formatted successfully!")
    print("First 200 characters:")
    print(dolphin_prompt[:200])

except Exception as e:
    print(f"❌ Error: {e}")
    print(f"Error type: {type(e)}")
