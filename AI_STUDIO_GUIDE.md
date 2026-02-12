# AI Studio Guide - Build The Unknown While You Sleep

## Overview

Your game development setup has been transformed into an autonomous multi-agent system that can work on your game for hours unattended. The system uses **smaller, faster AI models** optimized for your M4 Mac, automatically creates GitHub issues for progress tracking, and validates builds with Godot's headless mode.

## What's New

### 🤖 Multi-Agent Architecture

Instead of a single slow agent, you now have specialized agents:

1. **Agent Orchestrator** - Reads development_plan.md, creates tasks, manages execution
2. **Validator Agent** - Continuously checks builds, creates issues for errors
3. **Progress Reporter** - Shows real-time status and updates documentation

### ⚡ Performance Improvements

**Old Setup:**
- Single model: `qwen2.5-coder:32b` (slow on M4)
- No task prioritization
- Manual tracking required

**New Setup:**
- Three models automatically selected based on task complexity:
  - `qwen2.5-coder:7b` - **70% faster** for simple tasks
  - `qwen2.5-coder:14b` - **40% faster** for medium tasks
  - `deepseek-coder:6.7b` - Best for complex architecture
- Intelligent task parsing from development_plan.md
- Automatic GitHub issue creation and tracking
- Continuous build validation

### 📊 Automatic GitHub Integration

- Every task gets a GitHub issue
- Issues updated with progress (in_progress → completed/failed)
- Build errors automatically reported
- Track progress from anywhere via GitHub web interface

## Quick Start

### 1. Setup (One Time)

```bash
# Run the setup script
./scripts/ai_tools/setup.sh
```

This will:
- Check for required tools (ollama, gh, aider, tmuxinator)
- Download AI models (~10-15 minutes)
- Authenticate with GitHub

### 2. Start the AI Studio

**Option A: Using tmuxinator (Recommended)**

```bash
tmuxinator start the-unknown-ai-studio
```

This opens a multi-pane tmux session with:
- Pane 1: Orchestrator running tasks
- Pane 2: Progress monitor (updates every 30s)
- Pane 3: Build validator (checks every 60s)
- Pane 4: Git activity monitor
- Pane 5: GitHub issue tracker
- Pane 6: System resource monitor
- Pane 7: Ollama model status
- Pane 8: Manual intervention shell

**Option B: Manual execution**

```bash
# Run 3 tasks from current stage
python3 scripts/ai_tools/agent_orchestrator.py 3

# For overnight: run 10 tasks
python3 scripts/ai_tools/agent_orchestrator.py 10
```

### 3. Go to Sleep!

The agents will:
- Read tasks from `development_plan.md` Stage 1
- Create GitHub issues for each task
- Execute tasks with appropriate AI models
- Verify builds with Godot headless
- Auto-revert any failed commits
- Save progress to `.ai_progress.json`

### 4. Check Progress in the Morning

```bash
# View report
python3 scripts/ai_tools/progress_reporter.py

# Or check GitHub issues
gh issue list
```

## File Structure

```
the-unknown/
├── .tmuxinator.yml                    # Multi-pane workspace config (UPDATED)
├── run_studio.py                      # Legacy entry point (UPDATED - redirects to orchestrator)
├── development_plan.md                # Source of truth for tasks
├── .ai_progress.json                  # Progress state (auto-generated)
├── .validation_log.json               # Build history (auto-generated)
│
└── scripts/ai_tools/
    ├── setup.sh                       # One-time setup script (NEW)
    ├── agent_orchestrator.py          # Main coordinator (NEW)
    ├── validator_agent.py             # Build validator (NEW)
    ├── progress_reporter.py           # Status reporter (NEW)
    ├── fetch_asset.py                 # Asset downloader (existing)
    └── README.md                      # Detailed documentation (NEW)
```

## Model Selection Strategy

The orchestrator automatically picks the right model for each task:

| Task Type | Model | Speed vs 32b | Example Tasks |
|-----------|-------|--------------|---------------|
| Simple | qwen2.5-coder:7b | 3-4x faster | Debug overlay, input config, placeholder scenes |
| Medium | qwen2.5-coder:14b | 2x faster | Player controller, interaction system, basic AI |
| Complex | deepseek-coder:6.7b | Balanced | Event bus, state machines, procedural generation |

**Memory usage:**
- 7b model: ~4-6 GB RAM
- 14b model: ~8-10 GB RAM
- 6.7b model: ~4-5 GB RAM

Your M4 Mac with 32GB RAM can comfortably run all three concurrently.

## Workflow Example

### Night 1: Stage 1 Setup

```bash
# Start tmuxinator
tmuxinator start the-unknown-ai-studio

# Orchestrator will:
# 1. Parse development_plan.md Stage 1
# 2. Find tasks like "Event Bus autoload singleton"
# 3. Create GitHub issue #1: "[Stage 1] Event Bus autoload singleton"
# 4. Select deepseek-coder:6.7b (complex architecture)
# 5. Run aider to implement
# 6. Validate with Godot headless
# 7. Update issue #1 → closed
# 8. Move to next task...
```

### Morning 1: Review

```bash
# Check what was done
python3 scripts/ai_tools/progress_reporter.py

# Output:
# ╔══════════════════════════════════════════════════════════════╗
# ║           THE UNKNOWN - AI Development Progress              ║
# ╚══════════════════════════════════════════════════════════════╝
#
# 📊 CURRENT STATUS
#   Stage: 1
#   Tasks Completed: 5
#   Tasks Failed: 0
#
# 🐙 GITHUB METRICS
#   Open Issues: 1
#   Closed Issues: 5
#   Total Issues: 6
#
# 🔍 BUILD VALIDATION
#   Total Validations: 6
#   Success Rate: 100.0%
```

