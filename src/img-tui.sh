#!/bin/bash

APP_NAME="Image Compressor TUI"
VERSION="0.1"

options=(
    "Compress Image"
    "Exit"
)

selected=0
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[-1]}")")"
source "$SCRIPT_DIR/screen.sh"
draw_screen

while true; do
    draw_screen

    read -rsn1 key

    if [[ $key == $'\x1b' ]]; then
        read -rsn2 key
        case $key in
            '[A') ((selected--)) ;;
            '[B') ((selected++)) ;;
        esac
    elif [[ $key == "" ]]; then
        case $selected in
            0)
                clear
                echo "Compress feature coming next..."
                sleep 1
                ;;
            1)
                clear
                tput cnorm  # restore cursor
                exit 0
                ;;
        esac
    fi

    # Wrap around logic
    if [ $selected -lt 0 ]; then
        selected=$((${#options[@]} - 1))
    fi

    if [ $selected -ge ${#options[@]} ]; then
        selected=0
    fi
done