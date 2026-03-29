function compress_video_to_size() {
    draw_screen_for_video
    tput cnorm
    echo ""
    echo "Step 1: Enter full path of video file"
    read -r FILE

    if [ ! -f "$FILE" ]; then
        echo "File not found."
        sleep 2
        return
    fi

    # Get duration using ffprobe
    DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$FILE")
    if [ -z "$DURATION" ]; then
        echo "Could not Determine video duration."
        sleep 2
        return
    fi

    echo ""
    echo "Video Duration: ${DURATION} seconds"
    echo "Step 2: Enter target size in MB (e.g., 10, 25, 50)"
    read -r TARGET_MB

    if ! [[ "$TARGET_MB" =~ ^[0-9]+$ ]]; then
        echo "Invalid size."
        sleep 2
        return
    fi

    # Calculate bitrates
    # Target size in bits = MB * 1024 * 1024 * 8
    # Total bitrate = Size / Duration
    TARGET_BITS=$(( TARGET_MB * 1024 * 1024 * 8 ))
    TOTAL_BITRATE=$(( TARGET_BITS / ${DURATION%.*} ))
    
    # Reserve 128k for audio
    AUDIO_BITRATE=128000
    VIDEO_BITRATE=$(( TOTAL_BITRATE - AUDIO_BITRATE ))

    if [ $VIDEO_BITRATE -lt 100000 ]; then
        echo "Warning: Target size is very small for this duration. Quality will be poor."
        VIDEO_BITRATE=100000
    fi

    OUT="compressed_$(basename "${FILE%.*}").mp4"
    
    echo ""
    echo "Starting 2-Pass Compression..."
    echo "Pass 1..."
    ffmpeg -y -i "$FILE" -c:v libx264 -b:v "$VIDEO_BITRATE" -pass 1 -an -f mp4 /dev/null
    
    echo "Pass 2..."
    ffmpeg -y -i "$FILE" -c:v libx264 -b:v "$VIDEO_BITRATE" -pass 2 -c:a aac -b:a 128k "$OUT"

    # Cleanup ffmpeg2pass files
    rm -f ffmpeg2pass-0.log ffmpeg2pass-0.log.mbtree

    echo ""
    echo "Done."
    echo "Saved as: $OUT"
    echo ""
    read -p "Press Enter to return..."
    tput civis
}

function convert_to_mp4() {
    draw_screen_for_video
    tput cnorm
    echo ""
    echo "Enter video file path:"
    read -r FILE
    if [ ! -f "$FILE" ]; then echo "File not found."; sleep 2; return; fi

    OUT="${FILE%.*}.mp4"
    echo "Converting to MP4..."
    ffmpeg -i "$FILE" -c:v libx264 -c:a aac "$OUT"
    
    echo "Done: $OUT"
    read -p "Press Enter to return..."
    tput civis
}

function extract_audio() {
    draw_screen_for_video
    tput cnorm
    echo ""
    echo "Enter video file path:"
    read -r FILE
    if [ ! -f "$FILE" ]; then echo "File not found."; sleep 2; return; fi

    OUT="${FILE%.*}.mp3"
    echo "Extracting audio to MP3..."
    ffmpeg -i "$FILE" -q:a 0 -map a "$OUT"
    
    echo "Done: $OUT"
    read -p "Press Enter to return..."
    tput civis
}

function remove_audio() {
    draw_screen_for_video
    tput cnorm
    echo ""
    echo "Enter video file path:"
    read -r FILE
    if [ ! -f "$FILE" ]; then echo "File not found."; sleep 2; return; fi

    OUT="muted_$(basename "$FILE")"
    echo "Removing audio track..."
    ffmpeg -i "$FILE" -c copy -an "$OUT"
    
    echo "Done: $OUT"
    read -p "Press Enter to return..."
    tput civis
}

function video_options() {
    local options=("COMPRESS VIDEO (TARGET SIZE)" "CONVERT TO MP4" "EXTRACT AUDIO (MP3)" "REMOVE AUDIO" "EXIT")
    local selected=0
    local key

    tput civis
    while true; do
        draw_screen_for_video
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
                case $selected in
                    0) compress_video_to_size ;;
                    1) convert_to_mp4 ;;
                    2) extract_audio ;;
                    3) remove_audio ;;
                    4) break ;;
                esac
                ;;
        esac
    done
}
