# Agent Safeguards - Implementation Guide

This document describes the safeguards implemented to prevent AI agents from creating malformed files and to ensure task completion is properly verified.

## Quick Reference

### Check for Issues
```bash
# Scan for malformed files (dry-run, won't delete)
python3 scripts/ai_tools/cleanup_agent.py

# Verify task completion
python3 scripts/ai_tools/task_verifier.py
```

### Fix Issues
```bash
# Execute cleanup (will delete malformed files after rescuing useful content)
python3 scripts/ai_tools/cleanup_agent.py --execute

# Check GitHub issues for incomplete work
gh issue list --label ai-generated
```

## Tools

### 1. Cleanup Agent (`scripts/ai_tools/cleanup_agent.py`)

**Purpose:** Detect and remove malformed files/folders created by agents

**What it detects:**
- Files/folders with backticks (`` ` ``) - markdown code formatting
- Files/folders with `**` - markdown bold formatting
- Names starting with "Path:", "Updated", "New File", etc.
- Names that look like code snippets (`if ...`, `def ...`, etc.)
- Files named just "python" with no extension

**Rescue feature:**
- Before deleting, scans for files > 100 bytes
- Automatically moves useful content to proper locations
- Example: `dimension_manager.gd` → `scripts/autoloads/dimension_manager.gd`

**Usage:**
```bash
# Dry-run (shows what would be deleted)
python3 scripts/ai_tools/cleanup_agent.py

# Execute (actually deletes)
python3 scripts/ai_tools/cleanup_agent.py --execute
```

### 2. Task Verifier (`scripts/ai_tools/task_verifier.py`)

**Purpose:** Verify that tasks marked "completed" actually have their deliverables

**What it checks:**
- Stage 1: Event bus, first-person controller, debug overlay, test scene
- Stage 2: Editor mode, UI, manager, palette, serializer, resources
- Stage 3: Dimension manager, objects, gates, triggers, shaders, audio
- Stage 4: Sanity/health systems, HUD components, effects

**What it does:**
- Scans for expected files based on stage
- Creates GitHub issues for missing deliverables
- Provides audit trail of completed vs claimed work

**Usage:**
```bash
python3 scripts/ai_tools/task_verifier.py
```

### 3. Updated Agent Orchestrator

**New safeguards in `scripts/ai_tools/agent_orchestrator.py`:**

#### Startup Cleanup
```python
def __init__(self):
    # ... existing code ...
    self.run_cleanup()  # Runs cleanup on every startup
```

#### File Path Constraints
```python
def get_files_for_task(self, task: Task) -> List[str]:
    """Determine which specific files aider should work on"""
    # Constrains aider to specific files based on task description
    # Prevents creating files in random locations
```

#### Task Verification
```python
def verify_task_deliverables(self, task: Task) -> bool:
    """Verify that expected files for a task actually exist"""
    # Checks if deliverables exist before marking task complete
```

#### Post-Task Cleanup
```python
def execute_task_with_aider(self, task: Task) -> bool:
    # ... do work ...
    # Run cleanup after each task to catch malformed files immediately
    self.run_cleanup()
```

## File Creation Rules

These rules are now enforced in the agent prompts:

### ✅ Allowed
- Create files in: `scenes/`, `scripts/`, `assets/`
- Use proper Godot extensions: `.gd`, `.tscn`, `.tres`, `.gdshader`
- Follow folder structure:
  - `scenes/` → subdivided: player/, ui/, editor/, levels/
  - `scripts/` → subdivided: autoloads/, player/, ui/, editor/, resources/
  - `assets/` → subdivided: configs/, shaders/, textures/, audio/

### ❌ Forbidden
- Files with backticks, asterisks, or markdown formatting in names
- Files in project root (except `.md` or `.json`)
- Files with code snippet names (`if ...`, `def ...`, etc.)
- Files without proper extensions

## Automated Protection

The `.tmuxinator.yml` now runs cleanup and verification on startup:

```yaml
on_project_start:
  - ollama pull qwen2.5-coder:7b
  - ollama pull qwen2.5-coder:14b
  - ollama pull deepseek-coder:6.7b
  - python3 scripts/ai_tools/cleanup_agent.py --execute
  - python3 scripts/ai_tools/task_verifier.py
```

## Monitoring

### Check for malformed files
```bash
# List any files/folders with malformed names
python3 scripts/ai_tools/cleanup_agent.py
```

### Check task completion
```bash
# Verify all completed stages have their deliverables
python3 scripts/ai_tools/task_verifier.py
```

### Check GitHub issues
```bash
# List all AI-generated issues
gh issue list --label ai-generated

# List build errors
gh issue list --label build-error

# List urgent issues
gh issue list --label urgent
```

## Recovery Process

If agents create malformed files:

1. **Stop the orchestrator** (Ctrl+C)
2. **Run cleanup**
   ```bash
   python3 scripts/ai_tools/cleanup_agent.py --execute
   ```
3. **Verify what was rescued**
   - Check the output for "Rescued:" messages
   - Verify files are in proper locations
4. **Run verification**
   ```bash
   python3 scripts/ai_tools/task_verifier.py
   ```
5. **Check GitHub issues** for incomplete work
6. **Resume orchestrator** - It will cleanup again on startup

## Prevention Layers

Multiple layers of protection:

1. ✅ **Startup cleanup** - Cleans before starting work
2. ✅ **File path constraints** - Aider only works on specific files
3. ✅ **Explicit rules** - Prompts forbid malformed names
4. ✅ **Post-task cleanup** - Catches issues immediately
5. ✅ **Task verification** - Checks deliverables exist
6. ✅ **GitHub tracking** - All incomplete work gets issues

## Troubleshooting

### "Too many malformed files!"
```bash
# First, do a dry-run to see what would be deleted
python3 scripts/ai_tools/cleanup_agent.py

# Review the output, then execute
python3 scripts/ai_tools/cleanup_agent.py --execute
```

### "Task marked complete but files missing"
```bash
# Run verifier to create GitHub issues
python3 scripts/ai_tools/task_verifier.py

# Check issues created
gh issue list --label ai-generated,build-error
```

### "Agent still creating malformed files"
This shouldn't happen with current safeguards, but if it does:
1. Check that orchestrator has latest updates
2. Verify cleanup is running after each task
3. Review aider prompts to ensure rules are included
4. File a bug report with examples

## Maintenance

### Weekly
```bash
# Check for any accumulated malformed files
python3 scripts/ai_tools/cleanup_agent.py

# Verify all claimed work is actually complete
python3 scripts/ai_tools/task_verifier.py
```

### After major agent runs
```bash
# Execute cleanup
python3 scripts/ai_tools/cleanup_agent.py --execute

# Verify deliverables
python3 scripts/ai_tools/task_verifier.py

# Review GitHub issues
gh issue list --label ai-generated
```

## Summary

The agent safeguards provide:
- ✅ Automatic detection and removal of malformed files
- ✅ Rescue of useful content before deletion
- ✅ Verification of task completion
- ✅ GitHub issue tracking for incomplete work
- ✅ Multiple layers of prevention
- ✅ Easy recovery process
- ✅ Automated monitoring via tmuxinator

With these safeguards, agents can work autonomously while maintaining repository cleanliness and ensuring all claimed work is actually completed.
