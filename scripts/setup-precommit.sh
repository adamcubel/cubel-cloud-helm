#!/bin/bash

# Setup script for pre-commit hooks
# This script installs pre-commit and sets up the hooks

set -e

echo "🔧 Setting up pre-commit hooks..."

# Check if pre-commit is installed
if ! command -v pre-commit &> /dev/null; then
    echo "📦 Installing pre-commit..."

    # Try to install via pip
    if command -v pip3 &> /dev/null; then
        pip3 install pre-commit
    elif command -v pip &> /dev/null; then
        pip install pre-commit
    elif command -v brew &> /dev/null; then
        # macOS with Homebrew
        brew install pre-commit
    else
        echo "❌ Error: Could not find pip or brew to install pre-commit"
        echo "Please install pre-commit manually:"
        echo "  https://pre-commit.com/#install"
        exit 1
    fi
fi

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    echo "⚠️  Warning: Helm is not installed. Some pre-commit hooks will fail."
    echo "Please install Helm: https://helm.sh/docs/intro/install/"
fi

# Initialize secrets baseline if it doesn't exist
if [ ! -f .secrets.baseline ]; then
    echo "🔐 Creating secrets baseline..."
    detect-secrets scan > .secrets.baseline 2>/dev/null || echo "{}" > .secrets.baseline
fi

# Install the pre-commit hooks
echo "🪝 Installing pre-commit hooks..."
pre-commit install

# Run hooks on all files to verify setup
echo "✅ Running pre-commit hooks on all files (this may take a moment)..."
pre-commit run --all-files || {
    echo ""
    echo "⚠️  Some pre-commit checks failed."
    echo "This is normal for the first run. The hooks have been installed."
    echo "Fix the issues and commit again."
}

echo ""
echo "✅ Pre-commit hooks installed successfully!"
echo ""
echo "ℹ️  The hooks will run automatically before each commit."
echo "ℹ️  To run hooks manually: pre-commit run --all-files"
echo "ℹ️  To skip hooks (not recommended): git commit --no-verify"
