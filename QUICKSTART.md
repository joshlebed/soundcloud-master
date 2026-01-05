# Quick Start Guide

## TL;DR

```bash
./soundcloud-master.sh your_mix.wav
```

That's it. Upload the `_SC.wav` file to SoundCloud.

---

## What Just Happened?

Your mix was analyzed and optimized for SoundCloud:
- **Louder:** Brought from ~-12 LUFS to ~-10 LUFS (competitive)
- **Safe:** Peak limited to -1.0 dB (no clipping after encoding)
- **Clean:** Dynamics preserved (no brick-walling)

---

## The Scripts

### `soundcloud-master.sh` - Full Featured
- Shows before/after analysis
- Detailed loudness stats
- Supports batch processing
- **Use this first**

### `sc-master-quick.sh` - Fast Mode
- Minimal output
- Quick processing
- **Use this once you trust it**

---

## Real Example (Your File)

**Before:**
```
groove_session_1.wav
Size: 632M (16-bit)
Loudness: -12.4 LUFS
Peak: 0.0 dBFS
```

**After:**
```
groove_session_1_SC.wav
Size: 947M (24-bit)
Loudness: -10.4 LUFS  ← +2 LU louder
Peak: -0.13 dBTP      ← Safe headroom
```

**Result:** Now competitive with other SoundCloud DJ uploads.

---

## Common Commands

```bash
# Single file
./soundcloud-master.sh my_mix.wav

# All files in folder
./soundcloud-master.sh *.wav

# Fast mode
./sc-master-quick.sh my_mix.wav

# Custom output name
./soundcloud-master.sh input.wav custom_name.wav
```

---

## What To Upload

✓ Upload: `your_mix_SC.wav` (the mastered file)
✗ Don't upload: `your_mix.wav` (the original)

Keep both files. Archive the original, distribute the SC version.

---

## Troubleshooting

**Too quiet?**
Edit `soundcloud-master.sh`, change:
```bash
TARGET_LUFS=-9.5  →  TARGET_LUFS=-9.0
```

**Too loud/distorted?**
Change to `-10.0` or `-10.5`.

**Script not working?**
```bash
chmod +x soundcloud-master.sh sc-master-quick.sh
```

---

## Read More

See `SOUNDCLOUD_MASTERING_README.md` for:
- Technical details
- Genre-specific targets
- Understanding the numbers
- Best practices
- Complete troubleshooting guide

---

## The Workflow

1. **Record** on RX3 (keep TRIM low)
2. **Export** WAV from RX3
3. **Master** with `./soundcloud-master.sh your_mix.wav`
4. **Upload** the `_SC.wav` to SoundCloud
5. **Win** (sounds competitive)

---

**Remember:** The RX3 recording was correct. This script is for *distribution*, not capture.
