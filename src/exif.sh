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
    select option in "EXIF REMOVAL FOR PNG" "EXIF REMOVAL FOR ENTIRE DIRECTORY" "EXIT"; do 
    case "$option" in
        "EXIF REMOVAL FOR PNG") 
        exif_remove ;;
        "EXIF REMOVAL FOR ENTIRE DIRECTORY") remove_metadata_entire_directory ;;
        "EXIT") break ;;
        *) echo "INVALID CHOICE" ;; 
    esac 
done 
}

    