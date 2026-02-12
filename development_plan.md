# THE UNKNOWN — Game Development Plan

**Engine:** Godot 4.x | **View:** First-Person 3D | **Genre:** Horror/Puzzle | **Player:** Single Player
**Dimensions:** Normal • Aztec • Viking • Nightmare

-----

## Project Overview

The Unknown is a first-person 3D horror/puzzle game. The player navigates dark, atmospheric levels while questioning their own sanity. A dimension-shifting mechanic lets the player traverse four parallel realities — Normal, Aztec, Viking, and Nightmare — each altering level geometry, aesthetics, puzzles, and threats. A pantheon of Gods with distinct personalities offers bargains, rewards, and betrayals. Permadeath with persistent consequences, a sanity/health dual-gauge system, and procedural level generation create a unique experience every run.

This plan is divided into 12 stages, each scoped to be achievable within limited Claude Pro conversation budgets. A built-in level editor (similar to Minecraft creative mode) ships from Stage 2 onward.

## Architecture Principles

- Modular scene composition — every system (dimension, God, enemy, trap) is its own scene/resource
- Event bus (Autoload singleton) for decoupled communication between systems
- Resource-based data (custom Resource classes) for Gods, enemies, traps, talismans, and dimension configs
- State machines for player, enemies, and game flow
- Shader-driven dimension switching with transition effects
- Save/load via serialized dictionaries (JSON) for level editor and permadeath persistence

## Folder Structure

```
res://
├── addons/          — third-party plugins
├── assets/          — textures, models, audio, shaders (subfolders per dimension)
├── scenes/          — player/, enemies/, traps/, levels/, ui/, editor/
├── scripts/         — autoloads/, components/, resources/, state_machines/
└── data/            — god_definitions/, enemy_definitions/, level_templates/
```

-----

## Stage 1 — Core Foundation & First-Person Controller

**Goal:** Playable first-person character in a test environment with basic interaction.
**Claude Sessions:** 2–3 conversations

### Tasks

- Project setup: Godot 4.x project, folder structure, .gitignore, export presets
- Event Bus autoload singleton (signal-based communication hub)
- First-person CharacterBody3D controller: WASD movement, mouse look, sprint, crouch, head bob
- Basic interaction system: raycast from camera, interact with Area3D triggers
- Placeholder test level: CSG boxes forming corridors and rooms, basic lighting
- Debug overlay (CanvasLayer): FPS, position, current state readouts
- Input map configuration for all planned actions

### Assets Needed

|Category|Asset                                            |Source / Notes                      |Priority|
|--------|-------------------------------------------------|------------------------------------|--------|
|Textures|Grid/prototype textures (floors, walls, ceiling) |Kenney Prototype Textures pack      |Now     |
|Fonts   |UI font (monospace for debug, sans-serif for HUD)|Google Fonts: Share Tech Mono, Inter|Now     |
|Audio   |Footstep placeholder sounds (4–6 variations)     |Freesound.org                       |Now     |

### Milestones

|Milestone                                      |Deliverable          |
|-----------------------------------------------|---------------------|
|Player can walk, sprint, crouch in test level  |CharacterBody3D scene|
|Raycast interaction picks up placeholder object|Interaction system   |
|Debug overlay shows live data                  |Debug HUD            |

-----

## Stage 2 — Level Editor (Creative Mode)

**Goal:** In-game level editor for placing geometry, objects, lights, and triggers on a 3D grid. This is your primary design tool going forward.
**Claude Sessions:** 3–4 conversations

### Tasks

- Editor mode toggle (separate game state) with free-fly camera and grid snapping
- Block palette system: wall, floor, ceiling, ramp, pillar, door frame — all CSG/MeshInstance3D
- Place, rotate, delete blocks with mouse. Ghost preview of placement
- Object palette: spawn points, interaction triggers, light sources, enemy spawn markers, trap markers
- Layer/dimension tagging — each placed object can be tagged to one or more dimensions (Normal, Aztec, Viking, Nightmare). Objects render only when that dimension is active
- Save/Load system: serialize level to JSON (block positions, rotations, tags, metadata)
- Quick-test button: switch from editor to play mode at a chosen spawn point, then return to editor
- Undo/redo stack (command pattern)
- Dimension toggle keybinds (1–4) for rapid preview in editor

