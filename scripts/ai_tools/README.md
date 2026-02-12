# AI Tools for The Unknown

This directory contains the autonomous AI agent system that builds the game while you sleep.

## Quick Start

### Using tmuxinator (Recommended)

```bash
tmuxinator start the-unknown-ai-studio
```

This starts a multi-pane tmux session with:
- **Orchestrator**: Main agent running tasks from development_plan.md
- **Validation**: Continuous build checker and git monitor
- **GitHub**: Issue tracker showing progress
- **Resources**: System and model monitoring
- **Manual**: Pane for manual intervention

### Manual Execution

Run the orchestrator directly:

```bash
# Run 3 tasks from the current stage
python3 scripts/ai_tools/agent_orchestrator.py 3

# Run 10 tasks (for overnight sessions)
python3 scripts/ai_tools/agent_orchestrator.py 10
```

## Components

### 1. Agent Orchestrator (`agent_orchestrator.py`)

**Purpose**: Main coordinator that reads `development_plan.md`, creates GitHub issues, and executes tasks.

**Features**:
- Parses development plan and extracts tasks for current stage
- Intelligently selects AI models based on task complexity:
  - `qwen2.5-coder:7b` - Fast, simple tasks
  - `qwen2.5-coder:14b` - Balanced, medium complexity
  - `deepseek-coder:6.7b` - Complex architectural tasks
- Creates GitHub issues for each task
- Updates issues with progress
- Verifies builds with Godot headless mode
- Auto-reverts failed commits
- Persists progress to `.ai_progress.json`

**Usage**:
```bash
# Default: run 5 tasks then stop
python3 scripts/ai_tools/agent_orchestrator.py

# Run specific number of tasks then stop
python3 scripts/ai_tools/agent_orchestrator.py 10

# CONTINUOUS MODE: Run until all 12 stages complete
python3 scripts/ai_tools/agent_orchestrator.py --continuous

# CONTINUOUS MODE: With custom task count per iteration
python3 scripts/ai_tools/agent_orchestrator.py --continuous 3
```

**New Features**:
- ✅ Automatic GitHub label creation (no more missing label errors)
- ✅ Bypasses 1Password/GPG signing for automated commits
- ✅ Continuous mode runs through all 12 stages automatically
- ✅ Graceful resume from crashes (saves progress every task)
- ✅ Failed tasks are tracked but don't stop progress

### 2. Validator Agent (`validator_agent.py`)

**Purpose**: Continuously monitors builds and creates issues for problems.

**Features**:
- Watches for git commits
- Runs Godot headless validation
- Creates GitHub issues for build errors
- Prevents duplicate error reports
- Logs all validations to `.validation_log.json`

**Usage**:
```bash
# Watch mode (check every 60 seconds)
python3 scripts/ai_tools/validator_agent.py 60

# Single validation
python3 scripts/ai_tools/validator_agent.py once
```

### 3. Progress Reporter (`progress_reporter.py`)

**Purpose**: Generates status reports and updates documentation.

**Features**:
- Shows current stage, tasks completed, GitHub metrics
- Displays build validation statistics
- Can update README.md with progress badge

**Usage**:
```bash
# Display report
python3 scripts/ai_tools/progress_reporter.py

# Update README.md with progress
python3 scripts/ai_tools/progress_reporter.py --update-readme
```

## Model Selection Strategy

The orchestrator automatically selects models based on task keywords:

| Model | Speed | Use Case | Keywords |
|-------|-------|----------|----------|
| `qwen2.5-coder:7b` | Fastest | Simple implementation | basic, placeholder, debug, simple, configuration |
| `qwen2.5-coder:14b` | Balanced | Medium complexity | most tasks by default |
| `deepseek-coder:6.7b` | Complex | Architecture | architecture, system, design, manager, autoload, state machine |

**Why these models?**
- Much faster than 32b model on M4 Mac
- Good quality-to-speed ratio
- Lower memory usage (important for long sessions)
- Can run multiple models concurrently

## Workflow

1. **Orchestrator** reads `development_plan.md` and extracts tasks for current stage
2. For each task:
   - Creates a GitHub issue for tracking
   - Selects appropriate AI model based on complexity
   - Runs `aider` with the model to implement the task
   - Verifies build with Godot headless mode
   - Updates GitHub issue with status
   - Auto-reverts if build fails
3. **Validator** runs in background, checking each commit
4. **Progress Reporter** shows status every 30 seconds

## File Structure

```
scripts/ai_tools/
├── agent_orchestrator.py   # Main coordinator
├── validator_agent.py      # Build validator
├── progress_reporter.py    # Status reporter
├── fetch_asset.py         # Asset downloader (legacy)
└── README.md              # This file

# Generated files (git-ignored)
.ai_progress.json          # Progress state
.validation_log.json       # Build validation history
```

