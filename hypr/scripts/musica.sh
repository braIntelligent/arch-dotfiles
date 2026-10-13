#!/bin/sh
# Musica de YouTube sin navegador: se busca, se elige en el menu y suena solo el audio.
# Despues del tema elegido sigue con la mezcla que YouTube arma a partir de el.
# uso: musica.sh              buscar y reproducir (reemplaza lo que este sonando)
#      musica.sh siguiente    pasar al tema siguiente
#      musica.sh parar        detener
# El audio lo baja yt-dlp y se lo pasa a mpv por una tuberia: si mpv abre la direccion
# por su cuenta, YouTube responde 403. Si deja de funcionar: extras/actualizar-yt-dlp.sh
Y="$HOME/.local/bin/yt-dlp"; [ -x "$Y" ] || Y=yt-dlp
R="${XDG_RUNTIME_DIR:-/tmp}"
sock="$R/musica.sock"       # identifica al mpv de la musica
pidf="$R/musica.pid"        # grupo de procesos de la cola
titf="$R/musica.titulo"     # tema que esta sonando
saltar="$R/musica.saltar"   # marca de que "siguiente" lo pidio el usuario
L="$HOME/.config/rofi/list.rasi"

sonando() { [ -s "$pidf" ] && kill -0 "$(cat "$pidf")" 2>/dev/null; }
parar()   { sonando && kill -- "-$(cat "$pidf")" 2>/dev/null; rm -f "$pidf" "$titf"; }

case "$1" in
    parar)
        parar; exit 0 ;;
    siguiente)
        sonando || exit 1
        : > "$saltar"
        pkill -f "input-ipc-server=$sock"; exit 0 ;;
    _cola)      # uso interno: reproduce, una tras otra, las lineas "id<TAB>titulo" de $2
        echo $$ > "$pidf"
        fallas=0
        while IFS="$(printf '\t')" read -r id titulo <&3; do
            [ -n "$id" ] || continue
            printf '%s\n' "$titulo" > "$titf"
            notify-send -a musica "  $titulo"
            # YouTube a ratos responde 403 a la descarga. Si un tema dura menos de
            # 8 segundos se toma como falla y se reintenta una vez por otro formato
            # (HLS), en vez de saltar al siguiente.
            sono=0
            for formato in 'bestaudio' 'bestaudio[protocol^=m3u8]/bestaudio'; do
                rm -f "$saltar"
                inicio=$(date +%s)
                "$Y" -q -f "$formato" -o - "https://www.youtube.com/watch?v=$id" 2>/dev/null </dev/null \
                    | mpv --no-video --really-quiet --input-ipc-server="$sock" \
                          --force-media-title="$titulo" - >/dev/null 2>&1
                # lo corto el usuario con "siguiente", o sono lo suficiente: no es falla
                if [ -f "$saltar" ] || [ $(( $(date +%s) - inicio )) -ge 8 ]; then sono=1; break; fi
                sleep 2
            done
            rm -f "$saltar"
            if [ "$sono" = 1 ]; then
                fallas=0
            else
                fallas=$(( fallas + 1 ))
                # tres temas seguidos sin sonar: se detiene, en vez de recorrer la lista entera
                if [ "$fallas" -ge 3 ]; then
                    notify-send -u critical "Musica" "YouTube no esta entregando el audio. Prueba de nuevo en un rato; si sigue igual: sh extras/actualizar-yt-dlp.sh del repositorio"
                    break
                fi
            fi
        done 3< "$2"
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
[ -n "$res" ] || { notify-send -u critical "Musica" "La busqueda no devolvio nada. Prueba extras/actualizar-yt-dlp.sh del repositorio"; exit 1; }

i=$(printf '%s\n' "$res" | awk -F'\t' '{ printf "%s  (%s)\n", $3, $2 }' \
    | rofi -dmenu -format i -kb-cancel "Escape,Super+space,Super+Shift+M" -i -p "$q" \
           -theme "$L" -theme-str 'window { width: 900px; } listview { lines: 15; }')
[ -n "$i" ] && [ "$i" -ge 0 ] 2>/dev/null || exit 0     # -1: se escribio algo que no esta en la lista
id=$(printf '%s\n' "$res" | sed -n "$(( i + 1 ))p" | cut -f1)

# la cola: el tema elegido y luego la mezcla de YouTube para ese tema
rm -f "$R"/musica-cola.*            # colas de busquedas anteriores
cola=$(mktemp "$R/musica-cola.XXXXXX")
printf '%s\n' "$res" | sed -n "$(( i + 1 ))p" | cut -f1,3 > "$cola"
parar
setsid "$0" _cola "$cola" >/dev/null 2>&1 &
sleep 4     # que la mezcla no se pida a la vez que el primer tema: juntas, YouTube a veces rechaza una
"$Y" --flat-playlist --playlist-end 25 --print '%(id)s	%(title)s' \
    "https://www.youtube.com/watch?v=$id&list=RD$id" 2>/dev/null | grep -v "^$id	" >> "$cola"
