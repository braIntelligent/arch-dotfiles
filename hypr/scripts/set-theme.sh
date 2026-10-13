#!/bin/sh
# Aplica un tema a todo el escritorio: Hyprland, barra, menus, terminal,
# notificaciones, bloqueo, navegador y aplicaciones GTK y Qt.
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

# Los modulos salen de una plantilla: @color@ se cambia por el color del tema, y
# @bateria@ y @panel@ por los dispositivos de este equipo. Si no hay, se quita esa
# linea y waybar los busca por su cuenta.
bateria=""
for d in /sys/class/power_supply/*; do
    [ "$(cat "$d/type" 2>/dev/null)" = Battery ] || continue
    [ "$(cat "$d/scope" 2>/dev/null)" = Device ] && continue     # mouse o teclado inalambrico
    bateria=$(basename "$d"); break
done
panel=$(ls /sys/class/backlight 2>/dev/null | head -n1)
sed -e "s/@blue@/$blue/g" -e "s/@cyan@/$cyan/g" -e "s/@green@/$green/g" \
    -e "s/@yellow@/$yellow/g" -e "s/@magenta@/$magenta/g" -e "s/@red@/$red/g" \
    -e "s/@dim@/$dim/g" \
    -e "s/@bateria@/${bateria:-@bateria@}/g" -e "/@bateria@/d" \
    -e "s/@panel@/${panel:-@panel@}/g" -e "/@panel@/d" \
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
# el tema es "Adwaita" a secas: "Adwaita-dark" no viene con GTK y lo dejaria claro
gsettings set org.gnome.desktop.interface gtk-theme Adwaita 2>/dev/null
# GTK 3 no siempre toma lo anterior (thunar salia claro): tambien por settings.ini
for v in 3.0 4.0; do
    ini="$HOME/.config/gtk-$v/settings.ini"
    [ -f "$ini" ] && ! grep -q "generado por set-theme.sh" "$ini" && continue
    mkdir -p "$HOME/.config/gtk-$v"
    printf '# generado por set-theme.sh\n[Settings]\ngtk-application-prefer-dark-theme=1\n' > "$ini"
done
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

# --- zathura (visor de PDF) ---
mkdir -p "$HOME/.config/zathura"
cat > "$HOME/.config/zathura/zathurarc" <<EOT
# Lo reescribe set-theme.sh al cambiar de tema.
# Teclas: j k y flechas se mueven, + - zoom, a ajusta a la pagina, s al ancho,
# / busca, Ctrl+r cambia entre la pagina con los colores del tema y la original, q cierra.
set font "Hack Nerd Font 11"
set selection-clipboard clipboard
set recolor true
set recolor-keephue true
set default-bg "$bg"
set default-fg "$fg"
set recolor-lightcolor "$bg"
set recolor-darkcolor "$fg"
set statusbar-bg "$bg_alt"
set statusbar-fg "$fg"
set inputbar-bg "$bg_alt"
set inputbar-fg "$fg"
set highlight-color "$yellow"
set highlight-active-color "$accent"
set index-bg "$bg"
set index-fg "$fg"
set index-active-bg "$accent"
set index-active-fg "$bg"
set notification-bg "$bg_alt"
set notification-fg "$fg"
set notification-error-bg "$red"
set notification-error-fg "$bg"
EOT

# --- qutebrowser ---
mkdir -p "$HOME/.config/qutebrowser"
cat > "$HOME/.config/qutebrowser/colores.py" <<EOT
# Colores del tema activo. Lo reescribe set-theme.sh
bg, bg_alt, fg, dim = "$bg", "$bg_alt", "$fg", "$dim"
accent, red, green, yellow = "$accent", "$red", "$green", "$yellow"

c.colors.webpage.bg = bg        # sin destello blanco mientras carga la pagina

c.colors.tabs.bar.bg = bg
for par in ("odd", "even"):
    setattr(c.colors.tabs, par + ".bg", bg)
    setattr(c.colors.tabs, par + ".fg", dim)
    setattr(c.colors.tabs.selected, par + ".bg", bg_alt)
    setattr(c.colors.tabs.selected, par + ".fg", fg)
    setattr(c.colors.completion, par + ".bg", bg)
c.colors.tabs.indicator.start = accent
c.colors.tabs.indicator.stop = green
c.colors.tabs.indicator.error = red

c.colors.statusbar.normal.bg = bg
c.colors.statusbar.normal.fg = fg
c.colors.statusbar.command.bg = bg
c.colors.statusbar.command.fg = fg
c.colors.statusbar.insert.bg = green
c.colors.statusbar.insert.fg = bg
c.colors.statusbar.passthrough.bg = accent
c.colors.statusbar.passthrough.fg = bg
c.colors.statusbar.url.fg = fg
c.colors.statusbar.url.success.http.fg = fg
c.colors.statusbar.url.success.https.fg = green
c.colors.statusbar.url.hover.fg = accent
c.colors.statusbar.url.warn.fg = yellow
c.colors.statusbar.url.error.fg = red

c.colors.completion.fg = fg
c.colors.completion.category.bg = bg_alt
c.colors.completion.category.fg = accent
c.colors.completion.category.border.top = bg_alt
c.colors.completion.category.border.bottom = bg_alt
c.colors.completion.item.selected.bg = accent
c.colors.completion.item.selected.fg = bg
c.colors.completion.item.selected.border.top = accent
c.colors.completion.item.selected.border.bottom = accent
c.colors.completion.item.selected.match.fg = bg
c.colors.completion.match.fg = accent
c.colors.completion.scrollbar.bg = bg
c.colors.completion.scrollbar.fg = dim

c.colors.hints.bg = yellow
c.colors.hints.fg = bg
c.colors.hints.match.fg = dim
c.hints.border = "1px solid " + bg

c.colors.messages.info.bg = bg
c.colors.messages.info.fg = fg
c.colors.messages.info.border = bg_alt
c.colors.messages.warning.bg = yellow
c.colors.messages.warning.fg = bg
c.colors.messages.warning.border = yellow
c.colors.messages.error.bg = red
c.colors.messages.error.fg = bg
c.colors.messages.error.border = red

c.colors.prompts.bg = bg_alt
c.colors.prompts.fg = fg
c.colors.prompts.border = "1px solid " + accent
c.colors.prompts.selected.bg = accent
c.colors.prompts.selected.fg = bg

c.colors.downloads.bar.bg = bg
c.colors.downloads.start.bg = accent
c.colors.downloads.start.fg = bg
c.colors.downloads.stop.bg = green
c.colors.downloads.stop.fg = bg
c.colors.downloads.error.bg = red
c.colors.downloads.error.fg = bg
EOT

printf '%s\n' "$theme" > "$HOME/.cache/theme"

# --- recargar ---
pkill -USR1 -x kitty 2>/dev/null
pkill -USR2 -x waybar 2>/dev/null
makoctl reload >/dev/null 2>&1
pgrep -x qutebrowser >/dev/null && qutebrowser ':config-source' >/dev/null 2>&1 &
hyprctl reload >/dev/null 2>&1 || true