## GitHub Integration

All agents create and update GitHub issues:

**Labels**:
- `stage-N` - Current development stage
- `ai-generated` - Created by AI
- `build-error` - Build validation failure
- `urgent` - Requires immediate attention

**Issue Flow**:
1. Task starts → Issue created with status "in_progress"
2. Task completes → Issue updated with "completed" and closed
3. Task fails → Issue updated with error details

## Configuration

Edit model preferences in `agent_orchestrator.py`:

```python
MODELS = {
    "fast": "ollama_chat/qwen2.5-coder:7b",
    "balanced": "ollama_chat/qwen2.5-coder:14b",
    "complex": "ollama_chat/deepseek-coder:6.7b"
}
```

### 4. Resume Check (`resume_check.py`)

**Purpose**: Check current progress after crashes or interruptions.

**Features**:
- Shows completed/failed tasks
- Displays GitHub issue status
- Lists next pending tasks
- Provides resume instructions

**Usage**:
```bash
# Check current status and resume instructions
python3 scripts/ai_tools/resume_check.py
```

## Resume After Crashes

The orchestrator automatically saves progress to `.ai_progress.json` after every task. If it crashes or you stop it:

1. **Check status**: `python3 scripts/ai_tools/resume_check.py`
2. **Review issues**: `gh issue list --label ai-generated`
3. **Resume**: Just run the orchestrator again - it picks up where it left off

```bash
# After crash, just run again
python3 scripts/ai_tools/agent_orchestrator.py --continuous 3
```

The orchestrator will:
- Load `.ai_progress.json`
- Skip completed tasks
- Skip failed tasks (review manually)
- Continue with pending tasks
- Resume from current stage

## Continuous Mode

**Overnight/Long Sessions**:
```bash
# Run continuously through all 12 stages
python3 scripts/ai_tools/agent_orchestrator.py --continuous 3
```

This will:
- Process 3 tasks per iteration
- Complete all tasks in Stage 1
- Automatically advance to Stage 2, 3, 4... up to Stage 12
- Only stop when all stages are complete or you press Ctrl+C
- Save progress after every task

**Stop gracefully**: Press `Ctrl+C` - progress is saved immediately

## Troubleshooting

### "Model not found"
Pull the models first:
```bash
ollama pull qwen2.5-coder:7b
ollama pull qwen2.5-coder:14b
ollama pull deepseek-coder:6.7b
```

### "Godot not found"
Update `GODOT_PATH` in the scripts:
```python
GODOT_PATH = "/Applications/Godot.app/Contents/MacOS/Godot"
```

### Tasks keep failing
Check `.validation_log.json` for detailed error messages. The validator creates GitHub issues for all build errors.

### Too many GitHub issues
Adjust `max_tasks` parameter to run fewer tasks per session:
```bash
python3 scripts/ai_tools/agent_orchestrator.py 2
```

### 1Password blocks commits
Fixed! The orchestrator now automatically configures git to bypass GPG signing:
```bash
git config --local commit.gpgsign false
```

### GitHub labels don't exist
Fixed! Labels are automatically created on first run. No more "label not found" errors.

### Agent stopped after 3 tasks
The old configuration ran only 3 tasks then stopped. New options:

**Single iteration** (safe for testing):
```bash
python3 scripts/ai_tools/agent_orchestrator.py 5
```

**Continuous mode** (for overnight):
```bash
python3 scripts/ai_tools/agent_orchestrator.py --continuous 3
```

### How to review failed tasks
```bash
# Check progress file
python3 scripts/ai_tools/resume_check.py

# Or view GitHub issues
gh issue list --label build-error
```

Failed tasks are tracked in `.ai_progress.json` and skipped in future runs. Review and fix manually.

## Performance Tips

1. **Close Godot Editor**: The headless validator works better with editor closed
2. **Use smaller models for simple tasks**: Edit model selection logic if needed
3. **Run overnight with low task count**: `python3 agent_orchestrator.py 5` runs ~5 tasks then stops
4. **Monitor with tmuxinator**: See all agents working in real-time
5. **Check RAM usage**: Each model uses ~4-8GB, monitor in Resources pane

## Safety Features

- ✅ Auto-reverts failed commits
- ✅ Creates GitHub issues for all errors
- ✅ Validates with Godot headless (no GUI corruption)
- ✅ Tracks all progress in `.ai_progress.json`
- ✅ Prevents duplicate error reports
- ✅ Uses smaller, faster models (less memory, more stable)

## Next Steps

After setup, just run:

```bash
tmuxinator start the-unknown-ai-studio
```

Then go to sleep! Check GitHub issues in the morning to see what was built.
