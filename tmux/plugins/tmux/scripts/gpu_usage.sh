#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $current_dir/utils.sh

get_platform() {
 case $(uname -s) in
 Linux)
  # use this option for when your gpu isn't detected
  gpu_label=$(get_tmux_option "@dracula-force-gpu" false)
  if [[ "$gpu_label" != false ]]; then
   echo $gpu_label
  else
   # Check for specific driver tools first (Most reliable method)
   if type -a radeontop >>/dev/null; then
    echo "amd"
   elif type -a nvidia-smi >>/dev/null; then
    echo "nvidia"
   else
    # Fallback: Detect hardware via lspci
    # We grab the whole line to grep for keywords
    gpu_info=$(lspci -v | grep -i "vga\|3d\|display" | head -n 1)

    if [[ "$gpu_info" =~ "AMD" ]] || [[ "$gpu_info" =~ "Radeon" ]] || [[ "$gpu_info" =~ "ATI" ]]; then
     echo "amd"
    elif [[ "$gpu_info" =~ "NVIDIA" ]]; then
     echo "nvidia"
    elif [[ "$gpu_info" =~ "Intel" ]]; then
     echo "intel"
    else
     # If no known brand is found, revert to old method (print 5th word)
     echo "$gpu_info" | awk '{print $5}'
    fi
   fi
  fi
  ;;

 Darwin)
  echo "apple"
  ;;

 CYGWIN* | MINGW32* | MSYS* | MINGW*)
  # Standardize windows detection if needed
  echo "windows"
  ;;
 esac
}
get_gpu() {
 # 1. Normalize platform to lowercase so it works with "NVIDIA" or "nvidia"
 gpu=$(get_platform | tr '[:upper:]' '[:lower:]')

 if [[ "$gpu" == "nvidia" ]]; then
  # Fixed the broken awk syntax and spacing
  usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | awk '{ printf("%d%%", $1) }')

 elif [[ "$gpu" == "amd" ]]; then
  # 2. Uses radeontop, strips the decimal, and adds a % sign
  usage=$(radeontop -d - -l 1 | sed -n 's/.*gpu \([0-9]*\)\..*/\1%/p')

 elif [[ "$gpu" == "apple" ]]; then
  # Kept existing logic, just cleaned up formatting
  # Note: 'sudo' here will require a password and might break background execution
  usage="$(sudo powermetrics --samplers gpu_power -i500 -n 1 | grep 'active residency' | sed 's/[^0-9.%]//g' | sed 's/[%].*$//g')%"

 else
  # Fallback for Intel or unknown cards
  usage="unknown"
 fi

 echo "$usage"
}

main() {
 # storing the refresh rate in the variable RATE, default is 5
 RATE=$(get_tmux_option "@dracula-refresh-rate" 5)
 gpu_label=$(get_tmux_option "@dracula-gpu-usage-label" "GPU")
 gpu_usage=$(get_gpu)
 echo "$gpu_label $gpu_usage"
 sleep $RATE
}

# run the main driver
main
