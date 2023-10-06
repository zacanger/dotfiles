#!/usr/bin/env bash
set -e

input_file="$1"
output_file="${1/.mov/.gif}"
width="${2:-300}"
rate="${3:-15}"

ffmpeg \
    -i "$input_file" \
    -filter_complex "[0:v] fps=$rate,scale=$width:-1,split [a][b];[a] palettegen [p];[b][p] paletteuse" \
    "$output_file"
