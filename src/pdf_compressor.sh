function compressPdfs() {
    tput cnorm

    if [ -z "$1" ]; then 
        echo "Usage: compressPdfs <Input Directory>"
        return 1 
    fi 
    
    local input_dir="$1"
    local output_dir="${input_dir}/compressed_pdfs"

    mkdir -p "$output_dir"

    shopt -s nullglob
    local pdf_files=("$input_dir"/*.pdf)

    if [ ${#pdf_files[@]} -eq 0 ]; then
        echo "No PDF files found in $input_dir"
        return 1
    fi

    for input_file in "${pdf_files[@]}"; do
        local base_name
        base_name=$(basename "$input_file")
        local output_file="${output_dir}/${base_name}"

        gs -sDEVICE=pdfwrite -dNOPAUSE -dQUIET -dBATCH \
          -dCompatibilityLevel=1.4 \
          -dPDFSETTINGS=/screen \
          -sOutputFile="$output_file" "$input_file" \
        || echo "Failed to process $input_file"

        if [ -e "$output_file" ]; then
            echo "Compressed $base_name"
        else    
            echo "Error creating output for $base_name"
        fi 
    done 

    echo "Processing completed. Check $output_dir"
    tput civis
}

function compression_by_size() {
    tput cnorm
    local input="$1"
    local target_kb="$2"

    if [ ! -f "$input" ]; then
        echo "File not found"
        return 1
    fi

    local target_bytes=$((target_kb * 1024))
    local output="compressed_$(basename "$input")"

    presets=("/prepress" "/printer" "/ebook" "/screen")

    for preset in "${presets[@]}"; do
        gs -sDEVICE=pdfwrite \
           -dCompatibilityLevel=1.4 \
           -dPDFSETTINGS=$preset \
           -dNOPAUSE -dQUIET -dBATCH \
           -sOutputFile="$output" \
           "$input"

        size=$(stat -c%s "$output")

        if [ "$size" -le "$target_bytes" ]; then
            echo "Compressed successfully using preset $preset"
            echo "Final size: $((size/1024)) KB"
            return 0
        fi
    done

    echo "Could not reach exact target size."
    echo "Final size: $((size/1024)) KB"
    return 1

    tput civis 
}


function pdf_options(){
    local options=("COMBINE COMPRESS ENTIRE FOLDER" "COMPRESS TO SPECIFIC SIZE-IN KB" "EXIT")
    local selected=0
    local key

    tput civis
    while true; do
        draw_screen_for_pdf
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
                    "COMBINE COMPRESS ENTIRE FOLDER") compressPdfs ;;
                    "COMPRESS TO SPECIFIC SIZE-IN KB") compression_by_size ;;
                    "EXIT") tput cnorm; break ;;
                esac
                ;;
        esac
    done
}