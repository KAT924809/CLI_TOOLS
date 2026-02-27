function compressPdfs() {
    tput cnorm
    echo ""
    echo "Enter directory path containing PDFs:"
    read -r input_dir

    if [ -z "$input_dir" ] || [ ! -d "$input_dir" ]; then 
        echo "Directory not found."
        sleep 2
        return 1 
    fi 
    
    local output_dir="${input_dir}/compressed_pdfs"

    mkdir -p "$output_dir"

    shopt -s nullglob
    local pdf_files=("$input_dir"/*.pdf)

    if [ ${#pdf_files[@]} -eq 0 ]; then
        echo "No PDF files found in $input_dir"
        sleep 2
        return 1
    fi

    echo ""
    echo "Compressing PDFs..."
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
            echo "Compressed: $base_name"
        else    
            echo "Error creating output for $base_name"
        fi 
    done 

    echo ""
    echo "Done."
    echo "Check: $output_dir"
    echo ""
    read -p "Press Enter to return to menu..."
    tput civis
}

function compression_by_size() {
    tput cnorm
    echo ""
    echo "Enter PDF file path:"
    read -r input

    if [ ! -f "$input" ]; then
        echo "File not found."
        sleep 2
        return 1
    fi

    echo ""
    echo "Enter target size in KB:"
    read -r target_kb

    local target_bytes=$((target_kb * 1024))
    local output="compressed_$(basename "$input")"

    presets=("/prepress" "/printer" "/ebook" "/screen")

    echo ""
    echo "Compressing to ${target_kb} KB..."
    for preset in "${presets[@]}"; do
        gs -sDEVICE=pdfwrite \
           -dCompatibilityLevel=1.4 \
           -dPDFSETTINGS=$preset \
           -dNOPAUSE -dQUIET -dBATCH \
           -sOutputFile="$output" \
           "$input"

        size=$(stat -c%s "$output")

        if [ "$size" -le "$target_bytes" ]; then
            echo ""
            echo "Done."
            echo "Compressed successfully using preset $preset"
            echo "Final size: $((size/1024)) KB"
            echo ""
            read -p "Press Enter to return to menu..."
            tput civis
            return 0
        fi
    done

    echo ""
    echo "Could not reach exact target size."
    echo "Final size: $((size/1024)) KB"
    echo ""
    read -p "Press Enter to return to menu..."
    tput civis
    return 1
}


function pdf_options(){
    local options=("COMPRESS ENTIRE FOLDER" "COMPRESS TO SPECIFIC SIZE" "EXIT")
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
                    "COMPRESS ENTIRE FOLDER") compressPdfs ;;
                    "COMPRESS TO SPECIFIC SIZE") compression_by_size ;;
                    "EXIT") tput cnorm; break ;;
                esac
                ;;
        esac
    done
}