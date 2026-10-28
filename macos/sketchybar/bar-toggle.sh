#!/usr/bin/env bash
# Oculta/muestra la barra. Al ocultarla baja el gap superior de AeroSpace para que
# la ventana ocupe el espacio; al mostrarla lo devuelve.
SB="/Users/amnesia/.local/bin/sketchybar"
AS="/Users/amnesia/.local/bin/aerospace"
CFG="$HOME/.config/aerospace/aerospace.toml"
GAP_SHOW=42
GAP_HIDE=4

state=$("$SB" --query bar 2>/dev/null | grep '"hidden"' | grep -oE 'on|off' | head -1)

if [ "$state" = "on" ]; then
  # estaba oculta -> mostrar
  "$SB" --bar hidden=off
  sed -i '' -E "s/^(gaps\.outer\.top =).*/\1        $GAP_SHOW/" "$CFG"
else
  # estaba visible -> ocultar
  "$SB" --bar hidden=on
  sed -i '' -E "s/^(gaps\.outer\.top =).*/\1        $GAP_HIDE/" "$CFG"
fi
"$AS" reload-config >/dev/null 2>&1
