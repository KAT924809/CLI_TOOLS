
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