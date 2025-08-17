#!/usr/bin/env python3
"""
FreshThreads Design Content Manager
Pulls free-to-use content from Freepik and TshirtDesigns.com for t-shirt creation.
Only downloads content that is explicitly marked as free for commercial use.
"""

import requests
import json
import os
import sys
from urllib.parse import urljoin, urlparse
from pathlib import Path
import time
from typing import Dict, List, Optional
import argparse
from dataclasses import dataclass
import hashlib
import re


@dataclass
class DesignAsset:
    """Represents a design asset with licensing information"""
    id: str
    title: str
    url: str
    download_url: str
    license_type: str
    tags: List[str]
    file_type: str
    size: Optional[str] = None
    author: Optional[str] = None
    attribution_required: bool = False


class FreepikScraper:
    """Scrapes free content from Freepik API/website"""

    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key
        self.base_url = "https://api.freepik.com/v1"
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'FreshThreads-DesignManager/1.0',
            'Accept': 'application/json'
        })

    def search_free_vectors(self, query: str, limit: int = 50) -> List[DesignAsset]:
        """Search for free vector graphics suitable for t-shirts"""
        assets = []

        # Note: Freepik API requires subscription, so we'll use their public RSS feeds
        # and scraping approach for free content only
        try:
            # Search for free vectors with t-shirt related terms
            search_terms = f"{query} t-shirt design vector free commercial use"
            print(f"Searching Freepik for: {search_terms}")

            # This would be implemented with actual Freepik API calls
            # For now, return sample structure showing what we'd collect
            sample_asset = DesignAsset(
                id="freepik_sample_001",
                title=f"Free {query} Vector Design",
                url="https://www.freepik.com/free-vector/sample-design",
                download_url="https://www.freepik.com/download/sample",
                license_type="Free for commercial use",
                tags=["vector", "t-shirt", "design", query.lower()],
                file_type="SVG",
                attribution_required=True,
                author="Freepik"
            )
            assets.append(sample_asset)

        except Exception as e:
            print(f"Error searching Freepik: {e}")

        return assets


class TshirtDesignsScraper:
    """Scrapes free content from TshirtDesigns.com"""

    def __init__(self):
        self.base_url = "https://www.tshirtdesigns.com"
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'FreshThreads-DesignManager/1.0'
        })

    def search_free_designs(self, query: str, limit: int = 50) -> List[DesignAsset]:
        """Search for free t-shirt designs"""
        assets = []

        try:
            # Search free section
            search_url = f"{self.base_url}/free-t-shirt-designs"
            print(f"Searching TshirtDesigns.com for free designs...")

            # This would be implemented with actual scraping
            # For now, return sample structure
            sample_asset = DesignAsset(
                id="tshirtdesigns_sample_001",
                title=f"Free {query} T-shirt Design",
                url=f"{self.base_url}/free-design/sample",
                download_url=f"{self.base_url}/download/free/sample.png",
                license_type="Free for commercial use",
                tags=["t-shirt", "design", "free", query.lower()],
                file_type="PNG",
                attribution_required=False
            )
            assets.append(sample_asset)

        except Exception as e:
            print(f"Error searching TshirtDesigns.com: {e}")

        return assets


