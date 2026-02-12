# 🛠️ Cyberlane/the-unknown: Master Task List

**Project Goal:** High-performance Godot 4 action-platformer.
**Standard:** GDScript 2.0 (static typing required), Godot 4.x.

## Phase 1: Planning & Setup (Manager Agent)

- [ ] **Task 101:** Audit `development_plan.md`.
  - _Action:_ Break down Phase 1 into 5 granular issues in `task_list.md`.
  - _Constraint:_ Each task must take <10 minutes of AI execution time.
- [ ] **Task 102:** Initialize Repository Structure.
  - _Action:_ Ensure `/assets`, `/scripts`, and `/scenes` folders exist.
  - _Constraint:_ Use `gh repo view` to verify remote sync.

## Phase 2: Core Execution (Architect & Art Director)

- [ ] **Task 201: Player Movement Controller**
  - _Issue:_ `gh issue create --title "Implement Player WASD" --body "Use CharacterBody3D"`
  - _Requirement:_ Clean code with `export` variables for speed/friction.
  - _Asset:_ Run `scripts/ai_tools/fetch_asset.py "low poly character"` if no placeholder exists.
- [ ] **Task 202: Environment Blockout**
  - _Issue:_ `gh issue create --title "Level 1 Prototype"`
  - _Tool:_ Use `scripts/ai_tools/fetch_asset.py` to fetch "concrete floor" and "crate".

## Phase 3: Validation (Supervisor Agent)

- [ ] **Verification Loop:**
  - [ ] Run `godot --headless --check-only` after every commit.
  - [ ] If check fails, revert commit and append error log to GitHub Issue.
