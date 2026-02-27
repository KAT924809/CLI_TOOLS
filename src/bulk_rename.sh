SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[-1]}")")"
source "$SCRIPT_DIR/screen.sh"

function bulk_rename_fn() {
    draw_screen_for_bulk_rename
    tput cnorm
    echo ""
    echo "Enter directory path:"
    read -r dir

    if [ -z "$dir" ] || [ ! -d "$dir" ]; then
        echo "Directory not found."
        sleep 2
        return 1
    fi

    echo ""
    echo "Enter rename pattern (example: photo_{n}_{date})"
    echo "Available placeholders: {n} = number, {date} = current date"
    read pattern

    if [ -z "$pattern" ]; then
        echo "Pattern cannot be empty."
        sleep 2
        return 1
    fi

    date_str=$(date +%Y%m%d)

    shopt -s nullglob
    files=("$dir"/*)

    if [ ${#files[@]} -eq 0 ]; then
        echo "No files found."
        sleep 2
        return 1
    fi

    echo ""
    echo "Preview:"
    echo "---------------------------"

    counter=1
    declare -A rename_map

    for file in "${files[@]}"; do
        [ -f "$file" ] || continue
        ext="${file##*.}"
        new_name="$pattern"
        new_name="${new_name//\{n\}/$counter}"
        new_name="${new_name//\{date\}/$date_str}"
        new_name="$new_name.$ext"

        echo "$(basename "$file")  →  $new_name"
        rename_map["$file"]="$dir/$new_name"

        ((counter++))
    done

    echo ""
    read -p "Apply changes? (y/N): " confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        for old in "${!rename_map[@]}"; do
            mv "$old" "${rename_map[$old]}"
        done
        echo ""
        echo "Done."
        echo "Rename complete."
    else
        echo ""
        echo "Cancelled."
    fi

    echo ""
    read -p "Press Enter to return to menu..."
    tput civis
}