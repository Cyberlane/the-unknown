#!/bin/bash
# Setup script for AI Agent System

set -e

echo "🎮 THE UNKNOWN - AI Agent Setup"
echo "================================"

# Check if ollama is installed
if ! command -v ollama &> /dev/null; then
    echo "❌ Ollama not found. Please install from https://ollama.ai"
    exit 1
fi

echo "✅ Ollama found"

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI not found. Please install: brew install gh"
    exit 1
fi

echo "✅ GitHub CLI found"

# Check if aider is installed
if ! command -v aider &> /dev/null; then
    echo "⚠️  Aider not found. Install with: pip install aider-chat"
    echo "Or: brew install aider"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "✅ Aider found"
fi

# Check if tmuxinator is installed
if ! command -v tmuxinator &> /dev/null; then
    echo "⚠️  Tmuxinator not found. Install with: brew install tmuxinator"
    echo "You can still run agents manually"
else
    echo "✅ Tmuxinator found"
fi

echo ""
echo "📦 Pulling AI models..."
echo "This may take a while (downloading ~4-8GB per model)"

# Pull models
models=("qwen2.5-coder:7b" "qwen2.5-coder:14b" "deepseek-coder:6.7b")

for model in "${models[@]}"; do
    echo ""
    echo "Pulling $model..."
    if ollama pull "$model"; then
        echo "✅ $model ready"
    else
        echo "❌ Failed to pull $model"
        exit 1
    fi
done

echo ""
echo "🔐 Checking GitHub authentication..."
if gh auth status &> /dev/null; then
    echo "✅ GitHub authenticated"
else
    echo "⚠️  GitHub not authenticated. Running: gh auth login"
    gh auth login
fi

echo ""
echo "✨ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Review the configuration in scripts/ai_tools/agent_orchestrator.py"
echo "2. Start the AI studio:"
echo "   tmuxinator start the-unknown-ai-studio"
echo ""
echo "Or run manually:"
echo "   python3 scripts/ai_tools/agent_orchestrator.py 3"
echo ""
echo "📚 Read scripts/ai_tools/README.md for full documentation"
