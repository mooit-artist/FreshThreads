#!/bin/bash

# FreshThreads Auto-Fix Script
# Automatically fixes common code style issues

echo "🔧 FreshThreads Auto-Fix Suite"
echo "=============================="

# Fix JavaScript files
echo "🔧 Auto-fixing JavaScript files..."
if command -v eslint >/dev/null 2>&1; then
    eslint --fix "docs/**/*.js" && echo "✅ JavaScript files fixed" || echo "⚠️ Some JS issues couldn't be auto-fixed"
else
    echo "⚠️ ESLint not found, skipping JS fixes"
fi
echo

# Fix CSS files
echo "🔧 Auto-fixing CSS files..."
if command -v prettier >/dev/null 2>&1; then
    prettier --write "docs/**/*.css" && echo "✅ CSS files formatted" || echo "⚠️ Some CSS issues couldn't be auto-fixed"
else
    echo "⚠️ Prettier not found, skipping CSS fixes"
fi
echo

# Fix Python files
echo "🔧 Auto-fixing Python files..."
if command -v black >/dev/null 2>&1; then
    black scripts/ && echo "✅ Python files formatted with Black"
elif [ -f "/Users/bryanjorgensen/Library/Python/3.9/bin/black" ]; then
    /Users/bryanjorgensen/Library/Python/3.9/bin/black scripts/ && echo "✅ Python files formatted with Black"
else
    echo "⚠️ Black not found, skipping Python formatting"
fi

echo "🔧 Auto-fixing Python imports..."
if command -v isort >/dev/null 2>&1; then
    isort scripts/ && echo "✅ Python imports sorted"
elif [ -f "/Users/bryanjorgensen/Library/Python/3.9/bin/isort" ]; then
    /Users/bryanjorgensen/Library/Python/3.9/bin/isort scripts/ && echo "✅ Python imports sorted"
else
    echo "⚠️ isort not found, skipping import sorting"
fi
echo

# Fix Markdown files
echo "🔧 Auto-fixing Markdown files..."
if command -v markdownlint >/dev/null 2>&1; then
    markdownlint --fix . && echo "✅ Markdown files fixed" || echo "⚠️ Some Markdown issues couldn't be auto-fixed"
else
    echo "⚠️ markdownlint not found, skipping Markdown fixes"
fi
echo

# Format HTML and JSON files
echo "🔧 Auto-formatting additional files..."
if command -v prettier >/dev/null 2>&1; then
    prettier --write "docs/**/*.{html,json}" && echo "✅ HTML and JSON files formatted" || echo "⚠️ Some formatting issues remain"
else
    echo "⚠️ Prettier not found, skipping HTML/JSON formatting"
fi

echo
echo "✅ Auto-fix completed!"
echo "🧪 Run 'make lint' to check remaining issues"
