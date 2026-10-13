#!/bin/sh
# Muestra los atajos leyendo los comentarios del sxhkdrc, en columnas y por categoria.
# Categoria = bloque "#", "# Titulo", "#". Descripcion = comentario sobre el atajo.
rc="$HOME/.config/sxhkd/sxhkdrc"

# colores del tema activo (Tokyo Night si no hay ninguno guardado)
bg="#1a1b26"; dim="#565f89"; red="#f7768e"; green="#73daca"; yellow="#e0af68"
blue="#7aa2f7"; magenta="#bb9af7"; cyan="#7dcfff"
t="$HOME/.config/bspwm/themes/$(cat "$HOME/.cache/theme" 2>/dev/null).sh"
[ -f "$t" ] && . "$t"

rows=$(mktemp)
awk -v bg="$bg" -v key="${accent:-$blue}" -v pal="$green $red $yellow $magenta $blue $cyan" '
  function esc(s) { gsub(/&/, "\\&amp;", s); gsub(/</, "\\&lt;", s); gsub(/>/, "\\&gt;", s); return s }
  BEGIN { nc = split(pal, col, " "); W = 66 }
  /^#[ \t]*$/ { titulo = !titulo; next }
  /^#/ {
      txt = substr($0, 2); sub(/^[ \t]+/, "", txt)
      if (titulo) {
          l = int((W - length(txt)) / 2); c = col[(k++ % nc) + 1]
          printf "<span background=\"%s\" foreground=\"%s\" weight=\"bold\">%*s%s%*s</span>\n", \
                 c, bg, l, "", esc(txt), W - l - length(txt), ""
      } else if (desc == "") desc = txt
      next
  }
  /^$/ { desc = ""; next }
  /^super|^alt|^ctrl/ {
      if (desc != "") {
          d = substr(desc, 1, W - 2 - length($0))
          printf "%s <span foreground=\"%s\" weight=\"bold\">%*s</span>\n", \
                 esc(d), key, W - 1 - length(d), esc($0)
      }
      desc = ""
  }
' "$rc" > "$rows"

# columnas segun el ancho del monitor (cada columna ocupa unos 1040px a escala 2x)
w=$(bspc query -T -m 2>/dev/null | grep -o '"width":[0-9]*' | head -1 | cut -d: -f2)
cols=$(( (${w:-1280} * 92 / 100 - 96) / 1040 ))
[ "$cols" -lt 1 ] && cols=1; [ "$cols" -gt 4 ] && cols=4
n=$(wc -l < "$rows")
lines=$(( (n + cols - 1) / cols )); [ "$lines" -gt 18 ] && lines=18

art=' ██████ ██   ██ ███████  █████  ████████     ███████ ██   ██ ███████ ███████ ████████
██      ██   ██ ██      ██   ██    ██        ██      ██   ██ ██      ██         ██   
██      ███████ █████   ███████    ██        ███████ ███████ █████   █████      ██   
██      ██   ██ ██      ██   ██    ██             ██ ██   ██ ██      ██         ██   
 ██████ ██   ██ ███████ ██   ██    ██        ███████ ██   ██ ███████ ███████    ██   '
mesg="<span font_desc=\"Hack Nerd Font 7\" foreground=\"$magenta\">$art</span>
<span style=\"italic\" foreground=\"$dim\">(Super + Shift + D para cerrar)</span>"

rofi -dmenu -kb-cancel "Escape,Super+space,Super+D" -i -markup-rows -p "Atajos" -mesg "$mesg" \
     -theme "$HOME/.config/rofi/cheatsheet.rasi" \
     -theme-str "listview { columns: $cols; lines: $lines; }" < "$rows" >/dev/null
rm -f "$rows"
