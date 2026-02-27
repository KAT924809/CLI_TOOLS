#!/bin/bash

APP_NAME="Image Compressor TUI"
VERSION="0.1"

options=(
    "Compress Image"
    "MetaData / EXIF - Removal"
    "PDF Compressor"
    "DOCX TO PDF"
    "Bulk Rename"
    "Secure Shred"
    "Exit"
)

selected=0
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[-1]}")")"
source "$SCRIPT_DIR/compress_image_menu.sh"
source "$SCRIPT_DIR/screen.sh"
source "$SCRIPT_DIR/exif.sh"
source "$SCRIPT_DIR/pdf_compressor.sh"
source "$SCRIPT_DIR/docx_pdf.sh"
source "$SCRIPT_DIR/bulk_rename.sh"
source "$SCRIPT_DIR/secure_shred.sh"
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
                compress_image_menu
                sleep 1
                ;;
            1)
                clear
                exif_options
                
                ;;
            2)
                clear
                pdf_options
                
                ;;
            3)
                clear
                docx_options
                
                ;;
            4)
                clear
                bulk_rename_fn
                ;;
            5)
                clear
                secure_shred
                ;;
            6)
                clear
                tput cnorm 
                exit 0
                ;;
        esac
    fi

    if [ $selected -lt 0 ]; then
        selected=$((${#options[@]} - 1))
    fi

    if [ $selected -ge ${#options[@]} ]; then
        selected=0
    fi
done