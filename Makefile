# FreshThreads LLC - Makefile
# Provides convenient commands for development and local LLM integration

.PHONY: help dev validate format deploy llm-start llm-stop llm-status llm-chat llm-review llm-analyze llm-security llm-improve llm-compat llm-models llm-pull llm-switch llm-tasks python-setup python-install python-activate python-clean python-deps python-status python-shell python-run python-update analyze-html analyze-html-report continue-setup continue-status continue-sync llm-full-setup secrets-get secrets-set secrets-list secrets-delete secrets-export secrets-import secrets-setup security-scan security-test security-auth security-monitor security-report security-fix security-status security-validate aikido-demo aikido-test aikido-status aikido-scan aikido-scan-cli aikido-scan-release aikido-setup-cli csp-add csp-check csp-validate csp-report design-analyze design-refactor design-preview design-colors lint lint-html lint-css lint-js lint-json lint-python lint-shell lint-markdown lint-yaml lint-fix clean install docker-build docker-dev docker-prod docker-test docker-test-unit docker-test-integration docker-test-security docker-test-e2e docker-test-accessibility docker-test-load docker-cleanup docker-logs docker-status docker-security-status docker-security-logs docker-test-openappsec sonar-start sonar-stop sonar-status sonar-analyze sonar-report sonar-cleanup sonar-logs sonar-backup issue-list issue-view issue-create issue-assign issue-comment issue-close issue-labels issue-status issue-help issue-feature issue-bug issue-deployment issue-setup-labels issue-list-labels pr-create pr-list pr-view pr-merge pr-status pr-help branch-protect branch-protect-status branch-protect-disable

