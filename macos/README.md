# macOS nativo — AeroSpace + SketchyBar

Tercera opción del repo, al lado de la configuración de Linux. La idea de fondo
es la misma de siempre: un tiling WM minimal, una barra propia y una terminal
que se ve igual en todas partes. Lo que cambia es el sistema abajo.

## La historia: VM → ALARM → nativo

1. **VM (Arch ARM en VMware Fusion)** — el punto de partida. Arch Linux ARM
   corriendo virtualizado sobre Apple Silicon, con **bspwm + polybar** (ver la
   carpeta `bspwm/` del repo). Funcionaba, pero una VM gasta batería y se siente
   invitada en su propia casa.
2. **ALARM (Arch Linux ARM nativo / Asahi)** — el intento de correr Arch directo
   sobre el M1. Más cerca del metal, pero el soporte gráfico todavía cojea en
   este hardware y terminó descartado.
3. **macOS nativo con AeroSpace** — la conclusión: en vez de pelear contra el
   Mac, se replica la experiencia de bspwm/polybar **encima de macOS**. Mismo
   flujo, misma estética, cero VM, cero batería extra.

`AeroSpace` hace de tiling WM (el rol de bspwm) y `SketchyBar` de barra (el rol
de polybar). La terminal (`kitty`), el editor (`nvim`), los temas y el `zsh`
vienen de `compartido/`, así que todo se ve igual que en Linux.

## Qué hay acá

| Carpeta | Qué es |
|---------|--------|
| `aerospace/` | `aerospace.toml` — el tiling WM. Va en `~/.config/aerospace/`. |
| `sketchybar/` | La barra: `sketchybarrc`, `plugins/`, scripts de tema/toggle y las paletas en `themes/`. Va en `~/.config/sketchybar/`. |
| `kitty/` | `kitty.conf` (override macOS: sin barra de título, `Cmd+R` resize de splits) + `base.conf` y `color.ini` (copiados de `compartido/kitty`) + `quick-access-terminal.conf` (el scratchpad). Va en `~/.config/kitty/`. |
| `borders/` | `bordersrc` de **JankyBorders**: borde redondeado en la ventana activa con el color de acento del tema. Va en `~/.config/borders/`. |
| `zsh/` | `zshrc`, `lab.zsh` y `p10k.zsh` adaptados a macOS (rutas, BSD sed, pbcopy). |
| `launchagents/` | Los `.plist` que arrancan AeroSpace, SketchyBar y JankyBorders al login (`~/Library/LaunchAgents/`). |

El editor `nvim` y las paletas base salen de `compartido/` (misma config que en
Linux); acá las paletas se copian además en `sketchybar/themes/` porque es desde
ahí donde las lee `set-theme.sh` en el Mac.

## Cómo se usa

La config **no** se enlaza por symlink: se **copia** a `~/.config` y vive en la
máquina, independiente del repo. Este apartado es solo la referencia.

```sh
# WM y barra
mkdir -p ~/.config/aerospace ~/.config/sketchybar
cp macos/aerospace/aerospace.toml ~/.config/aerospace/
cp -R macos/sketchybar/ ~/.config/sketchybar/

# borde de ventanas
mkdir -p ~/.config/borders
cp macos/borders/bordersrc ~/.config/borders/

# terminal
mkdir -p ~/.config/kitty
cp macos/kitty/* ~/.config/kitty/

# zsh (ojo: los dotfiles del home van con punto)
cp macos/zsh/zshrc   ~/.zshrc
cp macos/zsh/p10k.zsh ~/.p10k.zsh
cp macos/zsh/lab.zsh  ~/.config/lab.zsh

# autostart
cp macos/launchagents/*.plist ~/Library/LaunchAgents/
launchctl load -w ~/Library/LaunchAgents/com.amnesia.aerospace.plist
launchctl load -w ~/Library/LaunchAgents/com.amnesia.sketchybar.plist
launchctl load -w ~/Library/LaunchAgents/com.amnesia.borders.plist
```

`set-theme.sh` también recolorea el borde de JankyBorders al cambiar de tema, así
que barra, borde y terminal siempre van con el mismo acento.

### Segundo monitor (iPad con Sidecar)

`aerospace.toml` fija los workspaces a monitores: el **4 vive en el iPad**
(Sidecar) y el resto en la pantalla del Mac. Si el iPad no está conectado, el 4
cae solo a la pantalla principal. Se desactivó `move-mouse` al cambiar de
monitor porque provocaba un rebote de foco de vuelta al workspace 1.

### Dependencias (sin Homebrew)

Todo se instala de binarios/fuentes oficiales, no con brew:

- **AeroSpace** (release de GitHub), **SketchyBar** (compilado de fuente con
  Xcode CLT), **JankyBorders** (compilado de fuente con clang, no necesita
  desactivar SIP), **kitty** (dmg oficial).
- `zsh`: powerlevel10k en `~/.local/share/zsh/plugins/powerlevel10k`;
  `zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-sudo` en el mismo dir;
  `lsd`/`bat`/`zoxide`/`fzf`/`yazi` como binarios arm64 en `~/.local/bin`.
- Fuente **Hack Nerd Font** en `~/Library/Fonts`.

### Atajos clave (AeroSpace, modificador `Alt`)

- `Alt+Enter` kitty · `Alt+N` Brave · `Alt+C` VS Code · `Alt+D` Discord · `Alt+F` Finder
- `Alt+1..5` workspaces · `Alt+Shift+1..5` mover ventana · `Alt+Tab` workspace anterior
- `Alt+H/J/K/L` foco · `Alt+Shift+H/J/K/L` mover · `Alt+T` tiles/accordion · `Alt+V` horizontal/vertical
- `Alt+R` modo resize · `Alt+Shift+F` fullscreen · `Alt+Shift+Tab` workspace al otro monitor
- `Alt+M` minimizar · `Alt+Shift+M` restaurar todas · `Alt+B` ocultar barra · `Alt+Shift+B` barra lab/sys
- `Alt+Shift+T` temas · `Alt+Shift+W` wallpapers (selector con preview en vivo)
- `Alt+Shift+Enter` terminal scratchpad

> Teclado **latino**: se evita `/`, `,` y las vocales con Option (son dead keys
> de tildes). Por eso los atajos usan consonantes y `Alt+T`/`Alt+R` en vez de
> `Alt+/`.
