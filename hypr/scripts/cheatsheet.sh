#!/bin/sh
# Hoja de atajos: lee los atajos y sus descripciones directamente de Hyprland.
key="#7aa2f7"
t="$HOME/.config/hypr/themes/$(cat "$HOME/.cache/theme" 2>/dev/null).sh"
[ -f "$t" ] && . "$t" && key=${accent:-$blue}

rows=$(mktemp)
hyprctl binds -j | jq -r '
    .[] | select(.has_description and (.mouse | not))
    | [ .description,
        ((if (.modmask / 64 | floor) % 2 == 1 then "Super + " else "" end)
         + (if .modmask % 2 == 1 then "Shift + " else "" end) + .key) ] | @tsv' \
| awk -F'\t' -v key="$key" '
    function esc(s) { gsub(/&/, "\\&amp;", s); gsub(/</, "\\&lt;", s); gsub(/>/, "\\&gt;", s); return s }
    { W = 62; d = substr($1, 1, W - 2 - length($2))
      printf "%s <span foreground=\"%s\" weight=\"bold\">%*s</span>\n", esc(d), key, W - 1 - length(d), esc($2) }
' > "$rows"

w=$(hyprctl monitors -j | jq -r '.[0] | (.width / .scale | floor)')
cols=$(( (${w:-1280} * 92 / 100 - 48) / 500 ))
[ "$cols" -lt 1 ] && cols=1; [ "$cols" -gt 4 ] && cols=4
n=$(wc -l < "$rows")
lines=$(( (n + cols - 1) / cols )); [ "$lines" -gt 22 ] && lines=22

rofi -dmenu -kb-cancel "Escape,Super+space,Super+D" -i -markup-rows -p "Atajos" \
     -mesg "<span style=\"italic\">(Super + Shift + D para cerrar)</span>" \
     -theme "$HOME/.config/rofi/cheatsheet.rasi" \
     -theme-str "listview { columns: $cols; lines: $lines; }" < "$rows" >/dev/null
rm -f "$rows"
