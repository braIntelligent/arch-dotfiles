#!/bin/sh
# Selector de fondos con miniaturas. Guarda la eleccion para que persista.
dir="$HOME/Pictures/wallpapers"
mkdir -p "$dir"
choice=$(
    for f in "$dir"/*; do
        [ -f "$f" ] || continue
        printf '%s\0icon\x1f%s\n' "$(basename "$f")" "$f"
    done | rofi -dmenu -kb-cancel "Escape,Super+space,Super+C" -i -p "Fondo" -show-icons \
               -theme "$HOME/.config/rofi/wallpaper.rasi"
)
[ -n "$choice" ] || exit 0
printf '%s\n' "$dir/$choice" > "$HOME/.cache/wall"
exec "$HOME/.config/hypr/scripts/aplicar-fondo.sh"
