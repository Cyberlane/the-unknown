#!/usr/bin/env python3
"""
Multi-Agent Orchestrator for The Unknown
Coordinates specialized AI agents to build the game autonomously
"""

import subprocess
import os
import sys
import json
import time
from pathlib import Path
from dataclasses import dataclass
from typing import List, Optional
import re

# CONFIGURATION
GODOT_PATH = "/Applications/Godot.app/Contents/MacOS/Godot"
PROJECT_ROOT = Path(__file__).parent.parent.parent
DEV_PLAN = PROJECT_ROOT / "development_plan.md"
PROGRESS_FILE = PROJECT_ROOT / ".ai_progress.json"

# Model configuration - using faster models for better performance on M4
MODELS = {
    "fast": "ollama_chat/qwen2.5-coder:7b",      # Fast for simple tasks
    "balanced": "ollama_chat/qwen2.5-coder:14b", # Medium complexity
    "complex": "ollama_chat/deepseek-coder:6.7b" # Complex architectural tasks
}

@dataclass
class Task:
    id: str
    title: str
    description: str
    stage: int
    priority: str
    model: str
    github_issue: Optional[int] = None
    status: str = "pending"  # pending, in_progress, completed, failed

class AgentOrchestrator:
    def __init__(self):
        self.progress = self.load_progress()
        self.current_stage = self.progress.get("current_stage", 1)
        self.setup_git_config()
        self.run_cleanup()  # Clean up malformed files on startup

    def load_progress(self):
        """Load progress from persistent storage"""
        if PROGRESS_FILE.exists():
            with open(PROGRESS_FILE) as f:
                return json.load(f)
        return {
            "current_stage": 1,
            "completed_tasks": [],
            "failed_tasks": [],
            "github_issues": {}
        }

    def save_progress(self):
        """Save progress to persistent storage"""
        with open(PROGRESS_FILE, "w") as f:
            json.dump(self.progress, f, indent=2)

    def setup_git_config(self):
        """Configure git to bypass GPG signing for automated commits"""
        print("🔧 Configuring git for automated commits...")

        # Disable GPG signing for this repository to bypass 1Password
        subprocess.run(
            ["git", "config", "--local", "commit.gpgsign", "false"],
            capture_output=True
        )

        # Set committer info for AI agents if not already set
        result = subprocess.run(
            ["git", "config", "--local", "user.name"],
            capture_output=True,
            text=True
        )

        if not result.stdout.strip():
            subprocess.run(
                ["git", "config", "--local", "user.name", "AI Agent Orchestrator"],
                capture_output=True
            )
            subprocess.run(
                ["git", "config", "--local", "user.email", "ai-agent@the-unknown.local"],
                capture_output=True
            )

        print("✅ Git configured for automated commits")

    def run_cleanup(self):
        """Run cleanup agent to remove malformed files/folders"""
        print("\n🧹 Running cleanup agent...")

        cleanup_script = PROJECT_ROOT / "scripts" / "ai_tools" / "cleanup_agent.py"

        if not cleanup_script.exists():
            print("⚠️  Cleanup script not found, skipping cleanup")
            return

        try:
            # Run cleanup with --execute flag to actually clean
            result = subprocess.run(
                ["python3", str(cleanup_script), "--execute"],
                capture_output=True,
                text=True,
                timeout=30
            )

            if result.returncode == 0:
                print("✅ Cleanup completed")
                if "Rescued:" in result.stdout:
                    print("   🆘 Some files were rescued and moved to proper locations")
            else:
                print(f"⚠️  Cleanup had issues: {result.stderr}")

        except Exception as e:
            print(f"⚠️  Cleanup failed: {e}")

    def get_urgent_github_issues(self) -> List[Task]:
        """Fetch open urgent GitHub issues and convert them to tasks"""
        print("🔍 Checking for urgent backlog issues...")

        try:
            result = subprocess.run(
                ["gh", "issue", "list",
                 "--label", "urgent",
                 "--state", "open",
                 "--json", "number,title,body,labels"],
                capture_output=True,
                text=True
            )

            if result.returncode != 0:
                print("⚠️  Failed to fetch GitHub issues")
                return []

            issues = json.loads(result.stdout)
            tasks = []

            for issue in issues:
                # Parse the issue to extract missing deliverables
                task = self.parse_github_issue_to_task(issue)
                if task:
                    tasks.append(task)

            if tasks:
                print(f"⚠️  Found {len(tasks)} URGENT backlog issues to address first!")

            return tasks

        except Exception as e:
            print(f"⚠️  Error fetching urgent issues: {e}")
            return []

    def parse_github_issue_to_task(self, issue: dict) -> Optional[Task]:
        """Convert a GitHub issue into a Task object"""
        # Extract stage from labels
        stage = None
        for label in issue.get("labels", []):
            if label["name"].startswith("stage-"):
                stage = int(label["name"].split("-")[1])
                break

        if not stage:
            return None

        # Extract missing deliverables from the issue body
        body = issue.get("body", "")
        deliverables = []

        for line in body.split('\n'):
            # Look for checkbox items with file paths
            if '- [ ]' in line and '`' in line:
                # Extract the file path and description
                match = re.search(r'`([^`]+)`\s*-?\s*(.*)', line)
                if match:
                    deliverables.append(match.group(1).strip())

        if not deliverables:
            return None

        # Create task description from deliverables
        description = f"Missing deliverables from Stage {stage}:\n"
        description += "\n".join(f"- {d}" for d in deliverables)

        # Determine model based on task complexity
        model = self.determine_model(description)

        task_id = f"GH{issue['number']}"

        return Task(
            id=task_id,
            title=f"Fix missing deliverables from Stage {stage}",
            description=description,
            stage=stage,
            priority="urgent",
            model=model,
            github_issue=issue['number'],
            status="pending"
        )

    def parse_development_plan(self) -> List[Task]:
        """Parse development_plan.md and extract tasks for current stage"""
        if not DEV_PLAN.exists():
            print("❌ development_plan.md not found!")
            return []

        with open(DEV_PLAN) as f:
            content = f.read()

        tasks = []
        current_stage = None
        in_tasks_section = False

        for line in content.split('\n'):
            # Detect stage header
            stage_match = re.match(r'^## Stage (\d+)', line)
            if stage_match:
                current_stage = int(stage_match.group(1))
                in_tasks_section = False
                continue

            # Detect tasks section
            if line.startswith('### Tasks'):
                in_tasks_section = True
                continue

            # Stop at next section
            if line.startswith('###') and not line.startswith('### Tasks'):
                in_tasks_section = False

            # Parse task items
            if in_tasks_section and line.startswith('- ') and current_stage:
                task_desc = line[2:].strip()
                if task_desc and current_stage == self.current_stage:
                    # Determine model based on task complexity
                    model = self.determine_model(task_desc)

                    task_id = f"S{current_stage}T{len(tasks)+1}"
                    tasks.append(Task(
                        id=task_id,
                        title=task_desc[:80],
                        description=task_desc,
                        stage=current_stage,
                        priority="high" if "autoload" in task_desc.lower() or "setup" in task_desc.lower() else "normal",
                        model=model
                    ))

        return tasks

    def determine_model(self, task_desc: str) -> str:
        """Determine which model to use based on task complexity"""
        task_lower = task_desc.lower()

        # Complex tasks requiring architectural decisions
        if any(word in task_lower for word in ["architecture", "system", "design", "manager", "autoload", "state machine"]):
            return MODELS["complex"]

        # Simple implementation tasks
        if any(word in task_lower for word in ["basic", "placeholder", "debug", "simple", "configuration"]):
            return MODELS["fast"]

        # Default to balanced
        return MODELS["balanced"]

    def ensure_github_labels(self):
        """Ensure required GitHub labels exist, create if missing"""
        required_labels = [
            ("ai-generated", "AI generated task", "0366d6"),
            ("build-error", "Build validation failure", "d73a4a"),
            ("urgent", "Requires immediate attention", "b60205"),
        ]

        # Add stage labels
        for stage in range(1, 13):
            required_labels.append(
                (f"stage-{stage}", f"Development stage {stage}", "fbca04")
            )

        for label_name, description, color in required_labels:
            try:
                # Check if label exists
                check = subprocess.run(
                    ["gh", "label", "list", "--json", "name"],
                    capture_output=True,
                    text=True
                )

                if check.returncode == 0:
                    existing_labels = json.loads(check.stdout)
                    label_exists = any(l["name"] == label_name for l in existing_labels)

                    if not label_exists:
                        # Create the label
                        subprocess.run(
                            ["gh", "label", "create", label_name,
                             "--description", description,
                             "--color", color],
                            capture_output=True
                        )
                        print(f"📋 Created label: {label_name}")
            except Exception as e:
                print(f"⚠️  Error ensuring label {label_name}: {e}")

    def create_github_issue(self, task: Task) -> Optional[int]:
        """Create a GitHub issue for tracking, if label is missing then create the label"""
        # Check if issue already exists
        if task.id in self.progress.get("github_issues", {}):
            return self.progress["github_issues"][task.id]

        # Ensure labels exist before creating issue
        self.ensure_github_labels()

        body = f"""## Stage {task.stage} Task

**Description:**
{task.description}

**Priority:** {task.priority}
**Model:** {task.model}
**Task ID:** {task.id}

---
*This issue was automatically created by the AI agent orchestrator*
"""

        try:
            result = subprocess.run(
                ["gh", "issue", "create",
                 "--title", f"[Stage {task.stage}] {task.title}",
                 "--body", body,
                 "--label", f"stage-{task.stage},ai-generated"],
                capture_output=True,
                text=True
            )

            if result.returncode == 0:
                # Extract issue number from output
                issue_url = result.stdout.strip()
                issue_num = int(issue_url.split('/')[-1])

                # Save to progress
                if "github_issues" not in self.progress:
                    self.progress["github_issues"] = {}
                self.progress["github_issues"][task.id] = issue_num
                self.save_progress()

                print(f"✅ Created issue #{issue_num}: {task.title}")
                return issue_num
            else:
                print(f"⚠️  Failed to create issue: {result.stderr}")
                return None
        except Exception as e:
            print(f"⚠️  Error creating issue: {e}")
            return None

    def update_github_issue(self, task: Task, status: str, message: str = ""):
        """Update GitHub issue with progress"""
        if task.github_issue:
            status_emoji = {
                "in_progress": "🔄",
                "completed": "✅",
                "failed": "❌"
            }.get(status, "📝")

            comment = f"{status_emoji} **Status Update:** {status.replace('_', ' ').title()}\n\n{message}"

            try:
                subprocess.run(
                    ["gh", "issue", "comment", str(task.github_issue), "--body", comment],
                    capture_output=True
                )

                if status == "completed":
                    subprocess.run(
                        ["gh", "issue", "close", str(task.github_issue)],
                        capture_output=True
                    )
            except Exception as e:
                print(f"⚠️  Error updating issue: {e}")

    def verify_godot_build(self) -> tuple[bool, str]:
        """Run Godot headless verification"""
        print("🔍 Verifying GDScript with Godot headless...")

        result = subprocess.run(
            [GODOT_PATH, "--headless", "--check-only", "--quit"],
            capture_output=True,
            text=True,
            timeout=30
        )

        if result.returncode != 0 and ("ERROR" in result.stderr or "SCRIPT ERROR" in result.stderr):
            return False, result.stderr

        return True, "Build verification passed"

    def get_files_for_task(self, task: Task) -> List[str]:
        """Determine which specific files aider should work on for this task"""
        task_lower = task.description.lower()
        files = []

        # For GitHub issue tasks, extract file paths from description
        if task.id.startswith("GH"):
            for line in task.description.split('\n'):
                # Look for file paths in the description
                if line.strip().startswith('- '):
                    # Extract file path (may have description after it)
                    file_path = line.strip()[2:].strip()
                    # Remove any trailing descriptions
                    if ' - ' in file_path:
                        file_path = file_path.split(' - ')[0].strip()
                    # Remove backticks if present
                    file_path = file_path.replace('`', '')
                    if file_path and (file_path.endswith('.gd') or file_path.endswith('.tscn')):
                        files.append(file_path)
        else:
            # Parse task description to determine required files
            if "event bus" in task_lower or "eventbus" in task_lower:
                files.append("scripts/autoloads/event_bus.gd")

            if "first-person" in task_lower or "controller" in task_lower:
                files.extend([
                    "scenes/player/first_person_controller.tscn",
                    "scripts/player/first_person_controller.gd"
                ])

            if "debug overlay" in task_lower:
                files.extend([
                    "scenes/ui/debug_overlay.tscn",
                    "scripts/ui/debug_overlay.gd"
                ])

            if "editor" in task_lower and "mode" in task_lower:
                files.append("scripts/autoloads/editor_mode.gd")

            if "dimension" in task_lower:
                if "manager" in task_lower:
                    files.append("scripts/autoloads/dimension_manager.gd")
                if "object" in task_lower:
                    files.append("scripts/dimension_object.gd")
                if "gate" in task_lower or "switching" in task_lower:
                    files.append("scripts/dimension_gate.gd")
                if "trigger" in task_lower:
                    files.append("scripts/dimension_trigger.gd")

            if "palette" in task_lower:
                files.append("scripts/editor/block_palette_manager.gd")

            if "serializ" in task_lower or "save" in task_lower or "load" in task_lower:
                files.append("scripts/editor/level_serializer.gd")

            if "sanity" in task_lower:
                files.extend([
                    "scripts/player/sanity_system.gd",
                    "scripts/ui/sanity_hud.gd"
                ])

            if "health" in task_lower:
                files.extend([
                    "scripts/player/health_system.gd",
                    "scripts/ui/health_hud.gd"
                ])

        # Add development_plan.md for context
        files.append("development_plan.md")

        return files

    def execute_task_with_aider(self, task: Task) -> bool:
        """Execute a task using aider with appropriate model"""
        print(f"\n{'='*80}")
        print(f"🤖 Executing Task {task.id}: {task.title}")
        print(f"📊 Model: {task.model}")
        if task.github_issue:
            print(f"🔗 GitHub Issue: #{task.github_issue}")
        print(f"{'='*80}\n")

        # Update or create GitHub issue
        if not task.github_issue:
            task.github_issue = self.create_github_issue(task)

        self.update_github_issue(task, "in_progress", f"Starting work with model: {task.model}")

        # Get specific files for this task
        task_files = self.get_files_for_task(task)
        print(f"📂 Working on {len(task_files)} specific files")

        # Build aider command
        is_backlog_task = task.id.startswith("GH")

        if is_backlog_task:
            prompt = f"""
URGENT BACKLOG TASK - Missing Deliverables

{task.description}

This task addresses missing files from a previous stage. You MUST create all the files listed above.
Each file listed is a deliverable that was supposed to exist but is missing.

CRITICAL REQUIREMENTS:
1. CREATE all files mentioned in the task description above
2. Use Godot 4.x / GDScript 2.0 syntax ONLY
3. Use CharacterBody3D instead of KinematicBody3D
4. Use proper typed GDScript with type hints
5. Follow the architecture principles in development_plan.md:
   - Modular scene composition
   - Event bus for communication (EventBus autoload)
   - Resource-based data for configs
   - State machines where appropriate
6. Create clean, well-commented code
7. Use export variables for designer-facing parameters

FILE CREATION RULES:
- Create files exactly at the paths specified in the task description
- NEVER create files with backticks, asterisks, or markdown formatting in the name
- ALWAYS use proper GDScript/Godot file extensions (.gd, .tscn, .tres, .gdshader)

Folder structure:
- scenes/ for .tscn files (subdivided: player/, ui/, editor/, levels/)
- scripts/ for .gd files (subdivided: autoloads/, player/, ui/, editor/, resources/)
- assets/ for external resources (configs/, shaders/, textures/)
"""
        else:
            prompt = f"""
{task.description}

CRITICAL REQUIREMENTS:
1. Use Godot 4.x / GDScript 2.0 syntax ONLY
2. Use CharacterBody3D instead of KinematicBody3D
3. Use proper typed GDScript with type hints
4. Follow the architecture principles in development_plan.md:
   - Modular scene composition
   - Event bus for communication (EventBus autoload)
   - Resource-based data for configs
   - State machines where appropriate

5. Create clean, well-commented code
6. Use export variables for designer-facing parameters

FILE CREATION RULES:
- ONLY create files in these directories: scenes/, scripts/, assets/
- NEVER create files with backticks, asterisks, or markdown formatting in the name
- NEVER create files in the project root unless it's a .md or .json file
- ALWAYS use proper GDScript/Godot file extensions (.gd, .tscn, .tres, .gdshader)

Folder structure:
- scenes/ for .tscn files (subdivided: player/, ui/, editor/, levels/)
- scripts/ for .gd files (subdivided: autoloads/, player/, ui/, editor/, resources/)
- assets/ for external resources (configs/, shaders/, textures/)
"""

        aider_cmd = [
            "aider",
            "--model", task.model,
            "--message", prompt,
            "--yes-always",
            "--auto-commit",
            "--no-suggest-shell-commands"
        ]

        # Add specific files to the command
        for file_path in task_files:
            aider_cmd.append(file_path)

        result = subprocess.run(
            aider_cmd,
            stdin=subprocess.DEVNULL,
            capture_output=True,
            text=True
        )

        if result.returncode != 0:
            print(f"❌ Aider failed: {result.stderr}")
            self.update_github_issue(task, "failed", f"Aider execution failed:\n```\n{result.stderr}\n```")
            return False

        # Verify build
        build_ok, build_msg = self.verify_godot_build()

        if not build_ok:
            print(f"❌ Build verification failed!")
            print(build_msg)

            # Revert the commit
            print("⏪ Reverting last commit...")
            subprocess.run(["git", "reset", "--hard", "HEAD~1"])

            self.update_github_issue(task, "failed", f"Build verification failed:\n```\n{build_msg}\n```")
            return False

        # Verify task completion by checking if expected files exist
        print("🔍 Verifying task deliverables...")
        verification_passed = self.verify_task_deliverables(task)

        if not verification_passed:
            print("⚠️  Task marked complete but some deliverables may be missing")
            self.update_github_issue(task, "completed", "Task completed with warnings - some deliverables may need review")
        else:
            print(f"✅ Task {task.id} completed and verified!")
            # For GitHub issue tasks, update checkboxes and close if all done
            if task.id.startswith("GH"):
                self.update_github_issue_checkboxes(task)
            else:
                self.update_github_issue(task, "completed", "Task completed and fully verified")

        # Update progress
        self.progress["completed_tasks"].append(task.id)
        self.save_progress()

        # Run cleanup after each task to catch any malformed files immediately
        self.run_cleanup()

        return True

    def update_github_issue_checkboxes(self, task: Task):
        """Update checkboxes in GitHub issue and close if all deliverables are done"""
        if not task.github_issue:
            return

        try:
            # Get current issue body
            result = subprocess.run(
                ["gh", "issue", "view", str(task.github_issue), "--json", "body"],
                capture_output=True,
                text=True
            )

            if result.returncode != 0:
                return

            issue_data = json.loads(result.stdout)
            body = issue_data.get("body", "")

            # Check which deliverables now exist
            updated_body = ""
            all_complete = True

            for line in body.split('\n'):
                if '- [ ]' in line and '`' in line:
                    # Extract file path
                    match = re.search(r'`([^`]+)`', line)
                    if match:
                        file_path = match.group(1).strip()
                        full_path = PROJECT_ROOT / file_path

                        # Check if file exists
                        if full_path.exists():
                            # Mark as complete
                            updated_body += line.replace('- [ ]', '- [x]') + '\n'
                        else:
                            # Still incomplete
                            updated_body += line + '\n'
                            all_complete = False
                    else:
                        updated_body += line + '\n'
                else:
                    updated_body += line + '\n'

            # Update the issue body with checked boxes
            subprocess.run(
                ["gh", "issue", "edit", str(task.github_issue), "--body", updated_body],
                capture_output=True
            )

            # Add comment and close if all complete
            if all_complete:
                comment = "✅ **All Deliverables Completed**\n\nAll missing files have been created and verified. Closing issue."
                subprocess.run(
                    ["gh", "issue", "comment", str(task.github_issue), "--body", comment],
                    capture_output=True
                )
                subprocess.run(
                    ["gh", "issue", "close", str(task.github_issue)],
                    capture_output=True
                )
                print(f"✅ Closed GitHub issue #{task.github_issue} - all deliverables complete!")
            else:
                comment = "🔄 **Progress Update**\n\nSome deliverables have been completed. Updated checkboxes above. Issue remains open for remaining items."
                subprocess.run(
                    ["gh", "issue", "comment", str(task.github_issue), "--body", comment],
                    capture_output=True
                )
                print(f"📝 Updated GitHub issue #{task.github_issue} - partial progress")

        except Exception as e:
            print(f"⚠️  Error updating GitHub issue checkboxes: {e}")

    def verify_task_deliverables(self, task: Task) -> bool:
        """Verify that expected files for a task actually exist"""
        expected_files = self.get_files_for_task(task)

        # Remove context files like development_plan.md
        expected_files = [f for f in expected_files if not f.endswith('.md')]

        missing = []
        for file_path in expected_files:
            full_path = PROJECT_ROOT / file_path
            if not full_path.exists():
                missing.append(file_path)

        if missing:
            print(f"⚠️  Missing {len(missing)} expected deliverables:")
            for file_path in missing:
                print(f"   - {file_path}")
            return False

        return True

    def display_progress_summary(self):
        """Display a summary of current progress"""
        print(f"\n{'='*80}")
        print(f"📊 PROGRESS SUMMARY")
        print(f"{'='*80}")
        print(f"Current Stage: {self.current_stage}")
        print(f"Completed Tasks: {len(self.progress.get('completed_tasks', []))}")
        print(f"Failed Tasks: {len(self.progress.get('failed_tasks', []))}")
        print(f"GitHub Issues Created: {len(self.progress.get('github_issues', {}))}")

        # Check for urgent backlog issues
        try:
            result = subprocess.run(
                ["gh", "issue", "list", "--label", "urgent", "--state", "open", "--json", "number"],
                capture_output=True,
                text=True
            )
            if result.returncode == 0:
                urgent_issues = json.loads(result.stdout)
                if urgent_issues:
                    print(f"\n⚠️  URGENT BACKLOG: {len(urgent_issues)} open issues requiring attention")
        except:
            pass

        # Show recent completions
        recent = self.progress.get("completed_tasks", [])[-5:]
        if recent:
            print(f"\nRecent Completions:")
            for task_id in recent:
                print(f"  ✅ {task_id}")

        # Show failed tasks
        failed = self.progress.get("failed_tasks", [])
        if failed:
            print(f"\nFailed Tasks (need manual review):")
            for task_id in failed:
                print(f"  ❌ {task_id}")

        print(f"{'='*80}\n")

    def run_stage(self, max_tasks: int = 5, continuous: bool = False):
        """Run tasks for current stage

        Args:
            max_tasks: Maximum tasks to run per iteration
            continuous: If True, keep running until all stages complete
        """
        iteration = 0

        while True:
            iteration += 1

            print(f"\n🎮 THE UNKNOWN - AI Agent Orchestrator")
            print(f"📍 Current Stage: {self.current_stage}/12")
            print(f"🔄 Iteration: {iteration}")
            print(f"🎯 Max tasks per iteration: {max_tasks}\n")

            # Display progress summary
            self.display_progress_summary()

            # PRIORITY 1: Get urgent backlog issues first
            urgent_tasks = self.get_urgent_github_issues()

            # PRIORITY 2: Get new tasks from development plan
            plan_tasks = self.parse_development_plan()

            # Combine with urgent tasks first
            all_tasks = urgent_tasks + plan_tasks

            if not all_tasks:
                print("✨ No tasks found for current stage. Moving to next stage!")
                self.current_stage += 1
                self.save_progress()

                # Check if we've completed all stages
                if self.current_stage > 12:
                    print("\n🎉 ALL STAGES COMPLETED! Game development finished!")
                    return

                if not continuous:
                    return

                continue

            if urgent_tasks:
                print(f"⚠️  BACKLOG: {len(urgent_tasks)} urgent issues to fix")
            if plan_tasks:
                print(f"📋 PLANNED: {len(plan_tasks)} new tasks for Stage {self.current_stage}")
            print(f"📊 TOTAL: {len(all_tasks)} tasks (urgent issues prioritized first)")

            # Filter out completed tasks
            pending_tasks = [
                t for t in all_tasks
                if t.id not in self.progress.get("completed_tasks", [])
                and t.id not in self.progress.get("failed_tasks", [])
            ]

            if not pending_tasks:
                print("✨ All tasks completed! Moving to next stage!")
                self.current_stage += 1
                self.save_progress()

                if not continuous:
                    return

                continue

            print(f"⏳ Pending tasks: {len(pending_tasks)}")

            # Execute up to max_tasks
            executed = 0
            failed_count = 0

            for task in pending_tasks[:max_tasks]:
                success = self.execute_task_with_aider(task)
                executed += 1

                if not success:
                    failed_count += 1
                    print(f"⚠️  Task {task.id} failed. Continuing with next task...")
                    self.progress["failed_tasks"].append(task.id)
                    self.save_progress()

                    # If too many failures in a row, stop
                    if failed_count >= 3:
                        print(f"❌ Too many failures ({failed_count}). Stopping for review.")
                        print(f"💡 Check failed tasks in GitHub issues or .ai_progress.json")
                        return

                # Small delay between tasks
                time.sleep(2)

            print(f"\n✅ Iteration {iteration} complete: {executed - failed_count} succeeded, {failed_count} failed")
            print(f"📊 Total progress: {len(self.progress['completed_tasks'])} tasks completed")

            # If not continuous mode, stop after one iteration
            if not continuous:
                print(f"\n💤 Single iteration complete. Run again to continue.")
                return

            # In continuous mode, check if there are more pending tasks
            if not pending_tasks[max_tasks:]:
                print(f"\n✨ All pending tasks in stage {self.current_stage} completed!")
                print(f"🔄 Moving to next stage...")
                time.sleep(5)  # Brief pause before next stage

