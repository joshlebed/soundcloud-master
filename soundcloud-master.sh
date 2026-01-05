#!/usr/bin/env bash
#
# soundcloud-master.sh
# Master DJ mixes for SoundCloud upload
# Targets: -9.5 LUFS integrated loudness, -1.0 dBTP true peak
#
# Usage: ./soundcloud-master.sh input.wav
#        ./soundcloud-master.sh input.wav output.wav
#        ./soundcloud-master.sh *.wav  (batch mode)

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Target loudness settings (per the SoundCloud advice)
TARGET_LUFS=-9.5
TARGET_TP=-1.0
TARGET_LRA=8

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo -e "${RED}Error: ffmpeg not found${NC}"
    echo "Install with: brew install ffmpeg"
    exit 1
fi

# Function to measure loudness
measure_loudness() {
    local file="$1"
    echo -e "${BLUE}Analyzing: $(basename "$file")${NC}"

    ffmpeg -i "$file" -filter_complex ebur128 -f null - 2>&1 | \
        grep -E "I:|LRA:|TP:" | tail -n 5
}

# Function to get peak level
get_peak() {
    local file="$1"
    ffmpeg -i "$file" -af "astats" -f null - 2>&1 | \
        grep "Peak level dB:" | head -n 1 | awk '{print $4}'
}

# Function to master a single file
master_file() {
    local input="$1"
    local output="${2:-}"

    # Check if input file exists
    if [[ ! -f "$input" ]]; then
        echo -e "${RED}Error: File not found: $input${NC}"
        return 1
    fi

    # Generate output filename if not provided
    if [[ -z "$output" ]]; then
        local dir=$(dirname "$input")
        local base=$(basename "$input" .wav)
        output="${dir}/${base}_SC.wav"
    fi

    # Check if output already exists
    if [[ -f "$output" ]]; then
        echo -e "${YELLOW}Warning: Output file already exists: $output${NC}"
        read -p "Overwrite? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Skipping..."
            return 0
        fi
    fi

    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  SoundCloud Master                                     ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${BLUE}Input:${NC}  $input"
    echo -e "${BLUE}Output:${NC} $output"
    echo

    # Measure input loudness
    echo -e "${YELLOW}━━━ Source Analysis ━━━${NC}"
    measure_loudness "$input"
    echo

    # Apply loudness normalization
    echo -e "${YELLOW}━━━ Mastering ━━━${NC}"
    echo "Target: ${TARGET_LUFS} LUFS, ${TARGET_TP} dBTP"
    echo

    ffmpeg -i "$input" \
        -filter_complex "loudnorm=I=${TARGET_LUFS}:TP=${TARGET_TP}:LRA=${TARGET_LRA}:linear=true" \
        -ar 44100 \
        -c:a pcm_s24le \
        "$output" -y 2>&1 | grep -E "time=|size=" | tail -n 1

    echo

    # Measure output loudness
    echo -e "${YELLOW}━━━ Mastered Result ━━━${NC}"
    measure_loudness "$output"

    echo
    local output_peak=$(get_peak "$output")
    echo -e "${GREEN}✓ Mastered file created: $(basename "$output")${NC}"
    echo -e "${BLUE}  Peak:${NC} ${output_peak} dB"

    # File size comparison
    local input_size=$(ls -lh "$input" | awk '{print $5}')
    local output_size=$(ls -lh "$output" | awk '{print $5}')
    echo -e "${BLUE}  Size:${NC} ${input_size} → ${output_size}"
    echo
}

# Show usage
usage() {
    echo "Usage: $0 <input.wav> [output.wav]"
    echo "       $0 *.wav  (batch mode)"
    echo
    echo "Examples:"
    echo "  $0 my_mix.wav                    # Creates my_mix_SC.wav"
    echo "  $0 my_mix.wav mastered.wav       # Specify output name"
    echo "  $0 *.wav                         # Master all .wav files"
    echo
    echo "Settings:"
    echo "  Target Loudness: ${TARGET_LUFS} LUFS"
    echo "  True Peak Limit: ${TARGET_TP} dBTP"
    echo "  Loudness Range:  ${TARGET_LRA} LU"
    exit 1
}

# Main logic
main() {
    if [[ $# -eq 0 ]]; then
        usage
    fi

    # Check if we're in batch mode (multiple files)
    if [[ $# -gt 2 ]] || [[ "$1" == *.wav && $# -gt 1 && "$2" == *.wav ]]; then
        # Batch mode
        echo -e "${GREEN}Batch mode: Processing ${#} files${NC}"
        echo
        for file in "$@"; do
            if [[ -f "$file" && "$file" == *.wav ]]; then
                master_file "$file"
                echo
            fi
        done
    else
        # Single file mode
        master_file "$1" "${2:-}"
    fi

    echo -e "${GREEN}Done!${NC}"
}

main "$@"
