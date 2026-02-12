#!/usr/bin/env python3
"""
Validator Agent - Continuously monitors builds and creates issues for problems
Runs in the background to catch issues early
"""

import subprocess
import time
import json
from pathlib import Path
from datetime import datetime

GODOT_PATH = "/Applications/Godot.app/Contents/MacOS/Godot"
PROJECT_ROOT = Path(__file__).parent.parent.parent
VALIDATION_LOG = PROJECT_ROOT / ".validation_log.json"

class ValidatorAgent:
    def __init__(self):
        self.validation_history = self.load_history()
        self.last_commit = None
        self.ensure_github_labels()

    def load_history(self):
        if VALIDATION_LOG.exists():
            with open(VALIDATION_LOG) as f:
                return json.load(f)
        return {"validations": [], "errors": []}

    def save_history(self):
        with open(VALIDATION_LOG, "w") as f:
            json.dump(self.validation_history, f, indent=2)

    def get_current_commit(self):
        """Get current git commit hash"""
        result = subprocess.run(
            ["git", "rev-parse", "HEAD"],
            capture_output=True,
            text=True
        )
        return result.stdout.strip()

    def validate_build(self):
        """Run Godot headless validation"""
        print(f"🔍 [{datetime.now().strftime('%H:%M:%S')}] Validating build...")

        result = subprocess.run(
            [GODOT_PATH, "--headless", "--check-only", "--quit"],
            capture_output=True,
            text=True,
            timeout=30
        )

        commit = self.get_current_commit()
        timestamp = datetime.now().isoformat()

        validation_entry = {
            "timestamp": timestamp,
            "commit": commit,
            "success": True,
            "stderr": "",
            "stdout": ""
        }

        if result.returncode != 0 and ("ERROR" in result.stderr or "SCRIPT ERROR" in result.stderr):
            validation_entry["success"] = False
            validation_entry["stderr"] = result.stderr
            validation_entry["stdout"] = result.stdout

            print(f"❌ Validation failed!")
            print(f"Errors:\n{result.stderr}")

            # Create GitHub issue for the error
            self.create_error_issue(commit, result.stderr)
        else:
            print(f"✅ Build valid")

        self.validation_history["validations"].append(validation_entry)
        self.save_history()

        return validation_entry["success"]

    def ensure_github_labels(self):
        """Ensure required GitHub labels exist"""
        required_labels = [
            ("build-error", "Build validation failure", "d73a4a"),
            ("urgent", "Requires immediate attention", "b60205"),
            ("ai-generated", "AI generated task", "0366d6"),
        ]

        for label_name, description, color in required_labels:
            try:
                check = subprocess.run(
                    ["gh", "label", "list", "--json", "name"],
                    capture_output=True,
                    text=True
                )

                if check.returncode == 0:
                    existing_labels = json.loads(check.stdout)
                    label_exists = any(l["name"] == label_name for l in existing_labels)

                    if not label_exists:
                        subprocess.run(
                            ["gh", "label", "create", label_name,
                             "--description", description,
                             "--color", color],
                            capture_output=True
                        )
            except:
                pass  # Silently continue if label creation fails

    def create_error_issue(self, commit: str, error_text: str):
        """Create GitHub issue for build errors"""
        # Check if we already created an issue for this error
        error_hash = hash(error_text)
        recent_errors = [e for e in self.validation_history.get("errors", [])
                        if e.get("error_hash") == error_hash]

        if recent_errors:
            print("⚠️  Similar error already reported")
            return

        # Extract error details
        error_lines = [line for line in error_text.split('\n') if 'ERROR' in line]
        error_summary = error_lines[0] if error_lines else "Build verification failed"

        body = f"""## Automated Build Validation Error

**Commit:** `{commit}`
**Timestamp:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

### Error Output:
```
{error_text}
```

### Action Required:
This build error was detected by the automated validation agent. Please review and fix before proceeding.

---
*This issue was automatically created by the Validator Agent*
"""

        try:
            result = subprocess.run(
                ["gh", "issue", "create",
                 "--title", f"🚨 Build Error: {error_summary[:60]}",
                 "--body", body,
                 "--label", "build-error,urgent,ai-generated"],
                capture_output=True,
                text=True
            )

            if result.returncode == 0:
                issue_url = result.stdout.strip()
                print(f"📋 Created error issue: {issue_url}")

                # Log the error
                if "errors" not in self.validation_history:
                    self.validation_history["errors"] = []

                self.validation_history["errors"].append({
                    "timestamp": datetime.now().isoformat(),
                    "commit": commit,
                    "error_hash": error_hash,
                    "issue_url": issue_url
                })
                self.save_history()
        except Exception as e:
            print(f"⚠️  Failed to create error issue: {e}")

    def watch(self, interval: int = 60):
        """Continuously watch for changes and validate"""
        print(f"👁️  Validator Agent starting (checking every {interval}s)")
        print("Press Ctrl+C to stop\n")

        try:
            while True:
                current_commit = self.get_current_commit()

                # Only validate if commit changed
                if current_commit != self.last_commit:
                    self.validate_build()
                    self.last_commit = current_commit

                time.sleep(interval)
        except KeyboardInterrupt:
            print("\n\n👋 Validator Agent stopped")
            self.save_history()

def main():
    import sys
    agent = ValidatorAgent()

    if len(sys.argv) > 1 and sys.argv[1] == "once":
        # Single validation
        agent.validate_build()
    else:
        # Watch mode
        interval = int(sys.argv[1]) if len(sys.argv) > 1 else 60
        agent.watch(interval)

if __name__ == "__main__":
    main()
