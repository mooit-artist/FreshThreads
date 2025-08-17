#!/usr/bin/env python3
"""
Quick test of Pollinations AI integration for Enhanced FreshVision
"""

import requests
import time
from pathlib import Path


def test_pollinations_generation():
    """Test actual image generation with Pollinations AI"""
    print("🌸 Testing Pollinations AI image generation...")

    # Test prompt for t-shirt design
    prompt = "minimalist t-shirt design, geometric shapes, black and white, clean typography"

    # Build URL
    base_url = "https://image.pollinations.ai/prompt"
    url = f"{base_url}/{requests.utils.quote(prompt)}"

    params = {
        'width': 512,
        'height': 512,
        'model': 'flux',
        'enhance': 'true',
        'nologo': 'true'
    }

    print(f"📡 Sending request to Pollinations AI...")
    print(f"🎯 Prompt: {prompt}")
    print(f"📏 Size: {params['width']}x{params['height']}")

    start_time = time.time()

    try:
        response = requests.get(url, params=params, timeout=60)

        if response.status_code == 200:
            # Save the image
            output_dir = Path("docs/assets/designs/test-output")
            output_dir.mkdir(parents=True, exist_ok=True)

            timestamp = int(time.time())
            filename = f"pollinations_test_{timestamp}.png"
            filepath = output_dir / filename

            with open(filepath, 'wb') as f:
                f.write(response.content)

            generation_time = time.time() - start_time
            file_size = len(response.content) / 1024  # KB

            print(f"✅ SUCCESS!")
            print(f"⏱️  Generation time: {generation_time:.2f} seconds")
            print(f"💾 File size: {file_size:.1f} KB")
            print(f"📁 Saved to: {filepath}")

            return True

        else:
            print(f"❌ HTTP Error: {response.status_code}")
            print(f"Response: {response.text[:200]}")
            return False

    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return False


def main():
    """Run Pollinations AI test"""
    print("🧪 Enhanced FreshVision - Pollinations AI Test")
    print("=" * 50)

    success = test_pollinations_generation()

    print("\n📊 Test Results:")
    if success:
        print("✅ Pollinations AI is working and ready for Enhanced FreshVision!")
        print("🚀 You can now use 'make fresh-vision-enhanced' to start designing")
    else:
        print("❌ Pollinations AI test failed")
        print("🔧 Check your internet connection and try again")


if __name__ == "__main__":
    main()
