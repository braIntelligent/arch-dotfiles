# arch-dotfiles

Configuración de mi escritorio en Arch Linux ARM (aarch64), en dos variantes con los mismos atajos, barra, menús y temas:

- **bspwm (X11):** bspwm, sxhkd, polybar, picom, rofi y kitty. Es la que uso en una máquina virtual de VMware Fusion.
- **Hyprland (Wayland):** Hyprland, waybar, rofi 2 y kitty. Pensada para instalar en un equipo real con Asahi ALARM.

## Instalar la variante Hyprland

Sobre un Arch Linux ARM ya instalado, con un usuario que tenga `sudo`:

```sh
sudo pacman -Syu git
git clone https://github.com/braIntelligent/arch-dotfiles.git
cd arch-dotfiles
sh hypr/instalar.sh
```

El script instala los paquetes, compila rofi 2 (los repositorios traen la 1.7.5, que no funciona en Wayland), copia la configuración y deja Hyprland arrancando al iniciar sesión en la primera consola. Detecta si corre en una máquina virtual y aplica los ajustes que eso requiere; se puede forzar con `--vm` o `--nativo`.

Está probado en una máquina virtual de VMware Fusion. En un equipo real todavía no.

### Desde Asahi ALARM Minimal recién instalado

La instalación mínima arranca en consola con el usuario `root` (clave `root`). Antes de correr el instalador hay que tener red y un usuario normal:

```sh
loadkeys la-latin1                                    # teclado latinoamericano en la consola
nmcli device wifi connect "NOMBRE_RED" password "CLAVE"
pacman -Syu git

useradd -m -G wheel -s /bin/bash USUARIO
passwd USUARIO
passwd                                                # cambiar la clave de root
EDITOR=vim visudo                                     # quitar el # de la linea "%wheel ALL=(ALL:ALL) ALL"
exit
```

Después se inicia sesión con ese usuario y se siguen los pasos de arriba (`git clone` y `sh hypr/instalar.sh`).

Los fondos de pantalla no vienen incluidos: van en `~/Pictures/wallpapers`.

## Carpetas

| Carpeta | Contenido |
|---|---|
| `hypr/` | Variante Hyprland: configuración, barra, menús y el instalador |
| `bspwm-scripts/`, `sxhkd/`, `polybar/`, `picom/`, `rofi/` | Variante bspwm |
| `kitty/`, `zsh/`, `themes/` | Compartido por ambas |
| `scripts/` | Instalación de herramientas y ajustes puntuales de la máquina virtual |

## Atajos principales

`Super` es la tecla Cmd o Windows. `Super + Shift + D` muestra la hoja completa.

| Atajo | Acción |
|---|---|
| `Super + Enter` | Terminal |
| `Super + Espacio` | Lanzador |
| `Super + h j k l` | Mover el foco |
| `Super + y u i o` | Abrir una terminal hacia ese lado |
| `Super + m` | Ocultar todo el escritorio o traerlo de vuelta |
| `Super + d` | Terminal desplegable |
| `Super + e` | Menú central |
| `Super + Shift + a` | Temas, con vista previa |
