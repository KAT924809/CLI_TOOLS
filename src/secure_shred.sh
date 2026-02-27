SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[-1]}")")"
source "$SCRIPT_DIR/screen.sh"

function secure_shred() {
    draw_screen_for_shred
    tput cnorm
    echo ""
    echo "Enter file path to securely delete:"
    read -r file

    if [ ! -f "$file" ]; then
        echo "File not found."
        sleep 2
        return 1
    fi

    echo ""
    read -p "Number of overwrite passes (default 3): " passes
    passes=${passes:-3}

    echo ""
    echo "WARNING: This will permanently destroy the file!"
    read -p "Are you sure? This is irreversible. (y/N): " confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo ""
        echo "Shredding file..."
        shred -u -n "$passes" "$file"
        echo ""
        echo "Done."
        echo "File securely shredded."
    else
        echo ""
        echo "Cancelled."
    fi

    echo ""
    read -p "Press Enter to return to menu..."
    tput civis
}
