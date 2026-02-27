function text_diff() {
    tput cnorm
    echo ""
    echo "Enter first text file path:"
    read -r file1

    if [ ! -f "$file1" ]; then
        echo "File not found."
        sleep 2
        return 1
    fi

    echo ""
    echo "Enter second text file path:"
    read -r file2

    if [ ! -f "$file2" ]; then
        echo "File not found."
        sleep 2
        return 1
    fi

    echo ""
    echo "Comparing files..."
    echo "Press 'q' to exit diff viewer"
    sleep 2
    diff --color=always -y "$file1" "$file2" | less -R
    tput civis
}

function pdf_diff() {
    tput cnorm
    echo ""
    echo "Enter first PDF file path:"
    read -r file1

    if [ ! -f "$file1" ]; then
        echo "File not found."
        sleep 2
        return 1
    fi

    echo ""
    echo "Enter second PDF file path:"
    read -r file2

    if [ ! -f "$file2" ]; then
        echo "File not found."
        sleep 2
        return 1
    fi

    echo ""
    echo "Converting PDFs to text..."
    pdftotext "$file1" /tmp/file1.txt
    pdftotext "$file2" /tmp/file2.txt

    echo "Comparing files..."
    echo "Press 'q' to exit diff viewer"
    sleep 2
    diff --color=always -y /tmp/file1.txt /tmp/file2.txt | less -R

    rm -f /tmp/file1.txt /tmp/file2.txt
    tput civis
}

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
function encrypt_pdf() {
    tput cnorm

    local input="$1"
    local password="$2"

    if [ -z "$input" ] || [ -z "$password" ]; then
        echo "Usage: encrypt_pdf <file.pdf> <password>"
        return 1
    fi

    if [ ! -f "$input" ]; then
        echo "File not found"
        return 1
    fi

    local output="encrypted_$(basename "$input")"

    qpdf --encrypt "$password" "$password" 256 \
        -- "$input" "$output"

    if [ -f "$output" ]; then
        echo "Encrypted successfully → $output"
    else
        echo "Encryption failed"
    fi

    tput civis
}

function decrypt_pdf() {
    tput cnorm

    local input="$1"
    local password="$2"

    if [ -z "$input" ] || [ -z "$password" ]; then
        echo "Usage: decrypt_pdf <file.pdf> <password>"
        return 1
    fi

    if [ ! -f "$input" ]; then
        echo "File not found"
        return 1
    fi

    local output="decrypted_$(basename "$input")"

    qpdf --password="$password" --decrypt \
        "$input" "$output"

    if [ -f "$output" ]; then
        echo "Decrypted successfully → $output"
    else
        echo "Decryption failed (wrong password?)"
    fi

    tput civis
}
function split_pdf() {
    tput cnorm

    local input="$1"

    if [ -z "$input" ]; then
        echo "Usage: split_pdf <file.pdf>"
        return 1
    fi

    if [ ! -f "$input" ]; then
        echo "File not found"
        return 1
    fi

    echo ""
    echo "Split options:"
    echo "1) Split all pages (one file per page)"
    echo "2) Split by page range"
    echo ""
    read -p "Enter choice: " split_choice

    local base="${input%.pdf}"

    case $split_choice in
        1)
            pdfseparate "$input" "${base}_page_%d.pdf"
            echo "PDF split complete (all pages)."
            ;;
        2)
            read -p "Enter start page: " start_page
            read -p "Enter end page: " end_page
            pdfseparate -f "$start_page" -l "$end_page" "$input" "${base}_page_%d.pdf"
            echo "PDF split complete (pages $start_page-$end_page)."
            ;;
        *)
            echo "Invalid choice."
            sleep 2
            return
            ;;
    esac

    echo ""
    read -p "Press Enter to return to menu..."
    tput civis
}

function merge_pdfs() {
    tput cnorm

    if [ "$#" -lt 2 ]; then
        echo "Usage: merge_pdfs output.pdf input1.pdf input2.pdf ..."
        return 1
    fi

    local output="$1"
    shift

    pdfunite "$@" "$output"

    if [ -f "$output" ]; then
        echo "Merged successfully → $output"
    else
        echo "Merge failed"
    fi

    tput civis
}

function docx_options(){
    local options=("DOCX to PDF" "DOCX TO PDF FULL BATCH" "ENCRYPT PDF" "DECRYPT PDF" "SPLIT PDF" "MERGE PDFs" "TEXT DIFF" "PDF DIFF" "EXIT")
    local selected=0
    local key

    tput civis
    while true; do
        draw_screen_for_docx
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
                    "DOCX to PDF") 
                        tput cnorm
                        echo ""
                        read -p "Enter DOCX file path: " docx_file
                        convert_docx_to_pdf "$docx_file"
                        read -p "Press Enter to continue..."
                        ;;
                    "DOCX TO PDF FULL BATCH") 
                        tput cnorm
                        echo ""
                        read -p "Enter directory path: " docx_dir
                        convert_docx_folder "$docx_dir"
                        read -p "Press Enter to continue..."
                        ;;
                    "ENCRYPT PDF")
                        tput cnorm
                        echo ""
                        read -p "Enter PDF file path: " pdf_file
                        read -sp "Enter password: " pdf_pass
                        echo ""
                        encrypt_pdf "$pdf_file" "$pdf_pass"
                        read -p "Press Enter to continue..."
                        ;;
                    "DECRYPT PDF")
                        tput cnorm
                        echo ""
                        read -p "Enter encrypted PDF file path: " enc_file
                        read -sp "Enter password: " dec_pass
                        echo ""
                        decrypt_pdf "$enc_file" "$dec_pass"
                        read -p "Press Enter to continue..."
                        ;;
                    "SPLIT PDF")
                        tput cnorm
                        echo ""
                        read -p "Enter PDF file path: " split_file
                        split_pdf "$split_file"
                        ;;
                    "MERGE PDFs")
                        tput cnorm
                        echo ""
                        read -p "Enter output PDF name: " output_pdf
                        read -p "Enter input PDFs (space-separated): " -a input_pdfs
                        merge_pdfs "$output_pdf" "${input_pdfs[@]}"
                        read -p "Press Enter to continue..."
                        ;;
                    "TEXT DIFF")
                        clear
                        text_diff
                        ;;
                    "PDF DIFF")
                        clear
                        pdf_diff
                        ;;
                    "EXIT") tput cnorm; break ;;
                esac
                ;;
        esac
    done
}
