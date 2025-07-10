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

CPU_MODEL=$(lscpu | grep "Model name:" | cut -d':' -f2 | sed 's/^[ \t]*//; s/@ .*/@/; s/(R)//g; s/(TM)//g; s/To Be Filled By O.E.M.//; s/  */ /g')
CPU_CORES=$(nproc)
CPU_SPEED=$(lscpu | grep "CPU max MHz:" | awk '{printf "%.1fGHz", $4/1000}')
CPU_INFO="${CPU_MODEL_COLOR}CPU: ${CPU_MODEL} (${CPU_CORES}) @ ${CPU_SPEED}${RESET}"

neofetch

echo "==============================================================================="

format_temp_line() {
    clean_line=$(echo "$1" | sed 's/°C//g')
    name=$(echo "$clean_line" | awk -F: '{print $1}')
    temp_val=$(echo "$clean_line" | awk -F'+' '{print $2}' | awk '{print $1}')
    high_val=$(echo "$clean_line" | grep -oP 'high = \+\K\d+\.?\d*')
    crit_val=$(echo "$clean_line" | grep -oP 'crit = \+\K\d+\.?\d*')

    if [[ "$name" == "Package id 0" ]]; then
        NAME_COLOR="$PKG_COLOR"
    else
        NAME_COLOR="$CORE_COLOR"
    fi

    line="${NAME_COLOR}%-13s${RESET}: ${TEMP_COLOR}+%s${RESET}°${C_COLOR}C${RESET}" 
    line+=$(printf "  ${LIMIT_LABEL_COLOR}high${RESET} = ${TEMP_COLOR}+%s${RESET}°${C_COLOR}C${RESET}" "$high_val")
    line+=$(printf "  ${LIMIT_LABEL_COLOR}crit${RESET} = ${TEMP_COLOR}+%s${RESET}°${C_COLOR}C${RESET}" "$crit_val")
    
    printf "$line" "$name" "$temp_val"
}

cpu_temps=()
while read -r line; do
    cpu_temps+=("$(format_temp_line "$line")")
done < <(sensors | grep -E 'Package id 0|Core 0|Core 1')

cpu_text="${CPU_INFO}\n${cpu_temps[0]}\n${cpu_temps[1]}\n${cpu_temps[2]}"

if command -v nvidia-smi &> /dev/null; then
    gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | head -n1)
    gpu_line="${GTX_COLOR}GTX 1050 Ti${RESET}:  ${TEMP_COLOR}+%s${RESET}°${C_COLOR}C${RESET}" 
    gpu_line=$(printf "$gpu_line" "$gpu_temp")
else
    gpu_line="NVIDIA GPU not detected or nvidia-smi not installed."
fi

center_vertically() {
    local art=$1
    local text=$2
    local art_height=$(echo "$art" | wc -l)
    local text_height=$(echo -e "$text" | wc -l)
    local padding=$(( (art_height - text_height) / 2 ))
    
    for ((i=0; i<padding; i++)); do
        printf "\n"
    done
    printf "%s" "$text"
}

cpu_ascii=$(jp2a --width=58 --colors /var/lib/vz/images/intel-pic.jpg)
centered_cpu=$(center_vertically "$cpu_ascii" "$cpu_text")
paste <(echo "$cpu_ascii") <(echo -e "$centered_cpu")

echo

gpu_ascii=$(jp2a --width=85 --colors /var/lib/vz/images/nvidia-pic.jpg)
centered_gpu=$(center_vertically "$gpu_ascii" "$gpu_line")
paste <(echo "$gpu_ascii") <(echo "$centered_gpu")

echo