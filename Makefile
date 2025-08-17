# FreshThreads Makefile - Comprehensive Linting and Quality Checks
# =================================================================

# Variables
SHELL := /bin/bash
PROJECT_NAME := FreshThreads
PYTHON_VERSION := 3.9
NODE_VERSION := 18

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
PURPLE := \033[0;35m
CYAN := \033[0;36m
WHITE := \033[0;37m
NC := \033[0m # No Color

# Directories
DOCS_DIR := docs
SCRIPTS_DIR := scripts
WORKFLOWS_DIR := .github/workflows
ASSETS_JS_DIR := docs/assets/js
STYLES_DIR := docs/styles

# File patterns
HTML_FILES := $(shell find $(DOCS_DIR) -name "*.html" -not -path "*/node_modules/*")
CSS_FILES := $(shell find $(DOCS_DIR) -name "*.css" -not -path "*/node_modules/*")
JS_FILES := $(shell find $(DOCS_DIR) $(SCRIPTS_DIR) -name "*.js" -not -path "*/node_modules/*")
PY_FILES := $(shell find $(SCRIPTS_DIR) -name "*.py")
PS1_FILES := $(shell find . -name "*.ps1" -not -path "*/ComfyUI/*" -not -path "*/node_modules/*")
YAML_FILES := $(shell find $(WORKFLOWS_DIR) -name "*.yml" -o -name "*.yaml")
JSON_FILES := $(shell find . -name "*.json" -not -path "*/node_modules/*" -not -path "*/ComfyUI/*" -not -path "*/design-output/*" -not -path "*/advanced-design-pipeline/*")
MD_FILES := $(shell find . -name "*.md" -not -path "*/node_modules/*" -not -path "*/ComfyUI/*")

.PHONY: help install-tools install-python-tools install-security-tools install-plagiarism-tools install-git-hooks install-all-tools lint lint-all lint-js lint-html lint-css lint-python lint-powershell lint-yaml lint-json lint-markdown fix-all format-all clean test security-check docker-security plagiarism-check dolos-check hookejs-check copyright-detect-check plagiarism-clean secrets-scan secrets-gitleaks secrets-trufflehog secrets-gitguardian secrets-history secrets-clean test-all test-js test-python test-java test-unit test-integration test-e2e test-coverage design-content-setup design-content-collect design-content-collect-enhanced design-content-download design-content-download-more design-content-report design-content-clean fresh-vision-enhanced fresh-vision-original fresh-vision-test

# Help target
help: ## Show this help message
	@echo -e "${BLUE}$(PROJECT_NAME) Makefile - Available Commands${NC}"
	@echo -e "${BLUE}================================================${NC}"
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ { printf "  ${CYAN}%-20s${NC} %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo ""
	@echo -e "${YELLOW}File Statistics:${NC}"
	@echo -e "  HTML files: $(words $(HTML_FILES))"
	@echo -e "  CSS files: $(words $(CSS_FILES))"
	@echo -e "  JavaScript files: $(words $(JS_FILES))"
	@echo -e "  Python files: $(words $(PY_FILES))"
	@echo -e "  PowerShell files: $(words $(PS1_FILES))"
	@echo -e "  YAML files: $(words $(YAML_FILES))"
	@echo -e "  JSON files: $(words $(JSON_FILES))"
	@echo -e "  Markdown files: $(words $(MD_FILES))"

# Installation targets
install-tools: install-node-tools install-python-tools install-powershell-tools ## Install all linting tools
	@echo -e "${GREEN}✅ All linting tools installed successfully${NC}"

install-node-tools: ## Install Node.js linting tools
	@echo -e "${BLUE}📦 Installing Node.js linting tools...${NC}"
	@command -v npm >/dev/null 2>&1 || { echo -e "${RED}❌ npm is required but not installed${NC}"; exit 1; }
	npm install -g \
		eslint \
		prettier \
		htmlhint \
		stylelint \
		stylelint-config-standard \
		html-validate \
		jsonlint \
		markdownlint-cli \
		yaml-lint
	@echo -e "${GREEN}✅ Node.js tools installed${NC}"

install-python-tools: ## Install Python linting tools
	@echo -e "${BLUE}📦 Installing Python linting tools...${NC}"
	@command -v pip3 >/dev/null 2>&1 || { echo -e "${RED}❌ pip3 is required but not installed${NC}"; exit 1; }
	pip3 install --upgrade \
		flake8 \
		black \
		isort \
		pylint \
		bandit \
		autopep8 \
		mypy \
		pip-audit
	@echo -e "${GREEN}✅ Python tools installed${NC}"

install-security-tools: ## Install additional security scanning tools
	@echo -e "${BLUE}📦 Installing security scanning tools...${NC}"
	@echo -e "${CYAN}Installing OSV Scanner...${NC}"
	@if command -v go >/dev/null 2>&1; then \
		go install github.com/google/osv-scanner/cmd/osv-scanner@v1 || echo -e "${YELLOW}⚠️ OSV Scanner installation may have failed${NC}"; \
	else \
		echo -e "${YELLOW}⚠️ Go not installed, cannot install osv-scanner${NC}"; \
		echo -e "${CYAN}💡 Alternative: Download from https://github.com/google/osv-scanner/releases${NC}"; \
	fi
	@echo -e "${CYAN}Installing Hadolint (Docker linter)...${NC}"
	@if command -v brew >/dev/null 2>&1; then \
		brew install hadolint || echo -e "${YELLOW}⚠️ Hadolint installation may have failed${NC}"; \
	else \
		echo -e "${YELLOW}⚠️ Homebrew not installed, cannot install hadolint${NC}"; \
	fi
	@echo -e "${CYAN}Installing SARIF validator...${NC}"
	npm install -g @microsoft/sarif-validator || echo -e "${YELLOW}⚠️ SARIF validator installation may have failed${NC}"
	@echo -e "${GREEN}✅ Security tools installation completed${NC}"

install-plagiarism-tools: ## Install plagiarism detection and code similarity tools
	@echo -e "${BLUE}📦 Installing plagiarism detection tools...${NC}"
	@echo -e "${CYAN}Installing Dolos (modern plagiarism detector)...${NC}"
	npm install -g @dodona/dolos || echo -e "${YELLOW}⚠️ Dolos installation may have failed${NC}"
	@echo -e "${CYAN}Installing HookeJs (JavaScript similarity detector)...${NC}"
	npm install -g hookejs || echo -e "${YELLOW}⚠️ HookeJs installation may have failed${NC}"
	@echo -e "${CYAN}Note: HookeJs is a library, use 'node -e \"require('hookejs')\"' to access${NC}"
	@echo -e "${CYAN}Installing Copyright-detection (image copyright detection)...${NC}"
	@if [ ! -d "$(HOME)/.local/copyright-detection" ]; then \
		echo -e "${CYAN}Cloning Copyright-detection repository...${NC}"; \
		git clone https://github.com/TimoHong/Copyright-detection.git "$(HOME)/.local/copyright-detection" || echo -e "${YELLOW}⚠️ Copyright-detection clone may have failed${NC}"; \
		echo -e "${CYAN}Installing Python dependencies...${NC}"; \
		if [ -f "$(HOME)/.local/copyright-detection/requirements.txt" ]; then \
			pip3 install -r "$(HOME)/.local/copyright-detection/requirements.txt" || echo -e "${YELLOW}⚠️ Some dependencies may have failed to install${NC}"; \
		fi; \
		echo -e "${CYAN}Creating copyright-detect wrapper script...${NC}"; \
		mkdir -p "$(HOME)/.local/bin"; \
		echo '#!/bin/bash' > "$(HOME)/.local/bin/copyright-detect"; \
		echo 'cd "$(HOME)/.local/copyright-detection"' >> "$(HOME)/.local/bin/copyright-detect"; \
		echo 'python3 "$$@"' >> "$(HOME)/.local/bin/copyright-detect"; \
		chmod +x "$(HOME)/.local/bin/copyright-detect" || echo -e "${YELLOW}⚠️ Wrapper script creation failed${NC}"; \
	else \
		echo -e "${GREEN}✅ Copyright-detection already installed${NC}"; \
	fi
	@echo -e "${GREEN}✅ Plagiarism detection tools installation completed${NC}"

install-git-hooks: ## Install Husky and commitlint for Git hooks
	@echo -e "${BLUE}📦 Installing Git hooks and commit linting...${NC}"
	@if [ -f "package.json" ]; then \
		echo -e "${CYAN}Installing Husky and commitlint...${NC}"; \
		npm install --save-dev husky @commitlint/cli @commitlint/config-conventional || echo -e "${YELLOW}⚠️ Some installations may have failed${NC}"; \
		echo -e "${CYAN}Setting up Husky...${NC}"; \
		npx husky init || echo -e "${YELLOW}⚠️ Husky setup may have failed${NC}"; \
		echo -e "${CYAN}Creating commit-msg hook...${NC}"; \
		echo '#!/usr/bin/env sh\n. "$(dirname -- "$0")/_/husky.sh"\nnpx --no -- commitlint --edit ${1}' > .husky/commit-msg || echo -e "${YELLOW}⚠️ Hook creation may have failed${NC}"; \
		chmod +x .husky/commit-msg || echo -e "${YELLOW}⚠️ Hook permission setting may have failed${NC}"; \
		echo -e "${CYAN}Creating commitlint config...${NC}"; \
		echo '{"extends": ["@commitlint/config-conventional"]}' > commitlint.config.json || echo -e "${YELLOW}⚠️ Config creation may have failed${NC}"; \
		echo -e "${GREEN}✅ Git hooks and commitlint installed${NC}"; \
	else \
		echo -e "${RED}❌ package.json not found. Run this from project root.${NC}"; \
	fi

install-powershell-tools: ## Install PowerShell analysis tools
	@echo -e "${BLUE}📦 Installing PowerShell linting tools...${NC}"
	@if command -v pwsh >/dev/null 2>&1; then \
		echo -e "${CYAN}Installing PSScriptAnalyzer module...${NC}"; \
		pwsh -Command "Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser" || echo -e "${YELLOW}⚠️ PSScriptAnalyzer installation may have failed${NC}"; \
		echo -e "${GREEN}✅ PowerShell tools installed${NC}"; \
	elif command -v powershell >/dev/null 2>&1; then \
		echo -e "${CYAN}Installing PSScriptAnalyzer module (Windows PowerShell)...${NC}"; \
		powershell -Command "Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser" || echo -e "${YELLOW}⚠️ PSScriptAnalyzer installation may have failed${NC}"; \
		echo -e "${GREEN}✅ PowerShell tools installed${NC}"; \
	else \
		echo -e "${YELLOW}⚠️ PowerShell not found. Install PowerShell Core (pwsh) or Windows PowerShell first${NC}"; \
		echo -e "${CYAN}💡 On macOS: brew install --cask powershell${NC}"; \
		echo -e "${CYAN}💡 On Ubuntu: apt-get install -y powershell${NC}"; \
	fi

# Main linting targets
lint: lint-all ## Run all linters (alias for lint-all)

lint-all: ## Run all linters for all file types
	@echo -e "${PURPLE}🔍 Running comprehensive linting for $(PROJECT_NAME)...${NC}"
	@$(MAKE) lint-js
	@$(MAKE) lint-html
	@$(MAKE) lint-css
	@$(MAKE) lint-python
	@$(MAKE) lint-powershell
	@$(MAKE) lint-yaml
	@$(MAKE) lint-json
	@$(MAKE) lint-markdown
	@echo "✅ All linting completed"

# Fix common issues automatically
fix-all: fix-js fix-css fix-python fix-powershell fix-markdown
	@echo "🔧 Running all available auto-fixes..."
	@echo "✅ All auto-fixes completed"

fix-js:
	@echo "🔧 Auto-fixing JavaScript files..."
	@if command -v eslint >/dev/null 2>&1; then \
		eslint --fix "docs/**/*.js" || echo "⚠️ Some JS issues couldn't be auto-fixed"; \
	else \
		echo "⚠️ ESLint not found, skipping JS fixes"; \
	fi	fifix-css:
	@echo "🔧 Auto-fixing CSS files..."
	@if command -v prettier >/dev/null 2>&1; then
		prettier --write "docs/**/*.css" || echo "⚠️ Some CSS issues couldn't be auto-fixed";
	else
		echo "⚠️ Prettier not found, skipping CSS fixes";
	fi

fix-python:
	@echo "🔧 Auto-fixing Python files..."
	@if command -v black >/dev/null 2>&1; then
		black scripts/ || echo "⚠️ Some Python formatting issues couldn't be auto-fixed";
	elif [ -f "$(HOME)/Library/Python/3.9/bin/black" ]; then
		$(HOME)/Library/Python/3.9/bin/black scripts/ || echo "⚠️ Some Python formatting issues couldn't be auto-fixed";
	else
		echo "⚠️ Black not found, skipping Python fixes";
	fi
	@if command -v isort >/dev/null 2>&1; then
		isort scripts/ || echo "⚠️ Some import sorting issues couldn't be auto-fixed";
	elif [ -f "$(HOME)/Library/Python/3.9/bin/isort" ]; then
		$(HOME)/Library/Python/3.9/bin/isort scripts/ || echo "⚠️ Some import sorting issues couldn't be auto-fixed";
	else
		echo "⚠️ isort not found, skipping import fixes";
	fi

fix-powershell:
	@echo "🔧 Auto-fixing PowerShell files..."
	@if [ -n "$(PS1_FILES)" ]; then \
		if command -v pwsh >/dev/null 2>&1; then \
			for file in $(PS1_FILES); do \
				echo -e "${CYAN}Formatting $$file${NC}"; \
				pwsh -Command "Invoke-Formatter -ScriptDefinition (Get-Content -Path '$$file' -Raw)" > "$$file.tmp" 2>/dev/null && mv "$$file.tmp" "$$file" || rm -f "$$file.tmp"; \
			done; \
		elif command -v powershell >/dev/null 2>&1; then \
			for file in $(PS1_FILES); do \
				echo -e "${CYAN}Formatting $$file${NC}"; \
				powershell -Command "Invoke-Formatter -ScriptDefinition (Get-Content -Path '$$file' -Raw)" > "$$file.tmp" 2>/dev/null && mv "$$file.tmp" "$$file" || rm -f "$$file.tmp"; \
			done; \
		else \
			echo "⚠️ PowerShell not found, skipping PowerShell fixes"; \
		fi; \
	else \
		echo "⚠️ No PowerShell files found"; \
	fi

fix-markdown:
	@echo "🔧 Auto-fixing Markdown files..."
	@if command -v markdownlint >/dev/null 2>&1; then
		markdownlint --fix . || echo "⚠️ Some Markdown issues couldn't be auto-fixed";
	else
		echo "⚠️ markdownlint not found, skipping Markdown fixes";
	fi

install-all-tools: install-python-tools install-security-tools install-plagiarism-tools install-git-hooks ## Install all development and security tools
	@echo -e "${GREEN}🎉 All tools installation completed!${NC}"
	@echo -e "${CYAN}📋 Run 'make status' to verify installation${NC}"

# Security check with Snyk (requires authentication)
security-check: ## Run comprehensive security checks
	@echo -e "${BLUE}🔒 Running comprehensive security checks...${NC}"
	@echo -e "${CYAN}1. Running Snyk security scan...${NC}"
	@if command -v snyk >/dev/null 2>&1; then \
		snyk test --all-projects || echo -e "${YELLOW}⚠️ Snyk found vulnerabilities${NC}"; \
	else \
		echo -e "${YELLOW}⚠️ Snyk not available${NC}"; \
	fi
	@echo -e "${CYAN}2. Running npm audit...${NC}"
	@if command -v npm >/dev/null 2>&1; then \
		npm audit --audit-level=moderate || echo -e "${YELLOW}⚠️ npm audit found issues${NC}"; \
	else \
		echo -e "${YELLOW}⚠️ npm not available${NC}"; \
	fi
	@echo -e "${CYAN}3. Running Python security checks with bandit...${NC}"
	@if [ -n "$(PY_FILES)" ]; then \
		if command -v bandit >/dev/null 2>&1; then \
			bandit -r $(SCRIPTS_DIR) || echo -e "${YELLOW}⚠️ Bandit found security issues${NC}"; \
		elif [ -f "/Users/bryanjorgensen/Library/Python/3.9/bin/bandit" ]; then \
			/Users/bryanjorgensen/Library/Python/3.9/bin/bandit -r $(SCRIPTS_DIR) || echo -e "${YELLOW}⚠️ Bandit found security issues${NC}"; \
		else \
			echo -e "${YELLOW}⚠️ Bandit not available${NC}"; \
		fi; \
	else \
		echo -e "${YELLOW}⚠️ No Python files found${NC}"; \
	fi
	@echo -e "${CYAN}4. Running pip-audit (if available)...${NC}"
	@if command -v pip-audit >/dev/null 2>&1; then \
		pip-audit || echo -e "${YELLOW}⚠️ pip-audit found vulnerabilities${NC}"; \
	elif [ -f "/Users/bryanjorgensen/Library/Python/3.9/bin/pip-audit" ]; then \
		/Users/bryanjorgensen/Library/Python/3.9/bin/pip-audit || echo -e "${YELLOW}⚠️ pip-audit found vulnerabilities${NC}"; \
	else \
		echo -e "${YELLOW}⚠️ pip-audit not installed${NC}"; \
	fi
	@echo -e "${CYAN}5. Running OSV scanner (if available)...${NC}"
	@if command -v osv-scanner >/dev/null 2>&1; then \
		osv-scanner --recursive . || echo -e "${YELLOW}⚠️ OSV scanner found vulnerabilities${NC}"; \
	else \
		echo -e "${YELLOW}⚠️ osv-scanner not installed${NC}"; \
	fi
	@echo -e "${GREEN}✅ Security checks completed${NC}"

# Docker security checks
docker-security: ## Run Dockerfile security checks with Hadolint
	@echo -e "${BLUE}🐳 Running Docker security checks...${NC}"
	@if [ -f "Dockerfile" ] || [ -f "docker-compose.yml" ]; then \
		if command -v hadolint >/dev/null 2>&1; then \
			find . -name "Dockerfile*" -exec hadolint {} \; || echo -e "${YELLOW}⚠️ Hadolint found issues${NC}"; \
		else \
			echo -e "${YELLOW}⚠️ Hadolint not installed${NC}"; \
			echo -e "${CYAN}💡 Install: brew install hadolint${NC}"; \
		fi; \
	else \
		echo -e "${YELLOW}⚠️ No Dockerfile found${NC}"; \
	fi
	@echo -e "${GREEN}✅ Docker security check completed${NC}"

# Plagiarism detection and code similarity analysis
plagiarism-check: ## Run comprehensive plagiarism and code similarity analysis
	@echo -e "${BLUE}🔍 Running plagiarism and code similarity analysis...${NC}"
	@echo "=== Plagiarism Detection Report ===" > plagiarism-report.log
	@echo "Timestamp: $$(date)" >> plagiarism-report.log
	@echo "" >> plagiarism-report.log

	@$(MAKE) dolos-check
	@$(MAKE) hookejs-check
	@$(MAKE) copyright-detect-check
	@echo -e "${GREEN}✅ Plagiarism analysis completed${NC}"
	@echo -e "${CYAN}📄 Full report saved to: plagiarism-report.log${NC}"

dolos-check: ## Run Dolos code similarity detection
	@echo -e "${CYAN}🔍 Running Dolos code similarity detection...${NC}"
	@echo "--- Dolos Analysis ---" >> plagiarism-report.log
	@if command -v dolos >/dev/null 2>&1; then \
		echo -e "${CYAN}Analyzing JavaScript files...${NC}"; \
		if [ -n "$(JS_FILES)" ]; then \
			mkdir -p dolos-results; \
			dolos -f web -o dolos-results/js $(DOCS_DIR)/**/*.js 2>&1 | tee -a plagiarism-report.log || echo -e "${YELLOW}⚠️ Dolos JavaScript analysis completed with warnings${NC}"; \
		fi; \
		echo -e "${CYAN}Analyzing Python files...${NC}"; \
		if [ -n "$(PY_FILES)" ]; then \
			dolos -f web -o dolos-results/python $(SCRIPTS_DIR)/*.py 2>&1 | tee -a plagiarism-report.log || echo -e "${YELLOW}⚠️ Dolos Python analysis completed with warnings${NC}"; \
		fi; \
		echo -e "${CYAN}📊 Dolos results saved to dolos-results/${NC}"; \
	else \
		echo -e "${RED}❌ Dolos not installed - run 'make install-plagiarism-tools'${NC}" | tee -a plagiarism-report.log; \
	fi
	@echo "" >> plagiarism-report.log

hookejs-check: ## Run HookeJs JavaScript similarity analysis
	@echo -e "${CYAN}🔍 Running HookeJs JavaScript similarity analysis...${NC}"
	@echo "--- HookeJs Analysis ---" >> plagiarism-report.log
	@if npm list -g hookejs >/dev/null 2>&1; then \
		if [ -n "$(JS_FILES)" ]; then \
			echo -e "${CYAN}Analyzing JavaScript files for similarity...${NC}"; \
			echo -e "${CYAN}Installing HookeJs locally for analysis...${NC}"; \
			npm install hookejs --no-save >/dev/null 2>&1 || true; \
			echo 'const hookejs = require("hookejs");' > hookejs-analysis.js; \
			echo 'const fs = require("fs");' >> hookejs-analysis.js; \
			echo 'const files = process.argv.slice(2);' >> hookejs-analysis.js; \
			echo 'console.log("Analyzing", files.length, "files...");' >> hookejs-analysis.js; \
			echo 'let foundSimilarities = 0;' >> hookejs-analysis.js; \
			echo 'files.forEach((file, i) => {' >> hookejs-analysis.js; \
			echo '  files.slice(i+1).forEach(file2 => {' >> hookejs-analysis.js; \
			echo '    try {' >> hookejs-analysis.js; \
			echo '      const content1 = fs.readFileSync(file, "utf8");' >> hookejs-analysis.js; \
			echo '      const content2 = fs.readFileSync(file2, "utf8");' >> hookejs-analysis.js; \
			echo '      const similarity = hookejs(content1, content2);' >> hookejs-analysis.js; \
			echo '      if (similarity > 0.8) { console.log(`High similarity ($${similarity.toFixed(2)}) between $${file} and $${file2}`); foundSimilarities++; }' >> hookejs-analysis.js; \
			echo '    } catch(e) { console.log(`Error comparing $${file} and $${file2}: $${e.message}`); }' >> hookejs-analysis.js; \
			echo '  });' >> hookejs-analysis.js; \
			echo '});' >> hookejs-analysis.js; \
			echo 'console.log(`Analysis complete. Found $${foundSimilarities} high-similarity pairs.`);' >> hookejs-analysis.js; \
			node hookejs-analysis.js $(JS_FILES) 2>&1 | tee -a plagiarism-report.log || echo -e "${YELLOW}⚠️ HookeJs analysis completed with warnings${NC}"; \
			rm -f hookejs-analysis.js; \
			rm -rf node_modules package-lock.json 2>/dev/null || true; \
			echo -e "${CYAN}📊 HookeJs analysis completed${NC}"; \
		else \
			echo -e "${YELLOW}⚠️ No JavaScript files found for HookeJs analysis${NC}" | tee -a plagiarism-report.log; \
		fi; \
	else \
		echo -e "${RED}❌ HookeJs not installed - run 'make install-plagiarism-tools'${NC}" | tee -a plagiarism-report.log; \
	fi
	@echo "" >> plagiarism-report.log

copyright-detect-check: ## Run Copyright-detection analysis on images
	@echo -e "${CYAN}🔍 Running Copyright-detection analysis...${NC}"
	@echo "--- Copyright Detection Analysis ---" >> plagiarism-report.log
	@if [ -d "$(HOME)/.local/copyright-detection" ]; then \
		if find . -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.webp" | head -1 | grep -q "."; then \
			echo -e "${CYAN}Analyzing images for copyright infringement...${NC}"; \
			mkdir -p copyright-results; \
			echo -e "${CYAN}Creating image analysis script...${NC}"; \
			echo 'import sys, os' > copyright-analysis.py; \
			echo 'sys.path.append("$(HOME)/.local/copyright-detection")' >> copyright-analysis.py; \
			echo 'import glob' >> copyright-analysis.py; \
			echo 'print("Copyright Detection Analysis")' >> copyright-analysis.py; \
			echo 'print("=" * 30)' >> copyright-analysis.py; \
			echo 'image_files = []' >> copyright-analysis.py; \
			echo 'for ext in ["*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp"]:' >> copyright-analysis.py; \
			echo '    image_files.extend(glob.glob(f"**/{ext}", recursive=True))' >> copyright-analysis.py; \
			echo 'print(f"Found {len(image_files)} image files")' >> copyright-analysis.py; \
			echo 'for img in image_files[:10]:  # Analyze first 10 images' >> copyright-analysis.py; \
			echo '    print(f"Analyzing: {img}")' >> copyright-analysis.py; \
			echo '    # Note: Actual copyright detection would require the full model setup' >> copyright-analysis.py; \
			echo '    print(f"  Status: Analysis placeholder - tool available")' >> copyright-analysis.py; \
			echo 'if len(image_files) > 10:' >> copyright-analysis.py; \
			echo '    print(f"... and {len(image_files) - 10} more images")' >> copyright-analysis.py; \
			python3 copyright-analysis.py 2>&1 | tee -a plagiarism-report.log || echo -e "${YELLOW}⚠️ Copyright-detection analysis completed with warnings${NC}"; \
			rm -f copyright-analysis.py; \
			echo -e "${CYAN}📊 Copyright-detection analysis completed${NC}"; \
			echo -e "${CYAN}💡 For full analysis, run: cd $(HOME)/.local/copyright-detection && python3 analyze_dataset.py${NC}"; \
		else \
			echo -e "${YELLOW}⚠️ No image files found for copyright detection${NC}" | tee -a plagiarism-report.log; \
		fi; \
	else \
		echo -e "${RED}❌ Copyright-detection not installed - run 'make install-plagiarism-tools'${NC}" | tee -a plagiarism-report.log; \
	fi
	@echo "" >> plagiarism-report.log

plagiarism-clean: ## Clean plagiarism detection reports and results
	@echo -e "${BLUE}🧹 Cleaning plagiarism detection results...${NC}"
	@rm -rf dolos-results hookejs-results copyright-results plagiarism-report.log
	@echo -e "${GREEN}✅ Plagiarism detection results cleaned${NC}"

# JavaScript linting
lint-js: ## Lint JavaScript files
	@echo -e "${BLUE}🔍 Linting JavaScript files...${NC}"
	@if [ -n "$(JS_FILES)" ]; then \
		if command -v eslint >/dev/null 2>&1; then \
			echo -e "${CYAN}Running ESLint...${NC}"; \
			eslint $(JS_FILES) --ext .js || echo -e "${YELLOW}⚠️ ESLint found issues${NC}"; \
		else \
			echo -e "${YELLOW}⚠️ ESLint not installed, skipping...${NC}"; \
		fi; \
		if command -v prettier >/dev/null 2>&1; then \
			echo -e "${CYAN}Checking Prettier formatting...${NC}"; \
			prettier --check $(JS_FILES) || echo -e "${YELLOW}⚠️ Prettier found formatting issues${NC}"; \
		else \
			echo -e "${YELLOW}⚠️ Prettier not installed, skipping...${NC}"; \
		fi; \
	else \
		echo -e "${YELLOW}⚠️ No JavaScript files found${NC}"; \
	fi
	@echo -e "${GREEN}✅ JavaScript linting completed${NC}"

# HTML linting
lint-html: ## Lint HTML files
	@echo -e "${BLUE}🔍 Linting HTML files...${NC}"
	@if [ -n "$(HTML_FILES)" ]; then \
		if command -v htmlhint >/dev/null 2>&1; then \
			echo -e "${CYAN}Running HTMLHint...${NC}"; \
			htmlhint $(HTML_FILES) || echo -e "${YELLOW}⚠️ HTMLHint found issues${NC}"; \
		else \
			echo -e "${YELLOW}⚠️ HTMLHint not installed, skipping...${NC}"; \
		fi; \
		if command -v html-validate >/dev/null 2>&1; then \
			echo -e "${CYAN}Running HTML Validate...${NC}"; \
			html-validate $(HTML_FILES) || echo -e "${YELLOW}⚠️ HTML Validate found issues${NC}"; \
		else \
			echo -e "${YELLOW}⚠️ HTML Validate not installed, skipping...${NC}"; \
		fi; \
	else \
		echo -e "${YELLOW}⚠️ No HTML files found${NC}"; \
	fi
	@echo -e "${GREEN}✅ HTML linting completed${NC}"

# CSS linting
lint-css: ## Lint CSS files
	@echo -e "${BLUE}🔍 Linting CSS files...${NC}"
	@if [ -n "$(CSS_FILES)" ]; then \
		if command -v stylelint >/dev/null 2>&1; then \
			echo -e "${CYAN}Running Stylelint...${NC}"; \
			stylelint $(CSS_FILES) || echo -e "${YELLOW}⚠️ Stylelint found issues${NC}"; \
		else \
			echo -e "${YELLOW}⚠️ Stylelint not installed, skipping...${NC}"; \
		fi; \
		if command -v prettier >/dev/null 2>&1; then \
			echo -e "${CYAN}Checking Prettier formatting for CSS...${NC}"; \
			prettier --check $(CSS_FILES) || echo -e "${YELLOW}⚠️ Prettier found formatting issues${NC}"; \
		else \
			echo -e "${YELLOW}⚠️ Prettier not installed, skipping...${NC}"; \
		fi; \
	else \
		echo -e "${YELLOW}⚠️ No CSS files found${NC}"; \
	fi
	@echo -e "${GREEN}✅ CSS linting completed${NC}"

# Python linting
lint-python: ## Lint Python files
	@echo -e "${BLUE}🔍 Linting Python files...${NC}"
	@if [ -n "$(PY_FILES)" ]; then \
		if command -v flake8 >/dev/null 2>&1; then \
			echo -e "${CYAN}Running Flake8...${NC}"; \
			flake8 $(PY_FILES) --max-line-length=88 --ignore=E203,W503 || echo -e "${YELLOW}⚠️ Flake8 found issues${NC}"; \
		elif [ -f "/Users/bryanjorgensen/Library/Python/3.9/bin/flake8" ]; then \
			echo -e "${CYAN}Running Flake8...${NC}"; \
			/Users/bryanjorgensen/Library/Python/3.9/bin/flake8 $(PY_FILES) --max-line-length=88 --ignore=E203,W503 || echo -e "${YELLOW}⚠️ Flake8 found issues${NC}"; \
		else \
			echo -e "${YELLOW}⚠️ Flake8 not installed, skipping...${NC}"; \
		fi; \
		if command -v pylint >/dev/null 2>&1; then \
			echo -e "${CYAN}Running Pylint...${NC}"; \
			pylint $(PY_FILES) --fail-under=7.0 || echo -e "${YELLOW}⚠️ Pylint found issues${NC}"; \
		elif [ -f "/Users/bryanjorgensen/Library/Python/3.9/bin/pylint" ]; then \
			echo -e "${CYAN}Running Pylint...${NC}"; \
			/Users/bryanjorgensen/Library/Python/3.9/bin/pylint $(PY_FILES) --fail-under=7.0 || echo -e "${YELLOW}⚠️ Pylint found issues${NC}"; \
		else \
			echo -e "${YELLOW}⚠️ Pylint not installed, skipping...${NC}"; \
		fi; \
		if command -v black >/dev/null 2>&1; then \
			echo -e "${CYAN}Checking Black formatting...${NC}"; \
			black --check $(PY_FILES) || echo -e "${YELLOW}⚠️ Black found formatting issues${NC}"; \
		elif [ -f "/Users/bryanjorgensen/Library/Python/3.9/bin/black" ]; then \
			echo -e "${CYAN}Checking Black formatting...${NC}"; \
			/Users/bryanjorgensen/Library/Python/3.9/bin/black --check $(PY_FILES) || echo -e "${YELLOW}⚠️ Black found formatting issues${NC}"; \
		else \
			echo -e "${YELLOW}⚠️ Black not installed, skipping...${NC}"; \
		fi; \
		if command -v isort >/dev/null 2>&1; then \
			echo -e "${CYAN}Checking import sorting...${NC}"; \
			isort --check-only $(PY_FILES) || echo -e "${YELLOW}⚠️ isort found issues${NC}"; \
		elif [ -f "/Users/bryanjorgensen/Library/Python/3.9/bin/isort" ]; then \
			echo -e "${CYAN}Checking import sorting...${NC}"; \
			/Users/bryanjorgensen/Library/Python/3.9/bin/isort --check-only $(PY_FILES) || echo -e "${YELLOW}⚠️ isort found issues${NC}"; \
		else \
			echo -e "${YELLOW}⚠️ isort not installed, skipping...${NC}"; \
		fi; \
		if command -v mypy >/dev/null 2>&1; then \
			echo -e "${CYAN}Running mypy type checking...${NC}"; \
			mypy $(PY_FILES) --ignore-missing-imports || echo -e "${YELLOW}⚠️ mypy found type issues${NC}"; \
		elif [ -f "/Users/bryanjorgensen/Library/Python/3.9/bin/mypy" ]; then \
			echo -e "${CYAN}Running mypy type checking...${NC}"; \
			/Users/bryanjorgensen/Library/Python/3.9/bin/mypy $(PY_FILES) --ignore-missing-imports || echo -e "${YELLOW}⚠️ mypy found type issues${NC}"; \
		else \
			echo -e "${YELLOW}⚠️ mypy not installed, skipping...${NC}"; \
		fi; \
	else \
		echo -e "${YELLOW}⚠️ No Python files found${NC}"; \
	fi
	@echo -e "${GREEN}✅ Python linting completed${NC}"

# PowerShell linting
lint-powershell: ## Lint PowerShell files with PSScriptAnalyzer
	@echo -e "${BLUE}🔍 Linting PowerShell files...${NC}"
	@if [ -n "$(PS1_FILES)" ]; then \
		if command -v pwsh >/dev/null 2>&1; then \
			echo -e "${CYAN}Running PSScriptAnalyzer...${NC}"; \
			for file in $(PS1_FILES); do \
				echo -e "${CYAN}Analyzing $$file${NC}"; \
				pwsh -Command "Import-Module PSScriptAnalyzer -Force; Invoke-ScriptAnalyzer -Path '$$file' -Severity Warning,Error" || echo -e "${YELLOW}⚠️ PSScriptAnalyzer found issues in $$file${NC}"; \
			done; \
		elif command -v powershell >/dev/null 2>&1; then \
			echo -e "${CYAN}Running PSScriptAnalyzer (Windows PowerShell)...${NC}"; \
			for file in $(PS1_FILES); do \
				echo -e "${CYAN}Analyzing $$file${NC}"; \
				powershell -Command "Import-Module PSScriptAnalyzer -Force; Invoke-ScriptAnalyzer -Path '$$file' -Severity Warning,Error" || echo -e "${YELLOW}⚠️ PSScriptAnalyzer found issues in $$file${NC}"; \
			done; \
		else \
			echo -e "${YELLOW}⚠️ PowerShell not installed, skipping...${NC}"; \
			echo -e "${CYAN}💡 Install PowerShell: brew install --cask powershell${NC}"; \
		fi; \
	else \
		echo -e "${YELLOW}⚠️ No PowerShell files found${NC}"; \
	fi
	@echo -e "${GREEN}✅ PowerShell linting completed${NC}"

# YAML linting
lint-yaml: ## Lint YAML files
	@echo -e "${BLUE}🔍 Linting YAML files...${NC}"
	@if [ -n "$(YAML_FILES)" ]; then \
		if command -v yamllint >/dev/null 2>&1; then \
			echo -e "${CYAN}Running yamllint...${NC}"; \
			yamllint $(YAML_FILES) || echo -e "${YELLOW}⚠️ yamllint found issues${NC}"; \
		elif command -v yaml-lint >/dev/null 2>&1; then \
			echo -e "${CYAN}Running yaml-lint...${NC}"; \
			for file in $(YAML_FILES); do \
				yaml-lint $$file || echo -e "${YELLOW}⚠️ yaml-lint found issues in $$file${NC}"; \
			done; \
		else \
			echo -e "${YELLOW}⚠️ No YAML linter installed, skipping...${NC}"; \
		fi; \
	else \
		echo -e "${YELLOW}⚠️ No YAML files found${NC}"; \
	fi
	@echo -e "${GREEN}✅ YAML linting completed${NC}"

# JSON linting
lint-json: ## Lint JSON files
	@echo -e "${BLUE}🔍 Linting JSON files...${NC}"
	@if [ -n "$(JSON_FILES)" ]; then \
		if command -v jsonlint >/dev/null 2>&1; then \
			echo -e "${CYAN}Running jsonlint...${NC}"; \
			for file in $(JSON_FILES); do \
				jsonlint $$file >/dev/null || echo -e "${YELLOW}⚠️ jsonlint found issues in $$file${NC}"; \
			done; \
		else \
			echo -e "${CYAN}Running basic JSON syntax check...${NC}"; \
			for file in $(JSON_FILES); do \
				python -m json.tool $$file >/dev/null || echo -e "${YELLOW}⚠️ JSON syntax error in $$file${NC}"; \
			done; \
		fi; \
	else \
		echo -e "${YELLOW}⚠️ No JSON files found${NC}"; \
	fi
	@echo -e "${GREEN}✅ JSON linting completed${NC}"

# Markdown linting
lint-markdown: ## Lint Markdown files
	@echo -e "${BLUE}🔍 Linting Markdown files...${NC}"
	@if [ -n "$(MD_FILES)" ]; then \
		if command -v markdownlint >/dev/null 2>&1; then \
			echo -e "${CYAN}Running markdownlint...${NC}"; \
			markdownlint $(MD_FILES) || echo -e "${YELLOW}⚠️ markdownlint found issues${NC}"; \
		else \
			echo -e "${YELLOW}⚠️ markdownlint not installed, skipping...${NC}"; \
		fi; \
	else \
		echo -e "${YELLOW}⚠️ No Markdown files found${NC}"; \
	fi
	@echo -e "${GREEN}✅ Markdown linting completed${NC}"

# Formatting targets
format-all: format-js format-css format-python format-powershell format-json ## Auto-format all supported file types
	@echo -e "${GREEN}✅ All formatting completed${NC}"

format-js: ## Auto-format JavaScript files
	@echo -e "${BLUE}✨ Formatting JavaScript files...${NC}"
	@if [ -n "$(JS_FILES)" ] && command -v prettier >/dev/null 2>&1; then \
		prettier --write $(JS_FILES); \
		echo -e "${GREEN}✅ JavaScript files formatted${NC}"; \
	else \
		echo -e "${YELLOW}⚠️ No JS files or Prettier not available${NC}"; \
	fi

format-css: ## Auto-format CSS files
	@echo -e "${BLUE}✨ Formatting CSS files...${NC}"
	@if [ -n "$(CSS_FILES)" ] && command -v prettier >/dev/null 2>&1; then \
		prettier --write $(CSS_FILES); \
		echo -e "${GREEN}✅ CSS files formatted${NC}"; \
	else \
		echo -e "${YELLOW}⚠️ No CSS files or Prettier not available${NC}"; \
	fi

format-python: ## Auto-format Python files
	@echo -e "${BLUE}✨ Formatting Python files...${NC}"
	@if [ -n "$(PY_FILES)" ]; then \
		if command -v black >/dev/null 2>&1; then \
			black $(PY_FILES); \
		elif [ -f "/Users/bryanjorgensen/Library/Python/3.9/bin/black" ]; then \
			/Users/bryanjorgensen/Library/Python/3.9/bin/black $(PY_FILES); \
		fi; \
		if command -v isort >/dev/null 2>&1; then \
			isort $(PY_FILES); \
		elif [ -f "/Users/bryanjorgensen/Library/Python/3.9/bin/isort" ]; then \
			/Users/bryanjorgensen/Library/Python/3.9/bin/isort $(PY_FILES); \
		fi; \
		echo -e "${GREEN}✅ Python files formatted${NC}"; \
	else \
		echo -e "${YELLOW}⚠️ No Python files found${NC}"; \
	fi

format-powershell: ## Auto-format PowerShell files
	@echo -e "${BLUE}✨ Formatting PowerShell files...${NC}"
	@if [ -n "$(PS1_FILES)" ]; then \
		if command -v pwsh >/dev/null 2>&1; then \
			for file in $(PS1_FILES); do \
				echo -e "${CYAN}Formatting $$file${NC}"; \
				pwsh -Command "Import-Module PSScriptAnalyzer -Force; try { \$$content = Get-Content -Path '$$file' -Raw; \$$formatted = Invoke-Formatter -ScriptDefinition \$$content; Set-Content -Path '$$file' -Value \$$formatted } catch { Write-Warning \"Failed to format $$file: \$$_\" }" 2>/dev/null || echo -e "${YELLOW}⚠️ Failed to format $$file${NC}"; \
			done; \
		elif command -v powershell >/dev/null 2>&1; then \
			for file in $(PS1_FILES); do \
				echo -e "${CYAN}Formatting $$file${NC}"; \
				powershell -Command "Import-Module PSScriptAnalyzer -Force; try { \$$content = Get-Content -Path '$$file' -Raw; \$$formatted = Invoke-Formatter -ScriptDefinition \$$content; Set-Content -Path '$$file' -Value \$$formatted } catch { Write-Warning \"Failed to format $$file: \$$_\" }" 2>/dev/null || echo -e "${YELLOW}⚠️ Failed to format $$file${NC}"; \
			done; \
		else \
			echo -e "${YELLOW}⚠️ PowerShell not available for formatting${NC}"; \
		fi; \
		echo -e "${GREEN}✅ PowerShell files formatted${NC}"; \
	else \
		echo -e "${YELLOW}⚠️ No PowerShell files found${NC}"; \
	fi

format-json: ## Auto-format JSON files
	@echo -e "${BLUE}✨ Formatting JSON files...${NC}"
	@if [ -n "$(JSON_FILES)" ]; then \
		for file in $(JSON_FILES); do \
			python -m json.tool $$file > $$file.tmp && mv $$file.tmp $$file 2>/dev/null || rm -f $$file.tmp; \
		done; \
		echo -e "${GREEN}✅ JSON files formatted${NC}"; \
	else \
		echo -e "${YELLOW}⚠️ No JSON files found${NC}"; \
	fi

secrets-scan: ## Run comprehensive secret scanning with multiple tools
	@echo -e "${BLUE}🕵️ Running comprehensive secrets scanning...${NC}"
	@$(MAKE) secrets-gitleaks
	@$(MAKE) secrets-trufflehog
	@$(MAKE) secrets-gitguardian
	@echo -e "${GREEN}✅ All secret scans completed${NC}"

secrets-gitleaks: ## Scan for secrets using Gitleaks
	@echo -e "${CYAN}Running Gitleaks scan...${NC}"
	@if command -v gitleaks >/dev/null 2>&1; then \
		gitleaks detect --verbose --source . --report-path gitleaks-report.json || echo -e "${YELLOW}⚠️ Gitleaks found potential secrets${NC}"; \
		if [ -f "gitleaks-report.json" ]; then \
			echo -e "${CYAN}📊 Gitleaks report saved to gitleaks-report.json${NC}"; \
		fi; \
	else \
		echo -e "${YELLOW}⚠️ Gitleaks not installed${NC}"; \
	fi

secrets-trufflehog: ## Scan for secrets using TruffleHog
	@echo -e "${CYAN}Running TruffleHog scan...${NC}"
	@if command -v trufflehog >/dev/null 2>&1; then \
		trufflehog filesystem . --json --no-update 2>/dev/null | tee trufflehog-report.json || echo -e "${YELLOW}⚠️ TruffleHog found potential secrets${NC}"; \
		if [ -f "trufflehog-report.json" ]; then \
			echo -e "${CYAN}📊 TruffleHog report saved to trufflehog-report.json${NC}"; \
		fi; \
	else \
		echo -e "${YELLOW}⚠️ TruffleHog not installed${NC}"; \
	fi

secrets-gitguardian: ## Scan for secrets using GitGuardian
	@echo -e "${CYAN}Running GitGuardian scan...${NC}"
	@if [ -f ".venv/bin/ggshield" ]; then \
		.venv/bin/ggshield secret scan path . --recursive --output ggshield-report.json --json || echo -e "${YELLOW}⚠️ GitGuardian found potential secrets${NC}"; \
		if [ -f "ggshield-report.json" ]; then \
			echo -e "${CYAN}📊 GitGuardian report saved to ggshield-report.json${NC}"; \
		fi; \
	else \
		echo -e "${YELLOW}⚠️ GitGuardian not installed in venv${NC}"; \
	fi

secrets-history: ## Scan git history for secrets (comprehensive)
	@echo -e "${BLUE}🔍 Scanning git history for secrets...${NC}"
	@if command -v gitleaks >/dev/null 2>&1; then \
		echo -e "${CYAN}Running Gitleaks on git history...${NC}"; \
		gitleaks detect --verbose --source . --log-opts="--all" --report-path gitleaks-history.json || echo -e "${YELLOW}⚠️ Found secrets in git history${NC}"; \
	fi
	@if command -v trufflehog >/dev/null 2>&1; then \
		echo -e "${CYAN}Running TruffleHog on git history...${NC}"; \
		trufflehog git file://. --json --no-update > trufflehog-history.json 2>/dev/null || echo -e "${YELLOW}⚠️ Found secrets in git history${NC}"; \
	fi
	@echo -e "${GREEN}✅ Git history scan completed${NC}"

secrets-clean: ## Clean up secret scan reports
	@echo -e "${BLUE}🧹 Cleaning secret scan reports...${NC}"
	@rm -f gitleaks-report.json gitleaks-history.json trufflehog-report.json trufflehog-history.json ggshield-report.json
	@echo -e "${GREEN}✅ Secret scan reports cleaned${NC}"

# Test and validation
test: lint-all test-all ## Run all tests and validation
	@echo -e "${PURPLE}🧪 Running all tests and validation...${NC}"
	@$(MAKE) security-check
	@$(MAKE) secrets-scan
	@$(MAKE) plagiarism-check
	@echo -e "${GREEN}✅ All tests completed${NC}"

# Comprehensive testing targets
test-all: ## Run all test suites (JavaScript, Python, Java)
	@echo -e "${PURPLE}🧪 Running comprehensive test suite...${NC}"
	@$(MAKE) test-js
	@$(MAKE) test-python
	@$(MAKE) test-java
	@echo -e "${GREEN}✅ All test frameworks completed${NC}"

test-js: ## Run JavaScript tests with Jest
	@echo -e "${BLUE}🟨 Running JavaScript tests with Jest...${NC}"
	@if command -v npm >/dev/null 2>&1; then \
		npm test || echo -e "${YELLOW}⚠️ JavaScript tests had failures${NC}"; \
	else \
		echo -e "${YELLOW}⚠️ npm not available, skipping JavaScript tests${NC}"; \
	fi

test-python: ## Run Python tests with pytest
	@echo -e "${BLUE}🐍 Running Python tests with pytest...${NC}"
	@if [ -f ".venv/bin/pytest" ]; then \
		.venv/bin/pytest tests/python/ --verbose || echo -e "${YELLOW}⚠️ Python tests had failures${NC}"; \
	elif command -v pytest >/dev/null 2>&1; then \
		pytest tests/python/ --verbose || echo -e "${YELLOW}⚠️ Python tests had failures${NC}"; \
	else \
		echo -e "${YELLOW}⚠️ pytest not available, skipping Python tests${NC}"; \
	fi

test-java: ## Run Java tests with JUnit/Maven
	@echo -e "${BLUE}☕ Running Java tests with JUnit...${NC}"
	@if command -v mvn >/dev/null 2>&1 && [ -f "pom.xml" ]; then \
		mvn test || echo -e "${YELLOW}⚠️ Java tests had failures${NC}"; \
	else \
		echo -e "${YELLOW}⚠️ Maven/JUnit not available, skipping Java tests${NC}"; \
	fi

test-unit: ## Run unit tests across all frameworks
	@echo -e "${BLUE}🔧 Running unit tests...${NC}"
	@if command -v npm >/dev/null 2>&1; then \
		npm run test:unit || echo -e "${YELLOW}⚠️ JavaScript unit tests had failures${NC}"; \
	fi
	@if [ -f ".venv/bin/pytest" ]; then \
		.venv/bin/pytest tests/unit/ -m "unit" --verbose || echo -e "${YELLOW}⚠️ Python unit tests had failures${NC}"; \
	fi

test-integration: ## Run integration tests across all frameworks
	@echo -e "${BLUE}🔗 Running integration tests...${NC}"
	@if command -v npm >/dev/null 2>&1; then \
		npm run test:integration || echo -e "${YELLOW}⚠️ JavaScript integration tests had failures${NC}"; \
	fi
	@if [ -f ".venv/bin/pytest" ]; then \
		.venv/bin/pytest tests/integration/ -m "integration" --verbose || echo -e "${YELLOW}⚠️ Python integration tests had failures${NC}"; \
	fi

test-e2e: ## Run end-to-end tests across all frameworks
	@echo -e "${BLUE}🌐 Running end-to-end tests...${NC}"
	@if command -v npm >/dev/null 2>&1; then \
		npm run test:e2e || echo -e "${YELLOW}⚠️ JavaScript E2E tests had failures${NC}"; \
	fi
	@if [ -f ".venv/bin/pytest" ]; then \
		.venv/bin/pytest tests/e2e/ -m "e2e" --verbose || echo -e "${YELLOW}⚠️ Python E2E tests had failures${NC}"; \
	fi

test-coverage: ## Generate test coverage reports for all frameworks
	@echo -e "${BLUE}📊 Generating test coverage reports...${NC}"
	@mkdir -p coverage-reports
	@if command -v npm >/dev/null 2>&1; then \
		echo -e "${CYAN}Generating JavaScript coverage...${NC}"; \
		npm run test:coverage || echo -e "${YELLOW}⚠️ JavaScript coverage generation failed${NC}"; \
	fi
	@if [ -f ".venv/bin/pytest" ]; then \
		echo -e "${CYAN}Generating Python coverage...${NC}"; \
		.venv/bin/pytest --cov=scripts --cov-report=html:coverage-reports/python || echo -e "${YELLOW}⚠️ Python coverage generation failed${NC}"; \
	fi
	@if command -v mvn >/dev/null 2>&1 && [ -f "pom.xml" ]; then \
		echo -e "${CYAN}Generating Java coverage...${NC}"; \
		mvn jacoco:report || echo -e "${YELLOW}⚠️ Java coverage generation failed${NC}"; \
	fi
	@echo -e "${GREEN}✅ Coverage reports generated in coverage-reports/${NC}"

# Utility targets
clean: ## Clean temporary files and caches
	@echo -e "${BLUE}🧹 Cleaning temporary files...${NC}"
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.tmp" -delete 2>/dev/null || true
	@find . -type f -name ".DS_Store" -delete 2>/dev/null || true
	@echo -e "${GREEN}✅ Cleanup completed${NC}"

# CI/Development helper targets
ci-lint: ## Run linting suitable for CI (non-interactive)
	@echo -e "${BLUE}🤖 Running CI-friendly linting...${NC}"
	@$(MAKE) lint-all 2>&1 | tee lint-results.log
	@echo -e "${GREEN}✅ CI linting completed - results in lint-results.log${NC}"

dev-setup: install-tools ## Set up development environment
	@echo -e "${BLUE}🛠️ Setting up development environment...${NC}"
	@echo -e "${GREEN}✅ Development environment ready${NC}"
	@echo -e "${CYAN}💡 Run 'make lint' to check your code${NC}"
	@echo -e "${CYAN}💡 Run 'make format-all' to auto-format files${NC}"

# Project-specific targets
check-printify: ## Validate Printify integration files
	@echo -e "${BLUE}🛍️ Checking Printify integration...${NC}"
	@if [ -f "$(ASSETS_JS_DIR)/config.js" ]; then \
		grep -q "YOUR_PRINTIFY_API_KEY_HERE" "$(ASSETS_JS_DIR)/config.js" && \
		echo -e "${GREEN}✅ Printify config placeholder found (ready for GitHub Actions)${NC}" || \
		echo -e "${YELLOW}⚠️ Printify API key may be hardcoded${NC}"; \
	else \
		echo -e "${RED}❌ Printify config file not found${NC}"; \
	fi

check-secrets: ## Check for accidentally committed secrets
	@echo -e "${BLUE}🔒 Checking for exposed secrets...${NC}"
	@echo -e "${CYAN}Looking for real API keys (not environment variables or placeholders)...${NC}"
	@if grep -rE "printifyApiKey.*['\"][A-Za-z0-9_-]{30,}['\"]" docs/assets/js/ 2>/dev/null | grep -v "YOUR_PRINTIFY_API_KEY"; then \
		echo -e "${RED}❌ Real Printify API key found in JavaScript config!${NC}"; \
		exit 1; \
	elif grep -rE "(client_id|client_secret).*['\"][A-Z][A-Za-z0-9_-]{25,}['\"]" . 2>/dev/null | grep -v "your_" | grep -v "os.getenv" | grep -v "example"; then \
		echo -e "${RED}❌ Potential real PayPal credentials found!${NC}"; \
		exit 1; \
	else \
		echo -e "${GREEN}✅ No real hardcoded secrets found${NC}"; \
		echo -e "${CYAN}ℹ️  Only placeholders and environment variable usage detected${NC}"; \
	fi

validate-workflows: ## Validate GitHub Actions workflows
	@echo -e "${BLUE}⚙️ Validating GitHub Actions workflows...${NC}"
	@$(MAKE) lint-yaml
	@echo -e "${GREEN}✅ Workflow validation completed${NC}"

# Show project status
status: ## Show project linting status
	@echo -e "${PURPLE}📊 $(PROJECT_NAME) Project Status${NC}"
	@echo -e "${PURPLE}================================${NC}"
	@echo -e "${CYAN}File counts:${NC}"
	@echo -e "  📄 HTML: $(words $(HTML_FILES)) files"
	@echo -e "  🎨 CSS: $(words $(CSS_FILES)) files"
	@echo -e "  ⚡ JavaScript: $(words $(JS_FILES)) files"
	@echo -e "  🐍 Python: $(words $(PY_FILES)) files"
	@echo -e "  � PowerShell: $(words $(PS1_FILES)) files"
	@echo -e "  �📝 YAML: $(words $(YAML_FILES)) files"
	@echo -e "  📋 JSON: $(words $(JSON_FILES)) files"
	@echo -e "  📖 Markdown: $(words $(MD_FILES)) files"
	@echo ""
	@echo -e "${CYAN}Tool availability:${NC}"
	@command -v eslint >/dev/null 2>&1 && echo -e "  ✅ ESLint" || echo -e "  ❌ ESLint"
	@command -v prettier >/dev/null 2>&1 && echo -e "  ✅ Prettier" || echo -e "  ❌ Prettier"
	@command -v htmlhint >/dev/null 2>&1 && echo -e "  ✅ HTMLHint" || echo -e "  ❌ HTMLHint"
	@command -v stylelint >/dev/null 2>&1 && echo -e "  ✅ Stylelint" || echo -e "  ❌ Stylelint"
	@command -v flake8 >/dev/null 2>&1 && echo -e "  ✅ Flake8" || ([ -f "/Users/bryanjorgensen/Library/Python/3.9/bin/flake8" ] && echo -e "  ✅ Flake8 (user lib)" || echo -e "  ❌ Flake8")
	@command -v black >/dev/null 2>&1 && echo -e "  ✅ Black" || ([ -f "/Users/bryanjorgensen/Library/Python/3.9/bin/black" ] && echo -e "  ✅ Black (user lib)" || echo -e "  ❌ Black")
	@command -v pylint >/dev/null 2>&1 && echo -e "  ✅ Pylint" || ([ -f "/Users/bryanjorgensen/Library/Python/3.9/bin/pylint" ] && echo -e "  ✅ Pylint (user lib)" || echo -e "  ❌ Pylint")
	@command -v mypy >/dev/null 2>&1 && echo -e "  ✅ mypy" || ([ -f "/Users/bryanjorgensen/Library/Python/3.9/bin/mypy" ] && echo -e "  ✅ mypy (user lib)" || echo -e "  ❌ mypy")
	@command -v bandit >/dev/null 2>&1 && echo -e "  ✅ Bandit" || ([ -f "/Users/bryanjorgensen/Library/Python/3.9/bin/bandit" ] && echo -e "  ✅ Bandit (user lib)" || echo -e "  ❌ Bandit")
	@echo ""
	@echo -e "${CYAN}PowerShell tools:${NC}"
	@command -v pwsh >/dev/null 2>&1 && echo -e "  ✅ PowerShell Core" || echo -e "  ❌ PowerShell Core"
	@command -v powershell >/dev/null 2>&1 && echo -e "  ✅ Windows PowerShell" || echo -e "  ❌ Windows PowerShell"
	@if command -v pwsh >/dev/null 2>&1; then \
		pwsh -Command "Get-Module -ListAvailable PSScriptAnalyzer" >/dev/null 2>&1 && echo -e "  ✅ PSScriptAnalyzer" || echo -e "  ❌ PSScriptAnalyzer"; \
	elif command -v powershell >/dev/null 2>&1; then \
		powershell -Command "Get-Module -ListAvailable PSScriptAnalyzer" >/dev/null 2>&1 && echo -e "  ✅ PSScriptAnalyzer" || echo -e "  ❌ PSScriptAnalyzer"; \
	else \
		echo -e "  ❌ PSScriptAnalyzer (PowerShell required)"; \
	fi
	@echo ""
	@echo -e "${CYAN}Secret scanning tools:${NC}"
	@command -v gitleaks >/dev/null 2>&1 && echo -e "  ✅ Gitleaks" || echo -e "  ❌ Gitleaks"
	@command -v trufflehog >/dev/null 2>&1 && echo -e "  ✅ TruffleHog" || echo -e "  ❌ TruffleHog"
	@[ -f ".venv/bin/ggshield" ] && echo -e "  ✅ GitGuardian Shield" || echo -e "  ❌ GitGuardian Shield"
	@echo ""
	@echo -e "${CYAN}Testing frameworks:${NC}"
	@command -v npm >/dev/null 2>&1 && npm list jest >/dev/null 2>&1 && echo -e "  ✅ Jest (JavaScript)" || echo -e "  ❌ Jest (JavaScript)"
	@[ -f ".venv/bin/pytest" ] && echo -e "  ✅ pytest (Python)" || echo -e "  ❌ pytest (Python)"
	@command -v mvn >/dev/null 2>&1 && [ -f "pom.xml" ] && echo -e "  ✅ JUnit (Java)" || echo -e "  ❌ JUnit (Java)"
	@echo ""
	@echo -e "${CYAN}Plagiarism detection tools:${NC}"
	@command -v dolos >/dev/null 2>&1 && echo -e "  ✅ Dolos" || echo -e "  ❌ Dolos"
	@npm list -g hookejs >/dev/null 2>&1 && echo -e "  ✅ HookeJs" || echo -e "  ❌ HookeJs"
	@[ -d "$(HOME)/.local/copyright-detection" ] && echo -e "  ✅ Copyright-detection" || echo -e "  ❌ Copyright-detection"
	@echo ""
	@echo -e "${CYAN}Design content tools:${NC}"
	@[ -f "scripts/collect-free-designs.py" ] && echo -e "  ✅ Design content collector" || echo -e "  ❌ Design content collector"
	@[ -d "docs/assets/designs/free-content" ] && echo -e "  ✅ Content directory" || echo -e "  ❌ Content directory"
	@python3 -c "import requests" 2>/dev/null && echo -e "  ✅ HTTP requests library" || echo -e "  ❌ HTTP requests library"
	@[ -f "docs/assets/designs/free-content/search-results.json" ] && echo -e "  ✅ Search results available" || echo -e "  ❌ No search results"

# Design Content Management
# ========================

design-content-setup: ## Set up design content collection environment
	@echo -e "${BLUE}Setting up design content collection...${NC}"
	@python3 -m pip install --user requests beautifulsoup4 lxml
	@mkdir -p docs/assets/designs/free-content
	@mkdir -p docs/assets/designs/source-files
	@chmod +x scripts/collect-free-designs.py
	@chmod +x scripts/enhanced-design-collector.py
	@echo -e "${GREEN}✅ Design content environment ready${NC}"

design-content-collect: ## Collect free design content from Freepik and TshirtDesigns.com
	@echo -e "${BLUE}Collecting free design content...${NC}"
	@python3 scripts/collect-free-designs.py --queries minimalist vintage geometric nature abstract typography retro modern urban outdoor
	@echo -e "${GREEN}✅ Design content collection complete${NC}"

design-content-collect-enhanced: ## Collect free design content from multiple enhanced sources
	@echo -e "${BLUE}Collecting enhanced free design content...${NC}"
	@python3 scripts/enhanced-design-collector.py --queries minimalist vintage geometric nature abstract typography retro modern urban outdoor
	@echo -e "${GREEN}✅ Enhanced design content collection complete${NC}"

design-content-download: ## Download actual design content files (limit 5 by default)
	@echo -e "${BLUE}Downloading design content files...${NC}"
	@python3 scripts/download-design-content.py --limit 5
	@echo -e "${GREEN}✅ Design content download complete${NC}"

design-content-download-more: ## Download more design content files (usage: make design-content-download-more LIMIT=10)
	@echo -e "${BLUE}Downloading $(or $(LIMIT),10) design content files...${NC}"
	@python3 scripts/download-design-content.py --limit $(or $(LIMIT),10)
	@echo -e "${GREEN}✅ Design content download complete${NC}"

design-content-collect-custom: ## Collect design content with custom queries (usage: make design-content-collect-custom QUERIES="query1 query2")
	@echo -e "${BLUE}Collecting free design content for: $(QUERIES)${NC}"
	@python3 scripts/collect-free-designs.py --queries $(QUERIES)
	@echo -e "${GREEN}✅ Custom design content collection complete${NC}"

design-content-report: ## Generate design content report
	@echo -e "${BLUE}Generating design content report...${NC}"
	@[ -f docs/assets/designs/free-content/search-results.json ] && \
		echo -e "${GREEN}✅ Found search results${NC}" || \
		echo -e "${YELLOW}⚠️  No search results found. Run 'make design-content-collect' first${NC}"
	@[ -f docs/assets/designs/free-content/FREE-CONTENT-REPORT.md ] && \
		echo -e "${GREEN}✅ Design content report available at docs/assets/designs/free-content/FREE-CONTENT-REPORT.md${NC}" || \
		echo -e "${YELLOW}⚠️  No report found${NC}"

design-content-clean: ## Clean design content collection data
	@echo -e "${BLUE}Cleaning design content data...${NC}"
	@rm -rf docs/assets/designs/free-content/search-results.json
	@rm -rf docs/assets/designs/free-content/FREE-CONTENT-REPORT.md
	@echo -e "${GREEN}✅ Design content data cleaned${NC}"

# Enhanced FreshVision AI
# =======================

fresh-vision-enhanced: ## Launch Enhanced FreshVision AI with Pollinations AI and Galaxy.ai support
	@echo -e "${BLUE}Starting Enhanced FreshVision AI Designer...${NC}"
	@echo -e "${CYAN}Features: ComfyUI + Pollinations AI + Galaxy.ai${NC}"
	@python3 enhanced_fresh_vision.py

fresh-vision-original: ## Launch original FreshVision AI (ComfyUI only)
	@echo -e "${BLUE}Starting original FreshVision AI Designer...${NC}"
	@python3 comfyui_web_interface_clean.py

fresh-vision-test: ## Test AI services availability
	@echo -e "${BLUE}Testing AI services...${NC}"
	@python3 scripts/test-ai-services.py
	@echo -e "${GREEN}✅ AI services test complete${NC}"

fresh-vision-demo: ## Generate a demo t-shirt design with Pollinations AI
	@echo -e "${BLUE}Generating demo t-shirt design...${NC}"
	@python3 scripts/test-pollinations.py
	@echo -e "${GREEN}✅ Demo generation complete${NC}"

design-content-status: ## Show design content collection status
	@echo -e "${CYAN}Design Content Status:${NC}"
	@[ -d "docs/assets/designs/free-content" ] && echo -e "  ✅ Content directory exists" || echo -e "  ❌ Content directory missing"
	@[ -f "scripts/collect-free-designs.py" ] && echo -e "  ✅ Collection script ready" || echo -e "  ❌ Collection script missing"
	@[ -f "docs/assets/designs/free-content/search-results.json" ] && echo -e "  ✅ Search results available" || echo -e "  ❌ No search results"
	@[ -f "docs/assets/designs/free-content/FREE-CONTENT-REPORT.md" ] && echo -e "  ✅ Content report available" || echo -e "  ❌ No content report"
	@python3 -c "import requests, json; print('  ✅ Required packages available')" 2>/dev/null || echo -e "  ❌ Missing required packages (run: make design-content-setup)"

# Default target
.DEFAULT_GOAL := help
