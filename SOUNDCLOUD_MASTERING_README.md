# SoundCloud DJ Mix Mastering

Automated loudness mastering for DJ mixes to sound competitive on SoundCloud.

## The Problem

You recorded your mix on the RX3 with proper headroom (the right thing to do for sound quality), but when you upload to SoundCloud, it sounds **quiet** compared to other DJ mixes.

**Why?**
- SoundCloud does **not** apply loudness normalization on playback (unlike Spotify)
- Other DJs upload mixes at **-10 to -8 LUFS** integrated loudness
- Your RX3 recording might be at **-12 to -18 LUFS**
- Result: You sound 3-10 dB quieter than the competition

## The Solution

This script applies **distribution loudness optimization** while preserving:
- ✓ Dynamics (no brick-walling)
- ✓ Transients (kicks and hats stay punchy)
- ✓ Sound quality (no obvious distortion)
- ✓ Headroom for SoundCloud's lossy encoding

## Target Specifications

| Metric              | Target         | Why                                      |
|---------------------|----------------|------------------------------------------|
| Integrated Loudness | **-10 to -9 LUFS** | Competitive with other DJ uploads    |
| True Peak          | **-1.0 dBTP**  | Headroom for lossy encoding (Opus)       |
| Loudness Range     | **Preserved**  | Keep your mix dynamics intact            |
| Sample Rate        | **44.1 kHz**   | Standard for SoundCloud                  |
| Bit Depth          | **24-bit**     | Maximum quality before upload            |

## Installation

### Requirements

- macOS/Linux with bash
- ffmpeg (for audio processing)

### Install ffmpeg

```bash
brew install ffmpeg
```

### Make Scripts Executable

```bash
chmod +x soundcloud-master.sh
chmod +x sc-master-quick.sh
```

## Usage

### Option 1: Full Analysis Mode (Recommended First Time)

Shows before/after loudness stats and detailed info:

```bash
./soundcloud-master.sh your_mix.wav
```

This creates `your_mix_SC.wav` with full analysis output.

**Example output:**
```
╔════════════════════════════════════════════════════════╗
║  SoundCloud Master                                     ║
╚════════════════════════════════════════════════════════╝

Input:  groove_session_1.wav
Output: groove_session_1_SC.wav

━━━ Source Analysis ━━━
    I:         -12.4 LUFS
    LRA:         4.4 LU

━━━ Mastering ━━━
Target: -9.5 LUFS, -1.0 dBTP

━━━ Mastered Result ━━━
    I:         -10.4 LUFS
    LRA:         4.2 LU

✓ Mastered file created: groove_session_1_SC.wav
  Peak: -0.13 dB
  Size: 632M → 948M
```

### Option 2: Quick Mode (Fast)

Minimal output, just process and go:

```bash
./sc-master-quick.sh your_mix.wav
```

### Option 3: Custom Output Name

```bash
./soundcloud-master.sh input.wav my_soundcloud_upload.wav
```

### Option 4: Batch Processing

Master all WAV files in a directory:

```bash
./soundcloud-master.sh *.wav
```

## What The Script Does

### Processing Chain

1. **Loudness Normalization** (EBU R128)
   - Analyzes integrated loudness across entire mix
   - Applies gain to reach target (-9.5 LUFS)
   - Uses linear mode for transparency

2. **True Peak Limiting**
   - Applies gentle limiting to prevent clipping
   - Ceiling: -1.0 dBTP (safe for lossy encoding)
   - Lookahead enabled for transparent limiting

3. **Format Optimization**
   - Converts to 24-bit PCM (maximum quality)
   - Maintains 44.1 kHz sample rate
   - Preserves stereo imaging

### Technical Details

The script uses ffmpeg's `loudnorm` filter:

```bash
loudnorm=I=-9.5:TP=-1.0:LRA=8:linear=true
```

- `I=-9.5`: Target integrated loudness
- `TP=-1.0`: True peak limit
- `LRA=8`: Loudness range target (adaptive)
- `linear=true`: Linear normalization mode (more transparent)

## Real-World Example

### Before (RX3 Recording)
```
Input: groove_session_1.wav (62 minutes)
Integrated loudness: -12.4 LUFS
Peak level:          0.0 dBFS
Loudness range:      4.4 LU
File size:           632 MB (16-bit)
```

### After (SoundCloud Master)
```
Output: groove_session_1_SC.wav
Integrated loudness: -10.4 LUFS  ← Now competitive
Peak level:         -0.13 dBTP   ← Safe headroom
Loudness range:      4.2 LU      ← Dynamics preserved
File size:           948 MB (24-bit)
```

**Result:** Gained 2 LU of loudness while preserving dynamics and sound quality.

## Best Practices

### DO ✓
- Keep your RX3 TRIM low during recording (you did this right)
- Use this script for **distribution only**, not during recording
- Upload the mastered 24-bit WAV file to SoundCloud
- Compare your master against reference tracks at similar loudness
- Process a test section first if unsure

### DON'T ✗
- Touch the RX3 trim settings (keep recording with headroom)
- Apply compression or limiting before this script
- Normalize to 0 dBFS before processing
- Re-master an already mastered file
- Use this for streaming platforms with auto-normalization (Spotify, Apple Music)

