function remove_metadata_entire_directory(){
    tput cnorm
    echo ""
    echo "Enter full path of the directory:"
    read -r DIRe

    if [ ! -d "$DIRe" ]; then 
        echo "Directory not found."
        sleep 2 
        return 
    fi 
    
    echo ""
    echo "Processing directory..."
    BASENAME=$(basename "$DIRe")
    OUT="exif-metadata-null_${BASENAME}" 

    exiftool -recurse -all= "$DIRe" -o "$OUT"
    echo ""
    echo "Done."
    echo "Directory saved as: $OUT"
    echo ""
    read -p "Press Enter to return to menu..."
    tput civis
}

function exif_remove(){
    tput cnorm
    echo ""
    echo "Enter full path of the image:"
    read -r FILE

    if [ ! -f "$FILE" ]; then
        echo "File not found."
        sleep 2 
        return 
    fi 
    
    echo ""
    echo "Removing metadata..."
    BASENAME=$(basename "$FILE")
    OUT="exif-metadata-null_${BASENAME}"

    exiftool -all= "$FILE" -o "$OUT"
    echo ""
    echo "Done."
    echo "Saved as: $OUT"
    echo ""
    read -p "Press Enter to return to menu..."
    tput civis
} 

function view_pdf_metadata(){
    tput cnorm
    echo ""
    echo "Enter full path of the PDF:"
    read -r file

    if [ ! -f "$file" ]; then
        echo "File not found."
        sleep 2
        return 1 
    fi
    
    echo ""
    exiftool "$file"
    echo ""
    read -p "Press Enter to return to menu..."
    tput civis
}
function edit_pdf_metadata() {
    tput cnorm
    echo ""
    echo "Enter full path of the PDF:"
    read -r file

    if [ ! -f "$file" ]; then
        echo "File not found."
        sleep 2
        return 1
    fi

    echo ""
    read -p "New Author: " author
    read -p "New Title: " title
    read -p "New Subject: " subject
    read -p "New Keywords: " keywords

    echo ""
    echo "Updating metadata..."
    exiftool -Author="$author" \
             -Title="$title" \
             -Subject="$subject" \
             -Keywords="$keywords" \
             -overwrite_original "$file"

    echo ""
    echo "Done."
    echo "Metadata updated."
    echo ""
    read -p "Press Enter to return to menu..."
    tput civis
}
function view_image_exif(){
    tput cnorm
    echo ""
    echo "Enter full path of the image:"
    read -r file

    if [ ! -f "$file" ]; then
        echo "File not found."
        sleep 2
        return 1
    fi
    
    echo ""
    exiftool "$file"
    echo ""
    read -p "Press Enter to return to menu..."
    tput civis
}

function strip_image_exif(){
    tput cnorm
    echo ""
    echo "Enter full path of the image:"
    read -r file

    if [ ! -f "$file" ]; then
        echo "File not found."
        sleep 2
        return 1
    fi
    
    echo ""
    echo "Stripping metadata..."
    exiftool -all= -overwrite_original "$file"
    echo ""
    echo "Done."
    echo "Metadata stripped."
    echo ""
    read -p "Press Enter to return to menu..."
    tput civis
}
function exif_options(){
    local options=("REMOVE IMAGE METADATA" "REMOVE DIRECTORY METADATA" "VIEW PDF METADATA" "EDIT PDF METADATA" "VIEW IMAGE EXIF" "STRIP IMAGE EXIF" "EXIT")
    local selected=0
    local key

    tput civis
    while true; do
        draw_screen_for_exif
        echo ""

        for i in "${!options[@]}"; do
            if [ "$i" -eq "$selected" ]; then
                echo "${REV} > ${options[$i]} ${RESET}"
            else
                echo "   ${options[$i]}"
            fi
        done

        read -rsn1 key
        case "$key" in
            $'\x1b')
                read -rsn2 key
                case "$key" in
                    '[A') ((selected > 0)) && ((selected--)) ;;
                    '[B') ((selected < ${#options[@]} - 1)) && ((selected++)) ;;
                esac
                ;;
            '')
                case "${options[$selected]}" in
                    "REMOVE IMAGE METADATA") exif_remove ;;
                    "REMOVE DIRECTORY METADATA") remove_metadata_entire_directory ;;
                    "VIEW PDF METADATA") view_pdf_metadata ;;
                    "EDIT PDF METADATA") edit_pdf_metadata ;;
                    "VIEW IMAGE EXIF") view_image_exif ;;
                    "STRIP IMAGE EXIF") strip_image_exif ;;
                    "EXIT") tput cnorm; break ;;
                esac
                ;;
        esac
    done
}

    