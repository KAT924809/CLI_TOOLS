SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[-1]}")")"
source "$SCRIPT_DIR/screen.sh"

function compress_image_menu() {

    draw_screen_for_image_compressor 
    tput cnorm
    echo ""
    echo "Step 1: Enter full path of image"
    read -r FILE

    if [ ! -f "$FILE" ]; then
        echo "File not found."
        sleep 2
        return
    fi

    echo ""
    echo "Choose target size:"
    echo "1) 50 KB"
    echo "2) 100 KB"
    echo "3) 500 KB"
    echo "4) 1 MB"
    echo "5) Custom"
    echo ""

    read -p "Enter choice: " size_choice

    case $size_choice in
        1) TARGET_KB=50 ;;
        2) TARGET_KB=100 ;;
        3) TARGET_KB=500 ;;
        4) TARGET_KB=1024 ;;
        5)
            read -p "Enter size in KB: " TARGET_KB
            ;;
        *)
            echo "Invalid choice."
            sleep 2
            return
            ;;
    esac

    echo ""
    echo "Compressing to approximately ${TARGET_KB} KB..."
    sleep 1

    BASENAME=$(basename "$FILE")

    ext="${FILE##*.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

    # 📁 output file (convert PNG → JPG)
    if [[ "$ext" == "png" ]]; then
        OUT="compressed_${BASENAME%.*}.jpg"
    else
        OUT="compressed_${BASENAME}"
    fi

    quality=95
    min_quality=5
    step_size=5

    total_steps=$(( (95 - min_quality) / step_size + 1 ))
    step=0

    echo ""

    while [ $quality -ge $min_quality ]; do
        if [ -f "$OUT" ]; then
            CURRENT_KB=$(du -k "$OUT" | cut -f1)
        else
            CURRENT_KB=999999
        fi

        if [ "$CURRENT_KB" -gt $((TARGET_KB * 2)) ]; then
            resize="50%"
        else
            resize="70%"
        fi

        magick "$FILE" -strip -resize $resize -quality $quality "$OUT"

        CURRENT_KB=$(du -k "$OUT" | cut -f1)

        ((step++))
        progressbar "$step" "$total_steps"


        if [ "$CURRENT_KB" -le "$TARGET_KB" ]; then
            break
        fi

        ((quality-=step_size))
    done

    echo ""
    echo ""

    
    if [ "$CURRENT_KB" -gt "$TARGET_KB" ]; then
        echo "Could not reach exact target size. Try smaller dimensions."
    fi

    echo ""
    echo "Done."
    echo "Final size: ${CURRENT_KB} KB"
    echo "Saved as: $OUT"
    echo ""

    read -p "Press Enter to return to menu..."

    tput civis  
}