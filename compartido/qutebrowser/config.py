# qutebrowser: navegador liviano que se maneja con el teclado.
# Ayuda dentro del navegador: :help    Lo basico: o abre una direccion, f sigue un
# enlace, d cierra la pestana, J y K cambian de pestana, H y L van atras y adelante.
import os

config.load_autoconfig()    # respeta lo que se cambie con :set dentro del navegador

c.fonts.default_family = "Hack Nerd Font"
c.fonts.default_size = "11pt"
c.colors.webpage.preferred_color_scheme = "dark"    # pide a los sitios su version oscura
c.tabs.padding = {"top": 5, "bottom": 5, "left": 9, "right": 9}
c.statusbar.padding = {"top": 4, "bottom": 4, "left": 6, "right": 6}

# ,p  pasa el trafico por el proxy local (Caido o Burp en 127.0.0.1:8080) o lo saca.
# Vale hasta cerrar el navegador. El certificado: extras/certificado-proxy.sh
config.bind(",p", "config-cycle -p -t content.proxy http://127.0.0.1:8080 system")

# colores del tema activo: los escribe set-theme.sh
if os.path.exists(os.path.join(str(config.configdir), "colores.py")):
    config.source("colores.py")
