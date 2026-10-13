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

# los iconos de los modulos: la plantilla trae @color@ en vez de un color fijo
sed -e "s/@blue@/$blue/g" -e "s/@cyan@/$cyan/g" -e "s/@green@/$green/g" \
    -e "s/@yellow@/$yellow/g" -e "s/@magenta@/$magenta/g" -e "s/@red@/$red/g" \
    -e "s/@dim@/$dim/g" \
    "$HOME/.config/waybar/modulos.plantilla.jsonc" > "$HOME/.config/waybar/modulos.jsonc"

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

# indicador de volumen y brillo (scripts/nivel.sh): abajo al centro y breve
[app-name=osd]
anchor=bottom-center
margin=0,0,70,0
width=260
text-alignment=center
default-timeout=1200
progress-color=over $accent
text-color=$fg
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

# --- hyprlock (bloqueo de pantalla) ---
cat > "$HOME/.config/hypr/hyprlock-colores.conf" <<EOT
# Colores del tema activo. Lo reescribe set-theme.sh
\$bg     = rgb(${bg#\#})
\$fg     = rgb(${fg#\#})
\$accent = rgb(${accent#\#})
\$green  = rgb(${green#\#})
\$red    = rgb(${red#\#})
EOT

# --- aplicaciones GTK y Qt: oscuras y con los colores del tema ---
# (dialogos de archivo, LocalSend, KDE Connect; Firefox toma de aqui el modo oscuro)
gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>/dev/null
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark 2>/dev/null
marca="/* generado por set-theme.sh */"
css_gtk() {     # no pisa un gtk.css que no sea el nuestro
    [ ! -f "$1" ] || grep -qF "$marca" "$1" || return 0
    mkdir -p "$(dirname "$1")"
    { printf '%s\n' "$marca"; cat; } > "$1"
}
css_gtk "$HOME/.config/gtk-4.0/gtk.css" <<EOT
@define-color window_bg_color   $bg;
@define-color window_fg_color   $fg;
@define-color view_bg_color     $bg;
@define-color view_fg_color     $fg;
@define-color headerbar_bg_color $bg_alt;
@define-color headerbar_fg_color $fg;
@define-color sidebar_bg_color  $bg_alt;
@define-color card_bg_color     $bg_alt;
@define-color popover_bg_color  $bg_alt;
@define-color dialog_bg_color   $bg_alt;
@define-color accent_bg_color   $accent;
@define-color accent_fg_color   $bg;
@define-color accent_color      $accent;
EOT
css_gtk "$HOME/.config/gtk-3.0/gtk.css" <<EOT
@define-color theme_bg_color          $bg;
@define-color theme_fg_color          $fg;
@define-color theme_base_color        $bg;
@define-color theme_text_color        $fg;
@define-color theme_selected_bg_color $accent;
@define-color theme_selected_fg_color $bg;
@define-color borders                 $bg_alt;
window, .background { background-color: $bg; color: $fg; }
headerbar, .titlebar { background: $bg_alt; color: $fg; }
EOT

# KDE Connect y otras aplicaciones de KDE leen sus colores de kdeglobals
rgb() {     # "#rrggbb" -> "r,g,b"
    h=${1#\#}
    printf '%d,%d,%d' "0x$(printf %s "$h" | cut -c1-2)" "0x$(printf %s "$h" | cut -c3-4)" "0x$(printf %s "$h" | cut -c5-6)"
}
kg="$HOME/.config/kdeglobals"
if [ ! -f "$kg" ] || grep -qF "generado por set-theme.sh" "$kg"; then
    {
        echo "# generado por set-theme.sh"
        for seccion in Window View Button Header Tooltip Complementary; do
            fondo=$bg
            case "$seccion" in Button|Header|Tooltip) fondo=$bg_alt ;; esac
            cat <<EOT
[Colors:$seccion]
BackgroundNormal=$(rgb "$fondo")
BackgroundAlternate=$(rgb "$bg_alt")
ForegroundNormal=$(rgb "$fg")
ForegroundInactive=$(rgb "$dim")
ForegroundLink=$(rgb "$accent")
ForegroundNegative=$(rgb "$red")
ForegroundPositive=$(rgb "$green")
DecorationFocus=$(rgb "$accent")
DecorationHover=$(rgb "$accent")

EOT
        done
        cat <<EOT
[Colors:Selection]
BackgroundNormal=$(rgb "$accent")
BackgroundAlternate=$(rgb "$accent")
ForegroundNormal=$(rgb "$bg")
ForegroundInactive=$(rgb "$bg_alt")
DecorationFocus=$(rgb "$accent")
DecorationHover=$(rgb "$accent")
EOT
    } > "$kg"
fi

printf '%s\n' "$theme" > "$HOME/.cache/theme"

# --- recargar ---
pkill -USR1 -x kitty 2>/dev/null
pkill -USR2 -x waybar 2>/dev/null
makoctl reload >/dev/null 2>&1
hyprctl reload >/dev/null 2>&1 || true
