# Audio Assets

This directory contains audio files for the game.

## Required Audio Files

### SFX (Sound Effects)

**dimension_whoosh.ogg/wav** (sfx/)
- A short whoosh/swoosh sound effect for dimension transitions
- Duration: 0.3-0.5 seconds recommended
- The game will pitch-shift this sound for each dimension:
  - Normal: 1.0x (base pitch)
  - Viking: 0.85x (lower, heavier)
  - Aztec: 1.2x (higher, lighter)
  - Nightmare: 0.7x (lowest, ominous)

### Ambient Loops (Music/Atmosphere)

**ambient_normal.ogg** (ambient/)
- Calm, neutral ambient loop for Normal dimension
- Should loop seamlessly
- Duration: 30-60 seconds recommended
- Style: Peaceful, mysterious, exploration

**ambient_viking.ogg** (ambient/)
- Cold, atmospheric loop for Viking dimension
- Should loop seamlessly
- Style: Nordic, icy, wind sounds, distant chants

**ambient_aztec.ogg** (ambient/)
- Warm, mystical loop for Aztec dimension
- Should loop seamlessly
- Style: Jungle ambience, ancient instruments, mysterious

**ambient_nightmare.ogg** (ambient/)
- Dark, ominous loop for Nightmare dimension
- Should loop seamlessly
- Style: Unsettling, drones, whispers, horror ambience

**Note**: All ambient loops play simultaneously at -80db. When you switch dimensions,
the system cross-fades the active dimension to 0db over 2 seconds. This keeps all
loops in perfect sync for seamless transitions.

## Where to Get Free Audio

- **Freesound.org**: Search for "whoosh" or "swoosh" sounds
- **OpenGameArt.org**: Free game audio assets
- **Kenney.nl**: Free game assets including sound effects

## Adding Audio to the Game

### SFX (Dimension Whoosh)
1. Add your audio file to `audio/sfx/`
2. In Godot, navigate to the Player scene (`scenes/player/player.tscn`)
3. Select the Player node
4. In the Inspector, set the "Dimension Switch Sound" property to your audio file
5. The pitch variations will be applied automatically

### Ambient Loops
1. Add your 4 ambient loop files to `audio/ambient/`
2. In Godot, open the test scene (`scenes/test_scene.tscn`)
3. Select the "DimensionAmbientAudio" node
4. In the Inspector, under "Ambient Audio Loops":
   - Normal Ambient: Assign your normal loop
   - Viking Ambient: Assign your viking loop
   - Aztec Ambient: Assign your aztec loop
   - Nightmare Ambient: Assign your nightmare loop
5. Adjust "Crossfade Duration" if desired (default: 2.0 seconds)

## Audio Format Recommendations

- Use `.ogg` format for smaller file sizes (recommended)
- Use `.wav` for higher quality
- Sample rate: 44.1 kHz or 48 kHz
- Mono or stereo (mono recommended for SFX)
