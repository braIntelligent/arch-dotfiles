#!/bin/sh
# Aplica un tema a kitty, polybar, rofi y los bordes de bspwm.
# uso: set-theme.sh <id-del-tema>   (ej: tokyonight, gruvbox, catppuccin)
theme="$1"
tdir="$HOME/.config/bspwm/themes"
[ -f "$tdir/$theme.sh" ] || { echo "no existe el tema: $theme"; exit 1; }
. "$tdir/$theme.sh"
accent=${accent:-$blue}
dim=${dim:-$bg_alt}

# --- kitty ---
cat > "$HOME/.config/kitty/color.ini" <<EOT
cursor_shape          Underline
cursor_underline_thickness 1
window_padding_width  20
foreground $fg
background $bg
color0 $black
color8 $black
color1 $red
color9 $red
color2 $green
color10 $green
color3 $yellow
color11 $yellow
color4 $blue
color12 $blue
color5 $magenta
color13 $magenta
color6 $cyan
color14 $cyan
color7 $white
color15 $white
cursor $white
cursor_text_color $bg
selection_foreground $blue
selection_background $bg_alt
EOT

# --- polybar ---
cat > "$HOME/.config/polybar/colors.ini" <<EOT
[colors]
background = #d9${bg#\#}
background-alt = $bg_alt
foreground = $fg
dim = $dim
blue = $accent
purple = $magenta
cyan = $cyan
green = $green
yellow = $yellow
red = $red
EOT

# --- rofi ---
cat > "$HOME/.config/rofi/colors.rasi" <<EOT
* {
    bg:     ${bg}e6;
    bg-alt: $bg_alt;
    fg:     $fg;
    dim:    $dim;
    blue:   $accent;
    green:  $green;
    red:    $red;
}
EOT

# --- bordes de bspwm (en vivo) ---
bspc config focused_border_color "$accent"   2>/dev/null
bspc config normal_border_color  "$bg_alt"   2>/dev/null
bspc config active_border_color  "$dim"      2>/dev/null
bspc config presel_feedback_color "$magenta" 2>/dev/null

# --- fondo opcional del tema ---
if [ -n "$wallpaper" ] && [ -f "$wallpaper" ]; then
    feh --bg-fill "$wallpaper"
    printf '%s\n' "$wallpaper" > "$HOME/.cache/wall"
fi

printf '%s\n' "$theme" > "$HOME/.cache/theme"

# --- recargar ---
pkill -USR1 -x kitty 2>/dev/null
[ -x "$HOME/.config/polybar/launch.sh" ] && "$HOME/.config/polybar/launch.sh" >/dev/null 2>&1
