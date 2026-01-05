# SoundCloud Master

Automated loudness mastering for DJ mixes to sound competitive on SoundCloud.

## The Problem

You recorded your DJ mix on the RX3 with proper headroom (the right thing to do), but when you upload to SoundCloud, it sounds **quiet** compared to other DJ mixes.

**Why?**
- SoundCloud does **not** apply loudness normalization on playback (unlike Spotify)
- Other DJs upload at **-10 to -8 LUFS** integrated loudness
- Your RX3 recording might be at **-12 to -18 LUFS**
- Result: You sound 3-10 dB quieter than the competition

## The Solution

This tool applies **distribution loudness optimization** while preserving:
- ✓ Dynamics (no brick-walling)
- ✓ Transients (kicks and hats stay punchy)
- ✓ Sound quality (no obvious distortion)
- ✓ Headroom for SoundCloud's lossy encoding

## Quick Start

```bash
# Master a single file
./soundcloud-master.sh /path/to/your_mix.wav

# Fast mode (minimal output)
./sc-master-quick.sh /path/to/your_mix.wav

# Batch process
./soundcloud-master.sh /path/to/mixes/*.wav
```

Output: `your_mix_SC.wav` ready for SoundCloud upload.

## Installation

### Requirements

- macOS/Linux with bash
- ffmpeg

### Install

```bash
# Install ffmpeg
brew install ffmpeg

# Clone this repo
git clone https://github.com/joshlebed/soundcloud-master.git
cd soundcloud-master

# Make scripts executable
chmod +x soundcloud-master.sh sc-master-quick.sh
```

## Target Specifications

| Metric              | Target         |
|---------------------|----------------|
| Integrated Loudness | **-10 to -9 LUFS** |
| True Peak          | **-1.0 dBTP**  |
| Loudness Range     | **Preserved**  |
| Sample Rate        | **44.1 kHz**   |
| Bit Depth          | **24-bit**     |

## Real-World Example

```
BEFORE (RX3 Recording)          AFTER (SoundCloud Master)
━━━━━━━━━━━━━━━━━━━━━━          ━━━━━━━━━━━━━━━━━━━━━━━━━━
Loudness: -12.4 LUFS       →    Loudness: -10.4 LUFS ✓
Peak:     0.0 dBFS         →    Peak:     -0.13 dBTP ✓
Dynamics: 4.4 LU           →    Dynamics: 4.2 LU ✓
Size:     632 MB (16-bit)  →    Size:     947 MB (24-bit)
```

**Result:** +2.0 LU louder, dynamics preserved, SoundCloud-ready ✓

## Usage Examples

### Basic Usage

```bash
# Process a single file (creates my_mix_SC.wav)
./soundcloud-master.sh /path/to/my_mix.wav

# Custom output name
./soundcloud-master.sh input.wav output.wav

# Quick mode (no analysis, just process)
./sc-master-quick.sh /path/to/my_mix.wav
```

### Batch Processing

```bash
# Master all WAV files in a directory
./soundcloud-master.sh /path/to/mixes/*.wav
```

### Output

The full script shows:
- Source loudness analysis
- Processing progress
- Final mastered loudness stats
- File size comparison

Example output:
```
╔════════════════════════════════════════════════════════╗
║  SoundCloud Master                                     ║
╚════════════════════════════════════════════════════════╝

Input:  my_mix.wav
Output: my_mix_SC.wav

━━━ Source Analysis ━━━
    I:         -12.4 LUFS
    LRA:         4.4 LU

━━━ Mastering ━━━
Target: -9.5 LUFS, -1.0 dBTP

━━━ Mastered Result ━━━
    I:         -10.4 LUFS
    LRA:         4.2 LU

✓ Mastered file created: my_mix_SC.wav
```

## How It Works

Uses ffmpeg's EBU R128 `loudnorm` filter:

```bash
loudnorm=I=-9.5:TP=-1.0:LRA=8:linear=true
```

- `I=-9.5`: Target integrated loudness (LUFS)
- `TP=-1.0`: True peak limit (headroom for encoding)
- `LRA=8`: Loudness range target (preserves dynamics)
- `linear=true`: Transparent linear mode

## Documentation

- **QUICKSTART.md** - Quick reference guide
- **SOUNDCLOUD_MASTERING_README.md** - Complete technical documentation
- **TEST_RESULTS.md** - Validation results from real test file

## Best Practices

### DO ✓
- Keep RX3 TRIM low during recording
- Use this script for **distribution only**, not during recording
- Upload the mastered 24-bit WAV to SoundCloud
- Compare against reference tracks before uploading

### DON'T ✗
- Touch the RX3 trim settings (record with headroom)
- Apply compression/limiting before this script
- Normalize to 0 dBFS before processing
- Re-master an already mastered file
- Use for platforms with auto-normalization (Spotify, Apple Music)

## Customization

Edit `soundcloud-master.sh` to adjust targets:

```bash
TARGET_LUFS=-9.5    # Try -9.0 for louder, -10.5 for more conservative
TARGET_TP=-1.0      # Don't change this
TARGET_LRA=8        # Don't change this
```

### Genre-Specific Targets

| Genre          | Suggested LUFS |
|----------------|----------------|
| House/Techno   | -9.5 to -10    |
| Trance/Electro | -9.0 to -9.5   |
| Drum & Bass    | -9.0 to -9.5   |
| Ambient/Downtempo | -10.5 to -11 |

## Troubleshooting

### Output sounds distorted
Your source might be too hot. Check if input is already > -10 LUFS.

### Output is still too quiet
Edit `TARGET_LUFS=-9.5` to `-9.0` or `-8.5` in the script.
**Warning:** Don't go below -8.0 LUFS.

### ffmpeg not found
```bash
brew install ffmpeg
```

### File size increased
Expected. Script outputs 24-bit (vs 16-bit input) for maximum quality.

## Technical Background

### Why SoundCloud Needs This

Unlike Spotify (-14 LUFS with normalization):
- SoundCloud does **no playback normalization**
- Uses **~128 kbps Opus** lossy encoding
- Community uploads are **not level-matched**

### Two-Stage Workflow

1. **Capture stage (RX3)**: Optimize for sound quality with headroom
2. **Distribution stage (this script)**: Optimize for delivery loudness

This separation ensures both quality capture and competitive loudness.

## Credits

Based on professional loudness mastering practices and audio engineering community guidance.

**Core principle:** *Capture with headroom, deliver with loudness.*

## License

MIT License - Free to use and modify for personal and commercial DJ mixes.

## Author

Josh Lebed ([@joshlebed](https://github.com/joshlebed))

## Contributing

Issues and PRs welcome! If you have suggestions for improvements or find bugs, please open an issue.