### Review on GitHub

Visit your repo and see:
- ✅ Issue #1: Event Bus autoload - CLOSED
- ✅ Issue #2: First-person controller - CLOSED
- ✅ Issue #3: Basic interaction system - CLOSED
- ✅ Issue #4: Placeholder test level - CLOSED
- ✅ Issue #5: Debug overlay - CLOSED
- 🔄 Issue #6: Input map configuration - OPEN (in progress)

## Safety Features

### Auto-Revert on Build Failure

If aider creates code that breaks the build:
```
🔍 Supervisor: Verifying GDScript integrity via Headless Godot...
❌ DRIFT DETECTED: Build failed.
⏪ Reverting last commit to maintain codebase integrity...
```

The orchestrator automatically reverts the commit and creates a GitHub issue with the error details.

### Build Validator

Runs in the background, checking every commit:
```
🔍 [14:32:15] Validating build...
✅ Build valid
```

If errors are found, creates GitHub issues tagged `build-error` and `urgent`.

### Progress Persistence

All progress is saved to `.ai_progress.json`:
```json
{
  "current_stage": 1,
  "completed_tasks": ["S1T1", "S1T2", "S1T3"],
  "failed_tasks": [],
  "github_issues": {
    "S1T1": 1,
    "S1T2": 2
  }
}
```

If you stop and restart, it continues where it left off.

## Monitoring

### Real-time (tmuxinator)

The tmuxinator setup gives you 8 panes showing:
1. **Orchestrator output** - See tasks being executed
2. **Progress report** - Updated every 30s
3. **Build validator** - Continuous checking
4. **Git log** - Recent commits
5. **GitHub issues** - Open/closed issues
6. **System resources** - CPU/RAM usage
7. **Ollama status** - Which models are loaded
8. **Manual shell** - For quick fixes

### Remote Monitoring

Check progress from your phone:
```bash
# Via GitHub web interface
https://github.com/YOUR_USERNAME/the-unknown/issues

# Or using gh CLI
gh issue list
```

## Configuration

### Adjust Task Count

For shorter sessions:
```bash
# Only run 2 tasks
python3 scripts/ai_tools/agent_orchestrator.py 2
```

For overnight (leave it running):
```bash
# Run 15 tasks
python3 scripts/ai_tools/agent_orchestrator.py 15
```

### Change Model Selection

Edit `scripts/ai_tools/agent_orchestrator.py`:

```python
MODELS = {
    "fast": "ollama_chat/qwen2.5-coder:7b",      # Change to your preferred fast model
    "balanced": "ollama_chat/qwen2.5-coder:14b",  # Change to your preferred balanced model
    "complex": "ollama_chat/deepseek-coder:6.7b"  # Change to your preferred complex model
}
```

### Validation Frequency

Edit `.tmuxinator.yml` to change check interval:

```yaml
# Default: check every 60 seconds
- python3 scripts/ai_tools/validator_agent.py 60

# More frequent: check every 30 seconds
- python3 scripts/ai_tools/validator_agent.py 30
```

## Troubleshooting

### Models not found

```bash
ollama pull qwen2.5-coder:7b
ollama pull qwen2.5-coder:14b
ollama pull deepseek-coder:6.7b
```

### GitHub authentication failed

```bash
gh auth login
```

### Godot not found

Update `GODOT_PATH` in:
- `scripts/ai_tools/agent_orchestrator.py`
- `scripts/ai_tools/validator_agent.py`

```python
GODOT_PATH = "/Applications/Godot.app/Contents/MacOS/Godot"
```

### Task keeps failing

Check `.validation_log.json` for detailed errors:
```bash
cat .validation_log.json | jq '.validations[-1]'
```

Or check the GitHub issue that was automatically created.

## Tips for Best Results

1. **Close Godot Editor** - The headless validator works better with the editor closed
2. **Start with fewer tasks** - Run 3-5 tasks first to test the system
3. **Monitor first run** - Watch the tmuxinator session for the first 10 minutes
4. **Review in morning** - Check GitHub issues to see what was accomplished
5. **Fix failures manually** - If a task fails, fix it manually and update the issue
6. **Stage progression** - When Stage 1 is complete, orchestrator auto-advances to Stage 2

## Advanced Usage

### Custom Task Injection

Add tasks manually to `.ai_progress.json`:

```json
{
  "current_stage": 1,
  "custom_tasks": [
    {
      "id": "CUSTOM1",
      "title": "Fix player jump height",
      "description": "Adjust jump velocity in Player.gd",
      "model": "fast"
    }
  ]
}
```

### Progress Report in README

```bash
# Update README.md with progress badge
python3 scripts/ai_tools/progress_reporter.py --update-readme
```

### Single Validation

```bash
# Just check the build once
python3 scripts/ai_tools/validator_agent.py once
```

## Next Steps

1. ✅ Run setup: `./scripts/ai_tools/setup.sh`
2. ✅ Start tmuxinator: `tmuxinator start the-unknown-ai-studio`
3. ✅ Watch it work for 5-10 minutes
4. ✅ Go to sleep
5. ✅ Check GitHub issues in the morning
6. ✅ Review and test the generated code
7. ✅ Repeat!

## Getting Help

- 📖 Detailed docs: `scripts/ai_tools/README.md`
- 🐛 Check issues: `gh issue list`
- 📊 View progress: `python3 scripts/ai_tools/progress_reporter.py`
- 💬 Manual intervention: Use the Manual pane in tmuxinator

---

**Happy autonomous game development!** 🎮🤖
