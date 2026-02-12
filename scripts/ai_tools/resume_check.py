#!/usr/bin/env python3
"""
Resume Check - Shows current progress and helps resume after crashes
"""

import json
import subprocess
from pathlib import Path
from datetime import datetime

PROJECT_ROOT = Path(__file__).parent.parent.parent
PROGRESS_FILE = PROJECT_ROOT / ".ai_progress.json"
VALIDATION_LOG = PROJECT_ROOT / ".validation_log.json"

def load_progress():
    if PROGRESS_FILE.exists():
        with open(PROGRESS_FILE) as f:
            return json.load(f)
    return None

def load_validation():
    if VALIDATION_LOG.exists():
        with open(VALIDATION_LOG) as f:
            return json.load(f)
    return None

def get_github_issues():
    """Get open GitHub issues"""
    try:
        result = subprocess.run(
            ["gh", "issue", "list", "--state", "open", "--label", "ai-generated",
             "--json", "number,title,state"],
            capture_output=True,
            text=True
        )
        if result.returncode == 0:
            return json.loads(result.stdout)
        return []
    except:
        return []

def main():
    print("🔍 THE UNKNOWN - Resume Check\n")
    print("=" * 80)

    progress = load_progress()
    validation = load_validation()

    if not progress:
        print("❌ No progress file found (.ai_progress.json)")
        print("   This is a fresh start. Run the orchestrator to begin.")
        return

    print("📊 SAVED PROGRESS FOUND\n")

    # Current state
    current_stage = progress.get("current_stage", 1)
    completed = progress.get("completed_tasks", [])
    failed = progress.get("failed_tasks", [])
    github_issues = progress.get("github_issues", {})

    print(f"Current Stage: {current_stage}/12")
    print(f"Completed Tasks: {len(completed)}")
    print(f"Failed Tasks: {len(failed)}")
    print(f"GitHub Issues Created: {len(github_issues)}\n")

    # Recent activity
    if completed:
        print("✅ Recently Completed:")
        for task_id in completed[-10:]:
            issue_num = github_issues.get(task_id, "N/A")
            print(f"   {task_id} (Issue #{issue_num})")
        print()

    # Failed tasks
    if failed:
        print("❌ Failed Tasks (need review):")
        for task_id in failed:
            issue_num = github_issues.get(task_id, "N/A")
            print(f"   {task_id} (Issue #{issue_num})")
        print()

    # Validation history
    if validation:
        validations = validation.get("validations", [])
        if validations:
            recent = validations[-5:]
            success_count = sum(1 for v in recent if v.get("success", False))
            print(f"🔍 Recent Build Validations: {success_count}/{len(recent)} successful\n")

    # GitHub status
    open_issues = get_github_issues()
    if open_issues:
        print(f"🐙 Open GitHub Issues ({len(open_issues)}):")
        for issue in open_issues[:5]:
            print(f"   #{issue['number']}: {issue['title']}")
        if len(open_issues) > 5:
            print(f"   ... and {len(open_issues) - 5} more")
        print()

    # Resume instructions
    print("=" * 80)
    print("\n🔄 HOW TO RESUME:\n")

    print("Option 1: Run single iteration (recommended after crash)")
    print("   python3 scripts/ai_tools/agent_orchestrator.py 3")
    print()

    print("Option 2: Run continuously until all stages complete")
    print("   python3 scripts/ai_tools/agent_orchestrator.py --continuous 3")
    print()

    print("Option 3: Use tmuxinator for full monitoring")
    print("   tmuxinator start the-unknown-ai-studio")
    print()

    if failed:
        print("⚠️  NOTE: You have failed tasks. Review GitHub issues before resuming.")
        print("   These tasks will be skipped in future runs.")
        print()

    print("💡 TIP: The orchestrator automatically resumes from .ai_progress.json")
    print("   It will skip completed tasks and continue with pending ones.")
    print()

    # Show what's next
    print("=" * 80)
    print(f"\n📋 NEXT STEPS (Stage {current_stage}):\n")

    # Get pending tasks by checking development plan
    from agent_orchestrator import AgentOrchestrator
    orch = AgentOrchestrator()
    tasks = orch.parse_development_plan()

    pending = [
        t for t in tasks
        if t.id not in completed and t.id not in failed
    ]

    if pending:
        print(f"Found {len(pending)} pending tasks in Stage {current_stage}:\n")
        for task in pending[:5]:
            print(f"   {task.id}: {task.title}")
            print(f"      Model: {task.model}")
            print()
        if len(pending) > 5:
            print(f"   ... and {len(pending) - 5} more tasks")
    else:
        print(f"✨ All tasks in Stage {current_stage} are complete!")
        print(f"   Will advance to Stage {current_stage + 1} on next run.")

    print()

if __name__ == "__main__":
    main()
