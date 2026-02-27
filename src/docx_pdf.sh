function convert_docx_to_pdf() {
    tput cnorm

    local input="$1"

    if [ -z "$input" ]; then
        echo "Usage: convert_docx_to_pdf <file.docx>"
        return 1
    fi

    if [ ! -f "$input" ]; then
        echo "File not found: $input"
        return 1
    fi

    local output_dir
    output_dir="$(dirname "$input")"

    libreoffice --headless --convert-to pdf "$input" --outdir "$output_dir" >/dev/null 2>&1

    local output_file="${input%.docx}.pdf"

    if [ -f "$output_file" ]; then
        echo "Converted successfully:"
        echo "$output_file"
    else
        echo "Conversion failed."
        return 1
    fi

    tput civis
}


function convert_docx_folder() {
    tput cnorm

    local dir="$1"

    if [ -z "$dir" ]; then
        echo "Usage: convert_docx_folder <directory>"
        return 1
    fi

    if [ ! -d "$dir" ]; then
        echo "Directory not found"
        return 1
    fi

    shopt -s nullglob
    local files=("$dir"/*.docx)

    if [ ${#files[@]} -eq 0 ]; then
        echo "No DOCX files found in $dir"
        return 1
    fi

    for file in "${files[@]}"; do
        libreoffice --headless --convert-to pdf "$file" --outdir "$dir" >/dev/null 2>&1
        echo "Converted: $(basename "$file")"
    done

    echo "Batch conversion complete."
    tput civis
}

function docx_options(){
    local options=("DOCX to PDF" "DOCX TO PDF FULL BATCH" "EXIT")
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
                    "DOCX to PDF") convert_docx_to_pdf ;;
                    "DOCX TO PDF FULL BATCH") convert_docx_folder ;;
                    "EXIT") tput cnorm; break ;;
                esac
                ;;
        esac
    done
}