## Understanding The Numbers

### Integrated Loudness (LUFS)
- Measures average loudness across entire mix
- **-12 LUFS**: Typical RX3 recording with headroom
- **-10 LUFS**: SoundCloud target (competitive)
- **-8 LUFS**: Very loud (risk of fatigue)
- **-7 LUFS or louder**: Brick-walled, sounds bad

### True Peak (dBTP)
- Measures peak after inter-sample interpolation
- **-1.0 dBTP**: Safe for lossy encoding
- **0.0 dBTP**: Digital maximum (risky for encoding)
- **> 0.0 dBTP**: Will clip after encoding

### Loudness Range (LU)
- Measures dynamic range of your mix
- **4-6 LU**: Typical DJ mix (yours: 4.4 → 4.2)
- **Lower**: Less dynamic, more compressed
- **Higher**: More dynamic, more headroom

## Troubleshooting

### Script says "ffmpeg not found"
```bash
brew install ffmpeg
```

### Output sounds distorted
Your source might be too hot. Check the input peak level:
```bash
ffmpeg -i your_mix.wav -af astats -f null - 2>&1 | grep "Peak level"
```
If showing 0.0 dB and integrated is already > -10 LUFS, you may not need mastering.

### Output is still too quiet
The script preserves dynamics. If you need it louder:
1. Edit `soundcloud-master.sh`
2. Change `TARGET_LUFS=-9.5` to `TARGET_LUFS=-9.0` or `-8.5`
3. Reprocess

**Warning:** Don't go below -8.0 LUFS or you'll start losing quality.

### File size increased significantly
This is expected. The script outputs 24-bit instead of 16-bit:
- 16-bit: ~10 MB per minute
- 24-bit: ~15 MB per minute

SoundCloud accepts large files and the quality is worth it.

### Output sounds the same as input
Check the loudness difference:
```bash
./soundcloud-master.sh your_mix.wav
# Look at the "Source Analysis" vs "Mastered Result"
```
If your input is already at -10 LUFS, the script won't change much (that's correct behavior).

## Customization

### Change Target Loudness

Edit `soundcloud-master.sh` and modify:
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

## Workflow Integration

### Recommended Process

1. **Record** on RX3 with TRIM low (capture stage)
2. **Export** WAV from RX3
3. **Master** with this script (distribution stage)
4. **Upload** the `_SC.wav` file to SoundCloud
5. **Keep** both versions (archive original, use master for distribution)

### Directory Structure

```
Recording/
├── originals/
│   └── my_mix.wav              (RX3 export, keep forever)
├── soundcloud/
│   └── my_mix_SC.wav           (mastered, upload this)
└── soundcloud-master.sh        (this script)
```

## Technical Background

### Why SoundCloud Needs This

Unlike Spotify (-14 LUFS target with normalization):
- SoundCloud does **no playback normalization**
- Uses **~128 kbps Opus** lossy encoding
- Encoding can cause **inter-sample peaks** → needs headroom
- Community uploads are **not level-matched**

Result: You need to be loud, but clean.

### Why This Approach Works

1. **Two-stage workflow**
   - Capture (RX3): Optimize for sound quality
   - Distribution (this script): Optimize for delivery

2. **EBU R128 loudness**
   - Industry standard for broadcast
   - Perceptually accurate
   - Preserves dynamics better than peak normalization

3. **True-peak limiting**
   - Prevents clipping after lossy encoding
   - -1.0 dB headroom is the sweet spot for Opus

### What This Script Does NOT Do

- ❌ Multiband compression (not needed for DJ mixes)
- ❌ Harmonic saturation (minimal benefit, risk of artifacts)
- ❌ Stereo widening (don't mess with your mix)
- ❌ EQ correction (master your mix properly first)
- ❌ Brick-wall limiting (sounds terrible after encoding)

This is intentionally minimal. DJs tend to over-process.

## Validation

### Before Uploading

Compare against reference tracks:

1. Download 2-3 SoundCloud DJ mixes in your genre
2. Drop them into a DAW alongside your master
3. Loudness-match by ear
4. If yours disappears → reprocess at -9.0 LUFS
5. If yours sounds fatiguing → reprocess at -10.5 LUFS

Half-LUFS adjustments matter.

### Quick Quality Check

Listen for:
- ✓ Kicks still punch (not smeared)
- ✓ Hats still crisp (not fizzy)
- ✓ Bass still tight (not distorted)
- ✓ Overall clarity maintained

If anything sounds worse, your source might have issues.

## Credits

Based on professional loudness mastering practices and the DJ mix delivery advice from the audio engineering community.

**Core principle:**
*Capture with headroom, deliver with loudness.*

## License

Free to use and modify for personal and commercial DJ mixes.

---

## Quick Reference

```bash
# Most common usage
./soundcloud-master.sh my_mix.wav

# Fast mode
./sc-master-quick.sh my_mix.wav

# Batch process
./soundcloud-master.sh *.wav

# Check loudness
ffmpeg -i file.wav -filter_complex ebur128 -f null -

# Check peak
ffmpeg -i file.wav -af astats -f null - 2>&1 | grep "Peak level"
```

**Target:** -10 to -9 LUFS, -1.0 dBTP, preserve dynamics, upload and win.
