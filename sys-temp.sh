#!/bin/bash

clear

# ANSI Colors
PKG_COLOR="\033[38;2;11;2;189m"
CORE_COLOR="\033[38;2;2;160;227m"
TEMP_COLOR="\033[38;2;201;0;84m"
C_COLOR="\033[38;2;214;53;4m"
GTX_COLOR="\033[38;2;0;196;23m"
LIMIT_COLOR="\033[38;2;102;0;2m"
RESET="\033[0m"

neofetch

echo "=============================================="

jp2a --width=60 --colors /var/lib/vz/images/intel-pic.jpg

sensors | grep -E 'Package id 0|Core 0|Core 1' | while read -r line; do
    clean_line=$(echo "$line" | sed 's/°C//g')

    name=$(echo "$clean_line" | awk -F: '{print $1}')
    temp_val=$(echo "$clean_line" | awk -F'+' '{print $2}' | awk '{print $1}')
    high_val=$(echo "$clean_line" | grep -oP 'high = \+\K\d+\.?\d*')
    crit_val=$(echo "$clean_line" | grep -oP 'crit = \+\K\d+\.?\d*')

    if [[ "$name" == "Package id 0" ]]; then
        NAME_COLOR="$PKG_COLOR"
    else
        NAME_COLOR="$CORE_COLOR"
    fi

    printf "${NAME_COLOR}%-13s${RESET}: ${TEMP_COLOR}+%s${RESET}°${C_COLOR}C${RESET}" "$name" "$temp_val"

    if [[ -n "$high_val" ]]; then
        printf "  ${LIMIT_LABEL_COLOR}high${RESET} = ${TEMP_COLOR}+%s${RESET}°${C_COLOR}C${RESET}" "$high_val"
    fi

    if [[ -n "$crit_val" ]]; then
        printf "  ${LIMIT_LABEL_COLOR}crit${RESET} = ${TEMP_COLOR}+%s${RESET}°${C_COLOR}C${RESET}" "$crit_val"
    fi

    echo
done

echo
jp2a --width=85 --colors /var/lib/vz/images/nvidia-pic.jpg
if command -v nvidia-smi &> /dev/null; then
    TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | head -n1)
    printf "${GTX_COLOR}GTX 1050 Ti${RESET}:  ${TEMP_COLOR}+%s${RESET}°${C_COLOR}C${RESET}\n" "$TEMP"
else
    echo "NVIDIA GPU not detected or nvidia-smi not installed."
fi