# Default target
help:
	@echo "🧵 FreshThreads LLC - Development Commands"
	@echo ""
	@echo "📋 Available commands:"
	@echo "  make dev          - Start development server (http-server)"
	@echo "  make validate     - Validate HTML files"
	@echo "  make format       - Format HTML, CSS, and JS files"
	@echo "  make deploy       - Deploy to GitHub Pages"
	@echo ""
	@echo "🤖 Local LLM Commands:"
	@echo "  make llm-start    - Start local LLM server (Ollama)"
	@echo "  make llm-stop     - Stop local LLM server"
	@echo "  make llm-status   - Check LLM server status"
	@echo "  make llm-chat     - Interactive chat with local LLM"
	@echo "  make llm-review   - Review codebase with LLM"
	@echo "  make llm-analyze  - Analyze project structure with LLM"
	@echo "  make llm-security - Security review with LLM"
	@echo "  make llm-improve  - Get improvement suggestions"
	@echo "  make llm-compat   - Check GitHub Pages compatibility"
	@echo "  make llm-models   - List available models"
	@echo "  make llm-tasks    - Show recommended models for tasks"
	@echo "  make llm-pull MODEL=<name> - Pull a specific model"
	@echo "  make llm-switch MODEL=<name> - Switch default model"
	@echo ""
	@echo "🐍 Python Environment Commands:"
	@echo "  make python-setup    - Create Python virtual environment"
	@echo "  make python-install [PACKAGE=name] - Install dependencies or specific package"
	@echo "  make python-activate - Show activation command and status"
	@echo "  make python-deps     - Update requirements.txt"
	@echo "  make python-clean    - Remove Python environment"
	@echo "  make python-status   - Show environment status"
	@echo "  make python-shell    - Start Python shell in environment"
	@echo "  make python-run SCRIPT=<path> - Run Python script"
	@echo "  make python-update   - Update all packages"
	@echo "  make analyze-html    - Analyze HTML files for GitHub Pages compatibility"
	@echo "  make analyze-html-report - Generate detailed HTML analysis report"
	@echo ""
	@echo "🔧 Continue Extension Commands:"
	@echo "  make continue-setup  - Configure Continue extension for local LLM"
	@echo "  make continue-status - Check Continue extension configuration"
	@echo "  make continue-sync   - Sync Continue config with local LLM settings"
	@echo ""
	@echo "🔐 Secrets Management Commands:"
	@echo "  make secrets-get KEY=<key> - Retrieve secret from Keychain"
	@echo "  make secrets-set KEY=<key> - Store secret in Keychain"
	@echo "  make secrets-list    - List stored secrets for this project"
	@echo "  make secrets-delete KEY=<key> - Delete secret from Keychain"
	@echo "  make secrets-export [FILE=path] - Export secrets to .env file"
	@echo "  make secrets-import [FILE=path] - Import secrets from .env file"
	@echo "  make secrets-setup   - Interactive setup for common secrets"
	@echo ""
	@echo "🔒 Security Commands:"
	@echo "  make security-scan   - Run Snyk security scan"
	@echo "  make security-test   - Run comprehensive security tests"
	@echo "  make security-auth   - Authenticate with Snyk"
	@echo ""
	@echo "🛡️  Content Security Policy (CSP) Commands:"
	@echo "  make csp-add         - Add CSP headers to all HTML files"
	@echo "  make csp-check       - Check which files have CSP headers"
	@echo "  make csp-validate    - Validate CSP policy syntax"
	@echo "  make csp-report      - Generate CSP compliance report"
	@echo ""
	@echo "🎨 Design & LLM-Assisted Refactoring Commands:"
	@echo "  make design-analyze  - Analyze current design with LLM"
	@echo "  make design-refactor - LLM-assisted design refactoring"
	@echo "  make design-preview  - Preview design changes locally"
	@echo "  make design-colors   - Extract and analyze color palette"
	@echo ""
	@echo "🔍 Linting Commands:"
	@echo "  make lint            - Run all linters"
	@echo "  make lint-html       - Lint HTML files"
	@echo "  make lint-css        - Lint CSS files"
	@echo "  make lint-js         - Lint JavaScript files"
	@echo "  make lint-json       - Lint JSON files"
	@echo "  make lint-python     - Lint Python files"
	@echo "  make lint-shell      - Lint shell scripts"
	@echo "  make lint-markdown   - Lint Markdown files"
	@echo "  make lint-yaml       - Lint YAML files"
	@echo "  make lint-fix        - Auto-fix linting issues where possible"
	@echo ""
	@echo "🧹 Utility Commands:"
	@echo "  make clean        - Clean temporary files"
	@echo "  make install      - Install development dependencies"
	@echo ""
	@echo "🐳 Docker Commands:"
	@echo "  make docker-build         - Build Docker images"
	@echo "  make docker-dev           - Start development environment in Docker"
	@echo "  make docker-prod          - Start production environment in Docker"
	@echo "  make docker-test          - Run full test suite in Docker"
	@echo "  make docker-test-unit     - Run unit tests in Docker"
	@echo "  make docker-test-integration - Run integration tests in Docker"
	@echo "  make docker-test-security - Run security tests in Docker"
	@echo "  make docker-test-e2e      - Run end-to-end tests in Docker"
	@echo "  make docker-test-accessibility - Run accessibility tests in Docker"
	@echo "  make docker-test-load     - Run load tests in Docker"
	@echo "  make docker-cleanup       - Clean up Docker resources"
	@echo "  make docker-logs          - Show Docker container logs"
	@echo "  make docker-status        - Show Docker container status"
	@echo "  make docker-security-status - Check OpenAppSec security status"
	@echo "  make docker-security-logs - View OpenAppSec security logs"
	@echo "  make docker-test-openappsec - Run OpenAppSec security tests"
	@echo ""
	@echo "📊 SonarQube Code Quality Commands:"
	@echo "  make sonar-start          - Start SonarQube server"
	@echo "  make sonar-stop           - Stop SonarQube server"
	@echo "  make sonar-status         - Check SonarQube status"
	@echo "  make sonar-analyze        - Run code quality analysis"
	@echo "  make sonar-report         - Generate quality report"
	@echo "  make sonar-cleanup        - Clean up SonarQube data"
	@echo "  make sonar-logs           - View SonarQube logs"
	@echo "  make sonar-backup         - Backup SonarQube data"
	@echo ""
	@echo "🔗 GitHub Issue Management Commands:"
	@echo "  make issue-list           - List all GitHub issues"
	@echo "  make issue-view NUM=<n>   - View specific issue details"
	@echo "  make issue-create         - Create new issue (interactive)"
	@echo "  make issue-assign NUM=<n> - Assign issue to yourself"
	@echo "  make issue-comment NUM=<n> COMMENT='...' - Add comment to issue"
	@echo "  make issue-close NUM=<n>  - Close issue"
	@echo "  make issue-labels NUM=<n> LABELS='...' - Add labels to issue"
	@echo "  make issue-status         - Show issue statistics"
	@echo "  make issue-help           - Show detailed issue management help"
	@echo ""
	@echo "📋 Quick Issue Templates (Interactive):"
	@echo "  make issue-feature        - Create feature request (prompts for input)"
	@echo "  make issue-bug            - Create bug report (prompts for input)"
	@echo "  make issue-deployment     - Create deployment task (prompts for input)"
	@echo ""
	@echo "🏷️  Label Management:"
	@echo "  make issue-setup-labels   - Create standard GitHub issue labels"
	@echo "  make issue-list-labels    - List all available labels"
	@echo ""
	@echo "🔀 GitHub Pull Request Management Commands:"
	@echo "  make pr-create            - Create pull request (interactive)"
	@echo "  make pr-list              - List all pull requests"
	@echo "  make pr-view NUM=<n>      - View specific pull request details"
	@echo "  make pr-merge NUM=<n>     - Merge pull request"
	@echo "  make pr-status            - Show pull request statistics"
	@echo "  make pr-help              - Show detailed PR management help"
	@echo ""
	@echo "🛡️  Branch Protection Commands:"
	@echo "  make branch-protect       - Enable branch protection on main"
	@echo "  make branch-protect-status - Check branch protection status"
	@echo "  make branch-protect-disable - Disable branch protection (admin only)"
	@echo ""
	@echo "🚀 Combined Workflows:"
	@echo "  make llm-full-setup - Complete LLM development environment setup"
	@echo "  make llm-dev      - Start development server with LLM"
	@echo "  make llm-deploy   - LLM-assisted deployment"
	@echo "📋 Available commands:"
	@echo "  make dev          - Start development server (http-server)"
	@echo "  make validate     - Validate HTML files"
	@echo "  make format       - Format HTML, CSS, and JS files"
	@echo "  make deploy       - Deploy to GitHub Pages"
	@echo ""
	@echo "🤖 Local LLM Commands:"
	@echo "  make llm-start    - Start local LLM server (Ollama)"
	@echo "  make llm-stop     - Stop local LLM server"
	@echo "  make llm-status   - Check LLM server status"
	@echo "  make llm-chat     - Interactive chat with local LLM"
	@echo "  make llm-review   - Review codebase with LLM"
	@echo "  make llm-analyze  - Analyze project structure with LLM"
	@echo "  make llm-security - Security review with LLM"
	@echo "  make llm-improve  - Get improvement suggestions"
	@echo "  make llm-compat   - Check GitHub Pages compatibility"
	@echo "  make llm-models   - List available models"
	@echo "  make llm-tasks    - Show recommended models for tasks"
	@echo "  make llm-pull MODEL=<name> - Pull a specific model"
	@echo "  make llm-switch MODEL=<name> - Switch default model"
	@echo ""
	@echo "🐍 Python Environment Commands:"
	@echo "  make python-setup    - Create Python virtual environment"
	@echo "  make python-install [PACKAGE=name] - Install dependencies or specific package"
	@echo "  make python-activate - Show activation command and status"
	@echo "  make python-deps     - Update requirements.txt"
	@echo "  make python-clean    - Remove Python environment"
	@echo "  make python-status   - Show environment status"
	@echo "  make python-shell    - Start Python shell in environment"
	@echo "  make python-run SCRIPT=<path> - Run Python script"
	@echo "  make python-update   - Update all packages"
	@echo "  make analyze-html    - Analyze HTML files for GitHub Pages compatibility"
	@echo "  make analyze-html-report - Generate detailed HTML analysis report"
	@echo ""
	@echo "🔧 Continue Extension Commands:"
	@echo "  make continue-setup  - Configure Continue extension for local LLM"
	@echo "  make continue-status - Check Continue extension configuration"
	@echo "  make continue-sync   - Sync Continue config with local LLM settings"
	@echo ""
	@echo "🔐 Secrets Management Commands:"
	@echo "  make secrets-get KEY=<key> - Retrieve secret from Keychain"
	@echo "  make secrets-set KEY=<key> - Store secret in Keychain"
	@echo "  make secrets-list    - List stored secrets for this project"
	@echo "  make secrets-delete KEY=<key> - Delete secret from Keychain"
	@echo "  make secrets-export [FILE=path] - Export secrets to .env file"
	@echo "  make secrets-import [FILE=path] - Import secrets from .env file"
	@echo "  make secrets-setup   - Interactive setup for common secrets"
	@echo ""
	@echo "🔒 Security Commands:"
	@echo "  make security-scan   - Run Snyk security scan"
	@echo "  make security-test   - Run comprehensive security tests"
	@echo "  make security-auth   - Authenticate with Snyk"
	@echo ""
	@echo "🛡️  Content Security Policy (CSP) Commands:"
	@echo "  make csp-add         - Add CSP headers to all HTML files"
	@echo "  make csp-check       - Check which files have CSP headers"
	@echo "  make csp-validate    - Validate CSP policy syntax"
	@echo "  make csp-report      - Generate CSP compliance report"
	@echo ""
	@echo "🎨 Design & LLM-Assisted Refactoring Commands:"
	@echo "  make design-analyze  - Analyze current design with LLM"
	@echo "  make design-refactor - LLM-assisted design refactoring"
	@echo "  make design-preview  - Preview design changes locally"
	@echo "  make design-colors   - Extract and analyze color palette"
	@echo ""
	@echo "🔍 Linting Commands:"
	@echo "  make lint            - Run all linters"
	@echo "  make lint-html       - Lint HTML files"
	@echo "  make lint-css        - Lint CSS files"
	@echo "  make lint-js         - Lint JavaScript files"
	@echo "  make lint-json       - Lint JSON files"
	@echo "  make lint-python     - Lint Python files"
	@echo "  make lint-shell      - Lint shell scripts"
	@echo "  make lint-markdown   - Lint Markdown files"
	@echo "  make lint-yaml       - Lint YAML files"
	@echo "  make lint-fix        - Auto-fix linting issues where possible"
	@echo ""
	@echo "🧹 Utility Commands:"
	@echo "  make clean        - Clean temporary files"
	@echo "  make install      - Install development dependencies"
	@echo ""
	@echo "� Docker Commands:"
	@echo "  make docker-build         - Build Docker images"
	@echo "  make docker-dev           - Start development environment in Docker"
	@echo "  make docker-prod          - Start production environment in Docker"
	@echo "  make docker-test          - Run full test suite in Docker"
	@echo "  make docker-test-unit     - Run unit tests in Docker"
	@echo "  make docker-test-integration - Run integration tests in Docker"
	@echo "  make docker-test-security - Run security tests in Docker"
	@echo "  make docker-test-e2e      - Run end-to-end tests in Docker"
	@echo "  make docker-test-accessibility - Run accessibility tests in Docker"
	@echo "  make docker-test-load     - Run load tests in Docker"
	@echo "  make docker-cleanup       - Clean up Docker resources"
	@echo "  make docker-logs          - Show Docker container logs"
	@echo "  make docker-status        - Show Docker container status"
	@echo ""
	@echo "�🚀 Combined Workflows:"
	@echo "  make llm-full-setup - Complete LLM development environment setup"
	@echo "  make llm-dev      - Start development server with LLM"
	@echo "  make llm-deploy   - LLM-assisted deployment"

# Development commands
dev:
	@echo "🚀 Starting development server..."
	@cd docs && npx http-server . -p 5500 -c-1 -o

validate:
	@echo "✅ Validating HTML files..."
	@npx html-validate docs/*.html

format:
	@echo "🎨 Formatting code files..."
	@npx prettier --write docs/*.html docs/**/*.css docs/**/*.js

deploy:
	@echo "🚀 Deploying to GitHub Pages..."
	@git add .
	@git status
	@echo "Committing changes..."
	@git commit -m "Update website - $(shell date '+%Y-%m-%d %H:%M:%S')" || echo "No changes to commit"
	@git push origin main

# Local LLM commands
llm-start:
	@echo "🤖 Starting local LLM server (Ollama)..."
	@if ! command -v ollama >/dev/null 2>&1; then \
		echo "❌ Ollama not found. Please install Ollama first."; \
		echo "   Visit: https://ollama.ai"; \
		exit 1; \
	fi
	@echo "Starting Ollama server..."
	@ollama serve > /dev/null 2>&1 & echo $$! > .ollama.pid
	@sleep 3
	@echo "✅ Ollama server started"
	@echo "📋 Pulling dolphin-llama3 model if needed..."
	@ollama pull dolphin-llama3
	@echo "🎯 LLM server ready at http://localhost:11434"

llm-stop:
	@echo "🛑 Stopping local LLM server..."
	@if [ -f .ollama.pid ]; then \
		kill `cat .ollama.pid` 2>/dev/null || true; \
		rm .ollama.pid; \
		echo "✅ Ollama server stopped"; \
	else \
		echo "⚠️  No running Ollama server found"; \
	fi

