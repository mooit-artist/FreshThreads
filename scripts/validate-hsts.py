#!/usr/bin/env python3
"""
HSTS Validation Script for FreshThreads LLC
Validates HTTP Strict Transport Security header implementation
"""

import glob
import os
import re


class HSTSValidator:
    def __init__(self):
        self.docs_dir = "docs"
        self.valid_files = []
        self.invalid_files = []
        self.missing_files = []
        self.errors = []

    def get_html_files(self):
        """Get all HTML files in the docs directory"""
        pattern = os.path.join(self.docs_dir, "*.html")
        return glob.glob(pattern)

    def validate_hsts_policy(self, content):
        """Validate HSTS policy in HTML content"""
        # Look for HSTS meta tag
        hsts_pattern = r'<meta\s+http-equiv=["\']Strict-Transport-Security["\'][^>]*content=["\']([^"\']*)["\'][^>]*>'
        match = re.search(hsts_pattern, content, re.IGNORECASE)

        if not match:
            return False, "HSTS meta tag not found"

        policy = match.group(1)
        issues = []

        # Check max-age
        max_age_pattern = r"max-age=(\d+)"
        max_age_match = re.search(max_age_pattern, policy)
        if not max_age_match:
            issues.append("Missing max-age directive")
        else:
            max_age = int(max_age_match.group(1))
            if max_age < 31536000:  # Less than 1 year
                issues.append(
                    f"max-age too short: {max_age} seconds (recommended: 31536000)"
                )

        # Check includeSubDomains
        if "includeSubDomains" not in policy:
            issues.append("Missing includeSubDomains directive")

        # Check preload
        if "preload" not in policy:
            issues.append("Missing preload directive (recommended)")

        if issues:
            return False, "; ".join(issues)

        return True, "Valid HSTS policy"

    def validate_file(self, file_path):
        """Validate HSTS implementation in a single file"""
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()

            is_valid, message = self.validate_hsts_policy(content)

            if is_valid:
                self.valid_files.append(file_path)
                print(f"✅ {file_path}: {message}")
            else:
                if "not found" in message:
                    self.missing_files.append(file_path)
                    print(f"❌ {file_path}: {message}")
                else:
                    self.invalid_files.append((file_path, message))
                    print(f"⚠️  {file_path}: {message}")

        except Exception as e:
            error_msg = f"Error validating {file_path}: {str(e)}"
            self.errors.append(error_msg)
            print(f"🚨 {error_msg}")

    def generate_recommendations(self):
        """Generate security recommendations"""
        recommendations = []

        if self.missing_files:
            recommendations.append("Add HSTS headers to files missing them")

        if self.invalid_files:
            recommendations.append("Fix HSTS policy issues in flagged files")

        if not self.errors and not self.missing_files and not self.invalid_files:
            recommendations.extend(
                [
                    "Submit domain to HSTS preload list",
                    "Test HSTS with online security tools",
                    "Monitor HSTS compliance regularly",
                    "Consider implementing HSTS at server level",
                ]
            )

        return recommendations

    def run(self):
        """Main validation function"""
        print("🔒 FreshThreads LLC - HSTS Validation")
        print("=" * 40)

        if not os.path.exists(self.docs_dir):
            print(f"❌ Directory '{self.docs_dir}' not found!")
            return

        html_files = self.get_html_files()
        if not html_files:
            print(f"❌ No HTML files found in '{self.docs_dir}'")
            return

        print(f"📁 Validating {len(html_files)} HTML files\n")

        for file_path in html_files:
            self.validate_file(file_path)

        # Summary
        total_files = len(html_files)
        valid_count = len(self.valid_files)
        invalid_count = len(self.invalid_files)
        missing_count = len(self.missing_files)
        error_count = len(self.errors)

        print("\n📊 HSTS Validation Summary:")
        print(f"  ✅ Valid HSTS: {valid_count}/{total_files}")
        print(f"  ⚠️  Invalid HSTS: {invalid_count}/{total_files}")
        print(f"  ❌ Missing HSTS: {missing_count}/{total_files}")
        print(f"  🚨 Errors: {error_count}")

        # Show compliance percentage
        compliance_rate = (valid_count / total_files) * 100 if total_files > 0 else 0
        print(f"  📈 Compliance Rate: {compliance_rate:.1f}%")

        # Recommendations
        recommendations = self.generate_recommendations()
        if recommendations:
            print("\n💡 Recommendations:")
            for rec in recommendations:
                print(f"  • {rec}")

        # HSTS Best Practices
        print("\n🔐 HSTS Best Practices:")
        print("  • Use max-age of at least 31536000 seconds (1 year)")
        print("  • Include 'includeSubDomains' directive")
        print("  • Add 'preload' directive for browser preloading")
        print("  • Test with: https://hstspreload.org/")
        print("  • Implement at server level for production")


if __name__ == "__main__":
    validator = HSTSValidator()
    validator.run()
