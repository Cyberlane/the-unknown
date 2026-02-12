#!/usr/bin/env python3
"""
Task Verification Agent - Verifies that tasks marked as completed actually exist
Creates GitHub issues for incomplete work
"""

import subprocess
import json
from pathlib import Path
from typing import Dict, List, Set

PROJECT_ROOT = Path(__file__).parent.parent.parent
PROGRESS_FILE = PROJECT_ROOT / ".ai_progress.json"
DEV_PLAN = PROJECT_ROOT / "development_plan.md"

# Expected deliverables based on development plan stages
STAGE_DELIVERABLES = {
    1: {
        "scripts/autoloads/event_bus.gd": "Event Bus autoload singleton",
        "scenes/player/first_person_controller.tscn": "First-person character scene",
        "scripts/player/first_person_controller.gd": "FP controller script",
        "scenes/ui/debug_overlay.tscn": "Debug overlay UI",
        "scenes/test_scene.tscn": "Test level scene",
    },
    2: {
        "scripts/autoloads/editor_mode.gd": "Editor mode autoload",
        "scenes/editor/editor_ui.tscn": "Editor UI scene",
        "scripts/editor/editor_manager.gd": "Editor manager script",
        "scripts/editor/block_palette_manager.gd": "Block palette system",
        "scripts/editor/level_serializer.gd": "Save/load system",
        "scripts/resources/block_resource.gd": "Block resource definition",
        "scripts/resources/level_data.gd": "Level data resource",
    },
    3: {
        "scripts/autoloads/dimension_manager.gd": "Dimension manager autoload",
        "scripts/dimension_object.gd": "Dimension-aware object component",
        "scripts/dimension_gate.gd": "Dimension switching item",
        "scripts/dimension_trigger.gd": "Dimension trigger system",
        "assets/shaders/dimension_transition.gdshader": "Transition shader",
        "scripts/dimension_ambient_audio.gd": "Ambient audio system",
    },
    4: {
        "scripts/player/sanity_system.gd": "Sanity management system",
        "scripts/player/health_system.gd": "Health management system",
        "scripts/ui/sanity_hud.gd": "Sanity HUD display",
        "scripts/ui/health_hud.gd": "Health HUD display",
        "scripts/effects/sanity_effects.gd": "Sanity visual/audio effects",
    }
}