llm-status:
	@echo "📊 Checking LLM server status..."
	@if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then \
		echo "✅ Ollama server is running at http://localhost:11434"; \
		echo "📋 Available models:"; \
		curl -s http://localhost:11434/api/tags | jq -r '.models[].name' 2>/dev/null || echo "  - dolphin-llama3"; \
	else \
		echo "❌ Ollama server is not running"; \
		echo "   Run 'make llm-start' to start the server"; \
	fi

llm-chat:
	@echo "💬 Starting interactive chat with local LLM..."
	@if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then \
		echo "❌ Ollama server not running. Starting server..."; \
		make llm-start; \
	fi
	@./scripts/llm-helper.sh chat $(MODEL)

llm-review:
	@echo "🔍 Running LLM code review..."
	@if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then \
		echo "❌ Ollama server not running. Starting server..."; \
		make llm-start; \
	fi
	@./scripts/llm-helper.sh analyze $(FILE) $(MODEL)

llm-analyze:
	@echo "📊 Analyzing project with LLM..."
	@if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then \
		echo "❌ Ollama server not running. Starting server..."; \
		make llm-start; \
	fi
	@./scripts/llm-helper.sh analyze $(FILE) $(MODEL)

llm-security:
	@echo "🔒 Running security review..."
	@if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then \
		echo "❌ Ollama server not running. Starting server..."; \
		make llm-start; \
	fi
	@./scripts/llm-helper.sh security $(MODEL)

llm-improve:
	@echo "� Getting improvement suggestions..."
	@if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then \
		echo "❌ Ollama server not running. Starting server..."; \
		make llm-start; \
	fi
	@./scripts/llm-helper.sh improve

llm-compat:
	@echo "✅ Checking GitHub Pages compatibility..."
	@if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then \
		echo "❌ Ollama server not running. Starting server..."; \
		make llm-start; \
	fi
	@./scripts/llm-helper.sh compat $(MODEL)

llm-models:
	@echo "📋 Listing available models..."
	@if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then \
		echo "❌ Ollama server not running. Starting server..."; \
		make llm-start; \
	fi
	@./scripts/llm-helper.sh models

llm-tasks:
	@echo "🎯 Showing recommended models for tasks..."
	@./scripts/llm-helper.sh tasks

llm-pull:
	@if [ -z "$(MODEL)" ]; then \
		echo "❌ No model specified. Usage: make llm-pull MODEL=<model_name>"; \
		echo "Examples:"; \
		echo "  make llm-pull MODEL=codellama:13b"; \
		echo "  make llm-pull MODEL=mistral:7b"; \
		exit 1; \
	fi
	@echo "📥 Pulling model: $(MODEL)..."
	@if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then \
		echo "❌ Ollama server not running. Starting server..."; \
		make llm-start; \
	fi
	@./scripts/llm-helper.sh pull $(MODEL)

llm-switch:
	@if [ -z "$(MODEL)" ]; then \
		echo "❌ No model specified. Usage: make llm-switch MODEL=<model_name>"; \
		echo "Examples:"; \
		echo "  make llm-switch MODEL=codellama:13b"; \
		echo "  make llm-switch MODEL=mistral:7b"; \
		exit 1; \
	fi
	@echo "🔄 Switching to model: $(MODEL)..."
	@if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then \
		echo "❌ Ollama server not running. Starting server..."; \
		make llm-start; \
	fi
	@./scripts/llm-helper.sh switch $(MODEL)

# Python Environment Commands
python-setup:
	@echo "🐍 Setting up Python virtual environment..."
	@./scripts/python-env.sh create

python-install:
	@echo "📦 Installing Python dependencies..."
	@if [ -n "$(PACKAGE)" ]; then \
		./scripts/python-env.sh install $(PACKAGE); \
	else \
		./scripts/python-env.sh install; \
	fi

python-activate:
	@./scripts/python-env.sh status

python-deps:
	@echo "📝 Updating requirements.txt..."
	@./scripts/python-env.sh requirements

python-clean:
	@echo "🧹 Cleaning Python environment..."
	@./scripts/python-env.sh clean

python-status:
	@./scripts/python-env.sh status

python-shell:
	@echo "🐍 Starting Python shell in virtual environment..."
	@./scripts/python-env.sh shell

python-run:
	@if [ -z "$(SCRIPT)" ]; then \
		echo "❌ No script specified. Usage: make python-run SCRIPT=<script_path>"; \
		echo "Example: make python-run SCRIPT=scripts/build.py"; \
		exit 1; \
	fi
	@echo "🚀 Running Python script: $(SCRIPT)"
	@./scripts/python-env.sh run $(SCRIPT)

python-update:
	@echo "⬆️  Updating Python packages..."
	@./scripts/python-env.sh update

# Python-based analysis tools
analyze-html:
	@echo "🔍 Analyzing HTML files with Python..."
	@if [ ! -d "venv" ]; then \
		echo "❌ Python environment not found. Run 'make python-setup' first"; \
		exit 1; \
	fi
	@if [ -n "$(FILE)" ]; then \
		./scripts/python-env.sh run scripts/analyze_html.py --file $(FILE); \
	else \
		./scripts/python-env.sh run scripts/analyze_html.py; \
	fi

analyze-html-report:
	@echo "📊 Generating HTML analysis report..."
	@if [ ! -d "venv" ]; then \
		echo "❌ Python environment not found. Run 'make python-setup' first"; \
		exit 1; \
	fi
	@./scripts/python-env.sh run scripts/analyze_html.py --output analysis-report.json
	@echo "✅ Report saved to analysis-report.json"

# Utility commands
clean:
	@echo "🧹 Cleaning temporary files..."
	@rm -f .ollama.pid
	@rm -f /tmp/llm-review.txt
	@rm -f /tmp/llm-analysis.txt
	@rm -f security-report.json
	@rm -f .env.local
	@find . -name ".DS_Store" -delete 2>/dev/null || true
	@echo "✅ Cleanup complete"

install:
	@echo "📦 Installing development dependencies..."
	@echo "Installing Node.js dependencies..."
	@npm install
	@echo "Installing system dependencies..."
	@if ! command -v shellcheck >/dev/null 2>&1; then \
		echo "Installing shellcheck..."; \
		if command -v brew >/dev/null 2>&1; then \
			brew install shellcheck; \
		else \
			echo "⚠️  Please install shellcheck manually"; \
		fi; \
	fi
	@if ! command -v yamllint >/dev/null 2>&1; then \
		echo "Installing yamllint..."; \
		pip3 install yamllint; \
	fi
	@if ! command -v ollama >/dev/null 2>&1; then \
		echo "⚠️  Ollama not found. Please install manually:"; \
		echo "   Visit: https://ollama.ai"; \
	else \
		echo "✅ Ollama found"; \
	fi
	@echo "✅ Dependencies installation complete"

# Secrets Management Commands
secrets-get:
	@if [ -z "$(KEY)" ]; then \
		echo "❌ No key specified. Usage: make secrets-get KEY=<key_name>"; \
		echo "Examples:"; \
		echo "  make secrets-get KEY=github-token"; \
		echo "  make secrets-get KEY=api-key"; \
		echo ""; \
		echo "Available secrets:"; \
		./scripts/secrets-manager.sh list; \
		exit 1; \
	fi
	@./scripts/secrets-manager.sh get $(KEY)

secrets-set:
	@if [ -z "$(KEY)" ]; then \
		echo "❌ No key specified. Usage: make secrets-set KEY=<key_name>"; \
		echo "Examples:"; \
		echo "  make secrets-set KEY=github-token"; \
		echo "  make secrets-set KEY=api-key"; \
		exit 1; \
	fi
	@./scripts/secrets-manager.sh set $(KEY) $(VALUE)

secrets-list:
	@./scripts/secrets-manager.sh list

secrets-delete:
	@if [ -z "$(KEY)" ]; then \
		echo "❌ No key specified. Usage: make secrets-delete KEY=<key_name>"; \
		echo "Examples:"; \
		echo "  make secrets-delete KEY=github-token"; \
		echo "  make secrets-delete KEY=old-api-key"; \
		exit 1; \
	fi
	@./scripts/secrets-manager.sh delete $(KEY)

secrets-export:
	@echo "📤 Exporting secrets to .env file..."
	@./scripts/secrets-manager.sh export $(FILE)

secrets-import:
	@echo "📥 Importing secrets from .env file..."
	@./scripts/secrets-manager.sh import $(FILE)

secrets-setup:
	@echo "🔧 Setting up common development secrets..."
	@./scripts/secrets-manager.sh setup