### Assets Needed

|Category|Asset                                                       |Source / Notes             |Priority|
|--------|------------------------------------------------------------|---------------------------|--------|
|UI      |Editor icons (place, delete, rotate, save, load, play, undo)|Kenney Game Icons or Lucide|Now     |
|Textures|Colour-coded dimension overlay materials (translucent tints)|Create in Godot shader     |Now     |

### Milestones

|Milestone                                                |Deliverable           |
|---------------------------------------------------------|----------------------|
|Can build a multi-room level with the editor             |Editor scene + palette|
|Save level to JSON, reload it perfectly                  |Serialization system  |
|Tag blocks to dimensions, toggle visibility with 1–4 keys|Dimension layer system|
|Quick-test: play from editor, return to editor           |Mode switching        |

-----

## Stage 3 — Dimension System & Visual Switching

**Goal:** Full dimension-switching mechanic with distinct visual identities and transition effects. In-game switching via a held item; editor switching via keybind.
**Claude Sessions:** 3–4 conversations

### Dimension Design

- **Normal:** Contemporary/neutral. Concrete, metal, fluorescent lighting. Baseline reality.
- **Aztec:** Stone temples, gold accents, jungle vines, warm amber/green lighting. Sacrificial motifs.
- **Viking:** Rough-hewn wood, iron, snow particles, cold blue/grey lighting. Runic carvings.
- **Nightmare:** Organic/fleshy surfaces, impossible geometry, distorted audio, red/black palette. Sanity-draining.

### Tasks

- DimensionManager autoload: tracks current dimension, emits signals on change
- Per-dimension material sets: each block type has 4 material variants swapped at runtime
- Dimension item (held object): player equips it, uses it to cycle/select dimensions
- Transition shader: screen-space dissolve/warp effect during switch (approx. 1–2 seconds)
- Post-processing per dimension: color grading, vignette intensity, fog density/color via WorldEnvironment
- Dimension-specific ambient audio layers (crossfade on switch)
- Geometry differences: some blocks only exist in certain dimensions (tagged in editor). Enables puzzles where a wall blocks you in Normal but is absent in Viking
- Physics recalculation on switch: update collision shapes for dimension-specific geometry

### Assets Needed

|Category|Asset                                                   |Source / Notes         |Priority       |
|--------|--------------------------------------------------------|-----------------------|---------------|
|Textures|Normal dimension: concrete, metal, tile (PBR, tileable) |Poly Haven / AmbientCG |Now            |
|Textures|Aztec dimension: carved stone, gold, jungle vine (PBR)  |AmbientCG + custom     |Now            |
|Textures|Viking dimension: wood plank, iron, snow/ice (PBR)      |AmbientCG + custom     |Now            |
|Textures|Nightmare dimension: organic/flesh, corruption (PBR)    |Custom or Texture Haven|Now            |
|Shaders |Transition dissolve/warp shader                         |Write custom (GLSL)    |Now            |
|Shaders |4 post-processing profiles (color grade, fog, vignette) |Write custom           |Now            |
|Audio   |4 ambient loops (one per dimension, ~2 min each)        |Freesound / commission |Start sourcing |
|Audio   |Dimension switch SFX (whoosh/warp sound)                |Freesound              |Now            |
|Model   |Dimension-switching held item (placeholder: glowing orb)|Kenney or CSG sphere   |Placeholder now|

### Milestones

