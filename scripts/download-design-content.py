#!/usr/bin/env python3
"""
Design Content Download Manager
Downloads and organizes the free content found by the collectors.
"""

import json
import requests
from pathlib import Path
import time
from urllib.parse import urlparse
import hashlib
import re


class ContentDownloader:
    """Downloads and manages design content files"""

    def __init__(self, project_root: str = "."):
        self.project_root = Path(project_root)
        self.free_content_dir = self.project_root / \
            "docs" / "assets" / "designs" / "free-content"
        self.downloads_dir = self.free_content_dir / "downloads"
        self.downloads_dir.mkdir(parents=True, exist_ok=True)

        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
        })

    def load_search_results(self) -> dict:
        """Load search results from JSON file"""
        results_file = self.free_content_dir / "enhanced-search-results.json"
        if results_file.exists():
            with open(results_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        return {}

    def download_content(self, limit: int = 10):
        """Download actual content files"""
        results = self.load_search_results()
        if not results:
            print("No search results found. Run enhanced collector first.")
            return

        downloaded = 0
        attribution_data = []

        # Download from Unsplash (most reliable source)
        for item in results.get('unsplash', [])[:limit]:
            if downloaded >= limit:
                break

            try:
                print(f"Downloading: {item['title'][:50]}...")

                # Get file extension from URL
                parsed_url = urlparse(item['download_url'])
                file_ext = '.jpg'  # Unsplash typically serves JPG

                # Create safe filename
                safe_title = re.sub(r'[^\w\-_\.]', '_', item['title'][:30])
                filename = f"unsplash_{item['id']}_{safe_title}{file_ext}"
                filepath = self.downloads_dir / filename

                # Skip if already exists
                if filepath.exists():
                    print(f"  ✅ Already exists: {filename}")
                    continue

                # Download the file
                response = self.session.get(item['download_url'], timeout=30)
                response.raise_for_status()

                # Save the file
                with open(filepath, 'wb') as f:
                    f.write(response.content)

                print(
                    f"  ✅ Downloaded: {filename} ({len(response.content)} bytes)")

                # Track attribution info
                attribution_data.append({
                    'filename': filename,
                    'title': item['title'],
                    'author': item.get('author', 'Unknown'),
                    'source_url': item['url'],
                    'license': item['license'],
                    'attribution_required': item['attribution_required']
                })

                downloaded += 1
                time.sleep(1)  # Rate limiting

            except Exception as e:
                print(f"  ❌ Error downloading {item['title']}: {e}")

        # Generate attribution file
        self.generate_attribution_file(attribution_data)

        print(f"\n✅ Downloaded {downloaded} design files")
        print(f"📁 Files saved to: {self.downloads_dir}")

        return downloaded

    def generate_attribution_file(self, attribution_data):
        """Generate attribution file for downloaded content"""
        attribution_file = self.downloads_dir / "ATTRIBUTIONS.md"

        with open(attribution_file, 'w', encoding='utf-8') as f:
            f.write("# Design Content Attributions\n\n")
            f.write(
                "This file contains attribution information for downloaded design content.\n\n")

            for item in attribution_data:
                f.write(f"## {item['filename']}\n")
                f.write(f"- **Title**: {item['title']}\n")
                f.write(f"- **Author**: {item['author']}\n")
                f.write(f"- **Source**: {item['source_url']}\n")
                f.write(f"- **License**: {item['license']}\n")
                f.write(
                    f"- **Attribution Required**: {'Yes' if item['attribution_required'] else 'No'}\n")

                if item['attribution_required']:
                    f.write(
                        f"- **Attribution Text**: Photo by {item['author']} on Unsplash ({item['source_url']})\n")

                f.write("\n")

        print(f"📋 Attribution file generated: {attribution_file}")


def main():
    import argparse

    parser = argparse.ArgumentParser(
        description="Download free design content")
    parser.add_argument("--limit", type=int, default=5,
                        help="Maximum files to download")
    parser.add_argument("--project-root", default=".",
                        help="Project root directory")

    args = parser.parse_args()

    downloader = ContentDownloader(args.project_root)
    downloader.download_content(args.limit)


if __name__ == "__main__":
    main()
