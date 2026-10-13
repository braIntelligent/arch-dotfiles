#!/bin/sh
# Aplica un tema a kitty, waybar, rofi y Hyprland.
# uso: set-theme.sh <id-del-tema>   (los temas estan en ~/.config/hypr/themes)
theme="$1"
tdir="$HOME/.config/hypr/themes"
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

# --- waybar ---
cat > "$HOME/.config/waybar/colors.css" <<EOT
/* Colores del tema activo. Lo reescribe set-theme.sh */
@define-color bg      $bg;
@define-color bg_alt  $bg_alt;
@define-color fg      $fg;
@define-color dim     $dim;
@define-color accent  $accent;
@define-color magenta $magenta;
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

# --- mako (notificaciones) ---
mkdir -p "$HOME/.config/mako"
cat > "$HOME/.config/mako/config" <<EOT
# Notificaciones. Lo reescribe set-theme.sh al cambiar de tema.
font=Hack Nerd Font 11
anchor=top-right
margin=12
width=340
height=140
padding=12
border-size=2
border-radius=10
default-timeout=5000
max-visible=4
background-color=${bg}e6
text-color=$fg
border-color=$accent
progress-color=over $bg_alt

[urgency=critical]
border-color=$red
default-timeout=0
EOT

# --- hyprland (bordes) ---
cat > "$HOME/.config/hypr/colores.lua" <<EOT
-- Colores del tema activo. Lo reescribe set-theme.sh
return {
    bg      = "${bg#\#}",
    bg_alt  = "${bg_alt#\#}",
    fg      = "${fg#\#}",
    dim     = "${dim#\#}",
    accent  = "${accent#\#}",
    magenta = "${magenta#\#}",
}
EOT

printf '%s\n' "$theme" > "$HOME/.cache/theme"

# --- recargar ---
pkill -USR1 -x kitty 2>/dev/null
pkill -USR2 -x waybar 2>/dev/null
makoctl reload >/dev/null 2>&1
hyprctl reload >/dev/null 2>&1 || true
