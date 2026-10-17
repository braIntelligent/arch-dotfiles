#!/usr/bin/env bash
# Menu nativo para elegir tema (choose from list). Disparado por Alt+Shift+T.
tdir="$HOME/.config/sketchybar/themes"
cur=$(cat "$HOME/.cache/theme" 2>/dev/null)
ids=()
for f in "$tdir"/*.sh; do [ -f "$f" ] && ids+=("$(basename "$f" .sh)"); done
[ ${#ids[@]} -eq 0 ] && { osascript -e 'display notification "No hay temas"'; exit 0; }
list=$(printf '"%s",' "${ids[@]}" | sed 's/,$//')
choice=$(osascript -e "choose from list {$list} with prompt \"Tema (actual: ${cur:-?})\" with title \"Temas\"" 2>/dev/null)
[ -z "$choice" ] || [ "$choice" = "false" ] && exit 0
"$HOME/.config/sketchybar/set-theme.sh" "$choice"