|Milestone                                             |Deliverable                    |
|------------------------------------------------------|-------------------------------|
|Switch dimensions in-game with held item              |DimensionManager + item scene  |
|All 4 dimensions have distinct visuals                |Material sets + post-processing|
|Transition shader plays on switch                     |Screen-space shader            |
|Blocks tagged to dimensions appear/disappear correctly|Geometry toggling              |
|Ambient audio crossfades between dimensions           |Audio layer system             |

-----

## Stage 4 — Health, Sanity & HUD Systems

**Goal:** Dual health/sanity gauge system with gameplay effects. Full HUD with diegetic and screen-space elements.
**Claude Sessions:** 2–3 conversations

### Tasks

- PlayerStats autoload/component: health (0–100), sanity (0–100), signals for changes
- Health effects: below 50 = movement speed reduced proportionally. Below 20 = screen desaturation, laboured breathing audio
- Sanity effects: below 70 = occasional visual glitches (shader). Below 40 = phantom enemies appear (non-damaging hallucinations). Below 20 = severe distortion, audio hallucinations, false UI elements
- Sanity hallucination system: spawn transparent enemy meshes that vanish on approach. Whisper audio cues
- HUD design: health bar (red, bottom-left), sanity meter (purple, bottom-right), dimension indicator (top-centre), interaction prompt (centre-bottom)
- Screen damage overlay: red vignette pulse on health damage, purple/static on sanity damage
- Water phone instrument stinger sounds on sanity events

### Assets Needed

|Category|Asset                                                              |Source / Notes             |Priority       |
|--------|-------------------------------------------------------------------|---------------------------|---------------|
|Audio   |Heartbeat loop (layered, speeds up at low health)                  |Freesound                  |Now            |
|Audio   |Breathing sounds (normal, laboured, panicked)                      |Freesound / record         |Now            |
|Audio   |Whisper/hallucination audio (4–6 clips)                            |Freesound / commission     |Now            |
|Audio   |Water phone stingers (3–4 variations)                              |Commission or sample pack  |Start sourcing |
|Shaders |Sanity glitch shader (chromatic aberration, scan lines, distortion)|Write custom               |Now            |
|Shaders |Damage overlay shader (red pulse, purple static)                   |Write custom               |Now            |
|UI      |Health bar, sanity meter, dimension indicator sprites/designs      |Design in Figma or Inkscape|Now            |
|Model   |Hallucination enemy placeholder (dark humanoid silhouette)         |Mixamo or simple mesh      |Placeholder now|

-----

## Stage 5 — Enemy System & AI

**Goal:** Modular enemy framework with at least two core enemy types. Navigation, state machines, and player interaction.
**Claude Sessions:** 3–4 conversations

### Tasks

- EnemyBase class (CharacterBody3D): state machine (Idle, Patrol, Chase, Attack, Stunned, Dead), NavigationAgent3D
- EnemyResource (custom Resource): health, speed, damage type (health/sanity/both), dimension affinity, folklore origin, loot table
- Zombie Type: slow patrol, grabs player on contact (grapple state), drains health over time, player must mash to escape. Reduces player speed while held
- Lurker Type: stationary or slow roam. Proximity/line-of-sight triggers sanity drain. Scream attack: directional audio burst causes large sanity hit. Does not physically damage
- Enemy spawner system: reads spawn markers from level editor, respects dimension tags (some enemies only in certain dimensions)
- Folklore-inspired visual design notes for future enemy types (Wendigo, Draugr, Quetzalcoatl servant, Shadow, etc.)
- Enemy integration with God system (placeholder hooks): God buffs/debuffs to enemy stats
- Death/ragdoll system for enemies

### Assets Needed

|Category |Asset                                                   |Source / Notes                 |Priority      |
|---------|--------------------------------------------------------|-------------------------------|--------------|
|Models   |Zombie enemy (rigged, animated: idle, walk, grab)       |Mixamo + Blender or asset store|Start sourcing|
|Models   |Lurker enemy (rigged, animated: idle, scream)           |Mixamo + Blender or asset store|Start sourcing|
|Audio    |Zombie groans, shuffling (4–6 variations)               |Freesound                      |Now           |
|Audio    |Lurker scream/shriek (2–3 variations)                   |Freesound / commission         |Now           |
|Audio    |Grapple struggle sounds                                 |Freesound                      |Now           |
|VFX      |Sanity drain visual (purple particle aura around Lurker)|Godot GPUParticles3D           |Now           |
|Animation|Player grapple struggle (first-person arms)             |Custom or Mixamo               |Stage 8       |

