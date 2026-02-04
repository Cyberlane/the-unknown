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

## Where to Get Free Audio

- **Freesound.org**: Search for "whoosh" or "swoosh" sounds
- **OpenGameArt.org**: Free game audio assets
- **Kenney.nl**: Free game assets including sound effects

## Adding Audio to the Game

1. Add your audio file to `audio/sfx/`
2. In Godot, navigate to the Player scene (`scenes/player/player.tscn`)
3. Select the Player node
4. In the Inspector, set the "Dimension Switch Sound" property to your audio file
5. The pitch variations will be applied automatically

## Audio Format Recommendations

- Use `.ogg` format for smaller file sizes (recommended)
- Use `.wav` for higher quality
- Sample rate: 44.1 kHz or 48 kHz
- Mono or stereo (mono recommended for SFX)
