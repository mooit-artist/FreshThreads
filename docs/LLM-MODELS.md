# FreshThreads LLM Model Management

This document explains how to use different LLM models for various tasks in the FreshThreads project.

## 🤖 Available Models

### Default Models by Task

| Task                      | Recommended Model | Description                               |
| ------------------------- | ----------------- | ----------------------------------------- |
| **Code Review**           | `dolphin-llama3`  | General purpose, good for web development |
| **Security Analysis**     | `llama3:8b`       | Balanced model for security reviews       |
| **Architecture Analysis** | `codellama:13b`   | Advanced code analysis                    |
| **Chat/General**          | `dolphin-llama3`  | Interactive conversations                 |
| **Improvements**          | `dolphin-llama3`  | Design and UX suggestions                 |
| **Compatibility**         | `llama3:8b`       | GitHub Pages constraint checking          |
| **Documentation**         | `codellama:7b`    | Code documentation and comments           |

### Model Descriptions

- **dolphin-llama3**: General purpose, excellent for web development and design discussions
- **llama3:8b**: Balanced model good for analysis and security reviews
- **llama3:13b**: Larger model for complex analysis tasks
- **codellama:7b**: Specialized for code analysis and documentation
- **codellama:13b**: Advanced code analysis and architecture review
- **mistral:7b**: Fast responses for quick tasks
- **mixtral:8x7b**: High quality for complex reasoning tasks

## 🛠️ Make Commands

### Basic Usage (uses default models)

```bash
make llm-analyze              # Project structure analysis
make llm-security             # Security review
make llm-improve              # Improvement suggestions
make llm-chat                 # Interactive chat
```

### With Custom Models

```bash
make llm-analyze MODEL=codellama:13b
make llm-security MODEL=llama3:8b
make llm-chat MODEL=mistral:7b
```

### With Specific Files

```bash
make llm-review FILE=docs/index.html MODEL=codellama:7b
make llm-analyze FILE=docs/products.html
```

### Model Management

```bash
make llm-models               # List available models
make llm-tasks                # Show recommended models for tasks
make llm-pull MODEL=mistral:7b    # Pull a new model
make llm-switch MODEL=codellama:13b  # Switch default model
```

## 📱 Script Usage

### Direct Script Commands

```bash
# Basic analysis
./scripts/llm-helper.sh analyze
./scripts/llm-helper.sh analyze docs/index.html

# With custom models
./scripts/llm-helper.sh analyze docs/index.html codellama:7b
./scripts/llm-helper.sh security llama3:8b
./scripts/llm-helper.sh improve mistral:7b

# Model management
./scripts/llm-helper.sh models
./scripts/llm-helper.sh pull codellama:13b
./scripts/llm-helper.sh switch mistral:7b
./scripts/llm-helper.sh tasks
```

## 💬 Interactive Chat Commands

When using `make llm-chat` or `./scripts/llm-helper.sh chat`, you can use these commands:

```
/analyze [file] [model]    - Analyze specific file
/structure [model]         - Analyze project structure
/security [model]          - Security review
/improve [model]           - Improvement suggestions
/compat [model]            - GitHub Pages compatibility
/models                    - List available models
/switch <model>            - Switch current model
/tasks                     - Show recommended models
/pull <model>              - Pull a new model
```

### Examples:

```
🤖 FreshThreads LLM> /analyze docs/index.html codellama:7b
🤖 FreshThreads LLM> /security llama3:8b
🤖 FreshThreads LLM> /switch mistral:7b
🤖 FreshThreads LLM> /models
```

## 🎯 Task-Specific Recommendations

### For Code Reviews

```bash
make llm-review FILE=docs/index.html MODEL=codellama:7b
```

- Use `codellama:7b` or `codellama:13b` for detailed code analysis
- Use `dolphin-llama3` for general web development feedback

### For Security Analysis

```bash
make llm-security MODEL=llama3:8b
```

- Use `llama3:8b` for balanced security analysis
- Consider `mixtral:8x7b` for complex security scenarios

### For Architecture Analysis

```bash
make llm-analyze MODEL=codellama:13b
```

- Use `codellama:13b` for complex architectural decisions
- Use `llama3:13b` for large-scale analysis

### For Quick Tasks

```bash
make llm-improve MODEL=mistral:7b
```

- Use `mistral:7b` for fast responses
- Use `dolphin-llama3` for balanced speed and quality

## 🔧 Model Management

### Pulling New Models

```bash
# Pull specific models
make llm-pull MODEL=codellama:13b
make llm-pull MODEL=mistral:7b
make llm-pull MODEL=mixtral:8x7b

# Or using the script directly
./scripts/llm-helper.sh pull codellama:13b
```

### Switching Models

```bash
# Switch default model for session
make llm-switch MODEL=codellama:13b

# Or in interactive chat
🤖 FreshThreads LLM> /switch codellama:13b
```

### Checking Available Models

```bash
make llm-models              # List all available models
make llm-tasks               # Show task recommendations
```

## 🚀 Best Practices

1. **Use task-appropriate models**: Each model has strengths for specific tasks
2. **Start with defaults**: The configured defaults work well for most cases
3. **Pull models ahead of time**: Large models take time to download
4. **Monitor resource usage**: Larger models require more RAM and processing power
5. **Experiment**: Try different models to find what works best for your workflow

## 📊 Performance Considerations

| Model Size  | RAM Usage | Speed  | Quality | Best For                 |
| ----------- | --------- | ------ | ------- | ------------------------ |
| 7B models   | ~8GB      | Fast   | Good    | Quick tasks, general use |
| 8B models   | ~10GB     | Medium | Good    | Balanced tasks           |
| 13B models  | ~16GB     | Slower | Better  | Complex analysis         |
| 8x7B models | ~45GB     | Slow   | Best    | Complex reasoning        |

## 🔄 Workflow Examples

### Full Project Review

```bash
# 1. Start with structure analysis
make llm-analyze MODEL=codellama:13b

# 2. Security review
make llm-security MODEL=llama3:8b

# 3. Check specific files
make llm-review FILE=docs/index.html MODEL=codellama:7b

# 4. Get improvement suggestions
make llm-improve MODEL=dolphin-llama3
```

### Quick Development Iteration

```bash
# Fast analysis with smaller model
make llm-analyze MODEL=mistral:7b

# Quick chat for ideas
make llm-chat MODEL=dolphin-llama3
```

### Deep Architecture Review

```bash
# Use largest available model for complex analysis
make llm-analyze MODEL=mixtral:8x7b

# Interactive session for follow-up questions
make llm-chat MODEL=mixtral:8x7b
```
