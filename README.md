# arch-dotfiles

Escritorio en mosaico para **Mac con Apple Silicon**, sobre [Asahi ALARM](https://asahi-alarm.org) (Arch Linux ARM): Hyprland, una barra, menús hechos con rofi y temas que cambian todo el sistema de una vez. Se instala con un comando sobre la imagen mínima de ALARM.

Probado en un MacBook Air M1.

## Qué incluye

| | |
|---|---|
| Gestor de ventanas | Hyprland (Wayland), configurado en Lua, con atajos tipo vim |
| Barra | waybar en dos modos: métricas del equipo, o IP, VPN y máquina objetivo para laboratorios de seguridad |
| Menús | rofi 2: energía, fondos, temas con vista previa, hoja de atajos, capturas, portapapeles |
| Temas | Tokyo Night, Catppuccin, Gruvbox y Arch; se aplican a ventanas, barra, menús, terminal, notificaciones, bloqueo, navegador y aplicaciones GTK y Qt |
| Terminal | kitty con zsh, powerlevel10k y atajos estilo tmux |
| Propio del Mac | teclas de volumen y brillo con indicador en pantalla, luz del teclado, gestos del trackpad, parlantes, límite de carga de la batería |
| Sesión | bloqueo y suspensión por inactividad, luz nocturna, notificaciones, Bluetooth, grabación de pantalla |

## Instalación

Hace falta un Mac con Apple Silicon y Asahi ALARM en su variante **Minimal** ya instalado.

### 1. Conectar la red

La imagen mínima arranca en consola con el usuario `root` (clave `root`). Lo único que hay que hacer a mano es conectar el Wi-Fi:

```sh
nmcli device wifi connect "NOMBRE_RED" password "CLAVE"
```

### 2. Un comando

```sh
curl -fsSL https://raw.githubusercontent.com/braIntelligent/arch-dotfiles/main/hypr/preparar.sh | sh
```

El script pregunta la distribución del teclado, el nombre de usuario, las claves, la zona horaria y el nombre del equipo. Con eso crea el usuario, le da `sudo`, cambia la clave de root, descarga este repositorio e instala el escritorio completo. Tarda varios minutos, sobre todo por la compilación de rofi 2 (los repositorios traen la 1.7.5, que no funciona en Wayland).

Al terminar se escribe `exit` y se inicia sesión con el usuario nuevo: Hyprland parte solo.

Como se ejecuta como root, conviene leerlo antes. Para eso se descarga en vez de pasarlo directo a `sh`:

```sh
curl -fsSLO https://raw.githubusercontent.com/braIntelligent/arch-dotfiles/main/hypr/preparar.sh
less preparar.sh
sh preparar.sh
```

<details>
<summary>Instalación paso a paso, sin el script de preparación</summary>

Como root:

```sh
loadkeys la-latin1                                    # teclado de la consola; omitir si es US
pacman -Syu git
useradd -m -G wheel -s /bin/bash USUARIO
passwd USUARIO
passwd                                                # cambiar la clave de root
EDITOR=vim visudo                                     # quitar el # de "%wheel ALL=(ALL:ALL) ALL"
exit
```

Con el usuario nuevo:

```sh
git clone https://github.com/braIntelligent/arch-dotfiles.git
cd arch-dotfiles
sh hypr/instalar.sh --teclado latam
```

</details>

### Actualizar

`hypr/instalar.sh` se puede correr de nuevo cuando se quiera: no duplica nada y respalda cada archivo que reemplaza.

```sh
cd ~/arch-dotfiles && git pull
sh hypr/instalar.sh
```

### 3. Fondos de pantalla

No vienen incluidos. Las imágenes van en `~/Pictures/wallpapers` y se eligen con `Super + Shift + C`.

## Atajos

`Super` es la tecla Cmd. La lista completa se abre con `Super + Shift + D`.

| Atajo | Acción |
|---|---|
| `Super + Enter` | Terminal |
| `Super + Espacio` | Lanzador |
| `Super + N` | Navegador |
| `Super + H J K L` | Mover el foco |
| `Super + Shift + H J K L` | Intercambiar ventanas |
| `Super + Y U I O` | Abrir una terminal hacia ese lado |
| `Super + 1…5` | Cambiar de escritorio (con Shift, mandar la ventana) |
| `Super + W` | Cerrar la ventana |
| `Super + M` | Ocultar todo el escritorio o traerlo de vuelta |
| `Super + D` | Terminal desplegable |
| `Super + E` | Menú central |
| `Super + Shift + A` | Temas, con vista previa |
| `Super + Shift + B` | Cambiar la barra: normal o de laboratorio |
| `Super + G` | Bluetooth |
| `Super + Shift + V` | Historial del portapapeles |
| `Super + P` | Captura de una zona |
| `Super + Shift + S` | Menú de capturas y grabación |
| `Super + Shift + M` | Música de YouTube, solo audio |
| `Super + Shift + X` | Bloquear |
| `Super + Shift + E` | Apagar, reiniciar, suspender |
| Tres dedos hacia los lados | Cambiar de escritorio |

Los menús se cierran con la misma tecla que los abre.

## Personalizar

**Ajustes del equipo.** `~/.config/hypr/equipo.lua` guarda la distribución del teclado y la escala de la pantalla. El instalador lo crea una vez y no lo vuelve a tocar.

**Temas.** Cada tema es un archivo de variables en `~/.config/hypr/themes/`. Para agregar uno basta copiar un archivo existente y cambiar los colores: aparece solo en el selector.

**Barra de laboratorio.** La máquina objetivo se define desde la terminal con `settarget 10.10.10.5 nombre` y se quita con `cleartarget`.

**Batería.** `sudo sh extras/limite-carga.sh` limita la carga al 80 %, lo que alarga su vida útil si el equipo pasa mucho tiempo enchufado. Con `100` al final se quita el límite.

## Estructura

| Carpeta | Contenido |
|---|---|
| `hypr/` | El escritorio para Apple Silicon: configuración de Hyprland, barra, menús, `preparar.sh` (primer arranque) e `instalar.sh` (escritorio) |
| `compartido/` | Lo que usan las dos variantes: kitty, zsh, temas y qutebrowser |
| `extras/` | Opcionales: límite de carga, LocalSend, NvChad, herramientas de BlackArch |
| `bspwm/` | La variante para máquina virtual (ver más abajo) |

## Variante para máquina virtual

Hyprland necesita una tarjeta de video real y en una máquina virtual se arrastra. Para ese caso está `bspwm/`, el mismo escritorio sobre X11 (bspwm, sxhkd, polybar, picom y rofi), con los mismos atajos, menús y temas. La uso en VMware Fusion.

No tiene instalador: cada carpeta se copia a su lugar en `~/.config`.

| Carpeta del repositorio | Destino |
|---|---|
| `bspwm/scripts/` | `~/.config/bspwm/scripts/` |
| `bspwm/sxhkd/` | `~/.config/sxhkd/` |
| `bspwm/polybar/` | `~/.config/polybar/` |
| `bspwm/picom/` | `~/.config/picom/` |
| `bspwm/rofi/` | `~/.config/rofi/` |
| `compartido/themes/` | `~/.config/bspwm/themes/` |
| `compartido/kitty/` | `~/.config/kitty/` |

`bspwm/instalacion/` trae scripts sueltos para esa máquina: pantalla Retina, bloqueo de pantalla, ampliar el disco y el permiso para apagar desde el menú.

Las dos variantes tienen menús y scripts parecidos a propósito: cada una es independiente y en un equipo se instala una sola.

## Problemas conocidos

- **Las teclas de volumen no responden justo después de instalar.** El audio queda activo desde el siguiente inicio de sesión.
- **La música de YouTube deja de sonar.** YouTube cambia seguido; se arregla con `sh extras/actualizar-yt-dlp.sh`.
- **Hyprland no parte.** El registro queda en `~/.cache/hyprland-inicio.log`, y la configuración se revisa con `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`.

## Créditos

- [Asahi Linux](https://asahilinux.org) y [Asahi ALARM](https://asahi-alarm.org), que hacen posible Linux en estos equipos.
- [gh0stzk](https://github.com/gh0stzk/dotfiles), cuyos diseños de menús inspiraron los de este repositorio.

## Licencia

[MIT](LICENSE)
