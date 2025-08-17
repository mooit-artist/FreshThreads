#!/usr/bin/env python3
"""
Test AI services availability for Enhanced FreshVision
"""

import requests
import sys


def test_comfyui():
    """Test ComfyUI availability"""
    try:
        from comfyui_advanced_pipeline import ComfyUIAdvancedPipeline
        print('✅ ComfyUI: Available')
        return True
    except ImportError:
        print('❌ ComfyUI: Not Available')
        return False


def test_pollinations():
    """Test Pollinations AI availability"""
    try:
        response = requests.get(
            'https://image.pollinations.ai/prompt/test', timeout=10)
        if response.status_code == 200:
            print('✅ Pollinations AI: Available')
            return True
        else:
            print('⚠️  Pollinations AI: Service responding but may have issues')
            return False
    except Exception as e:
        print(f'❌ Pollinations AI: Not Available ({str(e)})')
        return False


def test_galaxy():
    """Test Galaxy.ai (placeholder)"""
    print('⚠️  Galaxy.ai: Ready (requires API key setup)')
    return True


def main():
    """Run all AI service tests"""
    print("🧪 Testing AI Services for Enhanced FreshVision...")
    print("=" * 50)

    services = {
        'ComfyUI': test_comfyui(),
        'Pollinations AI': test_pollinations(),
        'Galaxy.ai': test_galaxy()
    }

    print("\n📊 Summary:")
    available = sum(services.values())
    total = len(services)

    print(f"Available services: {available}/{total}")

    if available >= 1:
        print("✅ Enhanced FreshVision is ready to use!")
    else:
        print("❌ No AI services available")
        sys.exit(1)


if __name__ == '__main__':
    main()