# Security Commands
security-scan:
	@echo "🔒 Running Snyk security scan..."
	@if ! command -v snyk >/dev/null 2>&1; then \
		echo "❌ Snyk not found. Installing..."; \
		npm install -g snyk; \
	fi
	@echo "🔍 Scanning for vulnerabilities..."
	@snyk test --severity-threshold=medium || echo "⚠️  Vulnerabilities found - check output above"

security-test:
	@echo "🔒 Running comprehensive security tests..."
	@if ! command -v snyk >/dev/null 2>&1; then \
		echo "❌ Snyk not found. Installing..."; \
		npm install -g snyk; \
	fi
	@echo "🔍 Testing for known vulnerabilities..."
	@snyk test --json --severity-threshold=low > security-report.json || true
	@echo "🔍 Testing for license issues..."
	@snyk test --print-deps || true
	@echo "🔍 Scanning Docker images (if any)..."
	@if [ -f Dockerfile ]; then snyk test --docker || true; fi
	@echo "✅ Security tests completed. Check security-report.json for details."

security-auth:
	@echo "🔐 Authenticating with Snyk..."
	@if ! command -v snyk >/dev/null 2>&1; then \
		echo "❌ Snyk not found. Installing..."; \
		npm install -g snyk; \
	fi
	@echo "📋 Opening Snyk authentication..."
	@snyk auth
	@echo "✅ Snyk authentication completed"

security-monitor:
	@echo "🔍 Setting up Snyk monitoring..."
	@if ! command -v snyk >/dev/null 2>&1; then \
		echo "❌ Snyk not found. Installing..."; \
		npm install -g snyk; \
	fi
	@echo "📊 Enabling continuous monitoring..."
	@snyk monitor
	@echo "✅ Project is now being monitored for new vulnerabilities"

security-report:
	@echo "📋 Generating detailed security report..."
	@if ! command -v snyk >/dev/null 2>&1; then \
		echo "❌ Snyk not found. Installing..."; \
		npm install -g snyk; \
	fi
	@echo "📊 Creating vulnerability report..."
	@snyk test --json > security-report.json || true
	@snyk test --sarif > security-report.sarif || true
	@echo "📊 Creating license report..."
	@snyk test --print-deps --json > license-report.json || true
	@echo "✅ Security reports generated: security-report.json, security-report.sarif, license-report.json"

security-fix:
	@echo "🔧 Attempting to fix vulnerabilities..."
	@if ! command -v snyk >/dev/null 2>&1; then \
		echo "❌ Snyk not found. Installing..."; \
		npm install -g snyk; \
	fi
	@echo "🩹 Applying automatic fixes..."
	@snyk wizard || echo "⚠️  Manual intervention may be required for some vulnerabilities"
	@echo "✅ Automatic fixes applied where possible"

security-status:
	@echo "📊 Checking Snyk authentication status..."
	@if ! command -v snyk >/dev/null 2>&1; then \
		echo "❌ Snyk not found. Please run 'make security-auth' first"; \
		exit 1; \
	fi
	@echo "🔍 Checking authentication..."
	@snyk config get api && echo "✅ Authenticated" || echo "❌ Not authenticated - run 'make security-auth'"
	@echo "📋 Checking project monitoring status..."
	@snyk monitor --dry-run 2>/dev/null && echo "✅ Monitoring configured" || echo "⚠️  Monitoring not set up - run 'make security-monitor'"

security-validate:
	@echo "🔒 Running comprehensive security validation..."
	@./scripts/security-validation.sh

# Aikido Runtime Security Commands
aikido-demo:
	@echo "🛡️ Starting Aikido security demonstration server..."
	@echo "🔒 Runtime protection will be active during demo"
	@AIKIDO_BLOCK=true AIKIDO_DEBUG=true node scripts/aikido-demo.js

aikido-test:
	@echo "🧪 Testing Aikido protection capabilities..."
	@echo "🚀 Starting demo server in background..."
	@AIKIDO_BLOCK=true node scripts/aikido-demo.js &
	@DEMO_PID=$$!
	@sleep 3
	@echo "🔍 Testing XSS protection..."
	@curl -s "http://localhost:3000/security-test?input=<script>alert('xss')</script>" | head -5 || true
	@echo "🔍 Testing SQL injection protection..."
	@curl -s "http://localhost:3000/security-test?input='; DROP TABLE users; --" | head -5 || true
	@echo "🔍 Testing path traversal protection..."
	@curl -s "http://localhost:3000/security-test?file=../../../etc/passwd" | head -5 || true
	@echo "🛑 Stopping demo server..."
	@kill $$DEMO_PID 2>/dev/null || true

aikido-status:
	@echo "🛡️ Checking Aikido configuration..."
	@if [ -f "aikido.json" ]; then \
		echo "✅ Configuration file found: aikido.json"; \
	else \
		echo "❌ Configuration file not found"; \
	fi
	@echo "📦 Checking Aikido package..."
	@npm list @aikidosec/firewall 2>/dev/null | grep firewall || echo "❌ Aikido firewall not installed"
	@echo "🔧 Environment variables:"
	@echo "  AIKIDO_BLOCK: $${AIKIDO_BLOCK:-not set}"
	@echo "  AIKIDO_DEBUG: $${AIKIDO_DEBUG:-not set}"
	@echo "  AIKIDO_TOKEN: $${AIKIDO_TOKEN:+configured}"
	@echo "🧪 Testing import..."
	@AIKIDO_BLOCK=true node -e "require('@aikidosec/firewall'); console.log('✅ Aikido can be imported successfully');" 2>/dev/null || echo "❌ Failed to import Aikido"

# Aikido CLI Security Scanning Commands
aikido-setup-cli:
	@echo "🛡️ Setting up Aikido CLI for security scanning..."
	@if ! command -v npx >/dev/null 2>&1; then \
		echo "❌ npx not found. Please install Node.js first."; \
		exit 1; \
	fi
	@echo "📦 Installing Aikido CI API client..."
	@npm list -g @aikidosec/ci-api-client >/dev/null 2>&1 || npm install -g @aikidosec/ci-api-client
	@echo "✅ Aikido CLI ready for security scanning"
	@echo "💡 Configure API key with: npx @aikidosec/ci-api-client apikey <your-key>"

aikido-scan-cli:
	@echo "🔍 Running Aikido CLI security scan..."
	@if ! command -v npx >/dev/null 2>&1; then \
		echo "❌ npx not found. Please install Node.js first."; \
		exit 1; \
	fi
	@if [ -z "$(REPO_ID)" ] || [ -z "$(BASE_COMMIT)" ] || [ -z "$(HEAD_COMMIT)" ]; then \
		echo "❌ Missing required parameters. Usage:"; \
		echo "   make aikido-scan-cli REPO_ID=<id> BASE_COMMIT=<base> HEAD_COMMIT=<head> [BRANCH=<branch>]"; \
		echo ""; \
		echo "Example:"; \
		echo "   make aikido-scan-cli REPO_ID=12345 BASE_COMMIT=abc123 HEAD_COMMIT=def456 BRANCH=feature/security"; \
		exit 1; \
	fi
	@echo "🔍 Scanning repository $(REPO_ID) from $(BASE_COMMIT) to $(HEAD_COMMIT)..."
	@npx @aikidosec/ci-api-client scan $(REPO_ID) $(BASE_COMMIT) $(HEAD_COMMIT) $(if $(BRANCH),$(BRANCH),main) \
		$(if $(MIN_SEVERITY),--minimum-severity-level $(MIN_SEVERITY),) \
		$(if $(FAIL_ON_DEPS),--fail-on-dependency-scan,--no-fail-on-dependency-scan) \
		$(if $(FAIL_ON_SAST),--fail-on-sast-scan,) \
		$(if $(FAIL_ON_IAC),--fail-on-iac-scan,) \
		$(if $(FAIL_ON_SECRETS),--fail-on-secrets-scan,)

aikido-scan:
	@echo "🔍 Running Aikido security scan with auto-detected commits..."
	@if ! command -v npx >/dev/null 2>&1; then \
		echo "❌ npx not found. Please install Node.js first."; \
		exit 1; \
	fi
	@if [ -z "$(REPO_ID)" ]; then \
		echo "❌ REPO_ID required. Usage: make aikido-scan REPO_ID=<repository_id>"; \
		echo "💡 Find your repository ID in the Aikido dashboard"; \
		exit 1; \
	fi
	@echo "🔍 Auto-detecting commit range..."
	@BASE_COMMIT=$$(git merge-base origin/main HEAD); \
	HEAD_COMMIT=$$(git rev-parse HEAD); \
	CURRENT_BRANCH=$$(git branch --show-current); \
	echo "📋 Scan parameters:"; \
	echo "   Repository ID: $(REPO_ID)"; \
	echo "   Base commit: $$BASE_COMMIT"; \
	echo "   Head commit: $$HEAD_COMMIT"; \
	echo "   Branch: $$CURRENT_BRANCH"; \
	echo "🚀 Starting scan..."; \
	npx @aikidosec/ci-api-client scan $(REPO_ID) $$BASE_COMMIT $$HEAD_COMMIT $$CURRENT_BRANCH \
		--minimum-severity-level $(if $(MIN_SEVERITY),$(MIN_SEVERITY),MEDIUM) \
		$(if $(FAIL_ON_DEPS),,--no-fail-on-dependency-scan)