-----

## Stage 6 — Trap System

**Goal:** Modular trap framework with three core trap types. Editor integration for placement and configuration.
**Claude Sessions:** 2–3 conversations

### Tasks

- TrapBase class (Node3D): triggered vs. continuous, damage type (health/sanity/both), dimension affinity, reset timer
- TrapResource (custom Resource): damage amount, trigger radius, cooldown, linked dimension, visual/audio cues
- Gas Trap: area-of-effect cloud. Some variants drain health (green gas), some drain sanity (purple haze). Particle system + area damage
- Projectile Trap: wall/ceiling mounted, fires on player proximity or timer. Health damage. Some have poison coating (additional sanity DoT)
- Enemy Trap: container that, when triggered, releases one or more enemies into the level. Cage/door animation
- Trap placement in editor: select trap type, configure properties in inspector panel, place on grid
- Trap indicators: subtle environmental cues (discoloured floor tiles, small holes in walls) so observant players can avoid them
- God protection hooks: placeholder for God-granted trap immunity per level

### Assets Needed

|Category|Asset                                                           |Source / Notes           |Priority       |
|--------|----------------------------------------------------------------|-------------------------|---------------|
|VFX     |Gas cloud particle (green health variant, purple sanity variant)|Godot GPUParticles3D     |Now            |
|VFX     |Projectile trail + impact effect                                |Godot GPUParticles3D     |Now            |
|Models  |Dart/arrow projectile                                           |Low-poly custom or Kenney|Placeholder now|
|Models  |Gas vent (floor/wall mounted)                                   |Low-poly custom          |Placeholder now|
|Models  |Enemy cage/container (animated door)                            |Low-poly custom          |Placeholder now|
|Audio   |Gas hiss loop                                                   |Freesound                |Now            |
|Audio   |Dart whoosh + impact                                            |Freesound                |Now            |
|Audio   |Cage breaking/opening                                           |Freesound                |Now            |

-----

## Stage 7 — God System & Talisman Rooms

**Goal:** Full God bargain/betrayal system, favour gauges, talisman-gated rooms, and God-driven level modifiers.
**Claude Sessions:** 4–5 conversations

### Tasks

- GodResource (custom Resource): name, personality archetype (trickster, honourable, vengeful, etc.), associated dimension, favour gauge (-100 to +100), reward pool, punishment pool, lie probability
- 4–6 unique Gods, each loosely tied to a dimension or folklore tradition
- God interaction UI: conversation wheel for accepting/declining offers. Dialogue trees stored as JSON/Resource
- Favour gauge system: visible UI meters showing relationship with each God. Affects next-level generation
- God offers: before or during a level, a God can propose a bargain (e.g., destroy another God’s altar, kill their avatar). Reward or lie outcome based on God’s personality + RNG
- Betrayal system: accept one God’s offer, then complete it for a different God. Triggers punishment from betrayed God, reward/lie from receiving God
- Punishment effects: enemies gain health/speed, more traps, enemy type reinforcements
- Reward effects: enemies slower, player faster, fewer traps, immunity to certain trap/enemy types
- Talisman system: coloured talismans (Red = pure, Purple = impure, others as needed). Gate specific rooms
- Red talisman: grants room access but disables player attack within that room
- Purple talisman: grants access + attack, but talisman/suit degrades over time (durability bar)
- God altars and avatars: placeable in editor, targetable for God quest objectives

### Assets Needed

