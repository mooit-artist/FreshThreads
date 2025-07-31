#!/usr/bin/env python3
"""
HSTS Header Addition Script for FreshThreads LLC
Adds HTTP Strict Transport Security headers to HTML files
"""

import os
import re
import glob
from datetime import datetime


class HSTSHeaderManager:
    def __init__(self):
        self.docs_dir = "docs"
        self.hsts_header = 'Strict-Transport-Security'
        # HSTS max-age: 1 year (31536000 seconds), includeSubDomains, preload
        self.hsts_value = 'max-age=31536000; includeSubDomains; preload'
        self.processed_files = []
        self.skipped_files = []
        self.errors = []

    def get_html_files(self):
        """Get all HTML files in the docs directory"""
        pattern = os.path.join(self.docs_dir, "*.html")
        return glob.glob(pattern)

    def has_hsts_header(self, content):
        """Check if file already has HSTS header"""
        # Check for existing HSTS in meta tags
        hsts_pattern = r'<meta\s+http-equiv=["\']Strict-Transport-Security["\'][^>]*>'
        return bool(re.search(hsts_pattern, content, re.IGNORECASE))

    def add_hsts_meta_tag(self, content):
        """Add HSTS meta tag to HTML content"""
        hsts_meta = f'  <meta http-equiv="{self.hsts_header}" content="{self.hsts_value}">'

        # Try to add after existing meta tags
        meta_pattern = r'(<meta[^>]*>)'
        matches = list(re.finditer(meta_pattern, content, re.IGNORECASE))

        if matches:
            # Add after the last meta tag
            last_meta = matches[-1]
            insert_pos = last_meta.end()
            new_content = (content[:insert_pos] +
                           '\n' + hsts_meta +
                           content[insert_pos:])
        else:
            # Add after <head> tag
            head_pattern = r'(<head[^>]*>)'
            head_match = re.search(head_pattern, content, re.IGNORECASE)
            if head_match:
                insert_pos = head_match.end()
                new_content = (content[:insert_pos] +
                               '\n' + hsts_meta +
                               content[insert_pos:])
            else:
                # Add at the beginning if no head tag found
                new_content = hsts_meta + '\n' + content

        return new_content

    def process_file(self, file_path):
        """Process a single HTML file"""
        try:
            print(f"Processing: {file_path}")

            # Read file content
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            # Check if HSTS header already exists
            if self.has_hsts_header(content):
                print(f"  ⚠️  HSTS header already exists, skipping")
                self.skipped_files.append(file_path)
                return

            # Add HSTS header
            new_content = self.add_hsts_meta_tag(content)

            # Write back to file
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)

            print(f"  ✅ HSTS header added successfully")
            self.processed_files.append(file_path)

        except Exception as e:
            error_msg = f"Error processing {file_path}: {str(e)}"
            print(f"  ❌ {error_msg}")
            self.errors.append(error_msg)

    def create_hsts_template(self):
        """Create a template showing proper HSTS implementation"""
        template_content = """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="Strict-Transport-Security" content="max-age=31536000; includeSubDomains; preload">
  <title>HSTS Template - FreshThreads LLC</title>
</head>
<body>
  <h1>HSTS Security Template</h1>
  <p>This template shows proper HSTS header implementation.</p>

  <h2>HSTS Configuration:</h2>
  <ul>
    <li><strong>max-age=31536000</strong>: 1 year validity</li>
    <li><strong>includeSubDomains</strong>: Apply to all subdomains</li>
    <li><strong>preload</strong>: Enable HSTS preloading</li>
  </ul>

  <h2>Security Benefits:</h2>
  <ul>
    <li>Prevents protocol downgrade attacks</li>
    <li>Prevents cookie hijacking</li>
    <li>Forces HTTPS connections</li>
    <li>Protects against SSL stripping</li>
  </ul>
</body>
</html>"""

        template_path = os.path.join(self.docs_dir, "hsts-template.html")
        try:
            with open(template_path, 'w', encoding='utf-8') as f:
                f.write(template_content)
            print(f"📄 HSTS template created: {template_path}")
        except Exception as e:
            print(f"❌ Error creating template: {e}")

    def generate_report(self):
        """Generate a report of the HSTS implementation"""
        report = {
            "timestamp": datetime.now().isoformat(),
            "total_files": len(self.get_html_files()),
            "processed_files": len(self.processed_files),
            "skipped_files": len(self.skipped_files),
            "errors": len(self.errors),
            "hsts_policy": {
                "max_age": "31536000 seconds (1 year)",
                "include_subdomains": True,
                "preload": True
            },
            "processed_list": self.processed_files,
            "skipped_list": self.skipped_files,
            "errors_list": self.errors
        }

        return report

    def run(self):
        """Main execution function"""
        print("🔒 FreshThreads LLC - HSTS Header Implementation")
        print("=" * 50)

        # Check if docs directory exists
        if not os.path.exists(self.docs_dir):
            print(f"❌ Directory '{self.docs_dir}' not found!")
            return

        # Get HTML files
        html_files = self.get_html_files()
        if not html_files:
            print(f"❌ No HTML files found in '{self.docs_dir}'")
            return

        print(f"📁 Found {len(html_files)} HTML files")
        print()

        # Process each file
        for file_path in html_files:
            self.process_file(file_path)

        # Create template
        self.create_hsts_template()

        # Generate summary
        print()
        print("📊 HSTS Implementation Summary:")
        print(f"  ✅ Files processed: {len(self.processed_files)}")
        print(f"  ⚠️  Files skipped: {len(self.skipped_files)}")
        print(f"  ❌ Errors: {len(self.errors)}")

        if self.errors:
            print("\n🚨 Errors encountered:")
            for error in self.errors:
                print(f"  • {error}")

        print()
        print("🔐 HSTS Security Benefits:")
        print("  • Forces HTTPS connections")
        print("  • Prevents protocol downgrade attacks")
        print("  • Protects against SSL stripping")
        print("  • Enables browser HSTS preloading")

        print()
        print("💡 Next Steps:")
        print("  • Submit your domain to HSTS preload list")
        print("  • Test HSTS implementation with online tools")
        print("  • Monitor HSTS compliance regularly")
        print("  • Run 'make hsts-check' to verify implementation")


if __name__ == "__main__":
    manager = HSTSHeaderManager()
    manager.run()