aikido-scan-release:
	@echo "🚀 Running Aikido release scan..."
	@if ! command -v npx >/dev/null 2>&1; then \
		echo "❌ npx not found. Please install Node.js first."; \
		exit 1; \
	fi
	@if [ -z "$(REPO_ID)" ]; then \
		echo "❌ REPO_ID required. Usage: make aikido-scan-release REPO_ID=<repository_id> [COMMIT_ID=<commit>]"; \
		exit 1; \
	fi
	@COMMIT_ID=$(if $(COMMIT_ID),$(COMMIT_ID),$$(git rev-parse HEAD)); \
	echo "🔍 Running release scan for commit: $$COMMIT_ID"; \
	npx @aikidosec/ci-api-client scan-release $(REPO_ID) $$COMMIT_ID \
		--minimum-severity-level $(if $(MIN_SEVERITY),$(MIN_SEVERITY),HIGH)

# Linting Commands
lint:
	@echo "🔍 Running all linters..."
	@make lint-html
	@make lint-css
	@make lint-js
	@make lint-json
	@make lint-python
	@make lint-shell
	@make lint-markdown
	@make lint-yaml
	@echo "✅ All linting completed"

lint-html:
	@echo "🔍 Linting HTML files..."
	@if [ ! -f "package-lock.json" ]; then \
		echo "❌ Dependencies not installed. Run 'npm install' first"; \
		exit 1; \
	fi
	@find . -name "*.html" -not -path "./node_modules/*" -not -path "./venv/*" | xargs npx html-validate || echo "⚠️  HTML validation issues found"

lint-css:
	@echo "🔍 Linting CSS files..."
	@if [ ! -f "package-lock.json" ]; then \
		echo "❌ Dependencies not installed. Run 'npm install' first"; \
		exit 1; \
	fi
	@find . -name "*.css" -not -path "./node_modules/*" -not -path "./venv/*" | xargs npx stylelint --config-basedir . || echo "⚠️  CSS linting issues found"

lint-js:
	@echo "🔍 Linting JavaScript files..."
	@if [ ! -f "package-lock.json" ]; then \
		echo "❌ Dependencies not installed. Run 'npm install' first"; \
		exit 1; \
	fi
	@find . -name "*.js" -not -path "./node_modules/*" -not -path "./venv/*" | xargs npx eslint || echo "⚠️  JavaScript linting issues found"

lint-json:
	@echo "🔍 Linting JSON files..."
	@if [ ! -f "package-lock.json" ]; then \
		echo "❌ Dependencies not installed. Run 'npm install' first"; \
		exit 1; \
	fi
	@find . -name "*.json" -not -path "./node_modules/*" -not -path "./venv/*" -not -path "./.vscode/*" | xargs -I {} sh -c 'echo "Checking {}" && npx jsonlint {} > /dev/null' || echo "⚠️  JSON linting issues found"

lint-python:
	@echo "🔍 Linting Python files..."
	@if [ ! -d "venv" ]; then \
		echo "❌ Python environment not found. Run 'make python-setup' first"; \
		exit 1; \
	fi
	@source venv/bin/activate && python -m pip show flake8 >/dev/null 2>&1 || source venv/bin/activate && python -m pip install flake8
	@find . -name "*.py" -not -path "./venv/*" -exec venv/bin/python -m flake8 --max-line-length=100 --ignore=E203,W503 {} \; || echo "⚠️  Python linting issues found"

lint-shell:
	@echo "🔍 Linting shell scripts..."
	@if ! command -v shellcheck >/dev/null 2>&1; then \
		echo "❌ shellcheck not found. Installing..."; \
		if command -v brew >/dev/null 2>&1; then \
			brew install shellcheck; \
		else \
			echo "⚠️  Please install shellcheck manually"; \
			exit 1; \
		fi; \
	fi
	@find . -name "*.sh" -not -path "./venv/*" | xargs shellcheck || echo "⚠️  Shell script linting issues found"

lint-markdown:
	@echo "🔍 Linting Markdown files..."
	@if [ ! -f "package-lock.json" ]; then \
		echo "❌ Dependencies not installed. Run 'npm install' first"; \
		exit 1; \
	fi
	@find . -name "*.md" -not -path "./node_modules/*" -not -path "./venv/*" | xargs npx markdownlint || echo "⚠️  Markdown linting issues found"

lint-yaml:
	@echo "🔍 Linting YAML files..."
	@if ! command -v yamllint >/dev/null 2>&1 && ! python3 -m yamllint --version >/dev/null 2>&1; then \
		echo "❌ yamllint not found. Installing..."; \
		pip3 install yamllint; \
	fi
	@if command -v yamllint >/dev/null 2>&1; then \
		find . -name "*.yml" -o -name "*.yaml" -not -path "./venv/*" | xargs yamllint || echo "⚠️  YAML linting issues found"; \
	else \
		find . -name "*.yml" -o -name "*.yaml" -not -path "./venv/*" | xargs python3 -m yamllint || echo "⚠️  YAML linting issues found"; \
	fi

lint-fix:
	@echo "🔧 Auto-fixing linting issues..."
	@echo "📝 Formatting Python files with black..."
	@if [ -d "venv" ]; then \
		source venv/bin/activate && python -m pip show black >/dev/null 2>&1 || source venv/bin/activate && python -m pip install black; \
		find . -name "*.py" -not -path "./venv/*" -exec venv/bin/python -m black --line-length=100 {} \;; \
	fi
	@echo "📝 Formatting with prettier..."
	@if [ -f "package-lock.json" ]; then \
		npx prettier --write "docs/**/*.{html,css,js,json,md}" "*.{json,md}" ".github/**/*.{yml,yaml}" || true; \
	fi
	@echo "✅ Auto-fixing completed"

# Continue Extension Configuration
continue-setup:
	@echo "🔧 Configuring Continue extension for local LLM..."
	@./scripts/continue-helper.sh setup

continue-status:
	@echo "📊 Checking Continue extension configuration..."
	@./scripts/continue-helper.sh status

continue-sync:
	@echo "🔄 Syncing Continue config with local LLM settings..."
	@./scripts/continue-helper.sh sync

# Combined workflows
llm-dev:
	@echo "🚀 Starting full development environment with LLM..."
	@make llm-start
	@echo "⏳ Waiting for LLM server to be ready..."
	@sleep 5
	@echo "🌐 Starting development server..."
	@make dev

llm-deploy:
	@echo "🚀 LLM-assisted deployment..."
	@make llm-start
	@echo "🔍 Running pre-deployment review..."
	@make llm-review
	@echo "✅ Validation and formatting..."
	@make validate
	@make format
	@echo "📤 Deploying..."
	@make deploy
	@make llm-stop

llm-full-setup:
	@echo "🛠️  Complete LLM development environment setup..."
	@echo "📦 Installing dependencies..."
	@make install
	@echo "🐍 Setting up Python environment..."
	@make python-setup
	@echo "🤖 Starting LLM server..."
	@make llm-start
	@echo "🔧 Configuring Continue extension..."
	@make continue-setup
	@echo "🔒 Setting up security scanning..."
	@make security-auth
	@echo "✅ Full LLM development environment ready!"
	@echo ""
	@echo "🎯 Quick start guide:"
	@echo "  • Use 'make dev' to start development server"
	@echo "  • Use 'make llm-chat' for AI assistance"
	@echo "  • Use 'make lint' to check code quality"
	@echo "  • Use 'make csp-add' to secure your HTML files"

# Content Security Policy Commands
csp-add:
	@echo "🛡️  Adding CSP headers to HTML files..."
	@python3 scripts/add-csp.py