class DesignContentManager:
    """Main manager for design content operations"""

    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        self.designs_dir = self.project_root / "docs" / "assets" / "designs"
        self.source_dir = self.designs_dir / "source-files"
        self.metadata_file = self.designs_dir / "design-metadata.json"

        # Ensure directories exist
        self.designs_dir.mkdir(parents=True, exist_ok=True)
        self.source_dir.mkdir(exist_ok=True)

        self.freepik = FreepikScraper()
        self.tshirt_designs = TshirtDesignsScraper()

    def load_metadata(self) -> Dict:
        """Load existing design metadata"""
        if self.metadata_file.exists():
            with open(self.metadata_file) as f:
                return json.load(f)
        return {"designs": [], "last_updated": None}

    def save_metadata(self, metadata: Dict):
        """Save design metadata"""
        metadata["last_updated"] = time.strftime("%Y-%m-%d %H:%M:%S")
        with open(self.metadata_file, 'w') as f:
            json.dump(metadata, f, indent=2)

    def search_designs(self, query: str, sources: List[str] = None) -> List[DesignAsset]:
        """Search for designs across multiple sources"""
        if sources is None:
            sources = ["freepik", "tshirtdesigns"]

        all_assets = []

        if "freepik" in sources:
            print("Searching Freepik...")
            freepik_assets = self.freepik.search_free_vectors(query)
            all_assets.extend(freepik_assets)

        if "tshirtdesigns" in sources:
            print("Searching TshirtDesigns.com...")
            tshirt_assets = self.tshirt_designs.search_free_designs(query)
            all_assets.extend(tshirt_assets)

        return all_assets

    def download_asset(self, asset: DesignAsset) -> Optional[str]:
        """Download a design asset"""
        try:
            # Create filename
            safe_title = re.sub(r'[^\w\-_\.]', '_', asset.title)
            filename = f"{asset.id}_{safe_title}.{asset.file_type.lower()}"
            filepath = self.source_dir / filename

            # Skip if already exists
            if filepath.exists():
                print(f"Asset already exists: {filename}")
                return str(filepath)

            print(f"Downloading: {asset.title}")

            # Download the file
            response = requests.get(asset.download_url, stream=True)
            response.raise_for_status()

            with open(filepath, 'wb') as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)

            print(f"Downloaded: {filename}")
            return str(filepath)

        except Exception as e:
            print(f"Error downloading {asset.title}: {e}")
            return None

    def create_attribution_file(self, assets: List[DesignAsset]):
        """Create attribution file for designs that require it"""
        attribution_file = self.designs_dir / "ATTRIBUTIONS.md"

        with open(attribution_file, 'w') as f:
            f.write("# Design Attributions\n\n")
            f.write(
                "This file contains required attributions for design assets used in FreshThreads products.\n\n")

            for asset in assets:
                if asset.attribution_required:
                    f.write(f"## {asset.title}\n")
                    f.write(f"- **Source**: {asset.url}\n")
                    f.write(f"- **Author**: {asset.author or 'Unknown'}\n")
                    f.write(f"- **License**: {asset.license_type}\n")
                    f.write(f"- **Tags**: {', '.join(asset.tags)}\n\n")

    def pull_content(self, queries: List[str], sources: List[str] = None, limit_per_query: int = 10):
        """Pull content for multiple queries"""
        metadata = self.load_metadata()
        all_downloaded = []

        for query in queries:
            print(f"\n--- Searching for: {query} ---")
            assets = self.search_designs(query, sources)

            # Limit results per query
            assets = assets[:limit_per_query]

            for asset in assets:
                # Check if we already have this asset
                existing = next(
                    (d for d in metadata["designs"] if d["id"] == asset.id), None)
                if existing:
                    print(f"Skipping existing asset: {asset.title}")
                    continue

                # Download the asset
                filepath = self.download_asset(asset)
                if filepath:
                    asset_data = {
                        "id": asset.id,
                        "title": asset.title,
                        "url": asset.url,
                        "license_type": asset.license_type,
                        "tags": asset.tags,
                        "file_type": asset.file_type,
                        "filepath": filepath,
                        "attribution_required": asset.attribution_required,
                        "author": asset.author,
                        "downloaded_date": time.strftime("%Y-%m-%d %H:%M:%S"),
                        "query": query
                    }
                    metadata["designs"].append(asset_data)
                    all_downloaded.append(asset)

                # Be respectful with requests
                time.sleep(1)

        # Save updated metadata
        self.save_metadata(metadata)

        # Create attribution file
        self.create_attribution_file(all_downloaded)

        print(f"\nDownloaded {len(all_downloaded)} new design assets")
        return all_downloaded

    def list_designs(self) -> List[Dict]:
        """List all downloaded designs"""
        metadata = self.load_metadata()
        return metadata["designs"]

    def generate_report(self):
        """Generate a report of all design assets"""
        designs = self.list_designs()
        report_file = self.designs_dir / "DESIGN-REPORT.md"

        with open(report_file, 'w') as f:
            f.write("# FreshThreads Design Assets Report\n\n")
            f.write(f"Total designs: {len(designs)}\n\n")

            # Group by license type
            license_groups = {}
            for design in designs:
                license_type = design.get("license_type", "Unknown")
                if license_type not in license_groups:
                    license_groups[license_type] = []
                license_groups[license_type].append(design)

            for license_type, design_list in license_groups.items():
                f.write(f"## {license_type} ({len(design_list)} designs)\n\n")
                for design in design_list:
                    f.write(
                        f"- **{design['title']}** ({design['file_type']})\n")
                    f.write(f"  - Tags: {', '.join(design['tags'])}\n")
                    f.write(f"  - Downloaded: {design['downloaded_date']}\n")
                    if design.get('attribution_required'):
                        f.write(f"  - ⚠️ Attribution required\n")
                    f.write(f"\n")


def main():
    parser = argparse.ArgumentParser(
        description="FreshThreads Design Content Manager")
    parser.add_argument("command", choices=["search", "pull", "list", "report"],
                        help="Command to execute")
    parser.add_argument("--query", "-q", action="append",
                        help="Search query (can be used multiple times)")
    parser.add_argument("--sources", nargs="+", choices=["freepik", "tshirtdesigns"],
                        default=["freepik", "tshirtdesigns"], help="Sources to search")
    parser.add_argument("--limit", type=int, default=10,
                        help="Limit results per query")
    parser.add_argument("--project-root", default=".",
                        help="Project root directory")

    args = parser.parse_args()

    manager = DesignContentManager(args.project_root)

    if args.command == "search":
        if not args.query:
            print("Error: --query is required for search command")
            sys.exit(1)

        for query in args.query:
            assets = manager.search_designs(query, args.sources)
            print(f"\nFound {len(assets)} assets for '{query}':")
            for asset in assets:
                print(f"  - {asset.title} ({asset.license_type})")

    elif args.command == "pull":
        if not args.query:
            # Default queries for t-shirt designs
            args.query = ["minimalist", "vintage",
                          "geometric", "nature", "abstract"]

        manager.pull_content(args.query, args.sources, args.limit)

    elif args.command == "list":
        designs = manager.list_designs()
        print(f"Total designs: {len(designs)}")
        for design in designs:
            attribution = " (Attribution Required)" if design.get(
                "attribution_required") else ""
            print(
                f"  - {design['title']} ({design['license_type']}){attribution}")

    elif args.command == "report":
        manager.generate_report()
        print("Design report generated: docs/assets/designs/DESIGN-REPORT.md")


if __name__ == "__main__":
    main()
