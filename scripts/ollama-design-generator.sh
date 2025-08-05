#!/bin/bash

# Fresh Threads LLC - Ollama T-Shirt Design Generator
# Issue #24 Sprint 1 Implementation

echo "🎨 Fresh Threads LLC - Ollama Design Generator"
echo "=============================================="
echo ""

# Check if Ollama is running
if ! command -v ollama &> /dev/null; then
    echo "❌ Ollama not found. Please install Ollama first."
    echo "Visit: https://ollama.ai"
    exit 1
fi

# Create session file with timestamp
TIMESTAMP=$(date +%Y%m%d-%H%M)
SESSION_FILE="design_analysis/llm-sessions/ollama-session-${TIMESTAMP}.md"

echo "📝 Creating session file: $SESSION_FILE"
echo ""

# Initialize session file
cat > "$SESSION_FILE" << EOF
# Ollama T-Shirt Design Session - $(date)

**Model:** llama2
**Goal:** Generate marketable T-shirt designs for Fresh Threads LLC
**Sprint:** 1 - Issue #24

---

## Concept Generation Prompt:
\`\`\`
Create 3 marketable T-shirt designs for 'Fresh Threads LLC' targeting:
1) Young professionals seeking motivation
2) Software developers/programmers
3) Entrepreneurs and startup founders

For each design provide:
- Design name
- Target audience
- Main text/slogan
- Typography style recommendation
- Color palette (3 colors max with hex codes)
- Layout description (placement on shirt)
- Unique selling points

Focus on modern, minimalist aesthetics that work well for print-on-demand.
Avoid complex graphics - emphasize typography and simple geometric elements.
\`\`\`

---

## Ollama Response:
\`\`\`
EOF

echo "💭 Generating T-shirt design concepts with Ollama..."
echo "⏳ This may take a moment..."
echo ""

# Run Ollama and append to session file
ollama run llama2 "Create 3 marketable T-shirt designs for 'Fresh Threads LLC' targeting: 1) Young professionals seeking motivation, 2) Software developers/programmers, 3) Entrepreneurs and startup founders. For each design provide: Design name, Target audience, Main text/slogan, Typography style recommendation, Color palette (3 colors max with hex codes), Layout description (placement on shirt), Unique selling points. Focus on modern, minimalist aesthetics that work well for print-on-demand. Avoid complex graphics - emphasize typography and simple geometric elements." >> "$SESSION_FILE"

# Close the code block
echo '```' >> "$SESSION_FILE"

# Add analysis section
cat >> "$SESSION_FILE" << EOF

---

## Analysis & Selection:

### Concept Rankings:
1. **[Design Name]** - Score: X/10
   - Pros:
   - Cons:
   - Market Appeal:

2. **[Design Name]** - Score: X/10
   - Pros:
   - Cons:
   - Market Appeal:

3. **[Design Name]** - Score: X/10
   - Pros:
   - Cons:
   - Market Appeal:

### Selected for Development:
- [ ] Concept #1: [Name and brief description]
- [ ] Concept #2: [Name and brief description]

---

## Next Steps:
- [ ] Refine selected concepts with additional Ollama prompts
- [ ] Create digital designs in Canva/Figma
- [ ] Generate T-shirt mockups
- [ ] Add to Fresh Threads website
- [ ] Test market appeal

---

## Implementation Notes:
[Add your observations and modifications here]
EOF

echo "✅ Design concepts generated successfully!"
echo "📄 Session saved to: $SESSION_FILE"
echo ""
echo "🎯 Next Steps:"
echo "1. Review the generated concepts in the session file"
echo "2. Select your top 2 designs for development"
echo "3. Create digital versions using the Ollama specifications"
echo "4. Generate mockups for your website"
echo ""
echo "🚀 Ready to create your first Fresh Threads designs!"