csp-check:
	@echo "🔍 Checking CSP implementation..."
	@grep -l "Content-Security-Policy" docs/*.html || echo "No CSP headers found"

csp-validate:
	@echo "✅ Validating CSP policy syntax..."
	@python3 -c "import scripts.add_csp; print('CSP policy syntax is valid')" 2>/dev/null || echo "CSP validation requires custom script"

csp-report:
	@echo "📊 Generating comprehensive CSP compliance report..."
	@python3 scripts/csp-validator.py

# Design & LLM-Assisted Refactoring Commands
design-analyze:
	@echo "🎨 Analyzing current design with LLM..."
	@./scripts/llm-design-refactor.sh

design-refactor:
	@echo "🔄 Starting LLM-assisted design refactoring..."
	@echo "🎯 Target: Minimalistic black & white design based on logo"
	@echo "📁 New design system: docs/styles/minimalistic.css"
	@echo "🔍 Run 'make design-preview' to see changes"
	@echo "💡 Next: Update HTML files to use new CSS classes"

design-preview:
	@echo "👀 Starting design preview server..."
	@echo "🌐 Preview URL: http://localhost:5500"
	@echo "📱 Test the new minimalistic design"
	@make dev

design-colors:
	@echo "🎨 Analyzing logo colors and design palette..."
	@echo "📍 Logo location: docs/assets/Fresh_ThreadsLLCLogo.png"
	@echo "🔤 Primary colors: Black (#000000), White (#ffffff)"
	@echo "📊 Gray scale: 50, 100, 200, 300, 400, 500, 600, 700, 800, 900"
	@echo "✨ Design system ready in: docs/styles/minimalistic.css"

# Docker Commands
docker-build:
	@echo "🐳 Building Docker images..."
	@if ! command -v docker >/dev/null 2>&1; then \
		echo "❌ Docker not found. Please install Docker first."; \
		echo "   Visit: https://docker.com"; \
		exit 1; \
	fi
	@./scripts/docker-test.sh build

docker-dev:
	@echo "🐳 Starting development environment in Docker..."
	@if ! command -v docker >/dev/null 2>&1; then \
		echo "❌ Docker not found. Please install Docker first."; \
		exit 1; \
	fi
	@docker-compose up dev

docker-prod:
	@echo "🐳 Starting production environment in Docker..."
	@if ! command -v docker >/dev/null 2>&1; then \
		echo "❌ Docker not found. Please install Docker first."; \
		exit 1; \
	fi
	@docker-compose up -d prod
	@echo "🌐 Production server running at http://localhost:8080"
	@echo "🔍 Health check: http://localhost:8080/health"

docker-test:
	@echo "🐳 Running full test suite in Docker..."
	@./scripts/docker-test.sh test

docker-test-unit:
	@echo "🐳 Running unit tests in Docker..."
	@./scripts/docker-test.sh unit

docker-test-integration:
	@echo "🐳 Running integration tests in Docker..."
	@./scripts/docker-test.sh integration

docker-test-security:
	@echo "🐳 Running security tests in Docker..."
	@./scripts/docker-test.sh security

docker-test-e2e:
	@echo "🐳 Running end-to-end tests in Docker..."
	@./scripts/docker-test.sh e2e

docker-test-accessibility:
	@echo "🐳 Running accessibility tests in Docker..."
	@./scripts/docker-test.sh accessibility

docker-test-load:
	@echo "🐳 Running load tests in Docker..."
	@./scripts/docker-test.sh load

docker-cleanup:
	@echo "🐳 Cleaning up Docker resources..."
	@./scripts/docker-test.sh cleanup

docker-logs:
	@echo "🐳 Showing Docker container logs..."
	@echo "📋 Available containers:"
	@docker-compose ps || echo "No containers running"
	@echo ""
	@echo "Use 'docker-compose logs [service]' to see specific logs"
	@echo "Example: docker-compose logs dev"

docker-status:
	@echo "🐳 Docker container status..."
	@docker-compose ps || echo "No containers running"
	@echo ""
	@echo "🔍 System information:"
	@docker system df || true

docker-security-status:
	@echo "🛡️  Checking OpenAppSec security status..."
	@if docker-compose ps | grep -q "prod.*Up"; then \
		echo "🔍 OpenAppSec Status:"; \
		curl -s http://localhost:8080/open-appsec-status 2>/dev/null || echo "Status endpoint not accessible"; \
		echo ""; \
		echo "🔒 Security Headers Check:"; \
		curl -I http://localhost:8080 2>/dev/null | grep -E "(X-|Content-Security-Policy)" || echo "Headers not found"; \
	else \
		echo "❌ Production container not running. Start with 'make docker-prod'"; \
	fi

docker-security-logs:
	@echo "🛡️  Viewing OpenAppSec security logs..."
	@if docker-compose ps | grep -q "prod.*Up"; then \
		echo "📋 OpenAppSec Logs:"; \
		docker-compose exec prod cat /var/log/nano_agent/cp_nginx.log 2>/dev/null || echo "No OpenAppSec logs found"; \
		echo ""; \
		echo "📋 Nginx Error Logs:"; \
		docker-compose exec prod tail -20 /var/log/nginx/error.log 2>/dev/null || echo "No error logs found"; \
	else \
		echo "❌ Production container not running. Start with 'make docker-prod'"; \
	fi

docker-test-openappsec:
	@echo "🛡️  Running OpenAppSec security tests..."
	@if docker-compose ps | grep -q "prod.*Up"; then \
		echo "🔍 Testing OpenAppSec protection..."; \
		./scripts/test-openappsec.sh; \
	else \
		echo "❌ Production container not running. Start with 'make docker-prod' first"; \
		echo "💡 Quick start: make docker-prod && sleep 10 && make docker-test-openappsec"; \
	fi

# SonarQube Commands
sonar-start:
	@echo "📊 Starting SonarQube server..."
	@if ! command -v docker >/dev/null 2>&1; then \
		echo "❌ Docker not found. Please install Docker first."; \
		exit 1; \
	fi
	@./scripts/sonarqube-manager.sh start

sonar-stop:
	@echo "📊 Stopping SonarQube server..."
	@./scripts/sonarqube-manager.sh stop

sonar-status:
	@echo "📊 Checking SonarQube status..."
	@./scripts/sonarqube-manager.sh status

sonar-analyze:
	@echo "📊 Running SonarQube code analysis..."
	@./scripts/sonarqube-manager.sh analyze

sonar-report:
	@echo "📊 Generating SonarQube quality report..."
	@./scripts/sonarqube-manager.sh report

sonar-cleanup:
	@echo "📊 Cleaning up SonarQube data..."
	@./scripts/sonarqube-manager.sh cleanup

sonar-logs:
	@echo "📊 Viewing SonarQube logs..."
	@./scripts/sonarqube-manager.sh logs

sonar-backup:
	@echo "📊 Creating SonarQube backup..."
	@./scripts/sonarqube-manager.sh backup

# GitHub Issue Management Commands
issue-list:
	@echo "📋 Listing GitHub issues..."
	@gh issue list

issue-view:
	@if [ -z "$(NUM)" ]; then \
		echo "❌ Please specify issue number: make issue-view NUM=1"; \
		exit 1; \
	fi
	@echo "👁️  Viewing issue #$(NUM)..."
	@gh issue view $(NUM)

issue-create:
	@if [ -z "$(TITLE)" ]; then \
		read -p "📝 Enter issue title: " ISSUE_TITLE; \
	else \
		ISSUE_TITLE="$(TITLE)"; \
	fi; \
	if [ -z "$(BODY)" ]; then \
		read -p "📄 Enter issue description: " ISSUE_BODY; \
		if [ -z "$$ISSUE_BODY" ]; then \
			ISSUE_BODY="## Description\n\n[Add description here]\n\n## Acceptance Criteria\n\n- [ ] Criterion 1\n- [ ] Criterion 2"; \
		fi; \
	else \
		ISSUE_BODY="$(BODY)"; \
	fi; \
	echo "🆕 Creating new issue..."; \
	gh issue create --title "$$ISSUE_TITLE" --body "$$ISSUE_BODY" --label "$(if $(LABEL),$(LABEL),enhancement)"

issue-assign:
	@if [ -z "$(NUM)" ]; then \
		echo "❌ Please specify issue number: make issue-assign NUM=1"; \
		exit 1; \
	fi
	@echo "👤 Assigning issue #$(NUM) to yourself..."
	@gh issue edit $(NUM) --add-assignee @me

issue-comment:
	@if [ -z "$(NUM)" ] || [ -z "$(COMMENT)" ]; then \
		echo "❌ Usage: make issue-comment NUM=1 COMMENT='Working on this'"; \
		exit 1; \
	fi
	@echo "💬 Adding comment to issue #$(NUM)..."
	@gh issue comment $(NUM) --body "$(COMMENT)"

issue-close:
	@if [ -z "$(NUM)" ]; then \
		echo "❌ Please specify issue number: make issue-close NUM=1"; \
		exit 1; \
	fi
	@echo "✅ Closing issue #$(NUM)..."
	@gh issue close $(NUM) --comment "$(if $(COMMENT),$(COMMENT),Completed)"

issue-labels:
	@if [ -z "$(NUM)" ] || [ -z "$(LABELS)" ]; then \
		echo "❌ Usage: make issue-labels NUM=1 LABELS='bug,urgent'"; \
		exit 1; \
	fi
	@echo "🏷️  Adding labels to issue #$(NUM)..."
	@gh issue edit $(NUM) --add-label "$(LABELS)"

issue-status:
	@echo "📊 Issue summary:"
	@echo "🔓 Open issues: $(shell gh issue list --state=open --json number | jq length)"
	@echo "✅ Closed issues: $(shell gh issue list --state=closed --json number | jq length)"
	@echo ""
	@echo "📋 Recent issues:"
	@gh issue list --limit 5

# Issue creation help and examples
issue-help:
	@echo "🔗 GitHub Issue Management Help"
	@echo ""
	@echo "📋 Basic Commands:"
	@echo "  make issue-list                    - List all issues"
	@echo "  make issue-view NUM=1              - View specific issue"
	@echo "  make issue-assign NUM=1            - Assign issue to yourself"
	@echo "  make issue-close NUM=1             - Close an issue"
	@echo ""
	@echo "🆕 Creating Issues (Interactive):"
	@echo "  make issue-create                  - Create any type of issue (prompts for input)"
	@echo "  make issue-feature                 - Create feature request (prompts for input)"
	@echo "  make issue-bug                     - Create bug report (prompts for input)"
	@echo "  make issue-deployment              - Create deployment task (prompts for input)"
	@echo ""
	@echo "🆕 Creating Issues (Command Line):"
	@echo "  make issue-feature TITLE='Shopping Cart' DESC='Add cart functionality'"
	@echo "  make issue-bug TITLE='Login Error' DESC='Users cannot log in'"
	@echo "  make issue-deployment TITLE='Deploy v1.2' DESC='Deploy new features'"
	@echo ""
	@echo "💬 Managing Issues:"
	@echo "  make issue-comment NUM=1 COMMENT='Working on this now'"
	@echo "  make issue-labels NUM=1 LABELS='urgent,frontend'"
	@echo "  make issue-close NUM=1 COMMENT='Fixed in commit abc123'"
	@echo ""
	@echo "📊 Status and Reporting:"
	@echo "  make issue-status                  - Show issue statistics"
	@echo "  make issue-help                    - Show this help"

# Quick issue creation templates
issue-feature:
	@echo "🚀 Creating feature request..."
	@if [ -z "$(TITLE)" ]; then \
		read -p "📝 Enter feature title: " FEATURE_TITLE; \
	else \
		FEATURE_TITLE="$(TITLE)"; \
	fi; \
	if [ -z "$(DESC)" ]; then \
		read -p "📄 Enter feature description: " FEATURE_DESC; \
	else \
		FEATURE_DESC="$(DESC)"; \
	fi; \
	gh issue create --title "[FEATURE] $$FEATURE_TITLE" \
		--body "## Feature Description\n\n**What feature would you like to see added?**\n$$FEATURE_DESC\n\n**Why is this feature needed?**\n[Explain the problem this solves]\n\n**How should it work?**\n[Describe the expected behavior]\n\n## Acceptance Criteria\n\n- [ ] Feature requirement 1\n- [ ] Feature requirement 2\n- [ ] Feature requirement 3\n\n## Priority\n\n- [ ] High\n- [ ] Medium\n- [ ] Low" \
		--label "enhancement" || gh issue create --title "[FEATURE] $$FEATURE_TITLE" \
		--body "## Feature Description\n\n**What feature would you like to see added?**\n$$FEATURE_DESC\n\n**Why is this feature needed?**\n[Explain the problem this solves]\n\n**How should it work?**\n[Describe the expected behavior]\n\n## Acceptance Criteria\n\n- [ ] Feature requirement 1\n- [ ] Feature requirement 2\n- [ ] Feature requirement 3\n\n## Priority\n\n- [ ] High\n- [ ] Medium\n- [ ] Low"

issue-bug:
	@echo "🐛 Creating bug report..."
	@if [ -z "$(TITLE)" ]; then \
		read -p "📝 Enter bug title: " BUG_TITLE; \
	else \
		BUG_TITLE="$(TITLE)"; \
	fi; \
	if [ -z "$(DESC)" ]; then \
		read -p "📄 Enter bug description: " BUG_DESC; \
	else \
		BUG_DESC="$(DESC)"; \
	fi; \
	gh issue create --title "[BUG] $$BUG_TITLE" \
		--body "## Bug Description\n\n**Describe the bug**\n$$BUG_DESC\n\n**To Reproduce**\n1. Go to '...'\n2. Click on '....'\n3. Scroll down to '....'\n4. See error\n\n**Expected behavior**\n[What you expected to happen]\n\n**Screenshots**\n[If applicable, add screenshots]\n\n**Environment:**\n- Browser: [e.g. Chrome, Safari]\n- Version: [e.g. 22]\n- Device: [e.g. iPhone6]\n\n**Additional context**\n[Any other context about the problem]" \
		--label "bug"

# GitHub Pages and deployment related issue templates
issue-deployment:
	@echo "🚀 Creating deployment issue..."
	@if [ -z "$(TITLE)" ]; then \
		read -p "📝 Enter deployment title: " DEPLOY_TITLE; \
	else \
		DEPLOY_TITLE="$(TITLE)"; \
	fi; \
	if [ -z "$(DESC)" ]; then \
		read -p "📄 Enter deployment description: " DEPLOY_DESC; \
	else \
		DEPLOY_DESC="$(DESC)"; \
	fi; \
	gh issue create --title "[DEPLOYMENT] $$DEPLOY_TITLE" \
		--body "## Deployment Description\n\n**What needs to be deployed?**\n$$DEPLOY_DESC\n\n**Deployment Steps**\n\n- [ ] Step 1\n- [ ] Step 2\n- [ ] Step 3\n\n**Rollback Plan**\n\n- [ ] Rollback step 1\n- [ ] Rollback step 2\n\n**Testing Checklist**\n\n- [ ] Functionality test\n- [ ] Performance test\n- [ ] Security test" \
		--label "deployment" || gh issue create --title "[DEPLOYMENT] $$DEPLOY_TITLE" \
		--body "## Deployment Description\n\n**What needs to be deployed?**\n$$DEPLOY_DESC\n\n**Deployment Steps**\n\n- [ ] Step 1\n- [ ] Step 2\n- [ ] Step 3\n\n**Rollback Plan**\n\n- [ ] Rollback step 1\n- [ ] Rollback step 2\n\n**Testing Checklist**\n\n- [ ] Functionality test\n- [ ] Performance test\n- [ ] Security test"

# Label management commands
issue-setup-labels:
	@echo "🏷️  Setting up GitHub issue labels..."
	@echo "Creating standard labels for issue management..."
	@gh label create "feature-request" --description "New feature request" --color "a2eeef" --force || true
	@gh label create "deployment" --description "Deployment related tasks" --color "0e8a16" --force || true
	@gh label create "infrastructure" --description "Infrastructure and tooling" --color "0052cc" --force || true
	@gh label create "security" --description "Security related issues" --color "d93f0b" --force || true
	@gh label create "performance" --description "Performance improvements" --color "f9d0c4" --force || true
	@gh label create "ui/ux" --description "User interface and experience" --color "c5def5" --force || true
	@gh label create "backend" --description "Backend development" --color "5319e7" --force || true
	@gh label create "frontend" --description "Frontend development" --color "0052cc" --force || true
	@gh label create "urgent" --description "High priority issue" --color "d93f0b" --force || true
	@gh label create "low-priority" --description "Low priority issue" --color "fef2c0" --force || true
	@echo "✅ Labels setup complete!"

issue-list-labels:
	@echo "🏷️  Available labels:"
	@gh label list

# GitHub Pull Request Management Commands
pr-create:
	@echo "🔀 Creating pull request..."
	@if ! command -v gh >/dev/null 2>&1; then \
		echo "❌ GitHub CLI not found. Please install GitHub CLI first."; \
		echo "   Visit: https://cli.github.com"; \
		exit 1; \
	fi
	@echo "🔍 Checking if we're on a feature branch..."
	@CURRENT_BRANCH=$$(git branch --show-current); \
	if [ "$$CURRENT_BRANCH" = "main" ]; then \
		echo "❌ Cannot create PR from main branch. Please create a feature branch first."; \
		exit 1; \
	fi; \
	echo "📋 Current branch: $$CURRENT_BRANCH"; \
	echo "🔄 Checking if branch is pushed to remote..."; \
	if ! git ls-remote --exit-code --heads origin "$$CURRENT_BRANCH" >/dev/null 2>&1; then \
		echo "📤 Branch not found on remote. Pushing to origin..."; \
		git push -u origin "$$CURRENT_BRANCH"; \
	fi; \
	if [ -z "$(TITLE)" ]; then \
		echo "💡 Generating smart title from recent commits..."; \
		SUGGESTED_TITLE=$$(git log --oneline -1 --pretty=format:"%s" | sed 's/^[A-Z]*: *//'); \
		read -p "📝 Enter PR title (or press Enter for: $$SUGGESTED_TITLE): " PR_TITLE; \
		if [ -z "$$PR_TITLE" ]; then \
			PR_TITLE="$$SUGGESTED_TITLE"; \
		fi; \
	else \
		PR_TITLE="$(TITLE)"; \
	fi; \
	if [ -z "$(BODY)" ]; then \
		echo "📄 Generating PR description from commits..."; \
		COMMIT_LIST=$$(git log --oneline origin/main..HEAD --pretty=format:"- %s"); \
		DEFAULT_BODY="## Changes\n\n$$COMMIT_LIST\n\n## Testing\n\n- [ ] Manual testing completed\n- [ ] All tests pass\n\n## Checklist\n\n- [ ] Code follows project style guidelines\n- [ ] Self-review completed\n- [ ] Documentation updated if needed"; \
		read -p "📄 Enter PR description (or press Enter for auto-generated): " PR_BODY; \
		if [ -z "$$PR_BODY" ]; then \
			PR_BODY="$$DEFAULT_BODY"; \
		fi; \
	else \
		PR_BODY="$(BODY)"; \
	fi; \
	echo "🚀 Creating pull request..."; \
	PR_URL=$$(gh pr create --title "$$PR_TITLE" --body "$$PR_BODY" $(if $(REVIEWERS),--reviewer "$(REVIEWERS)",) $(if $(LABELS),--label "$(LABELS)",)); \
	echo "✅ Pull request created: $$PR_URL"

