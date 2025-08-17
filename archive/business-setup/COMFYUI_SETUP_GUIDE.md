# Fresh Threads ComfyUI Advanced Pipeline Setup Guide

## 🎯 Quick Start Guide

This guide will help you set up the complete ComfyUI advanced pipeline with DreamShaperXL Turbo, ControlNet Depth, and Dolphin Llama 3 integration.

## 📋 Prerequisites

### 1. ComfyUI Installation

```bash
# Clone ComfyUI
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI

# Install dependencies
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
pip install -r requirements.txt

# Start ComfyUI
python main.py
```

### 2. Required Models

Download these models to your ComfyUI installation:

#### Checkpoint Model

- **File:** `dreamshaper_xl_turbo.safetensors`
- **Location:** `ComfyUI/models/checkpoints/`
- **Source:** Hugging Face - Lykon/DreamShaperXL_Turbo

#### LoRA Model

- **File:** `LCM_LoRA_Weights_SD15.safetensors`
- **Location:** `ComfyUI/models/loras/`
- **Source:** Hugging Face - latent-consistency/lcm-lora-sdv1-5

#### ControlNet Model

- **File:** `control_v11f1p_sd15_depth.pth`
- **Location:** `ComfyUI/models/controlnet/`
- **Source:** Hugging Face - lllyasviel/ControlNet-v1-1

### 3. Ollama Setup

```bash
# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Pull Dolphin Llama 3
ollama pull dolphin-llama3:latest

# Start Ollama (if not auto-started)
ollama serve
```

## 🚀 Running the Pipeline

### Step 1: Start ComfyUI

```bash
cd ComfyUI
python main.py
```

ComfyUI will be available at: <http://127.0.0.1:8188>

### Step 2: Start Ollama

```bash
ollama serve
```

Ollama will be available at: <http://localhost:11434>

### Step 3: Launch Fresh Threads Pipeline

```bash
cd FreshThreads
python3 comfyui_web_interface.py
```

Web interface will be available at: <http://localhost:8081>

## 🎨 Using the Pipeline

### Web Interface Features

1. **ComfyUI Status** - Real-time connection monitoring
2. **Model Requirements** - Download checklist for required models
3. **Theme Selection** - 5 predefined design categories:
   - 🔧 Tech Minimal
   - 🎮 Retro Gaming
   - 🏙️ Streetwear Urban
   - 💪 Motivational Fitness
   - 🎭 Artistic Abstract

4. **Design Configuration** - Enter your concept and enable LCM-LoRA
5. **Generation Options** - Single design or batch processing
6. **Progress Tracking** - Real-time generation status
7. **Results Display** - GitHub-ready outputs

### Workflow Process

1. **Prompt Enhancement** 🧠
   - Dolphin Llama 3 enhances your concept
   - Theme-specific style keywords added
   - Professional design language applied

2. **Image Generation** 🎨
   - DreamShaperXL Turbo for high-quality output
   - ControlNet Depth for precise control
   - LCM-LoRA for ultra-fast generation

3. **Output Preparation** 📁
   - GitHub-ready folder structure
   - Metadata and prompt tracking
   - Printify-compatible formats

## 🛠️ Troubleshooting

### ComfyUI Not Connecting

```bash
# Check if ComfyUI is running
curl http://127.0.0.1:8188/system_stats

# Restart ComfyUI if needed
cd ComfyUI
python main.py
```

### Ollama Issues

```bash
# Check Ollama status
ollama list

# Pull missing models
ollama pull dolphin-llama3:latest

# Restart Ollama
ollama serve
```

### Missing Models

1. Check ComfyUI models directories exist
2. Download models from Hugging Face
3. Place in correct subdirectories
4. Restart ComfyUI

### Generation Failures

1. Verify all models are loaded in ComfyUI
2. Check ComfyUI logs for errors
3. Ensure sufficient GPU memory
4. Try with LCM-LoRA disabled for memory issues

## 📊 Advanced Features

### Batch Generation

- Predefined configurations for multiple themes
- Automatic GitHub output organization
- Progress tracking for multiple designs
- Error handling and retry logic

### GitHub Integration

```
📁 advanced-design-pipeline/
  └── github_output/
      └── design_YYYYMMDD_HHMMSS/
          ├── design_info.json
          ├── enhanced_prompt.txt
          ├── images/
          └── metadata/
```

### Customization

- Edit `design_themes` in `comfyui_advanced_pipeline.py`
- Modify workflow parameters for different styles
- Add new ControlNet models for different guidance types
- Integrate additional LoRA models

## 🎯 Next Steps

1. **Setup Complete** - All components running
2. **Generate Test Design** - Try the web interface
3. **Batch Processing** - Test multiple themes
4. **GitHub Integration** - Version control your designs
5. **Production Use** - Scale for T-shirt production

## 🆘 Support

If you encounter issues:

1. **Check Logs** - ComfyUI console output
2. **Verify Models** - All required files downloaded
3. **Test Components** - Run `comfyui_test_suite.py`
4. **Memory Issues** - Disable LCM-LoRA temporarily
5. **Network Issues** - Check firewall settings

## 🔗 Useful Links

- [ComfyUI GitHub](https://github.com/comfyanonymous/ComfyUI)
- [Ollama Documentation](https://ollama.ai/docs)
- [Hugging Face Models](https://huggingface.co/models)
- [ControlNet Documentation](https://github.com/lllyasviel/ControlNet)
- [DreamShaper XL](https://huggingface.co/Lykon/DreamShaperXL_Turbo)

---

**Fresh Threads LLC** - Advanced AI-Powered T-Shirt Design Pipeline
_Powered by ComfyUI + DreamShaperXL Turbo + ControlNet + Dolphin Llama 3_
