#!/usr/bin/env python3
"""
Cleanup Agent - Removes malformed files and folders created by AI agents
Run this before continuing with other tasks
"""

import os
import shutil
from pathlib import Path
import re

PROJECT_ROOT = Path(__file__).parent.parent.parent

# Patterns that indicate malformed files/folders created by agents
MALFORMED_PATTERNS = [
    r'.*`.*',  # Contains backticks (markdown formatting)
    r'.*\*\*.*',  # Contains ** (markdown bold)
    r'^Path:.*',  # Starts with "Path:"
    r'^Updated .*',  # Starts with "Updated"
    r'^New File .*',  # Starts with "New File"
    r'^\d+\. .*',  # Starts with number and period (markdown list)
    r'if .* collision:.*',  # Looks like code snippet
    r'^if .*:.*',  # Looks like code (if statement)
    r'^python$',  # Just the word "python" with no extension
]

# Known good directories that should never be deleted
PROTECTED_DIRS = {
    '.git', '.godot', '.claude', '.aider.tags.cache.v4',
    'scenes', 'scripts', 'assets', 'audio', 'materials', 'docs',
    'addons', 'data'
}

# Known good file patterns
PROTECTED_FILE_PATTERNS = [
    r'.*\.gd$',  # GDScript files
    r'.*\.tscn$',  # Godot scene files
    r'.*\.tres$',  # Godot resource files
    r'.*\.md$',  # Markdown docs
    r'.*\.py$',  # Python scripts
    r'.*\.json$',  # JSON files
    r'.*\.yml$',  # YAML files
]