|Category|Asset                                         |Source / Notes                   |Priority      |
|--------|----------------------------------------------|---------------------------------|--------------|
|UI      |Conversation wheel / dialogue UI              |Custom (design in Godot or Figma)|Now           |
|UI      |God favour gauge bars (one per God, coloured) |Custom                           |Now           |
|Models  |God altars (4–6 unique, dimension-themed)     |Commission or asset store        |Start sourcing|
|Models  |God avatar entities (4–6, folklore-inspired)  |Commission or asset store        |Start sourcing|
|Models  |Talisman items (Red, Purple, others)          |Low-poly custom                  |Now           |
|Audio   |God voice lines or stingers (unique per God)  |Commission or TTS + processing   |Start sourcing|
|Audio   |Altar interaction sounds                      |Freesound                        |Now           |
|VFX     |Talisman glow/aura (red, purple)              |Godot shaders + particles        |Now           |
|VFX     |Talisman degradation visual (cracking, fading)|Shader                           |Now           |

-----

## Stage 8 — Combat, Items & Player Abilities

**Goal:** Player combat mechanics, inventory system, usable items, and dimension-switching item upgrade path.
**Claude Sessions:** 3–4 conversations

### Tasks

- Melee combat: first-person arm animations, attack hitbox, damage calculation, enemy knockback
- Weapon types: basic (fists), blunt (club/torch), bladed. Each with different speed/damage/range
- Inventory system: limited slots, quick-select bar (1–4 items + dimension item)
- Dimension item progression: initially found in specific locations each level. Later levels allow player to carry it between levels
- Consumable items: health potion, sanity tonic, talisman charges
- Loot system: enemies drop items on death, chests in rooms, dead player body loot (permadeath)
- First-person arms/hands: viewmodel with animation states (idle, walk, attack, interact, hold item)
- Character selection screen: choose from X characters, each with stat modifiers (more health but less sanity, faster but frailer, etc.)

### Assets Needed

|Category |Asset                                                                |Source / Notes               |Priority      |
|---------|---------------------------------------------------------------------|-----------------------------|--------------|
|Models   |First-person arms (rigged, multi-animation)                          |Mixamo / custom Blender      |Now — critical|
|Models   |Weapons: torch, club, knife/blade (low-poly)                         |Kenney Weapons pack or custom|Now           |
|Models   |Consumable items: potion bottles, tonic vials                        |Kenney or custom             |Now           |
|Models   |Loot chest (animated open/close)                                     |Kenney or custom             |Now           |
|Models   |Dimension-switching item (final design replacing placeholder)        |Custom / commission          |Now           |
|Audio    |Melee swing, impact sounds (per weapon type)                         |Freesound                    |Now           |
|Audio    |Item pickup, consume, equip sounds                                   |Freesound                    |Now           |
|Animation|First-person arm animations (idle, walk, attack per weapon, interact)|Blender / Mixamo             |Now — critical|
|UI       |Inventory grid, item tooltips, quick-select bar                      |Custom Godot UI              |Now           |

-----

## Stage 9 — Procedural Level Generation

**Goal:** Procedural level generator that respects dimension rules, God favour modifiers, and supports permadeath continuity.
**Claude Sessions:** 3–4 conversations

### Tasks

- Room template library: hand-design 20–30 room templates in the level editor, tagged with properties (combat, puzzle, trap, safe, altar, boss)
- Graph-based level generator: generate a connectivity graph (rooms as nodes, corridors as edges), then stamp room templates
- God influence on generation: favour gauges modify enemy count, trap density, room difficulty distribution, loot quality
- Dimension-specific rooms: some templates only appear in certain dimensions, creating exploration incentives
- Talisman room placement: coloured talisman-gated rooms with guaranteed rewards or God altars
- Permadeath integration: on death, record current level seed + player death position. New run starts at that level (their level 1) with the previous player’s body as lootable (minus talismans/amulets)
- Seed system: deterministic generation from seed for reproducibility and sharing
- Difficulty scaling: deeper levels increase base difficulty, modified by God favour