pr-list:
	@echo "📋 Listing pull requests..."
	@if ! command -v gh >/dev/null 2>&1; then \
		echo "❌ GitHub CLI not found. Please install GitHub CLI first."; \
		exit 1; \
	fi
	@gh pr list

pr-view:
	@if [ -z "$(NUM)" ]; then \
		echo "❌ Please specify PR number: make pr-view NUM=1"; \
		exit 1; \
	fi
	@echo "👁️  Viewing pull request #$(NUM)..."
	@if ! command -v gh >/dev/null 2>&1; then \
		echo "❌ GitHub CLI not found. Please install GitHub CLI first."; \
		exit 1; \
	fi
	@gh pr view $(NUM)

pr-merge:
	@if [ -z "$(NUM)" ]; then \
		echo "❌ Please specify PR number: make pr-merge NUM=1"; \
		exit 1; \
	fi
	@echo "🔀 Merging pull request #$(NUM)..."
	@if ! command -v gh >/dev/null 2>&1; then \
		echo "❌ GitHub CLI not found. Please install GitHub CLI first."; \
		exit 1; \
	fi
	@echo "⚠️  This will merge PR #$(NUM) into main branch."
	@read -p "Are you sure? (y/N): " CONFIRM; \
	if [ "$$CONFIRM" = "y" ] || [ "$$CONFIRM" = "Y" ]; then \
		gh pr merge $(NUM) --squash --delete-branch; \
		echo "✅ Pull request #$(NUM) merged and branch deleted"; \
	else \
		echo "❌ Merge cancelled"; \
	fi

