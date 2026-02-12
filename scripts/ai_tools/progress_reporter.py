#!/usr/bin/env python3
"""
Progress Reporter - Generates status reports and updates GitHub
"""

import json
import subprocess
from pathlib import Path
from datetime import datetime

PROJECT_ROOT = Path(__file__).parent.parent.parent
PROGRESS_FILE = PROJECT_ROOT / ".ai_progress.json"
VALIDATION_LOG = PROJECT_ROOT / ".validation_log.json"

class ProgressReporter:
    def __init__(self):
        self.progress = self.load_progress()
        self.validation_history = self.load_validation_history()

    def load_progress(self):
        if PROGRESS_FILE.exists():
            with open(PROGRESS_FILE) as f:
                return json.load(f)
        return {
            "current_stage": 1,
            "completed_tasks": [],
            "failed_tasks": [],
            "github_issues": {}
        }

    def load_validation_history(self):
        if VALIDATION_LOG.exists():
            with open(VALIDATION_LOG) as f:
                return json.load(f)
        return {"validations": [], "errors": []}

    def get_git_stats(self):
        """Get git statistics"""
        # Total commits
        commits = subprocess.run(
            ["git", "rev-list", "--count", "HEAD"],
            capture_output=True,
            text=True
        ).stdout.strip()

        # Files changed
        files_changed = subprocess.run(
            ["git", "diff", "--name-only", "HEAD~5..HEAD"],
            capture_output=True,
            text=True
        ).stdout.strip().split('\n')

        return {
            "total_commits": commits,
            "recent_files": [f for f in files_changed if f]
        }

    def get_github_stats(self):
        """Get GitHub issue statistics"""
        try:
            # Open issues
            open_result = subprocess.run(
                ["gh", "issue", "list", "--state", "open", "--json", "number"],
                capture_output=True,
                text=True
            )
            open_issues = len(json.loads(open_result.stdout)) if open_result.returncode == 0 else 0

            # Closed issues
            closed_result = subprocess.run(
                ["gh", "issue", "list", "--state", "closed", "--json", "number"],
                capture_output=True,
                text=True
            )
            closed_issues = len(json.loads(closed_result.stdout)) if closed_result.returncode == 0 else 0

            return {
                "open": open_issues,
                "closed": closed_issues,
                "total": open_issues + closed_issues
            }
        except:
            return {"open": 0, "closed": 0, "total": 0}

    def generate_report(self):
        """Generate comprehensive progress report"""
        git_stats = self.get_git_stats()
        github_stats = self.get_github_stats()

        # Validation stats
        total_validations = len(self.validation_history.get("validations", []))
        successful_validations = sum(1 for v in self.validation_history.get("validations", [])
                                    if v.get("success", False))
        validation_rate = (successful_validations / total_validations * 100) if total_validations > 0 else 0

        report = f"""
╔══════════════════════════════════════════════════════════════╗
║           THE UNKNOWN - AI Development Progress              ║
╚══════════════════════════════════════════════════════════════╝

📊 CURRENT STATUS
  Stage: {self.progress.get('current_stage', 1)}
  Tasks Completed: {len(self.progress.get('completed_tasks', []))}
  Tasks Failed: {len(self.progress.get('failed_tasks', []))}

🐙 GITHUB METRICS
  Open Issues: {github_stats['open']}
  Closed Issues: {github_stats['closed']}
  Total Issues: {github_stats['total']}

📝 GIT ACTIVITY
  Total Commits: {git_stats['total_commits']}
  Recent Files: {len(git_stats['recent_files'])}

🔍 BUILD VALIDATION
  Total Validations: {total_validations}
  Success Rate: {validation_rate:.1f}%
  Build Errors: {len(self.validation_history.get('errors', []))}

⏰ LAST UPDATED
  {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

╔══════════════════════════════════════════════════════════════╗
"""

        return report

    def display(self):
        """Display progress report in terminal"""
        print(self.generate_report())

    def update_readme(self):
        """Update README.md with progress badge/section"""
        readme_path = PROJECT_ROOT / "README.md"

        if not readme_path.exists():
            return

        progress_section = f"""
## 🤖 AI Development Progress

- **Current Stage:** {self.progress.get('current_stage', 1)}/12
- **Tasks Completed:** {len(self.progress.get('completed_tasks', []))}
- **GitHub Issues:** {self.get_github_stats()['total']} total
- **Last Updated:** {datetime.now().strftime('%Y-%m-%d %H:%M')}

*This section is automatically updated by the AI agent orchestrator*
"""

        # Read current README
        with open(readme_path) as f:
            content = f.read()

        # Check if progress section exists
        if "## 🤖 AI Development Progress" in content:
            # Replace existing section
            lines = content.split('\n')
            start_idx = None
            end_idx = None

            for i, line in enumerate(lines):
                if line.startswith("## 🤖 AI Development Progress"):
                    start_idx = i
                elif start_idx is not None and line.startswith("##"):
                    end_idx = i
                    break

            if start_idx is not None:
                if end_idx is not None:
                    lines = lines[:start_idx] + progress_section.split('\n') + lines[end_idx:]
                else:
                    lines = lines[:start_idx] + progress_section.split('\n')

                content = '\n'.join(lines)
        else:
            # Append to end
            content += "\n" + progress_section

        # Write back
        with open(readme_path, 'w') as f:
            f.write(content)

        print("✅ Updated README.md with progress")

def main():
    reporter = ProgressReporter()
    reporter.display()

    # Also update README if requested
    import sys
    if len(sys.argv) > 1 and sys.argv[1] == "--update-readme":
        reporter.update_readme()

if __name__ == "__main__":
    main()
