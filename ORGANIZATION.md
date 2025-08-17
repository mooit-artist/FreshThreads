# Project Organization

This document describes the organization structure of the FreshThreads project after cleanup.

## Directory Structure

```
FreshThreads/
├── README.md                   # Main project documentation
├── CONTRIBUTING.md            # Contribution guidelines
├── package.json               # Node.js dependencies
├── package-lock.json          # Dependency lock file
├── Makefile                   # Build automation
├── Dockerfile                 # Docker configuration
├── Dockerfile.sonarqube       # SonarQube Docker config
├── .env*                      # Environment configuration files
├── .git*/                     # Git configuration
├── .vscode/                   # VS Code workspace settings
├── .venv/                     # Python virtual environment
├── node_modules/              # Node.js dependencies
│
├── docs/                      # Website and documentation
│   ├── index.html            # Main website
│   ├── products.html         # Products page
│   ├── assets/               # Website assets
│   └── styles/               # CSS files
│
├── src/                      # Source code
│
├── scripts/                  # Automation scripts
│   ├── etsy/                # Etsy integration scripts
│   ├── printful/            # Printful integration scripts
│   └── fix-all.sh           # General fix script
│
├── tests/                   # Test files
│   ├── javascript/         # JavaScript tests
│   ├── test-products.html  # Product testing page
│   └── test_format.py      # Python test utilities
│
├── config/                 # Configuration files
│   ├── eslint.config.js   # ESLint configuration
│   ├── pyproject.toml     # Python project config
│   ├── requirements-paypal.txt # PayPal dependencies
│   └── package-simple.json # Simplified package config
│
├── tools/                  # Development tools
│   ├── ai-design/         # AI design generation tools
│   │   ├── enhanced_fresh_vision.py
│   │   ├── *design*.py    # Various design generators
│   │   └── ENHANCED-FRESHVISION-GUIDE.md
│   ├── comfyui/          # ComfyUI related tools
│   │   ├── comfyui*.py   # ComfyUI scripts
│   │   └── comfyui*.html # ComfyUI interfaces
│   └── m365tools/        # Microsoft 365 tools
│
├── build/                 # Build outputs and generated files
│   ├── design-output/    # Generated designs
│   ├── generated_designs/ # AI generated content
│   ├── design_analysis/  # Design analysis results
│   └── target/           # Maven build output
│
├── archive/              # Historical and completed documentation
│   ├── project-logs/     # Project milestone documentation
│   │   ├── DAY-1-ACCOMPLISHMENTS.md
│   │   ├── FEATURE_REQUEST_*.md
│   │   └── planning documents
│   ├── business-setup/   # Business setup documentation
│   │   ├── PAYPAL-*.md
│   │   └── integration guides
│   └── security-reports/ # Security scans and reports
│       ├── gitleaks-report.json
│       ├── coverage reports
│       └── security scan results
│
├── assets/               # Project assets
│   └── images/          # Image files
│       ├── *.png        # Logo and design images
│       └── madeinusa.txt # Asset metadata
│
├── logs/                # Runtime logs
├── issues/              # Issue tracking
├── private-docs/        # Private documentation
├── production-ready/    # Production deployment files
├── project-management/  # Project management files
└── ComfyUI/            # ComfyUI installation (consider moving to tools/)
```

## Organization Principles

1. **Source Code** (`src/`, `docs/`) - Active development files
2. **Configuration** (`config/`) - All configuration files in one place
3. **Tools** (`tools/`) - Development and automation tools grouped by purpose
4. **Archive** (`archive/`) - Completed documentation and historical records
5. **Build** (`build/`) - Generated files and build outputs
6. **Tests** (`tests/`) - All testing related files
7. **Assets** (`assets/`) - Static assets like images and media

## Benefits of This Organization

- **Cleaner Root Directory**: Essential files only at the root level
- **Logical Grouping**: Related files are grouped together
- **Easy Navigation**: Clear hierarchy makes finding files easier
- **Better Maintenance**: Separated concerns make updates easier
- **Scalable Structure**: Can grow without becoming messy

## Next Steps

1. Consider moving `ComfyUI/` to `tools/ComfyUI/` when safe to do so
2. Review and update any hardcoded paths in scripts
3. Update CI/CD configurations if they reference moved files
4. Consider adding README files to major subdirectories