### Assets Needed

|Category  |Asset                                                                |Source / Notes               |Priority      |
|----------|---------------------------------------------------------------------|-----------------------------|--------------|
|Models    |Corridor connector pieces (straight, L-bend, T-junction, door frames)|Build from existing block set|Now           |
|Models    |Dead player body prop (lootable)                                     |Mixamo ragdoll or custom     |Now           |
|Textures  |Room-type indicator decorations (weapon racks, runes, etc.)          |Custom or asset store        |Stage 10      |
|Level Data|20–30 hand-designed room templates (JSON from editor)                |Design in your editor        |Now — critical|

-----

## Stage 10 — Final Art Pass & Dimension Polish

**Goal:** Replace all placeholder assets with final-quality models, textures, and audio. Each dimension feels like a fully realised world.
**Claude Sessions:** 2–3 conversations (mostly asset integration, less code)

### Tasks

- Replace all CSG/prototype geometry with final modular environment meshes (walls, floors, pillars, doors, decorations) per dimension
- Final PBR material pass: normal maps, roughness, metallic, emission for all surfaces
- Lighting pass per dimension: baked lightmaps or LightmapGI, placed light sources (torches, fluorescents, bioluminescence, etc.)
- Decals and detail meshes: cobwebs, blood stains, runes, carvings, vines, snow, bone piles
- Final enemy models with full animation sets (per folklore origin)
- Final trap models and VFX
- Environmental storytelling props: books, notes, murals, carvings that hint at lore
- Destructible/trackable objects: snow footprints (Viking), sand displacement (Aztec), flesh deformation (Nightmare) — inspired by Astro Bot/Luigi’s Mansion

### Assets Needed — Comprehensive Final List

|Category   |Asset                                                                       |Source / Notes           |Priority|
|-----------|----------------------------------------------------------------------------|-------------------------|--------|
|Environment|Modular wall/floor/ceiling kit — Normal dimension (20–30 pieces)            |Asset store / commission |Critical|
|Environment|Modular wall/floor/ceiling kit — Aztec dimension (20–30 pieces)             |Asset store / commission |Critical|
|Environment|Modular wall/floor/ceiling kit — Viking dimension (20–30 pieces)            |Asset store / commission |Critical|
|Environment|Modular wall/floor/ceiling kit — Nightmare dimension (20–30 pieces)         |Asset store / commission |Critical|
|Props      |Decorative props per dimension (20+ each): furniture, containers, wall decor|Asset store / commission |High    |
|Props      |Lore props: readable notes, murals, carvings (10–15)                        |Custom 2D art + 3D frames|High    |
|Enemies    |Final rigged+animated models for all enemy types (4–8 types)                |Commission / asset store |Critical|
|VFX        |Environmental particles: dust, embers, snow, spores, dripping               |Godot GPUParticles3D     |High    |
|Shaders    |Trackable surfaces: snow deformation, sand displacement, flesh deformation  |Custom compute shaders   |High    |
|Audio      |Final ambient loops per dimension (3–5 min, seamless)                       |Commission / purchase    |Critical|
|Audio      |Final music tracks (menu, gameplay per dimension, boss, death)              |Commission               |Critical|
|Audio      |Full SFX library: all enemies, traps, UI, environment (100+ sounds)         |Freesound + commission   |Critical|

-----

## Stage 11 — UI, Menus, Narrative & Progression

**Goal:** Complete game flow from main menu through gameplay to death/restart. Narrative elements, tutorials, and settings.
**Claude Sessions:** 2–3 conversations

### Tasks

- Main menu: new game, continue (if permadeath save exists), settings, quit. Atmospheric background (3D scene or animated art)
- Character selection screen: display characters with stat previews, lore blurbs
- Settings menu: graphics (resolution, quality, FOV), audio (master, music, SFX, ambience sliders), controls (rebindable), accessibility
- Pause menu: resume, settings, quit to menu
- Death screen: show how you died, stats, God relationships, offer to start new run
- Narrative system: environmental text pop-ups, readable notes/books, lore collectibles
- Tutorial system: first run teaches controls, dimension switching, sanity, God interactions via guided level
- Permadeath save file management: encrypted save storing death level, body position, loot, God relationships
- Conversation wheel polish: radial menu for God dialogues with timed responses

