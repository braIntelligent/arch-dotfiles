#!/bin/sh
# Musica de YouTube sin navegador: se busca, se elige en el menu y suena solo el audio.
# Despues del tema elegido sigue con la mezcla que YouTube arma a partir de el.
# uso: musica.sh              buscar y reproducir (reemplaza lo que este sonando)
#      musica.sh siguiente    pasar al tema siguiente
#      musica.sh parar        detener
# El audio lo baja yt-dlp y se lo pasa a mpv por una tuberia: si mpv abre la direccion
# por su cuenta, YouTube responde 403. Si deja de funcionar: scripts/actualizar-yt-dlp.sh
Y="$HOME/.local/bin/yt-dlp"; [ -x "$Y" ] || Y=yt-dlp
R="${XDG_RUNTIME_DIR:-/tmp}"
sock="$R/musica.sock"       # identifica al mpv de la musica
pidf="$R/musica.pid"        # grupo de procesos de la cola
titf="$R/musica.titulo"     # tema que esta sonando
L="$HOME/.config/rofi/list.rasi"

sonando() { [ -s "$pidf" ] && kill -0 "$(cat "$pidf")" 2>/dev/null; }
parar()   { sonando && kill -- "-$(cat "$pidf")" 2>/dev/null; rm -f "$pidf" "$titf"; }

case "$1" in
    parar)
        parar; exit 0 ;;
    siguiente)
        sonando || exit 1
        pkill -f "input-ipc-server=$sock"; exit 0 ;;
    _cola)      # uso interno: reproduce, una tras otra, las lineas "id<TAB>titulo" de $2
        echo $$ > "$pidf"
        while IFS="$(printf '\t')" read -r id titulo; do
            printf '%s\n' "$titulo" > "$titf"
            notify-send -a musica "  $titulo"
            "$Y" -q -f bestaudio -o - "https://www.youtube.com/watch?v=$id" 2>/dev/null \
                | mpv --no-video --really-quiet --input-ipc-server="$sock" \
                      --force-media-title="$titulo" - >/dev/null 2>&1
        done < "$2"
        rm -f "$pidf" "$titf" "$2"
        exit 0 ;;
esac

# --- buscar: se escribe en el menu; si hay algo sonando, se ofrece detenerlo o saltarlo
q=$( { sonando && printf '  Detener: %s\n  Siguiente\n' "$(cat "$titf" 2>/dev/null)"; } \
    | rofi -dmenu -kb-cancel "Escape,Super+space,Super+Shift+M" -i -p "Musica" \
           -theme "$L" -theme-str 'window { width: 760px; } listview { lines: 2; } entry { placeholder: "Buscar en YouTube"; }')
case "$q" in
    "")             exit 0 ;;
    "  Detener:"*) parar; exit 0 ;;
    "  Siguiente") exec "$0" siguiente ;;
esac

notify-send -a musica -t 2500 "Buscando: $q"
res=$("$Y" --flat-playlist --print '%(id)s	%(duration_string)s	%(title)s' "ytsearch15:$q" 2>/dev/null)
[ -n "$res" ] || { notify-send -u critical "Musica" "La busqueda no devolvio nada. Prueba scripts/actualizar-yt-dlp.sh"; exit 1; }

i=$(printf '%s\n' "$res" | awk -F'\t' '{ printf "%s  (%s)\n", $3, $2 }' \
    | rofi -dmenu -format i -kb-cancel "Escape,Super+space,Super+Shift+M" -i -p "$q" \
           -theme "$L" -theme-str 'window { width: 900px; } listview { lines: 15; }')
[ -n "$i" ] || exit 0
id=$(printf '%s\n' "$res" | sed -n "$(( i + 1 ))p" | cut -f1)

# la cola: el tema elegido y luego la mezcla de YouTube para ese tema
cola=$(mktemp "$R/musica-cola.XXXXXX")
printf '%s\n' "$res" | sed -n "$(( i + 1 ))p" | cut -f1,3 > "$cola"
parar
setsid "$0" _cola "$cola" >/dev/null 2>&1 &
"$Y" --flat-playlist --playlist-end 25 --print '%(id)s	%(title)s' \
    "https://www.youtube.com/watch?v=$id&list=RD$id" 2>/dev/null | grep -v "^$id	" >> "$cola"
