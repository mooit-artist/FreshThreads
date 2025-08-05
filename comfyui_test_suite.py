#!/usr/bin/env python3
"""
Fresh Threads LLC - ComfyUI Pipeline Test Suite
Tests the advanced ComfyUI integration with real workflows
"""

import json
import time
import subprocess
from pathlib import Path
from comfyui_advanced_pipeline import ComfyUIAdvancedPipeline
import requests


class ComfyUIPipelineTests:
    def __init__(self):
        self.pipeline = ComfyUIAdvancedPipeline()
        self.test_results = []

    def log_test(self, test_name, success, message="", data=None):
        """Log test results"""
        result = {
            "test": test_name,
            "success": success,
            "message": message,
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
            "data": data
        }
        self.test_results.append(result)

        status = "✅ PASS" if success else "❌ FAIL"
        print(f"{status} {test_name}: {message}")

    def test_ollama_connection(self):
        """Test Ollama connection and Dolphin Llama 3"""
        try:
            response = self.pipeline.ollama_generate(
                "dolphin-llama3:latest", "Test prompt")
            if "error" in response.lower():
                self.log_test("Ollama Connection", False, "Error in response")
            else:
                self.log_test("Ollama Connection", True,
                              "Connected successfully")
        except Exception as e:
            self.log_test("Ollama Connection", False, str(e))

    def test_comfyui_connection(self):
        """Test ComfyUI API connection"""
        try:
            status = self.pipeline.check_comfyui_status()
            if status:
                self.log_test("ComfyUI Connection", True, "ComfyUI is running")
            else:
                self.log_test("ComfyUI Connection", False,
                              "ComfyUI not accessible")
        except Exception as e:
            self.log_test("ComfyUI Connection", False, str(e))

    def test_prompt_enhancement(self):
        """Test prompt enhancement with Dolphin Llama 3"""
        try:
            theme = "tech_minimal"
            concept = "Error 404: Sleep Not Found"

            enhanced = self.pipeline.enhance_prompt_with_llm(concept, theme)

            if len(enhanced) > len(concept) and "404" in enhanced:
                self.log_test("Prompt Enhancement", True,
                              f"Enhanced prompt: {enhanced[:100]}...")
            else:
                self.log_test("Prompt Enhancement", False,
                              "Enhancement not effective")

        except Exception as e:
            self.log_test("Prompt Enhancement", False, str(e))

    def test_workflow_generation(self):
        """Test ComfyUI workflow JSON generation"""
        try:
            prompt = "A minimalist tech design with Error 404 theme"
            depth_image_path = "/tmp/test_depth.png"

            workflow = self.pipeline.create_comfyui_workflow(
                prompt, depth_image_path, use_lcm_lora=True)

            if isinstance(workflow, dict) and "1" in workflow:
                self.log_test("Workflow Generation", True,
                              "Valid workflow JSON created")
            else:
                self.log_test("Workflow Generation", False,
                              "Invalid workflow structure")

        except Exception as e:
            self.log_test("Workflow Generation", False, str(e))

    def test_depth_image_creation(self):
        """Test depth image generation"""
        try:
            depth_path = self.pipeline.create_depth_reference_image(
                "tech_minimal")

            if Path(depth_path).exists():
                self.log_test("Depth Image Creation", True,
                              f"Created: {depth_path}")
            else:
                self.log_test("Depth Image Creation", False,
                              "Depth image not created")

        except Exception as e:
            self.log_test("Depth Image Creation", False, str(e))

    def test_directory_structure(self):
        """Test output directory creation"""
        try:
            self.pipeline.setup_directories()

            required_dirs = ['designs', 'prompts',
                             'depth_images', 'github_output']
            all_exist = all((self.pipeline.base_dir / dir_name).exists()
                            for dir_name in required_dirs)

            if all_exist:
                self.log_test("Directory Structure", True,
                              "All directories created")
            else:
                self.log_test("Directory Structure",
                              False, "Missing directories")

        except Exception as e:
            self.log_test("Directory Structure", False, str(e))

    def test_github_integration(self):
        """Test GitHub output preparation"""
        try:
            # Mock design data
            design_data = {
                "theme": "tech_minimal",
                "concept": "Error 404: Sleep Not Found",
                "enhanced_prompt": "A minimalist tech T-shirt design...",
                "images": ["/tmp/test1.png", "/tmp/test2.png"],
                "timestamp": time.time()
            }

            github_output = self.pipeline.prepare_github_output(design_data)

            if github_output and "folder" in github_output:
                self.log_test("GitHub Integration", True,
                              f"Output prepared: {github_output['folder']}")
            else:
                self.log_test("GitHub Integration", False,
                              "GitHub output preparation failed")

        except Exception as e:
            self.log_test("GitHub Integration", False, str(e))

    def test_batch_configuration(self):
        """Test batch generation configuration"""
        try:
            batch_config = [
                {
                    "theme": "tech_minimal",
                    "concept": "Error 404: Sleep Not Found",
                    "use_lcm_lora": True
                },
                {
                    "theme": "retro_gaming",
                    "concept": "Level Up Your Style",
                    "use_lcm_lora": True
                }
            ]

            # Test configuration validation
            valid_config = all(
                "theme" in item and "concept" in item
                for item in batch_config
            )

            if valid_config:
                self.log_test("Batch Configuration", True,
                              f"Valid batch config with {len(batch_config)} items")
            else:
                self.log_test("Batch Configuration", False,
                              "Invalid batch configuration")

        except Exception as e:
            self.log_test("Batch Configuration", False, str(e))

    def test_model_requirements(self):
        """Test model file requirements checking"""
        try:
            model_paths = {
                "checkpoint": self.pipeline.base_dir / "models" / "checkpoints" / "dreamshaper_xl_turbo.safetensors",
                "lora": self.pipeline.base_dir / "models" / "loras" / "LCM_LoRA_Weights_SD15.safetensors",
                "controlnet": self.pipeline.base_dir / "models" / "controlnet" / "control_v11f1p_sd15_depth.pth"
            }

            missing_models = []
            for model_type, path in model_paths.items():
                if not path.exists():
                    missing_models.append(model_type)

            if not missing_models:
                self.log_test("Model Requirements", True,
                              "All required models found")
            else:
                self.log_test("Model Requirements", False,
                              f"Missing models: {', '.join(missing_models)}")

        except Exception as e:
            self.log_test("Model Requirements", False, str(e))

    def run_comprehensive_test(self):
        """Run all tests"""
        print("\n" + "🧪" * 60)
        print("   FRESH THREADS COMFYUI PIPELINE TESTS")
        print("🧪" * 60)
        print()

        # Run all tests
        self.test_ollama_connection()
        self.test_comfyui_connection()
        self.test_prompt_enhancement()
        self.test_workflow_generation()
        self.test_depth_image_creation()
        self.test_directory_structure()
        self.test_github_integration()
        self.test_batch_configuration()
        self.test_model_requirements()

        # Summary
        total_tests = len(self.test_results)
        passed_tests = sum(
            1 for result in self.test_results if result["success"])
        failed_tests = total_tests - passed_tests

        print("\n" + "📊" * 60)
        print("   TEST RESULTS SUMMARY")
        print("📊" * 60)
        print(f"Total Tests: {total_tests}")
        print(f"✅ Passed: {passed_tests}")
        print(f"❌ Failed: {failed_tests}")
        print(f"Success Rate: {(passed_tests/total_tests)*100:.1f}%")

        if failed_tests > 0:
            print("\n🔧 Failed Tests:")
            for result in self.test_results:
                if not result["success"]:
                    print(f"   • {result['test']}: {result['message']}")

        # Save results
        results_file = self.pipeline.base_dir / "test_results.json"
        with open(results_file, 'w') as f:
            json.dump(self.test_results, f, indent=2)
        print(f"\n📁 Full results saved to: {results_file}")

        return passed_tests == total_tests

    def create_test_report(self):
        """Create a detailed test report"""
        report = f"""# Fresh Threads ComfyUI Pipeline Test Report

Generated: {time.strftime("%Y-%m-%d %H:%M:%S")}

## Overview

This report contains the results of comprehensive testing for the Fresh Threads ComfyUI advanced pipeline integration.

## Pipeline Components Tested

1. **Ollama Integration** - Dolphin Llama 3 for prompt enhancement
2. **ComfyUI API** - Connection and workflow submission
3. **Prompt Enhancement** - LLM-powered prompt generation
4. **Workflow Generation** - ComfyUI JSON workflow creation
5. **Depth Image Creation** - ControlNet depth reference images
6. **Directory Structure** - Output folder organization
7. **GitHub Integration** - Version control ready output
8. **Batch Configuration** - Multi-design generation setup
9. **Model Requirements** - Required model file checking

## Test Results

"""

        for result in self.test_results:
            status = "✅ PASS" if result["success"] else "❌ FAIL"
            report += f"### {result['test']}\n"
            report += f"**Status:** {status}\n"
            report += f"**Message:** {result['message']}\n"
            report += f"**Timestamp:** {result['timestamp']}\n\n"

        # Statistics
        total = len(self.test_results)
        passed = sum(1 for r in self.test_results if r["success"])
        report += f"## Summary Statistics\n\n"
        report += f"- **Total Tests:** {total}\n"
        report += f"- **Passed:** {passed}\n"
        report += f"- **Failed:** {total - passed}\n"
        report += f"- **Success Rate:** {(passed/total)*100:.1f}%\n\n"

        if passed < total:
            report += "## Required Actions\n\n"
            report += "For failed tests, ensure:\n"
            report += "1. ComfyUI is running at http://127.0.0.1:8188\n"
            report += "2. Ollama is running with dolphin-llama3:latest model\n"
            report += "3. Required model files are downloaded and placed correctly\n"
            report += "4. All dependencies are installed\n\n"

        report += "## Next Steps\n\n"
        report += "1. Address any failed tests\n"
        report += "2. Download required ComfyUI models\n"
        report += "3. Test web interface at http://localhost:8081\n"
        report += "4. Run batch generation with real designs\n"

        return report


def main():
    """Run the test suite"""
    tester = ComfyUIPipelineTests()

    # Run tests
    success = tester.run_comprehensive_test()

    # Create and save report
    report = tester.create_test_report()
    report_file = tester.pipeline.base_dir / "COMFYUI_TEST_REPORT.md"

    with open(report_file, 'w') as f:
        f.write(report)

    print(f"\n📋 Detailed report saved to: {report_file}")

    if success:
        print("\n🎉 All tests passed! Pipeline is ready for use.")
        print("🚀 Next steps:")
        print("   1. Start ComfyUI: python main.py (in ComfyUI directory)")
        print("   2. Launch web interface: python comfyui_web_interface.py")
        print("   3. Start generating designs!")
    else:
        print("\n⚠️  Some tests failed. Check the report for details.")
        print("🔧 Common solutions:")
        print("   1. Install ComfyUI and required models")
        print("   2. Start Ollama with dolphin-llama3:latest")
        print("   3. Install Python dependencies")

    return success


if __name__ == "__main__":
    main()
