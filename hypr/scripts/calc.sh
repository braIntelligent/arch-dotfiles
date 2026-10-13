#!/bin/sh
# Calculadora: se escribe la cuenta, Enter la resuelve y copia el resultado.
# Sigue abierta para encadenar cuentas ("ans" es el resultado anterior); Esc cierra.
# Entiende + - * / ** % ( ), y funciones como sqrt(2), sin(pi/2), log(100, 10), hex(255).
L="$HOME/.config/rofi/list.rasi"
ans=0; msg="Escribe una cuenta. Por ejemplo: 1500 * 0.19"
while :; do
    e=$(rofi -dmenu -kb-cancel "Escape,Super+space,Super+Shift+U" -p "=" -mesg "$msg" \
             -theme "$L" -theme-str 'window { width: 620px; } listview { lines: 0; } entry { placeholder: ""; }' < /dev/null)
    [ -n "$e" ] || exit 0
    r=$(ANS="$ans" python3 -I -c '
import math, os, sys
nombres = {k: getattr(math, k) for k in dir(math) if not k.startswith("_")}
nombres.update(abs=abs, round=round, min=min, max=max, hex=hex, bin=bin, int=int, float=float, pow=pow)
try: nombres["ans"] = float(os.environ.get("ANS", "0"))
except ValueError: nombres["ans"] = 0
try:
    v = eval(sys.argv[1].replace("^", "**").replace(",", "."), {"__builtins__": {}}, nombres)
    if isinstance(v, float):
        v = float("%.12g" % v)          # sin el ruido de los decimales binarios
        if v.is_integer(): v = int(v)
    print(v)
except Exception as err:
    print("error:", err); sys.exit(1)
' "$e" 2>&1)
    if [ $? = 0 ]; then
        printf '%s' "$r" | wl-copy
        ans=$r; msg="$e = <b>$r</b>   (copiado)"
    else
        msg="$e   $r"
    fi
done