class TaskVerifier:
    def __init__(self):
        self.progress = self.load_progress()
        self.missing_deliverables: Dict[int, List[str]] = {}

    def load_progress(self) -> dict:
        """Load AI progress tracking"""
        if PROGRESS_FILE.exists():
            with open(PROGRESS_FILE) as f:
                return json.load(f)
        return {"completed_tasks": [], "github_issues": {}}

    def verify_stage(self, stage: int) -> bool:
        """Verify all deliverables for a stage exist"""
        if stage not in STAGE_DELIVERABLES:
            print(f"⚠️  No deliverables defined for Stage {stage}")
            return True

        print(f"\n🔍 Verifying Stage {stage} deliverables...")

        deliverables = STAGE_DELIVERABLES[stage]
        missing = []

        for filepath, description in deliverables.items():
            full_path = PROJECT_ROOT / filepath

            if full_path.exists():
                # Check if file is not empty
                if full_path.stat().st_size > 0:
                    print(f"  ✅ {filepath}")
                else:
                    print(f"  ⚠️  {filepath} (exists but empty)")
                    missing.append(f"{filepath} - {description} (file is empty)")
            else:
                print(f"  ❌ {filepath} (missing)")
                missing.append(f"{filepath} - {description}")

        if missing:
            self.missing_deliverables[stage] = missing
            return False

        return True

    def get_completed_stages(self) -> Set[int]:
        """Extract which stages have completed tasks"""
        completed_tasks = self.progress.get("completed_tasks", [])
        stages = set()

        for task_id in completed_tasks:
            # Extract stage number from task ID (e.g., S1T2 -> 1)
            if task_id.startswith('S') and 'T' in task_id:
                stage = int(task_id.split('T')[0][1:])
                stages.add(stage)

        return stages

    def check_existing_issue(self, stage: int) -> bool:
        """Check if an open issue already exists for this stage's missing deliverables"""
        try:
            result = subprocess.run(
                ["gh", "issue", "list",
                 "--state", "open",
                 "--label", f"stage-{stage}",
                 "--label", "urgent",
                 "--json", "number,title"],
                capture_output=True,
                text=True
            )

            if result.returncode == 0:
                issues = json.loads(result.stdout)
                # Check if any open issue matches this stage's missing deliverables pattern
                for issue in issues:
                    if f"[Stage {stage}]" in issue["title"] and "Missing Deliverables" in issue["title"]:
                        print(f"\n⚠️  Open issue already exists for Stage {stage}: #{issue['number']}")
                        return True
            return False
        except Exception as e:
            print(f"\n⚠️  Error checking for existing issues: {e}")
            return False

    def create_github_issue_for_missing(self, stage: int, missing: List[str]):
        """Create a GitHub issue for missing deliverables (only if one doesn't already exist)"""
        # Check if an issue already exists for this stage
        if self.check_existing_issue(stage):
            print(f"   Skipping issue creation - open issue already exists")
            return None

        title = f"[Stage {stage}] Missing Deliverables - Incomplete Work"

        body = f"""## Stage {stage} Verification Failed

The automated task verifier has detected that Stage {stage} was marked as completed, but the following deliverables are missing or incomplete:

### Missing Deliverables:
"""
        for item in missing:
            body += f"- [ ] `{item}`\n"

        body += """
### Required Actions:
1. Review each missing deliverable
2. Implement the missing components
3. Verify implementation with Godot headless check
4. Update this issue as items are completed
5. Close when all deliverables exist and are verified

### Notes:
- This issue was automatically created by the Task Verification Agent
- The agent marked tasks as completed prematurely without verifying deliverables
- Future agent runs should verify task completion before marking as done

### Labels:
`ai-generated`, `build-error`, `urgent`, `stage-{stage}`
"""

        try:
            result = subprocess.run(
                ["gh", "issue", "create",
                 "--title", title,
                 "--body", body,
                 "--label", f"ai-generated,build-error,urgent,stage-{stage}"],
                capture_output=True,
                text=True
            )

            if result.returncode == 0:
                issue_url = result.stdout.strip()
                print(f"\n📋 Created GitHub issue: {issue_url}")
                return issue_url
            else:
                print(f"\n❌ Failed to create GitHub issue: {result.stderr}")
                return None
        except Exception as e:
            print(f"\n❌ Error creating GitHub issue: {e}")
            return None

    def verify_all_completed_stages(self):
        """Verify all stages that have completed tasks"""
        print("🔍 Task Verification Agent")
        print("=" * 80)

        completed_stages = self.get_completed_stages()

        if not completed_stages:
            print("\n✅ No completed stages found in progress file")
            return

        print(f"\nFound completed tasks in stages: {sorted(completed_stages)}")

        all_valid = True

        for stage in sorted(completed_stages):
            is_valid = self.verify_stage(stage)

            if not is_valid:
                all_valid = False
                print(f"\n❌ Stage {stage} verification FAILED")

                if stage in self.missing_deliverables:
                    missing = self.missing_deliverables[stage]
                    print(f"   Missing {len(missing)} deliverable(s)")

                    # Create GitHub issue
                    self.create_github_issue_for_missing(stage, missing)
            else:
                print(f"\n✅ Stage {stage} verification PASSED")

        print("\n" + "=" * 80)

        if all_valid:
            print("✅ All completed stages verified successfully!")
        else:
            print("❌ Some stages have missing deliverables")
            print("📋 GitHub issues created for incomplete work")
            print("🔄 Agents should complete missing work before continuing")

        return all_valid

def main():
    verifier = TaskVerifier()
    verifier.verify_all_completed_stages()

if __name__ == "__main__":
    main()
