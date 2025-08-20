# FreshThreads Design Content Management

This system helps you collect free-to-use design content from Freepik and TshirtDesigns.com for t-shirt creation.

## 🎯 Purpose

- **Free Content Only**: Only searches and collects content that is explicitly marked as free for commercial use
- **License Tracking**: Maintains attribution requirements and license information
- **T-shirt Focused**: Searches for designs suitable for t-shirt printing
- **Automated Collection**: Streamlined workflow integrated into Makefile

## 🚀 Quick Start

### 1. Set Up Environment

```bash
make design-content-setup
```

This will:

- Install required Python packages (requests, beautifulsoup4, lxml)
- Create necessary directories
- Set up collection scripts

### 2. Collect Free Design Content

```bash
# Collect with default search terms
make design-content-collect

# Collect with custom search terms
make design-content-collect-custom QUERIES="skateboard music vintage retro"
```

### 3. Generate Report

```bash
make design-content-report
```

### 4. Check Status

```bash
make design-content-status
```

## 📁 Directory Structure

```
docs/assets/designs/
├── free-content/                 # Collected free content
│   ├── search-results.json       # Raw search results
│   └── FREE-CONTENT-REPORT.md   # Human-readable report
├── source-files/                 # Downloaded design files
└── ATTRIBUTIONS.md               # Required attributions
```

## 🎨 Content Sources

### Freepik

- **Focus**: Vector graphics, illustrations
- **License**: Free for commercial use with attribution
- **File Types**: SVG, AI, EPS, PNG
- **Rate Limiting**: 2 seconds between requests

### TshirtDesigns.com

- **Focus**: T-shirt specific designs
- **License**: Various (free section only)
- **File Types**: PNG, JPG, SVG
- **Rate Limiting**: 1 second between requests

## 🔍 Default Search Categories

The system searches for these categories by default:

- `minimalist` - Clean, simple designs
- `vintage` - Retro and classic styles
- `geometric` - Abstract geometric patterns
- `nature` - Natural elements and themes
- `abstract` - Abstract artistic designs
- `typography` - Text-based designs
- `retro` - Retro and nostalgic styles
- `modern` - Contemporary designs
- `urban` - Street and city themes
- `outdoor` - Adventure and outdoor themes

## 📋 Available Commands

| Command | Description |
|---------|-------------|
| `make design-content-setup` | Set up the design content collection environment |
| `make design-content-collect` | Collect free content with default search terms |
| `make design-content-collect-custom QUERIES="term1 term2"` | Collect with custom search terms |
| `make design-content-report` | Generate a detailed content report |
| `make design-content-status` | Check system status |
| `make design-content-clean` | Clean collected data |

## ⚖️ License Compliance

### Automatic Tracking

- All collected content includes license information
- Attribution requirements are tracked
- `ATTRIBUTIONS.md` file is automatically generated

### License Types Supported

- ✅ Free for commercial use
- ✅ CC0 Public Domain
- ✅ Creative Commons CC0
- ✅ Royalty Free
- ❌ Premium/Paid content (filtered out)

### Your Responsibilities

1. **Verify License**: Always double-check license terms before use
2. **Provide Attribution**: When required, include proper attribution
3. **Keep Records**: Maintain the `ATTRIBUTIONS.md` file
4. **Respect Terms**: Follow each source's specific terms of use

## 🛠️ Configuration

Edit `scripts/design-content-config.json` to customize:

```json
{
  "content_preferences": {
    "categories": ["minimalist", "vintage", "geometric"],
    "file_types": ["SVG", "PNG", "AI"],
    "max_file_size_mb": 10
  },
  "download_settings": {
    "max_downloads_per_query": 10,
    "max_downloads_per_session": 50
  }
}
```

## 📊 Reports and Analytics

### Content Report (`FREE-CONTENT-REPORT.md`)

- Total content found by source
- Individual design details
- License information
- Usage notes and compliance tips

### Search Results (`search-results.json`)

- Raw API/scraping results
- Metadata for each design
- Timestamp and search parameters

## 🔄 Workflow Integration

### Daily Workflow

```bash
# Morning: Check for new content
make design-content-collect

# Review results
make design-content-report

# Check status
make design-content-status
```

### Project Workflow

```bash
# Before starting a new design project
make design-content-collect-custom QUERIES="project-theme specific-style"

# Review available assets
cat docs/assets/designs/free-content/FREE-CONTENT-REPORT.md

# Use designs while respecting attribution requirements
cat docs/assets/designs/ATTRIBUTIONS.md
```

## ⚠️ Important Notes

### Rate Limiting

- Respectful delays between requests are built-in
- Don't modify rate limiting settings without good reason
- Be mindful of each platform's terms of service

### Content Quality

- All content is marked as "free for commercial use" by the source
- No guarantee of design quality or suitability
- Manual review recommended before using in products

### Legal Disclaimer

- This tool helps find content marked as free by the sources
- Always verify license terms independently
- You are responsible for compliance with licensing terms
- FreshThreads LLC is not responsible for licensing issues

## 🤝 Contributing

### Adding New Sources

1. Create a new client class in `scripts/collect-free-designs.py`
2. Implement the search method following existing patterns
3. Add configuration in `design-content-config.json`
4. Update this README

### Reporting Issues

- Check license compliance before reporting
- Include search terms and error messages
- Verify internet connection and source availability

---

**🚨 Remember**: This system only collects content marked as free for commercial use. Always verify licensing terms and provide attribution when required. When in doubt, contact the original content creator or use content you've created yourself.
