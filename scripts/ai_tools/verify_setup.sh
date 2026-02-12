#!/bin/bash
# Verify all fixes are applied and system is ready

set -e

echo "🔍 Verifying AI Agent Setup & Fixes"
echo "===================================="
echo ""

ALL_GOOD=true

# Check 1: Git GPG signing disabled
echo "1. Checking git GPG signing..."
GPG_SETTING=$(git config --local commit.gpgsign || echo "not set")
if [ "$GPG_SETTING" = "false" ]; then
    echo "   ✅ GPG signing disabled (1Password bypassed)"
else
    echo "   ⚠️  GPG signing not disabled yet"
    echo "      Will be set on first orchestrator run"
fi
echo ""

# Check 2: Progress files in gitignore
echo "2. Checking .gitignore..."
if grep -q ".ai_progress.json" .gitignore && grep -q ".validation_log.json" .gitignore; then
    echo "   ✅ Progress files excluded from git"
else
    echo "   ❌ Progress files NOT in .gitignore"
    ALL_GOOD=false
fi
echo ""

# Check 3: Scripts are executable
echo "3. Checking script permissions..."
SCRIPTS=(
    "scripts/ai_tools/agent_orchestrator.py"
    "scripts/ai_tools/validator_agent.py"
    "scripts/ai_tools/progress_reporter.py"
    "scripts/ai_tools/resume_check.py"
    "scripts/ai_tools/setup.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -x "$script" ]; then
        echo "   ✅ $script is executable"
    else
        echo "   ⚠️  $script not executable, fixing..."
        chmod +x "$script"
    fi
done
echo ""

# Check 4: Required tools
echo "4. Checking required tools..."

if command -v ollama &> /dev/null; then
    echo "   ✅ ollama found"
else
    echo "   ❌ ollama not found - install from https://ollama.ai"
    ALL_GOOD=false
fi

if command -v gh &> /dev/null; then
    echo "   ✅ gh (GitHub CLI) found"
else
    echo "   ❌ gh not found - install with: brew install gh"
    ALL_GOOD=false
fi

if command -v aider &> /dev/null; then
    echo "   ✅ aider found"
else
    echo "   ⚠️  aider not found - install with: pip install aider-chat"
fi

if command -v tmuxinator &> /dev/null; then
    echo "   ✅ tmuxinator found"
else
    echo "   ⚠️  tmuxinator not found - install with: brew install tmuxinator"
fi
echo ""

# Check 5: AI models
echo "5. Checking AI models..."
MODELS=("qwen2.5-coder:7b" "qwen2.5-coder:14b" "deepseek-coder:6.7b")

for model in "${MODELS[@]}"; do
    if ollama list | grep -q "$model"; then
        echo "   ✅ $model available"
    else
        echo "   ❌ $model not found - run: ollama pull $model"
        ALL_GOOD=false
    fi
done
echo ""

# Check 6: GitHub authentication
echo "6. Checking GitHub authentication..."
if gh auth status &> /dev/null; then
    echo "   ✅ GitHub authenticated"
else
    echo "   ❌ GitHub not authenticated - run: gh auth login"
    ALL_GOOD=false
fi
echo ""

# Check 7: Resume capability
echo "7. Checking resume capability..."
if [ -f ".ai_progress.json" ]; then
    COMPLETED=$(cat .ai_progress.json | python3 -c "import json, sys; print(len(json.load(sys.stdin).get('completed_tasks', [])))" 2>/dev/null || echo "0")
    echo "   ✅ Progress file exists ($COMPLETED tasks completed)"
    echo "      Run: python3 scripts/ai_tools/resume_check.py"
else
    echo "   ℹ️  No progress file yet (will be created on first run)"
fi
echo ""

# Check 8: Continuous mode in tmuxinator
echo "8. Checking tmuxinator configuration..."
if grep -q "\-\-continuous" .tmuxinator.yml; then
    echo "   ✅ Continuous mode enabled in tmuxinator"
else
    echo "   ⚠️  Continuous mode not in tmuxinator (agents will stop after 3 tasks)"
fi
echo ""

# Summary
echo "===================================="
if [ "$ALL_GOOD" = true ]; then
    echo "✅ All critical checks passed!"
    echo ""
    echo "🚀 Ready to run:"
    echo "   tmuxinator start the-unknown-ai-studio"
    echo ""
    echo "Or manually:"
    echo "   python3 scripts/ai_tools/agent_orchestrator.py --continuous 3"
else
    echo "⚠️  Some issues found. Please fix the ❌ items above."
    echo ""
    echo "Quick fixes:"
    echo "   ./scripts/ai_tools/setup.sh  # Install models and authenticate"
fi
echo ""

# Show next steps
if [ -f ".ai_progress.json" ]; then
    echo "💡 To resume from where you left off:"
    echo "   python3 scripts/ai_tools/resume_check.py"
    echo ""
fi

echo "📚 Documentation:"
echo "   - Full guide: AI_STUDIO_GUIDE.md"
echo "   - Applied fixes: FIXES_APPLIED.md"
echo "   - Tool docs: scripts/ai_tools/README.md"