class CleanupAgent:
    def __init__(self, dry_run=True):
        self.dry_run = dry_run
        self.malformed_dirs = []
        self.malformed_files = []
        self.files_to_rescue = []  # Files with content that should be moved

    def is_malformed_name(self, name: str) -> bool:
        """Check if a file/folder name matches malformed patterns"""
        for pattern in MALFORMED_PATTERNS:
            if re.match(pattern, name):
                return True
        return False

    def is_protected(self, path: Path) -> bool:
        """Check if a path should be protected from deletion"""
        # Check if it's a protected directory
        if path.name in PROTECTED_DIRS:
            return True

        # Check if it's in a protected directory
        try:
            path.relative_to(PROJECT_ROOT / '.git')
            return True
        except ValueError:
            pass

        try:
            path.relative_to(PROJECT_ROOT / '.godot')
            return True
        except ValueError:
            pass

        return False

    def suggest_proper_location(self, filename: str) -> Path:
        """Suggest proper location for a file based on its name and type"""
        # GDScript files
        if filename.endswith('.gd'):
            if 'autoload' in filename.lower() or filename in ['event_bus.gd', 'editor_mode.gd', 'dimension_manager.gd']:
                return PROJECT_ROOT / 'scripts' / 'autoloads' / filename
            elif 'player' in filename.lower() or 'controller' in filename.lower():
                return PROJECT_ROOT / 'scripts' / 'player' / filename
            elif 'ui' in filename.lower() or 'overlay' in filename.lower() or 'hud' in filename.lower():
                return PROJECT_ROOT / 'scripts' / 'ui' / filename
            elif 'editor' in filename.lower():
                return PROJECT_ROOT / 'scripts' / 'editor' / filename
            else:
                return PROJECT_ROOT / 'scripts' / filename

        # Scene files
        elif filename.endswith('.tscn'):
            if 'ui' in filename.lower() or 'overlay' in filename.lower() or 'hud' in filename.lower():
                return PROJECT_ROOT / 'scenes' / 'ui' / filename
            elif 'player' in filename.lower():
                return PROJECT_ROOT / 'scenes' / 'player' / filename
            elif 'editor' in filename.lower():
                return PROJECT_ROOT / 'scenes' / 'editor' / filename
            else:
                return PROJECT_ROOT / 'scenes' / filename

        # Resource files
        elif filename.endswith('.tres'):
            return PROJECT_ROOT / 'assets' / 'configs' / filename

        # Shader files
        elif filename.endswith('.gdshader'):
            return PROJECT_ROOT / 'assets' / 'shaders' / filename

        # Default to scripts/
        return PROJECT_ROOT / 'scripts' / filename

    def rescue_useful_files(self, malformed_dir: Path):
        """Find files in malformed directory that have useful content"""
        for file_path in malformed_dir.rglob('*'):
            if file_path.is_file():
                # Check if file has substantial content (> 100 bytes)
                size = file_path.stat().st_size
                if size > 100:
                    proper_location = self.suggest_proper_location(file_path.name)

                    # Check if file doesn't already exist in proper location
                    if not proper_location.exists():
                        self.files_to_rescue.append((file_path, proper_location))
                        print(f"    🆘 File to rescue: {file_path.name} ({size} bytes)")
                        print(f"       → Should move to: {proper_location.relative_to(PROJECT_ROOT)}")

    def scan_for_malformed(self):
        """Scan the project root for malformed files and directories"""
        print("🔍 Scanning for malformed files and directories...")

        for item in PROJECT_ROOT.iterdir():
            # Skip protected items
            if self.is_protected(item):
                continue

            # Check if name is malformed
            if self.is_malformed_name(item.name):
                if item.is_dir():
                    self.malformed_dirs.append(item)
                    print(f"  📁 Found malformed directory: {item.name}")
                    # Check for files to rescue
                    self.rescue_useful_files(item)
                else:
                    self.malformed_files.append(item)
                    print(f"  📄 Found malformed file: {item.name}")

    def cleanup(self):
        """Remove all malformed files and directories"""
        total = len(self.malformed_dirs) + len(self.malformed_files)

        if total == 0:
            print("✅ No malformed files or directories found!")
            return

        print(f"\n{'🧪 DRY RUN - ' if self.dry_run else ''}Found {total} items to clean up:")
        print(f"  📁 Directories: {len(self.malformed_dirs)}")
        print(f"  📄 Files: {len(self.malformed_files)}")
        print(f"  🆘 Files to rescue: {len(self.files_to_rescue)}")

        if self.dry_run:
            print("\n⚠️  DRY RUN MODE - No files will be deleted")
            print("Run with --execute to actually delete these items\n")
        else:
            print("\n⚠️  EXECUTING CLEANUP - Files will be permanently deleted!\n")

        # First, rescue useful files
        if self.files_to_rescue:
            print("\n🆘 Rescuing useful files before cleanup...")
            for source, dest in self.files_to_rescue:
                try:
                    if self.dry_run:
                        print(f"  [DRY RUN] Would move: {source.name}")
                        print(f"            to: {dest.relative_to(PROJECT_ROOT)}")
                    else:
                        # Create destination directory if needed
                        dest.parent.mkdir(parents=True, exist_ok=True)
                        # Move file
                        shutil.copy2(source, dest)
                        print(f"  ✅ Rescued: {source.name} → {dest.relative_to(PROJECT_ROOT)}")
                except Exception as e:
                    print(f"  ❌ Error rescuing {source.name}: {e}")
            print()

        # Remove malformed directories
        for dir_path in self.malformed_dirs:
            try:
                if self.dry_run:
                    print(f"  [DRY RUN] Would delete directory: {dir_path.name}")
                    # Show what's inside
                    files = list(dir_path.rglob('*'))
                    if files:
                        print(f"    Contains {len(files)} items")
                else:
                    print(f"  🗑️  Deleting directory: {dir_path.name}")
                    shutil.rmtree(dir_path)
            except Exception as e:
                print(f"  ❌ Error deleting {dir_path.name}: {e}")

        # Remove malformed files
        for file_path in self.malformed_files:
            try:
                if self.dry_run:
                    print(f"  [DRY RUN] Would delete file: {file_path.name}")
                    # Show file size
                    size = file_path.stat().st_size
                    print(f"    Size: {size} bytes")
                else:
                    print(f"  🗑️  Deleting file: {file_path.name}")
                    file_path.unlink()
            except Exception as e:
                print(f"  ❌ Error deleting {file_path.name}: {e}")

        if not self.dry_run:
            print(f"\n✅ Cleanup complete! Removed {total} malformed items")
        else:
            print(f"\n💡 Run again with --execute to perform actual cleanup")

def main():
    import sys

    dry_run = True
    if len(sys.argv) > 1 and sys.argv[1] in ['--execute', '-x']:
        dry_run = False

    print("🧹 Cleanup Agent - Malformed File Detector\n")

    agent = CleanupAgent(dry_run=dry_run)
    agent.scan_for_malformed()
    agent.cleanup()

if __name__ == "__main__":
    main()
