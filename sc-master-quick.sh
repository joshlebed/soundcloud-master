#!/usr/bin/env bash
#
# sc-master-quick.sh
# Quick SoundCloud master with minimal output
#
# Usage: ./sc-master-quick.sh input.wav

set -eo pipefail

INPUT="$1"
OUTPUT="${INPUT%.wav}_SC.wav"

if [[ ! -f "$INPUT" ]]; then
    echo "Error: File not found: $INPUT"
    exit 1
fi

echo "Mastering: $(basename "$INPUT")"

ffmpeg -i "$INPUT" \
    -filter_complex "loudnorm=I=-9.5:TP=-1.0:LRA=8:linear=true" \
    -ar 44100 \
    -c:a pcm_s24le \
    "$OUTPUT" -y \
    -loglevel error -stats

echo "Created: $(basename "$OUTPUT")"
