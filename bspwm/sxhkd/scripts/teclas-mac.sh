#!/bin/sh
# Atajos estilo Mac con Super en cualquier ventana.
# Uso: teclas-mac.sh copiar | pegar | cortar | todo | deshacer | rehacer | borrarlinea
#
# En las terminales solo aplican copiar y pegar (con Ctrl+Shift), porque ahi
# Ctrl+C cancela, Ctrl+Z suspende y Ctrl+A / Ctrl+X son teclas de edicion.
# borrarlinea: en terminales Ctrl+U; en el resto selecciona hasta el inicio y borra.
win=$(xdotool getactivewindow 2>/dev/null) || win=$(xdotool getwindowfocus 2>/dev/null) || exit 0
class=$(xprop -id "$win" WM_CLASS 2>/dev/null)

case "$class" in
    *kitty*|*Alacritty*|*URxvt*|*XTerm*|*st-256color*) term=1 ;;
    *) term=0 ;;
esac

if [ "$term" = 1 ]; then
    case "$1" in
        copiar) keys="ctrl+shift+c" ;;
        pegar)  keys="ctrl+shift+v" ;;
        borrarlinea) keys="ctrl+u" ;;
        *) exit 0 ;;
    esac
else
    case "$1" in
        copiar)   keys="ctrl+c" ;;
        pegar)    keys="ctrl+v" ;;
        cortar)   keys="ctrl+x" ;;
        todo)     keys="ctrl+a" ;;
        deshacer) keys="ctrl+z" ;;
        rehacer)  keys="ctrl+shift+z" ;;
        borrarlinea) keys="shift+Home BackSpace" ;;
        *) echo "uso: teclas-mac.sh copiar|pegar|cortar|todo|deshacer|rehacer|borrarlinea"; exit 1 ;;
    esac
fi

# sin comillas a proposito: borrarlinea manda dos teclas seguidas
xdotool key --clearmodifiers $keys

# --clearmodifiers vuelve a apretar Cmd al terminar. Si lo soltaste antes,
# queda pegado (el siguiente Enter abre una terminal): se suelta si el
# teclado fisico ya no lo tiene apretado (133/134 = Super_L/Super_R).
command -v xinput >/dev/null || exit 0
for id in $(xinput list | grep 'slave  keyboard' | grep -v XTEST | sed 's/.*id=\([0-9]*\).*/\1/'); do
    xinput query-state "$id" 2>/dev/null | grep -qE 'key\[13[34]\]=down' && exit 0
done
xdotool keyup Super_L Super_R
