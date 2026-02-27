function remove_metadata_entire_directory(){
    tput cnorm
    echo ""
    echo "Step 1: Enter Full Path of the Directory"
    read -F DIRe

    if [ ! -f "$DIRe" ]; then 
        echo "Directory Path maybe wrong, else Directory Not found"
        sleep 2 
        return 
    fi 
    echo  ""
    BASENAME=$(basename "$DIRe")
    OUT="exif-metadata-null_${BASENAME}" 

    exiftool -recurse -all="$DIRe" -o "$OUT"
    echo ""
    echo "DONE"
    echo "Directory Saved as $OUT"
    echo ""
    tput civis 

    
}

function exif_remove(){
    #to-do add loading screen 
    tput cnorm
    echo ""
    echo "Step 1: Enter Full Path of The Image"
    read -r FILE

    if [ ! -f "$FILE" ]; then

        echo "File Path maybe wrong, else File not found"
        sleep 2 
        return 
    fi 
    
    echo " "

    BASENAME=$(basename "$FILE")
    OUT="exif-metadata-null_${BASENAME}"

    exiftool -all="$FILE" -o "$OUT"
    echo ""
    echo "DONE"
    echo "Saved as: $OUT"

    tput civis


} 

function exif_options(){
    local options=("EXIF REMOVAL FOR PNG" "EXIF REMOVAL FOR ENTIRE DIRECTORY" "EXIT")
    local selected=0
    local key

    tput civis
    while true; do
        clear
        echo "Select an option:"
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
                    "EXIF REMOVAL FOR PNG") exif_remove ;;
                    "EXIF REMOVAL FOR ENTIRE DIRECTORY") remove_metadata_entire_directory ;;
                    "EXIT") tput cnorm; break ;;
                esac
                ;;
        esac
    done
}

    