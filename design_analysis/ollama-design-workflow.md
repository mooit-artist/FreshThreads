# Ollama T-Shirt Design Generation Workflow

**Issue #24 - Fresh Threads LLC Design Creation with Ollama**

---

## 🤖 Ollama Setup for T-Shirt Design

### Prerequisites:

- Ollama installed and running locally
- Model downloaded (llama2, codellama, mistral, etc.)
- Terminal access for Ollama commands

### Recommended Models for Design Work:

- **llama2:13b** - Best overall creativity and detailed responses
- **mistral:7b** - Fast and creative for brainstorming
- **codellama:7b** - Great for tech-themed designs
- **llama2:7b** - Good balance of speed and quality

---

## 🎯 Ollama Prompt Engineering for T-Shirt Designs

### Base Design Generation Command:

```bash
ollama run llama2 "You are a professional T-shirt designer creating concepts for 'Fresh Threads LLC', a motivational/tech apparel brand targeting young professionals and developers. Generate 3 detailed T-shirt design concepts. For each concept provide: 1) Target audience, 2) Main slogan/text, 3) Typography style, 4) Color scheme (hex codes), 5) Layout description, 6) Visual elements. Focus on minimalist, modern designs that are commercially viable for print-on-demand. Brand values: fresh perspective, growth mindset, clean aesthetics."
```

### Specific Design Refinement:

```bash
ollama run llama2 "Refine this T-shirt design for maximum commercial appeal: 'Fresh Perspective, Fresh Success' targeting young professionals. Provide: 1) 5 alternative slogans, 2) 3 font pairing suggestions, 3) 4 color schemes with hex codes, 4) Layout variations, 5) Additional design elements. Make it print-on-demand ready with 2-3 colors max."
```

### Tech-Themed Design Generation:

```bash
ollama run codellama "Create 3 programmer/developer T-shirt designs for 'Fresh Threads LLC'. Include: funny coding references, motivational tech quotes, debug humor. Each design needs: exact text, monospace font specifications, terminal color schemes, layout for center chest placement. Target: software developers, IT professionals, tech entrepreneurs."
```

---

## 🛠️ Ollama Workflow Script

Let me create a script to automate your design generation process:

### Design Generation Script:

````bash
#!/bin/bash
# ollama-design-generator.sh

echo "🎨 Fresh Threads LLC - Ollama Design Generator"
echo "=============================================="

# Create session file with timestamp
SESSION_FILE="design_analysis/llm-sessions/ollama-session-$(date +%Y%m%d-%H%M).md"

echo "# Ollama Design Session - $(date)" > "$SESSION_FILE"
echo "" >> "$SESSION_FILE"

# Design concept generation
echo "💡 Generating design concepts..."
echo "## Concept Generation Prompt:" >> "$SESSION_FILE"
echo '```' >> "$SESSION_FILE"
echo "Professional T-shirt design concepts for Fresh Threads LLC..." >> "$SESSION_FILE"
echo '```' >> "$SESSION_FILE"
echo "" >> "$SESSION_FILE"

echo "## Ollama Response:" >> "$SESSION_FILE"
echo '```' >> "$SESSION_FILE"

# Run Ollama and capture output
ollama run llama2 "You are a professional T-shirt designer for 'Fresh Threads LLC'. Create 3 marketable T-shirt designs targeting: 1) Young professionals seeking motivation, 2) Software developers/programmers, 3) Entrepreneurs and startup founders. For each design provide: Design name, Target audience, Main text/slogan, Typography style recommendation, Color palette (3 colors max with hex codes), Layout description (placement on shirt), Unique selling points. Focus on modern, minimalist aesthetics that work well for print-on-demand. Avoid complex graphics - emphasize typography and simple geometric elements." >> "$SESSION_FILE"

echo '```' >> "$SESSION_FILE"

echo "✅ Session saved to: $SESSION_FILE"
echo "📁 Review the generated concepts and select your favorites!"
````

---

## 🎨 Design Implementation Pipeline

### Step 1: Generate Concepts with Ollama

```bash
./scripts/ollama-design-generator.sh
```

### Step 2: Select Best Concepts

- Review Ollama output in session file
- Choose 2-3 strongest concepts
- Document selection rationale

### Step 3: Create Digital Designs

Based on Ollama specifications:

- Typography: Use recommended fonts
- Colors: Apply exact hex codes from Ollama
- Layout: Follow placement suggestions
- Export: High-res PNG for print

### Step 4: Generate Mockups

- Create T-shirt mockups with designs
- Test on different shirt colors
- Prepare for website integration

---

## 🚀 Quick Start Commands

### Generate Initial Concepts:

```bash
ollama run llama2 "Create 3 T-shirt designs for Fresh Threads LLC: 1 minimalist motivational, 1 tech/programming humor, 1 entrepreneur-focused. Each needs: catchy slogan, 2-color scheme, center chest layout, target demographic. Keep it simple for print-on-demand."
```

### Refine Specific Design:

```bash
ollama run llama2 "Improve this T-shirt concept: 'Fresh Perspective, Fresh Success'. Make it more marketable by suggesting: 5 alternative phrases, 3 color combinations, typography recommendations, and layout variations. Target: 25-35 year old professionals."
```

### Get Technical Specs:

```bash
ollama run llama2 "Convert this design concept into production specifications: [INSERT CONCEPT]. Provide: exact font names with fallbacks, precise hex color codes, sizing for 12x12 inch print area, file format requirements, placement measurements from center/top/sides."
```

---

## 📋 Ollama Session Management

### Session Documentation Template:

```markdown
# Ollama Design Session - [Date]

## Model Used: [llama2/mistral/codellama]

## Prompts and Responses:

### Prompt 1: Concept Generation

**Input:** [Your prompt]
**Output:** [Ollama response]

### Prompt 2: Refinement

**Input:** [Refinement prompt]
**Output:** [Ollama response]

## Selected Concepts:

1. **[Design Name]** - [Target/Description]
2. **[Design Name]** - [Target/Description]

## Implementation Notes:

- [ ] Create Design 1 in Canva
- [ ] Generate color variations
- [ ] Create mockups
- [ ] Add to website
```

---

## 🎯 Success Metrics for Ollama-Generated Designs

### Quality Indicators:

- Clear target audience defined
- Specific color schemes provided
- Typography recommendations included
- Commercial viability considered
- Print-on-demand constraints addressed

### Implementation Checklist:

- [ ] Run Ollama concept generation
- [ ] Document session results
- [ ] Select top 2 concepts
- [ ] Create digital designs
- [ ] Generate mockups
- [ ] Upload to website

---

**Ready to start?** Run your first Ollama design generation session and let's create some amazing T-shirt concepts! 🚀