### Assets Needed

|Category|Asset                                                   |Source / Notes     |Priority|
|--------|--------------------------------------------------------|-------------------|--------|
|UI      |Main menu background (3D scene or illustration)         |Custom / commission|Now     |
|UI      |Character portraits/art (one per selectable character)  |Commission         |Now     |
|UI      |Menu button styles, transitions, loading screens        |Custom Godot theme |Now     |
|UI      |Death screen art/animation                              |Custom             |Now     |
|Audio   |Menu music (atmospheric, 2–3 min loop)                  |Commission         |Now     |
|Audio   |UI sounds: button hover, click, transition whoosh       |Freesound          |Now     |
|Writing |Lore documents, God dialogue scripts, environmental text|Write or commission|Now     |

-----

## Stage 12 — Polish, Optimization & Release Prep

**Goal:** Final polish pass, performance optimization, bug fixing, and export-ready build.
**Claude Sessions:** 2–3 conversations

### Tasks

- Performance profiling: identify bottlenecks with Godot’s built-in profiler and monitors
- Occlusion culling setup for procedural levels
- LOD (Level of Detail) for all 3D models
- Audio optimization: streaming for long tracks, pooling for SFX
- Memory management: resource loading/unloading between levels
- Extensive playtesting: balance God rewards/punishments, enemy difficulty curves, sanity drain rates, loot distribution
- Bug fixing pass: edge cases in dimension switching, procedural generation, permadeath saves
- Accessibility review: subtitles, colorblind modes, input remapping verification, screen reader support for menus
- Export configuration: Windows, Linux, (Mac if applicable). Build pipeline
- Steam/Itch.io page preparation: screenshots, trailer capture, store descriptions
- Analytics hooks (optional): anonymous telemetry for balancing (death locations, God choices, dimension usage)

### Final Checklist

|Milestone                                               |Deliverable          |
|--------------------------------------------------------|---------------------|
|All placeholder assets replaced with final art          |Visual audit         |
|60 FPS stable on target hardware                        |Performance profiling|
|All God interactions balanced and tested                |Gameplay testing     |
|Permadeath loop feels fair and compelling               |Playtest feedback    |
|Sanity system creates genuine unease without frustration|Playtest feedback    |
|Level editor can produce diverse, interesting levels    |Designer testing     |
|Save/load works flawlessly across all systems           |Automated tests      |
|All 4 dimensions feel distinct and immersive            |Art/audio review     |
|Exported builds run on target platforms                 |QA builds            |

-----

## Appendix A — Asset Acquisition Timeline

### Stages 1–2: Prototype Phase

- Kenney Prototype Textures (free) — grid/dev textures for blocks
- Google Fonts: Share Tech Mono, Inter — debug + UI fonts
- Footstep placeholder audio (Freesound)
- Editor UI icons (Kenney Game Icons or Lucide — both free)

### Stage 3: Dimension Visuals

- PBR texture sets for all 4 dimensions (Poly Haven, AmbientCG — free; or purchase packs)
- 4 ambient audio loops — begin commissioning or sourcing (budget ~$50–200 per track if commissioned)
- Dimension switch SFX (Freesound)

### Stages 4–6: Gameplay Systems

- Heartbeat, breathing, whisper audio (Freesound — free)
- Water phone sample pack — commission or purchase ($30–100)
- Enemy models (Zombie, Lurker) — begin commissioning or sourcing from asset stores ($20–60 each)
- Trap model placeholders (build from CSG or low-poly in Blender)

### Stages 7–8: Depth Systems

