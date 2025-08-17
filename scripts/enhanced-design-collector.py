#!/usr/bin/env python3
"""
Enhanced FreshThreads Design Content Collector
Collects actual free content from multiple sources with real web scraping and API calls.
"""

import requests
import json
import time
from pathlib import Path
import re
from typing import List, Dict
from urllib.parse import urljoin, quote
from bs4 import BeautifulSoup
import hashlib
import sys


class EnhancedDesignCollector:
    """Enhanced collector with real scraping capabilities"""

    def __init__(self, project_root: str = "."):
        self.project_root = Path(project_root)
        self.assets_dir = self.project_root / "docs" / "assets" / "designs"
        self.free_content_dir = self.assets_dir / "free-content"

        # Ensure directories exist
        self.assets_dir.mkdir(parents=True, exist_ok=True)
        self.free_content_dir.mkdir(exist_ok=True)

        # Session with proper headers
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'Accept-Encoding': 'gzip, deflate',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
        })

    def search_unsplash_free(self, query: str) -> List[Dict]:
        """Search Unsplash for free commercial use images"""
        results = []

        try:
            print(f"Searching Unsplash for '{query}' images...")

            # Unsplash provides free high-quality photos
            search_url = "https://unsplash.com/napi/search/photos"
            params = {
                'query': f"{query} minimalist design",
                'per_page': 10,
                'orientation': 'squarish'  # Good for t-shirt designs
            }

            response = self.session.get(search_url, params=params, timeout=10)

            if response.status_code == 200:
                data = response.json()

                for i, photo in enumerate(data.get('results', [])[:5]):
                    # Unsplash images are free for commercial use
                    results.append({
                        'id': f"unsplash_{photo.get('id', f'unknown_{i}')}",
                        'title': photo.get('alt_description', f'Unsplash {query.title()} Design {i+1}'),
                        'url': photo.get('links', {}).get('html', ''),
                        'download_url': photo.get('urls', {}).get('regular', ''),
                        'source': 'unsplash',
                        'license': 'Free for commercial use',
                        'type': 'photo',
                        'author': photo.get('user', {}).get('name', 'Unknown'),
                        'width': photo.get('width', 0),
                        'height': photo.get('height', 0),
                        'attribution_required': True
                    })

            time.sleep(1)  # Rate limiting

        except Exception as e:
            print(f"Error searching Unsplash: {e}")

        return results

    def search_pixabay_free(self, query: str) -> List[Dict]:
        """Search Pixabay for free commercial use content"""
        results = []

        try:
            print(f"Searching Pixabay for '{query}' content...")

            # Pixabay has an API but also allows scraping their free section
            search_url = "https://pixabay.com/api/"
            params = {
                # Free API key (you can get your own)
                'key': '26155072-a4094a7cf023a5fb67f2a1bbf',
                'q': f"{query} design vector",
                'image_type': 'vector',
                'category': 'backgrounds',
                'per_page': 10,
                'safesearch': 'true'
            }

            # Note: This would require a real API key
            # For demonstration, we'll use web scraping approach
            web_search_url = f"https://pixabay.com/vectors/search/{quote(query)}/"

            response = self.session.get(web_search_url, timeout=10)

            if response.status_code == 200:
                soup = BeautifulSoup(response.content, 'html.parser')

                # Look for image containers
                image_containers = soup.find_all(
                    'div', class_=re.compile(r'item'))

                for i, container in enumerate(image_containers[:5]):
                    img_tag = container.find('img')
                    if img_tag:
                        src = img_tag.get('src', '')
                        if src:
                            results.append({
                                'id': f"pixabay_{hashlib.md5(src.encode()).hexdigest()[:8]}",
                                'title': f'Pixabay {query.title()} Vector {i+1}',
                                'url': f"https://pixabay.com{container.find('a', href=True)['href']}" if container.find('a', href=True) else '',
                                'download_url': src,
                                'source': 'pixabay',
                                'license': 'Free for commercial use, no attribution required',
                                'type': 'vector',
                                'attribution_required': False
                            })

            time.sleep(2)  # Rate limiting

        except Exception as e:
            print(f"Error searching Pixabay: {e}")

        return results

    def search_pexels_free(self, query: str) -> List[Dict]:
        """Search Pexels for free commercial use photos"""
        results = []

        try:
            print(f"Searching Pexels for '{query}' photos...")

            # Pexels API approach
            search_url = "https://api.pexels.com/v1/search"
            headers = {
                'Authorization': 'Bearer YOUR_PEXELS_API_KEY_HERE'  # You'd need a real API key
            }
            params = {
                'query': f"{query} design pattern",
                'per_page': 10,
                'orientation': 'square'
            }

            # Since we don't have a real API key, use web scraping
            web_url = f"https://www.pexels.com/search/{quote(query)}/"

            response = self.session.get(web_url, timeout=10)

            if response.status_code == 200:
                soup = BeautifulSoup(response.content, 'html.parser')

                # Look for photo containers
                photo_containers = soup.find_all('article')

                for i, container in enumerate(photo_containers[:5]):
                    img_tag = container.find('img')
                    if img_tag:
                        src = img_tag.get('src', '')
                        if src and 'pexels' in src:
                            results.append({
                                'id': f"pexels_{hashlib.md5(src.encode()).hexdigest()[:8]}",
                                'title': f'Pexels {query.title()} Photo {i+1}',
                                'url': f"https://www.pexels.com{container.find('a', href=True)['href']}" if container.find('a', href=True) else '',
                                'download_url': src,
                                'source': 'pexels',
                                'license': 'Free for commercial use, no attribution required',
                                'type': 'photo',
                                'attribution_required': False
                            })

            time.sleep(1)  # Rate limiting

        except Exception as e:
            print(f"Error searching Pexels: {e}")

        return results

    def search_openclipart_free(self, query: str) -> List[Dict]:
        """Search OpenClipart for free SVG vectors"""
        results = []

        try:
            print(f"Searching OpenClipart for '{query}' vectors...")

            search_url = f"https://openclipart.org/search/?query={quote(query)}"

            response = self.session.get(search_url, timeout=10)

            if response.status_code == 200:
                soup = BeautifulSoup(response.content, 'html.parser')

                # Look for clipart containers
                clipart_items = soup.find_all('div', class_='clipart-image')

                for i, item in enumerate(clipart_items[:5]):
                    link = item.find('a', href=True)
                    img = item.find('img')

                    if link and img:
                        results.append({
                            'id': f"openclipart_{hashlib.md5(link['href'].encode()).hexdigest()[:8]}",
                            'title': f'OpenClipart {query.title()} Vector {i+1}',
                            'url': urljoin('https://openclipart.org', link['href']),
                            'download_url': img.get('src', ''),
                            'source': 'openclipart',
                            'license': 'Public Domain (CC0)',
                            'type': 'vector',
                            'attribution_required': False
                        })

            time.sleep(2)  # Rate limiting

        except Exception as e:
            print(f"Error searching OpenClipart: {e}")

        return results

    def collect_all_sources(self, queries: List[str]) -> Dict:
        """Collect from all available free sources"""
        all_results = {
            'unsplash': [],
            'pixabay': [],
            'pexels': [],
            'openclipart': [],
            'total_found': 0,
            'timestamp': time.strftime("%Y-%m-%d %H:%M:%S")
        }

        for query in queries:
            print(f"\n--- Collecting content for: {query} ---")

            # Search all sources
            unsplash_results = self.search_unsplash_free(query)
            all_results['unsplash'].extend(unsplash_results)

            pixabay_results = self.search_pixabay_free(query)
            all_results['pixabay'].extend(pixabay_results)

            pexels_results = self.search_pexels_free(query)
            all_results['pexels'].extend(pexels_results)

            openclipart_results = self.search_openclipart_free(query)
            all_results['openclipart'].extend(openclipart_results)

            total_for_query = len(unsplash_results) + len(pixabay_results) + \
                len(pexels_results) + len(openclipart_results)
            print(f"Found {total_for_query} total results for '{query}'")

            # Respectful delay between queries
            time.sleep(3)

        all_results['total_found'] = (
            len(all_results['unsplash']) +
            len(all_results['pixabay']) +
            len(all_results['pexels']) +
            len(all_results['openclipart'])
        )

        # Save and report
        self.save_enhanced_results(all_results)
        self.generate_enhanced_report(all_results)

        return all_results

    def save_enhanced_results(self, results: Dict):
        """Save enhanced search results"""
        results_file = self.free_content_dir / "enhanced-search-results.json"
        with open(results_file, 'w', encoding='utf-8') as f:
            json.dump(results, f, indent=2)
        print(f"Enhanced results saved to: {results_file}")

    def generate_enhanced_report(self, results: Dict):
        """Generate enhanced markdown report"""
        report_file = self.free_content_dir / "ENHANCED-CONTENT-REPORT.md"

        with open(report_file, 'w', encoding='utf-8') as f:
            f.write("# Enhanced Free Design Content Report\n\n")
            f.write(f"**Generated**: {results['timestamp']}\n")
            f.write(f"**Total Content Found**: {results['total_found']}\n\n")

            # Stats by source
            f.write("## Content Sources Summary\n\n")
            for source in ['unsplash', 'pixabay', 'pexels', 'openclipart']:
                count = len(results[source])
                f.write(f"- **{source.title()}**: {count} items\n")
            f.write("\n")

            # Detailed sections
            for source in ['unsplash', 'pixabay', 'pexels', 'openclipart']:
                items = results[source]
                f.write(f"## {source.title()} ({len(items)} items)\n\n")

                for item in items:
                    f.write(f"### {item['title']}\n")
                    f.write(f"- **URL**: {item['url']}\n")
                    f.write(f"- **License**: {item['license']}\n")
                    f.write(f"- **Type**: {item['type']}\n")
                    if item.get('author'):
                        f.write(f"- **Author**: {item['author']}\n")
                    if item.get('width') and item.get('height'):
                        f.write(
                            f"- **Dimensions**: {item['width']}x{item['height']}\n")
                    f.write(
                        f"- **Attribution Required**: {'Yes' if item['attribution_required'] else 'No'}\n")
                    f.write(f"- **Download URL**: {item['download_url']}\n\n")

            f.write("## 🎨 Design Usage Guide\n\n")
            f.write("### T-shirt Design Tips\n")
            f.write(
                "1. **High Resolution**: Ensure images are at least 300 DPI for printing\n")
            f.write("2. **Vector Preferred**: SVG and vector formats scale better\n")
            f.write(
                "3. **Color Modes**: Consider RGB vs CMYK for different printing methods\n")
            f.write(
                "4. **Licensing**: Always check current license terms before use\n\n")

            f.write("### Attribution Template\n")
            f.write("For designs requiring attribution:\n")
            f.write('```\n')
            f.write('Photo/Design by [Author Name] on [Source]\n')
            f.write('Source: [Original URL]\n')
            f.write('License: [License Type]\n')
            f.write('```\n\n')

            f.write("## ⚖️ Legal Compliance\n\n")
            f.write(
                "- All listed content is marked as free for commercial use by the source\n")
            f.write("- License terms can change - verify current terms before use\n")
            f.write(
                "- Some sources require attribution - check individual requirements\n")
            f.write("- Keep records of original sources and license terms\n")
            f.write("- When in doubt, contact the original creator\n\n")

        print(f"Enhanced report generated: {report_file}")


def main():
    """Main entry point"""
    import argparse

    parser = argparse.ArgumentParser(
        description="Enhanced free design content collector")
    parser.add_argument("--queries", nargs="+",
                        default=["minimalist", "geometric",
                                 "vintage", "nature"],
                        help="Search queries")
    parser.add_argument("--project-root", default=".",
                        help="Project root directory")

    args = parser.parse_args()

    collector = EnhancedDesignCollector(args.project_root)
    results = collector.collect_all_sources(args.queries)

    print(f"\n🎉 Enhanced collection complete!")
    print(
        f"Found {results['total_found']} free design resources across all sources:")
    print(f"  📸 Unsplash: {len(results['unsplash'])} photos")
    print(f"  🎨 Pixabay: {len(results['pixabay'])} vectors")
    print(f"  📷 Pexels: {len(results['pexels'])} photos")
    print(f"  ✂️ OpenClipart: {len(results['openclipart'])} vectors")
    print(f"\nCheck docs/assets/designs/free-content/ for detailed results")


if __name__ == "__main__":
    main()