def main():
    orchestrator = AgentOrchestrator()

    # Parse command line arguments
    max_tasks = 5
    continuous = False

    if len(sys.argv) > 1:
        if sys.argv[1] == "--continuous" or sys.argv[1] == "-c":
            continuous = True
            max_tasks = int(sys.argv[2]) if len(sys.argv) > 2 else 5
        elif sys.argv[1] == "--help" or sys.argv[1] == "-h":
            print("""
AI Agent Orchestrator - Autonomous Game Development

Usage:
    python3 agent_orchestrator.py [OPTIONS] [MAX_TASKS]

Options:
    -c, --continuous    Run continuously until all stages complete
    -h, --help         Show this help message

Arguments:
    MAX_TASKS          Number of tasks per iteration (default: 5)

Examples:
    # Run 5 tasks then stop
    python3 agent_orchestrator.py

    # Run 10 tasks then stop
    python3 agent_orchestrator.py 10

    # Run continuously with 5 tasks per iteration
    python3 agent_orchestrator.py --continuous

    # Run continuously with 3 tasks per iteration
    python3 agent_orchestrator.py --continuous 3

Resume:
    Progress is automatically saved to .ai_progress.json
    Just run the script again to resume where it left off.
            """)
            return
        else:
            max_tasks = int(sys.argv[1])

    print(f"🚀 Starting orchestrator...")
    print(f"   Max tasks per iteration: {max_tasks}")
    print(f"   Continuous mode: {'ON' if continuous else 'OFF'}")
    print(f"   Press Ctrl+C to stop gracefully\n")

    try:
        orchestrator.run_stage(max_tasks=max_tasks, continuous=continuous)
    except KeyboardInterrupt:
        print("\n\n⏸️  Interrupted by user")
        print("💾 Progress saved to .ai_progress.json")
        print("🔄 Run again to resume where you left off")
        orchestrator.save_progress()

if __name__ == "__main__":
    main()