- God altar and avatar models (4–6) — commission ($100–300 each) or asset store
- God voice lines or stingers — commission voice actors or use TTS + heavy processing
- First-person arms model (rigged, animated) — critical, commission or Mixamo ($0–200)
- Weapon models (torch, club, blade) — Kenney Weapons (free) or purchase

### Stage 9: Level Generation

- 20–30 hand-designed room templates (you create these in your own editor)
- Corridor connector meshes (build from modular kit)
- Dead player body prop (Mixamo ragdoll or custom — free/$)

### Stage 10: Final Art

- 4 modular environment kits (20–30 pieces each) — largest art investment (~$200–800 per kit if commissioned)
- Decorative props (80+ total across dimensions) — asset store bundles or commission
- Final enemy models with full animations (4–8 types) — commission ($150–400 each)
- Final music tracks (6–10 tracks) — commission ($100–500 per track)
- Full SFX library (100+ sounds) — Freesound + purchased packs + commissions
- Trackable surface shaders (snow, sand, flesh) — custom development

### Stages 11–12: Polish

- Character portraits / selection art — commission ($50–200 per character)
- Menu background art/scene
- Lore writing (in-game documents, God dialogue)
- Marketing assets: screenshots, trailer, store page copy

-----

## Appendix B — Technical Reference

### Key Autoloads

- **EventBus:** Central signal hub. Systems emit and listen here. Avoids hard dependencies.
- **DimensionManager:** Tracks active dimension, emits dimension_changed signal, manages material/environment swaps.
- **PlayerStats:** Health, sanity, movement modifiers. Emits signals for HUD and effect systems.
- **GodManager:** Tracks favour gauges for all Gods, processes offers/betrayals, modifies level generation params.
- **GameState:** Current run data, permadeath persistence, level tracking, save/load orchestration.

### Custom Resource Types

- **EnemyResource:** name, base_health, speed, damage_type, damage_amount, dimension_affinity, folklore_origin, loot_table, model_path, animations
- **TrapResource:** name, trap_type (gas/projectile/enemy), damage_type, damage_amount, trigger_radius, cooldown, dimension_affinity, model_path
- **GodResource:** name, personality, dimension, lie_probability, reward_pool[], punishment_pool[], dialogue_tree_path, altar_model, avatar_model
- **TalismanResource:** colour, purity (bool), durability, grants_attack (bool), degradation_rate, associated_god
- **LevelTemplate:** room_type, blocks[], spawn_points[], traps[], dimension_tags[], connections[]

### Dimension Switching Flow

1. Player activates dimension item (or presses 1–4 in editor)
1. DimensionManager receives request, validates (can player switch? cooldown?)
1. Transition shader begins (screen effect, audio crossfade starts)
1. DimensionManager emits `pre_dimension_change` signal
1. All dimension-tagged nodes check their tags, toggle visibility/collision
1. Material swap system replaces surface materials on shared geometry
1. WorldEnvironment updates (fog, color grading, vignette)
1. Post-processing shader adjusts
1. DimensionManager emits `dimension_changed` signal
1. Transition shader completes. Player is in new dimension

-----

## Appendix C — Enemy & Folklore Reference

|Enemy     |Folklore Origin   |Dimension         |Behaviour                       |
|----------|------------------|------------------|--------------------------------|
|Zombie    |Global            |Normal            |Slow, grabs, drains health      |
|Lurker    |Lovecraftian      |Nightmare         |Proximity sanity drain, scream  |
|Draugr    |Norse             |Viking            |Armoured, strong melee, slow    |
|Nagual    |Aztec shapeshifter|Aztec             |Disguises as objects, ambush    |
|Wendigo   |Algonquian        |Viking / Nightmare|Fast, health + sanity damage    |
|Cihuateteo|Aztec spirit      |Aztec             |Sanity drain aura, floats       |
|Shadow    |Universal         |Nightmare         |Invisible until low sanity, fast|
|Hel-Walker|Norse underworld  |Viking            |Summons lesser enemies          |
