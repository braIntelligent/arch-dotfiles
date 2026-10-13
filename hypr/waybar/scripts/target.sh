#!/bin/sh
# Maquina objetivo para waybar. Se define con: settarget <ip> [nombre]
file="$HOME/.config/hypr/target"
if [ -s "$file" ] && [ -n "$(tr -d '[:space:]' < "$file")" ]; then
    echo "<span color='#f7768e'></span>  $(cat "$file")"
else
    echo "<span color='#565f89'>  no target</span>"
fi
