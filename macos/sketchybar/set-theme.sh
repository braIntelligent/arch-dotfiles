#!/usr/bin/env bash
# Aplica un tema (de ~/.config/sketchybar/themes) a kitty y sketchybar.
# uso: set-theme.sh <id>     (tokyonight | gruvbox | catppuccin | negro)
theme="$1"
tdir="$HOME/.config/sketchybar/themes"
[ -f "$tdir/$theme.sh" ] || { echo "no existe el tema: $theme"; exit 1; }
. "$tdir/$theme.sh"
accent=${accent:-$blue}
dim=${dim:-$bg_alt}

h(){ printf '0xff%s' "${1#\#}"; }          # #rrggbb -> 0xffrrggbb
bgx="0xcc${bg#\#}"                          # bg translucido (frosted: se difumina con blur_radius)

# --- kitty: theme.conf (lo incluye ~/.config/kitty/kitty.conf) ---
cat > "$HOME/.config/kitty/theme.conf" <<EOT
# Colores del tema activo (set-theme.sh). No editar a mano.
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
selection_foreground $fg
selection_background $bg_alt
EOT

# --- sketchybar: colors.sh ---
cat > "$HOME/.config/sketchybar/colors.sh" <<EOT
# Colores del tema activo ($name). Lo reescribe set-theme.sh.
export BAR_BG=$bgx
export FG=$(h "$fg")
export DIM=$(h "$dim")
export ACCENT=$(h "$accent")
export OCCUPIED=$(h "$magenta")
export GREEN=$(h "$green")
export RED=$(h "$red")
export YELLOW=$(h "$yellow")
export BLUE=$(h "$blue")
export BORDER=$(h "$bg_alt")
EOT


# --- neovim ---
# El fondo queda en NONE: se ve el de la terminal, que ya es el del tema.
mkdir -p "$HOME/.config/nvim/colors"
cat > "$HOME/.config/nvim/colors/tema.lua" <<EOT
-- Colores del tema activo. Lo reescribe set-theme.sh
vim.cmd("highlight clear")
vim.g.colors_name = "tema"
local c = {
    bg = "$bg", bg_alt = "$bg_alt", fg = "$fg", dim = "$dim", accent = "$accent",
    black = "$black", red = "$red", green = "$green", yellow = "$yellow",
    blue = "$blue", magenta = "$magenta", cyan = "$cyan",
}
local function hl(grupo, opciones) vim.api.nvim_set_hl(0, grupo, opciones) end

hl("Normal",       { fg = c.fg })
hl("NormalNC",     { fg = c.fg })
hl("NormalFloat",  { fg = c.fg, bg = c.bg_alt })
hl("FloatBorder",  { fg = c.accent, bg = c.bg_alt })
hl("SignColumn",   {})
hl("EndOfBuffer",  { fg = c.bg_alt })
hl("LineNr",       { fg = c.dim })
hl("CursorLineNr", { fg = c.accent, bold = true })
hl("CursorLine",   { bg = c.bg_alt })
hl("ColorColumn",  { bg = c.bg_alt })
hl("Visual",       { bg = c.black })
hl("Search",       { fg = c.bg, bg = c.yellow })
hl("IncSearch",    { fg = c.bg, bg = c.accent })
hl("CurSearch",    { fg = c.bg, bg = c.accent })
hl("MatchParen",   { fg = c.accent, bold = true, underline = true })
hl("NonText",      { fg = c.dim })
hl("Whitespace",   { fg = c.black })
hl("Folded",       { fg = c.dim, bg = c.bg_alt })
hl("WinSeparator", { fg = c.black })
hl("Pmenu",        { fg = c.fg, bg = c.bg_alt })
hl("PmenuSel",     { fg = c.bg, bg = c.accent })
hl("PmenuSbar",    { bg = c.bg_alt })
hl("PmenuThumb",   { bg = c.dim })
hl("StatusLine",     { fg = c.fg, bg = c.bg_alt })
hl("StatusLineNC",   { fg = c.dim, bg = c.bg_alt })
hl("StatusLineModo", { fg = c.bg, bg = c.accent, bold = true })
hl("TabLine",      { fg = c.dim, bg = c.bg_alt })
hl("TabLineSel",   { fg = c.bg, bg = c.accent })
hl("TabLineFill",  { bg = c.bg_alt })
hl("Title",        { fg = c.accent, bold = true })
hl("Directory",    { fg = c.blue })
hl("Question",     { fg = c.green })
hl("MoreMsg",      { fg = c.green })
hl("ModeMsg",      { fg = c.fg, bold = true })
hl("WarningMsg",   { fg = c.yellow })
hl("ErrorMsg",     { fg = c.red })

hl("Comment",    { fg = c.dim, italic = true })
hl("Constant",   { fg = c.yellow })
hl("String",     { fg = c.green })
hl("Character",  { fg = c.green })
hl("Number",     { fg = c.yellow })
hl("Boolean",    { fg = c.yellow })
hl("Identifier", { fg = c.fg })
hl("Function",   { fg = c.blue })
hl("Statement",  { fg = c.magenta })
hl("Keyword",    { fg = c.magenta })
hl("Operator",   { fg = c.cyan })
hl("PreProc",    { fg = c.magenta })
hl("Type",       { fg = c.cyan })
hl("Special",    { fg = c.cyan })
hl("Delimiter",  { fg = c.fg })
hl("Underlined", { fg = c.blue, underline = true })
hl("Todo",       { fg = c.bg, bg = c.yellow, bold = true })
hl("Error",      { fg = c.red })
hl("@variable",  { fg = c.fg })
hl("@property",  { fg = c.fg })
hl("@tag",       { fg = c.magenta })
hl("@tag.attribute", { fg = c.yellow })

hl("DiagnosticError", { fg = c.red })
hl("DiagnosticWarn",  { fg = c.yellow })
hl("DiagnosticInfo",  { fg = c.blue })
hl("DiagnosticHint",  { fg = c.cyan })
hl("DiagnosticUnderlineError", { undercurl = true, sp = c.red })
hl("DiagnosticUnderlineWarn",  { undercurl = true, sp = c.yellow })
hl("DiffAdd",    { fg = c.green })
hl("DiffChange", { fg = c.yellow })
hl("DiffDelete", { fg = c.red })
hl("DiffText",   { fg = c.bg, bg = c.yellow })
hl("Added",      { fg = c.green })
hl("Changed",    { fg = c.yellow })
hl("Removed",    { fg = c.red })
EOT

echo "$theme" > "$HOME/.cache/theme"

# kitty relee config con SIGUSR1 (barato)
pkill -USR1 -x kitty 2>/dev/null

# sketchybar: aplicar colores en vivo SIN --reload (eso reconstruye todo y laguea).
# Repintamos lo estatico del tema al instante; los items de datos toman el color
# nuevo en su proximo tick (1-3s), que para el preview se ve fluido.
SB=/Users/amnesia/.local/bin/sketchybar
. "$HOME/.config/sketchybar/colors.sh"
"$SB" --bar color="$BAR_BG" border_color="$BORDER" >/dev/null 2>&1
"$SB" --set picker label.color="$ACCENT" background.color="$BORDER" >/dev/null 2>&1
# recolorea los items de datos al instante (scripts rapidos, no bloquea)
"$SB" --update >/dev/null 2>&1
# borde de ventanas (JankyBorders): seguir el acento del tema en vivo
BORDERS=/Users/amnesia/.local/bin/borders
[ -x "$BORDERS" ] && "$BORDERS" active_color="$ACCENT" inactive_color="$DIM" >/dev/null 2>&1
echo "tema aplicado: $name"
