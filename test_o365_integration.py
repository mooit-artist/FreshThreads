#!/usr/bin/env python3
"""
Complete O365 Integration Test
Tests both direct email handler and Flask API integration
"""

import requests
import json
import sys
import os

# Add current directory to path
sys.path.append(os.path.dirname(__file__))


def test_direct_email():
    """Test direct O365EmailHandler"""
    print("🧪 Testing Direct O365EmailHandler...")

    try:
        from scripts.o365_email_handler import O365EmailHandler

        handler = O365EmailHandler()

        # Test data matching the expected format
        form_data = {
            "name": "Direct Test User",
            "email": "test@example.com",
            "subject": "Direct O365 Test - Integration Working!",
            "message": "This email was sent directly through the O365EmailHandler to test the integration."
        }

        result = handler.send_contact_form_email(form_data)

        if result['success']:
            print("✅ Direct email test: SUCCESS")
            print(f"   Method: {result['method']}")
            return True
        else:
            print("❌ Direct email test: FAILED")
            print(f"   Error: {result['error']}")
            return False

    except Exception as e:
        print(f"❌ Direct email test: ERROR - {str(e)}")
        return False


def test_flask_api():
    """Test Flask API endpoint"""
    print("\n🧪 Testing Flask API Contact Form...")

    try:
        # Test data
        test_contact = {
            "name": "API Test User",
            "email": "test@example.com",
            "subject": "Flask API Test - Contact Form Integration",
            "message": "This message was sent through the Flask API contact form endpoint to test the complete integration pipeline."
        }

        # Make request to Flask API
        response = requests.post(
            "http://127.0.0.1:5001/contact",
            headers={"Content-Type": "application/json"},
            json=test_contact,
            timeout=30
        )

        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                print("✅ Flask API test: SUCCESS")
                print(f"   Message: {result.get('message')}")
                print(f"   Method: {result.get('method', 'Unknown')}")
                return True
            else:
                print("❌ Flask API test: FAILED")
                print(f"   Error: {result.get('error')}")
                return False
        else:
            print(f"❌ Flask API test: HTTP {response.status_code}")
            print(f"   Response: {response.text}")
            return False

    except requests.exceptions.ConnectionError:
        print("❌ Flask API test: CONNECTION ERROR")
        print("   Make sure Flask server is running on port 5001")
        return False
    except Exception as e:
        print(f"❌ Flask API test: ERROR - {str(e)}")
        return False


def check_flask_server():
    """Check if Flask server is running"""
    try:
        response = requests.get("http://127.0.0.1:5001/health", timeout=5)
        if response.status_code == 200:
            print("✅ Flask server is running")
            return True
    except:
        pass

    print("❌ Flask server is not responding")
    print("   Start with: python contact_api.py")
    return False


def main():
    print("🚀 FreshThreads O365 Integration Test Suite")
    print("=" * 50)

    # Test direct email handler
    direct_success = test_direct_email()

    # Check Flask server
    flask_running = check_flask_server()

    # Test Flask API if running
    api_success = False
    if flask_running:
        api_success = test_flask_api()

    # Summary
    print("\n" + "=" * 50)
    print("🎯 Test Results Summary:")
    print(
        f"   Direct O365EmailHandler: {'✅ PASS' if direct_success else '❌ FAIL'}")
    print(
        f"   Flask Server Running: {'✅ PASS' if flask_running else '❌ FAIL'}")
    print(f"   Flask API Integration: {'✅ PASS' if api_success else '❌ FAIL'}")

    if direct_success and api_success:
        print("\n🎉 COMPLETE SUCCESS! Your O365 integration is fully working!")
        print("   ✅ Direct email sending works")
        print("   ✅ Contact form API works")
        print("   ✅ Your contact page is ready for production!")
    elif direct_success:
        print("\n⚠️  PARTIAL SUCCESS! Direct email works, but Flask API needs attention.")
        print("   ✅ O365 authentication and email sending is working")
        print("   ❌ Contact form API needs debugging")
    else:
        print("\n❌ INTEGRATION ISSUES! Check configuration and try again.")

    return direct_success and api_success


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
