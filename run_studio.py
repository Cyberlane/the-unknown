#!/usr/bin/env python3
"""
Legacy run_studio.py - now redirects to the new agent orchestrator
This file is kept for backward compatibility
"""

import subprocess
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent
ORCHESTRATOR = PROJECT_ROOT / "scripts/ai_tools/agent_orchestrator.py"

def main():
    print("🔄 Redirecting to new Agent Orchestrator...")
    print("=" * 60)

    # Forward any arguments to the orchestrator
    args = sys.argv[1:] if len(sys.argv) > 1 else []

    subprocess.run(["python3", str(ORCHESTRATOR)] + args)

if __name__ == "__main__":
    main()
