#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"

# Config packages to offer (exclude non-config dirs/files)
EXCLUDE_DIRS=(".git" "scripts" "package-backup")

PACKAGES=()
for d in "$DOTFILES_DIR"/*/; do
    name=$(basename "$d")
    skip=0
    for exclude in "${EXCLUDE_DIRS[@]}"; do
        if [ "$name" = "$exclude" ]; then
            skip=1
            break
        fi
    done
    [ $skip -eq 0 ] && PACKAGES+=("$name")
done
IFS=$'\n' PACKAGES=($(sort <<<"${PACKAGES[*]}")); unset IFS

die() {
    echo "$1" >&2
    exit 1
}

link_config() {
    local pkg="$1"
    local pkg_dir="$DOTFILES_DIR/$pkg"

    if [ ! -d "$pkg_dir" ]; then
        echo "  Skipping $pkg (directory not found)"
        return
    fi

    if command -v stow &>/dev/null; then
        echo "  Using stow for $pkg..."
        (cd "$DOTFILES_DIR" && stow "$pkg" 2>&1) || echo "  Warning: stow $pkg had issues"
    else
        echo "  Linking $pkg manually..."
        while IFS= read -r -d '' source; do
            relative="${source#$pkg_dir/}"
            target="$HOME/$relative"
            if [ -e "$target" ] || [ -L "$target" ]; then
                echo "  Skipping $relative (already exists)"
                continue
            fi
            mkdir -p "$(dirname "$target")"
            ln -s "$source" "$target"
            echo "  Linked $relative"
        done < <(find "$pkg_dir" -type f -o -type l -print0)
    fi
}

show_menu() {
    echo "Available configs in $DOTFILES_DIR:"
    echo ""
    for i in "${!PACKAGES[@]}"; do
        printf "  [%2d]  %s\n" $((i+1)) "${PACKAGES[$i]}"
    done
    echo ""
    echo "  [ a]  Select all"
    echo "  [ q]  Quit"
    echo ""
}

while true; do
    show_menu
    echo -n "Enter numbers separated by spaces: "
    IFS= read -r input

    [ -z "$input" ] && continue

    if [ "$input" = "q" ]; then
        echo "Exiting."
        exit 0
    fi

    SELECTED=()
    if [ "$input" = "a" ]; then
        SELECTED=("${PACKAGES[@]}")
    else
        valid=1
        for num in $input; do
            if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt "${#PACKAGES[@]}" ]; then
                echo "Invalid selection: $num"
                valid=0
                break
            fi
            SELECTED+=("${PACKAGES[$((num-1))]}")
        done
        [ $valid -eq 0 ] && continue
    fi

    echo ""
    echo "Linking selected configs..."
    for pkg in "${SELECTED[@]}"; do
        link_config "$pkg"
    done
    echo ""
    echo "Done!"
    echo ""
done
