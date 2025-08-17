#!/usr/bin/env python3
"""
Fresh Threads LLC - ComfyUI Model Downloader
Downloads required models for the advanced pipeline
"""

import os
import requests
from pathlib import Path
import time


class ComfyUIModelDownloader:
    def __init__(self, comfyui_path="/Users/bryanjorgensen/Documents/GitHub/CodeProjects/WEB/FreshThreads/ComfyUI"):
        self.comfyui_path = Path(comfyui_path)
        self.models_dir = self.comfyui_path / "models"

        # Model download URLs - Fixed and verified
        self.models = {
            "checkpoints": {
                "dreamshaper_xl_turbo.safetensors": {
                    "url": "https://huggingface.co/Lykon/dreamshaper-xl-turbo/resolve/main/DreamShaperXL_Turbo_dpmppSdeKarras_half_pruned_6.safetensors",
                    "size": "6.8 GB"
                }
            },
            "loras": {
                "LCM_LoRA_Weights_SD15.safetensors": {
                    "url": "https://huggingface.co/latent-consistency/lcm-lora-sdv1-5/resolve/main/pytorch_lora_weights.safetensors",
                    "size": "134 MB"
                }
            },
            "controlnet": {
                "control_v11f1p_sd15_depth.pth": {
                    "url": "https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11f1p_sd15_depth.pth",
                    "size": "1.4 GB"
                }
            }
        }

    def ensure_directories(self):
        """Create model directories if they don't exist"""
        for model_type in self.models.keys():
            model_dir = self.models_dir / model_type
            model_dir.mkdir(parents=True, exist_ok=True)
            print(f"✅ Created directory: {model_dir}")

    def download_file(self, url: str, filepath: Path, description: str):
        """Download a file with progress bar"""
        print(f"🔄 Downloading {description}...")
        print(f"   URL: {url}")
        print(f"   Destination: {filepath}")

        try:
            response = requests.get(url, stream=True)
            response.raise_for_status()

            total_size = int(response.headers.get('content-length', 0))
            downloaded = 0

            with open(filepath, 'wb') as f:
                for chunk in response.iter_content(chunk_size=8192):
                    if chunk:
                        f.write(chunk)
                        downloaded += len(chunk)

                        if total_size > 0:
                            percent = (downloaded / total_size) * 100
                            print(
                                f"\r   Progress: {percent:.1f}% ({downloaded // (1024*1024)} MB / {total_size // (1024*1024)} MB)", end="")

            print(f"\n✅ Downloaded: {filepath}")
            return True

        except Exception as e:
            print(f"\n❌ Failed to download {description}: {e}")
            return False

    def check_existing_models(self):
        """Check which models are already downloaded"""
        existing = {}

        for model_type, models in self.models.items():
            existing[model_type] = {}
            model_dir = self.models_dir / model_type

            for model_name, model_info in models.items():
                model_path = model_dir / model_name
                existing[model_type][model_name] = model_path.exists()

        return existing

    def download_all_models(self):
        """Download all required models"""
        print("🎯 ComfyUI Model Downloader for Fresh Threads Advanced Pipeline")
        print("=" * 80)

        # Ensure directories exist
        self.ensure_directories()

        # Check existing models
        existing = self.check_existing_models()

        print("\n📋 Model Status:")
        total_downloads = 0

        for model_type, models in self.models.items():
            print(f"\n📁 {model_type.upper()}:")

            for model_name, model_info in models.items():
                status = "✅ EXISTS" if existing[model_type][model_name] else "⬇️ NEEDED"
                print(f"   {model_name} ({model_info['size']}) - {status}")

                if not existing[model_type][model_name]:
                    total_downloads += 1

        if total_downloads == 0:
            print("\n🎉 All models are already downloaded!")
            return True

        print(f"\n🔄 Need to download {total_downloads} models")

        # Download missing models
        success_count = 0

        for model_type, models in self.models.items():
            for model_name, model_info in models.items():
                if not existing[model_type][model_name]:
                    model_path = self.models_dir / model_type / model_name

                    if self.download_file(model_info["url"], model_path, model_name):
                        success_count += 1
                    else:
                        print(
                            f"❌ Skipping {model_name} due to download failure")

        print(f"\n📊 Download Summary:")
        print(f"   Total needed: {total_downloads}")
        print(f"   Successfully downloaded: {success_count}")
        print(f"   Failed: {total_downloads - success_count}")

        if success_count == total_downloads:
            print("\n🎉 All models downloaded successfully!")
            print("\n🚀 Next steps:")
            print("   1. Models are now in ComfyUI/models/ directories")
            print("   2. Restart ComfyUI to load the new models")
            print("   3. Test the Fresh Threads pipeline!")
            return True
        else:
            print("\n⚠️ Some models failed to download")
            print("💡 You may need to download them manually from Hugging Face")
            return False

    def show_manual_download_instructions(self):
        """Show manual download instructions"""
        print("\n📖 Manual Download Instructions:")
        print("=" * 50)
        print("\nIf automatic download fails, you can download manually:")

        for model_type, models in self.models.items():
            print(f"\n📁 {model_type.upper()} models go in:")
            print(f"   {self.models_dir / model_type}")

            for model_name, model_info in models.items():
                print(f"\n🔗 {model_name}:")
                print(f"   URL: {model_info['url']}")
                print(f"   Size: {model_info['size']}")
                print(f"   Save as: {model_name}")

        print("\n💡 Tips:")
        print("   1. Download files to the correct directories")
        print("   2. Keep the exact filenames")
        print("   3. Restart ComfyUI after downloading")
        print("   4. Check ComfyUI logs for any loading errors")


def main():
    downloader = ComfyUIModelDownloader()

    print("Fresh Threads ComfyUI Model Downloader")
    print("=====================================")
    print()
    print("This script will download the required models for the advanced pipeline:")
    print("1. DreamShaperXL Turbo (6.8 GB)")
    print("2. LCM-LoRA Weights (134 MB)")
    print("3. ControlNet Depth (1.4 GB)")
    print()
    print("Total download size: ~8.3 GB")
    print()

    choice = input(
        "Do you want to proceed with downloads? (y/n): ").lower().strip()

    if choice == 'y':
        success = downloader.download_all_models()
        if not success:
            print("\n" + "="*50)
            downloader.show_manual_download_instructions()
    else:
        print("\n📖 Showing manual download instructions instead:")
        downloader.show_manual_download_instructions()

    print("\n🔗 Useful Links:")
    print("   • Hugging Face: https://huggingface.co/")
    print("   • ComfyUI Docs: https://docs.comfy.org/")
    print("   • Fresh Threads Pipeline: http://localhost:8081")


if __name__ == "__main__":
    main()