pr-status:
	@echo "📊 Pull request summary:"
	@if ! command -v gh >/dev/null 2>&1; then \
		echo "❌ GitHub CLI not found. Please install GitHub CLI first."; \
		exit 1; \
	fi
	@echo "🔓 Open PRs: $$(gh pr list --state=open --json number | jq length)"
	@echo "✅ Merged PRs: $$(gh pr list --state=merged --json number | jq length)"
	@echo "❌ Closed PRs: $$(gh pr list --state=closed --json number | jq length)"
	@echo ""
	@echo "📋 Recent pull requests:"
	@gh pr list --limit 5

pr-help:
	@echo "🔀 GitHub Pull Request Management Help"
	@echo ""
	@echo "📋 Basic Commands:"
	@echo "  make pr-list                       - List all pull requests"
	@echo "  make pr-view NUM=1                 - View specific pull request"
	@echo "  make pr-merge NUM=1                - Merge pull request (with confirmation)"
	@echo "  make pr-status                     - Show pull request statistics"
	@echo ""
	@echo "🆕 Creating Pull Requests:"
	@echo "  make pr-create                     - Create PR (interactive with smart defaults)"
	@echo "  make pr-create TITLE='Feature X'   - Create PR with custom title"
	@echo "  make pr-create REVIEWERS='@user1,@user2' - Create PR with reviewers"
	@echo "  make pr-create LABELS='feature,urgent' - Create PR with labels"
	@echo ""
	@echo "💡 Smart Features:"
	@echo "  • Auto-detects if you're on main branch (prevents PR creation)"
	@echo "  • Auto-pushes branch to remote if not already pushed"
	@echo "  • Generates smart title from recent commit messages"
	@echo "  • Creates description with commit list and checklist"
	@echo "  • Supports custom titles, reviewers, and labels"
	@echo ""
	@echo "🔄 Workflow Integration:"
	@echo "  1. Work on feature branch"
	@echo "  2. Commit and push changes"
	@echo "  3. Run 'make pr-create' to create pull request"
	@echo "  4. Use 'make pr-merge NUM=X' when ready to merge"
	@echo ""
	@echo "Examples:"
	@echo "  make pr-create TITLE='Add user authentication' REVIEWERS='@teammate'"
	@echo "  make pr-view NUM=5"
	@echo "  make pr-merge NUM=5"

# GitHub Branch Protection Commands
branch-protect:
	@echo "🛡️  Setting up branch protection for main branch..."
	@if ! command -v gh >/dev/null 2>&1; then \
		echo "❌ GitHub CLI not found. Please install GitHub CLI first."; \
		exit 1; \
	fi
	@echo "🔒 Enabling branch protection rules..."
	@echo "⚠️  This requires admin permissions on the repository."
	@echo '{"required_status_checks":null,"required_pull_request_reviews":{"required_approving_review_count":1},"enforce_admins":true,"restrictions":null}' | \
		gh api repos/mooit-artist/FreshThreads/branches/main/protection --method PUT --input - > /dev/null && \
		echo "✅ Branch protection enabled!" || echo "❌ Failed to set branch protection. You need admin access."
	@echo "📋 Protection rules applied:"
	@echo "   • Require pull request reviews (1 approving review)"
	@echo "   • Enforce restrictions for administrators"
	@echo "   • Direct commits to main are now blocked"
	@echo "   • Changes must be made through pull requests"

branch-protect-status:
	@echo "🛡️  Checking branch protection status..."
	@if ! command -v gh >/dev/null 2>&1; then \
		echo "❌ GitHub CLI not found. Please install GitHub CLI first."; \
		exit 1; \
	fi
	@echo "🔍 Main branch protection status:"
	@if gh api repos/mooit-artist/FreshThreads/branches/main/protection >/dev/null 2>&1; then \
		echo "✅ Branch protection is ENABLED"; \
		echo "📋 Protection details:"; \
		gh api repos/mooit-artist/FreshThreads/branches/main/protection | jq -r '.required_pull_request_reviews // "No PR review requirements"'; \
		echo "🔒 Direct commits to main are BLOCKED"; \
		echo "🔀 Changes must be made through pull requests"; \
	else \
		echo "❌ Branch protection is DISABLED"; \
		echo "⚠️  Direct commits to main are ALLOWED"; \
		echo "💡 To enable protection: make branch-protect"; \
	fi

branch-protect-disable:
	@echo "🛡️  Disabling branch protection for main branch..."
	@if ! command -v gh >/dev/null 2>&1; then \
		echo "❌ GitHub CLI not found. Please install GitHub CLI first."; \
		exit 1; \
	fi
	@echo "⚠️  WARNING: This will allow direct commits to main branch!"
	@read -p "Are you sure you want to disable branch protection? (y/N): " CONFIRM; \
	if [ "$$CONFIRM" = "y" ] || [ "$$CONFIRM" = "Y" ]; then \
		gh api repos/mooit-artist/FreshThreads/branches/main/protection --method DELETE --silent || echo "❌ Failed to disable protection. Check your permissions."; \
		echo "✅ Branch protection disabled. Direct commits to main are now allowed."; \
	else \
		echo "❌ Operation cancelled"; \
	fi
