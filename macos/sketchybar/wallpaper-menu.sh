#!/usr/bin/env bash
# Menu nativo para elegir wallpaper (choose from list). Disparado por Alt+Shift+W.
dir="$HOME/Pictures/wallpapers"
mkdir -p "$dir"
cd "$dir" 2>/dev/null || exit 0
files=()
for f in *; do [ -f "$f" ] && files+=("$f"); done
[ ${#files[@]} -eq 0 ] && { osascript -e 'display notification "No hay fondos en ~/Pictures/wallpapers" with title "Wallpaper"'; exit 0; }
list=$(printf '"%s",' "${files[@]}" | sed 's/,$//')
choice=$(osascript -e "choose from list {$list} with prompt \"Fondo\" with title \"Wallpapers\"" 2>/dev/null)
[ -z "$choice" ] || [ "$choice" = "false" ] && exit 0
w="$dir/$choice"
echo "$w" > "$HOME/.cache/wall"
osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$w\""
