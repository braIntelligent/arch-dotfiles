-- Hyprland para Mac con Apple Silicon (Asahi ALARM).
-- Sintaxis Lua de Hyprland 0.55+. Referencia: https://wiki.hypr.land/Configuring/

local HOME = os.getenv("HOME")
local S = HOME .. "/.config/hypr/scripts/"
-- dofile y no require: asi los colores se releen en cada "hyprctl reload"
local c = dofile(HOME .. "/.config/hypr/colores.lua")

-- Ajustes propios del equipo: ~/.config/hypr/equipo.lua (lo crea instalar.sh).
-- Si falta, o no trae algun valor, se usan estos.
local equipo = { teclado = "us", escala = 2 }
local ok_equipo, propio = pcall(dofile, HOME .. "/.config/hypr/equipo.lua")
if ok_equipo and type(propio) == "table" then
    for k, v in pairs(propio) do equipo[k] = v end
end

-- Si existe ~/.config/hypr/es-vm se aplican los ajustes para maquina virtual
-- (lo crea instalar.sh cuando detecta una VM; en un equipo real no existe).
local marca = io.open(HOME .. "/.config/hypr/es-vm")
local es_vm = marca ~= nil
if marca then marca:close() end

-- En VMware, las aplicaciones que dibujan con OpenGL directo sobre Wayland fallan
-- al entregar su imagen (wl_surface.attach). kitty funciona si dibuja por software.
local terminal = es_vm and "env LIBGL_ALWAYS_SOFTWARE=1 kitty" or "kitty"

------------------------------------------------------------------ pantalla
if es_vm then
    -- La VM anuncia 1280x800 como preferida; se pide la real y se escala al doble.
    hl.monitor({ output = "", mode = "2560x1600@60", position = "auto", scale = 2 })
else
    -- Pantalla del portatil (eDP-1 es el panel interno): resolucion propia y la
    -- escala de equipo.lua (2 en las pantallas Retina).
    hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = equipo.escala })
    -- Cualquier otra pantalla que se conecte: su resolucion propia, al lado, y la
    -- escala que le corresponda segun su tamano.
    hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
end

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
-- las aplicaciones Qt (KDE Connect) toman el aspecto de las GTK: oscuro, como el resto
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")

------------------------------------------------------------------ aspecto
hl.config({
    general = {
        gaps_in     = 6,
        gaps_out    = 12,
        border_size = 2,
        col = {
            active_border   = "rgb(" .. c.accent .. ")",
            inactive_border = "rgb(" .. c.bg_alt .. ")",
        },
        layout = "dwindle",
    },
    decoration = {
        rounding = 10,
        -- En la VM cada efecto se paga caro (2560x1600 sobre una tarjeta virtual):
        -- sin sombras y con el desenfoque mas barato posible.
        shadow = { enabled = not es_vm, range = 12, render_power = 3, color = 0x66000000 },
        blur   = { enabled = true, size = es_vm and 3 or 5, passes = es_vm and 1 or 2 },
    },
    animations = { enabled = true },
    dwindle = { preserve_split = true },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        -- con la pantalla apagada por inactividad, una tecla o el trackpad la encienden
        key_press_enables_dpms  = true,
        mouse_move_enables_dpms = true,
    },
    input = {
        kb_layout    = equipo.teclado,
        follow_mouse = 1,
        -- desplazamiento: "natural" es el sentido del Mac (el contenido sigue a los dedos).
        -- scroll_factor es la velocidad: 1.0 normal, menos es mas lento, mas es mas rapido.
        natural_scroll = true,          -- mouse
        scroll_factor  = 1.0,
        touchpad = {
            natural_scroll = true,      -- trackpad
            scroll_factor  = 1.0,
            -- clic secundario apretando el trackpad con dos dedos, como en macOS
            -- (sin esto, el clic secundario es apretar en la esquina inferior derecha)
            clickfinger_behavior = true,
            -- solo vale apretar: tocar sin apretar no hace clic
            tap_to_click = false,
        },
    },
    gestures = {
        -- cambio de escritorio con tres dedos: basta un deslizamiento corto.
        -- distance: recorrido total en pixeles; cancel_ratio: que parte hay que
        -- recorrer para que cambie; min_speed: un gesto rapido cambia aunque sea corto
        workspace_swipe_distance           = 150,
        workspace_swipe_cancel_ratio       = 0.15,
        workspace_swipe_min_speed_to_force = 5,
    },
    ecosystem = { no_update_news = true, no_donation_nag = true },
})

-- Animaciones cortas. "speed" va en decimas de segundo: menos es mas rapido.
-- Para apagarlas del todo: animations = { enabled = false } mas arriba.
hl.animation({ leaf = "global",     enabled = true, speed = 2,   bezier = "default" })
hl.animation({ leaf = "windows",    enabled = true, speed = 2,   bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 1.5, bezier = "default" })
hl.animation({ leaf = "layers",     enabled = true, speed = 1.5, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2,   bezier = "default" })
hl.animation({ leaf = "border",     enabled = false })

-- tres dedos hacia los lados en el trackpad: cambiar de escritorio
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

------------------------------------------------------------------ reglas
-- ignorar las peticiones de "maximizar" de las aplicaciones: kitty la pide al
-- abrir y quedaba tapando a las demas ventanas
hl.window_rule({
    name  = "sin-maximizar",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- terminal desplegable: vive en un escritorio especial, flotante y arriba
hl.window_rule({
    name  = "scratchpad",
    match = { class = "^scratchpad$" },
    workspace = "special:scratch",
    float = true,
    size  = { "monitor_w * 0.6", "monitor_h * 0.48" },
    move  = { "monitor_w * 0.2", 40 },
})

-- VPN (openvpn): ventana flotante con el registro; cerrarla corta la VPN
hl.window_rule({
    name  = "vpn",
    match = { class = "^vpn$" },
    float = true,
    size  = { "monitor_w * 0.6", "monitor_h * 0.5" },
    move  = { "monitor_w * 0.2", "monitor_h * 0.25" },
})

-- bluetui: ventana flotante al centro. stay_focused: mientras este abierta se queda
-- con el teclado, aunque el puntero pase sobre otra ventana (si no, las teclas
-- se iban a la de atras). Se cierra con q o con Super + G.
hl.window_rule({
    name  = "bluetooth",
    match = { class = "^bluetooth$" },
    float = true,
    stay_focused = true,
    size  = { "monitor_w * 0.6", "monitor_h * 0.7" },
    move  = { "monitor_w * 0.2", "monitor_h * 0.15" },
})

------------------------------------------------------------------ arranque
hl.on("hyprland.start", function()
    hl.exec_cmd(S .. "aplicar-fondo.sh")
    hl.exec_cmd(S .. "barra.sh")
    hl.exec_cmd("mako")        -- notificaciones
    -- modo oscuro para los navegadores y las aplicaciones GTK. set-theme.sh tambien lo pide,
    -- pero si la instalacion se hizo sin sesion grafica ese ajuste no quedo guardado
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme prefer-dark")
    hl.exec_cmd("hypridle")    -- bloqueo y apagado de pantalla por inactividad
    -- historial del portapapeles: guarda cada texto o imagen que se copia
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    -- dialogo de clave para las aplicaciones que piden permisos de administrador
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd(S .. "bateria-aviso.sh")   -- avisos de bateria baja
    hl.exec_cmd("hyprsunset")              -- luz nocturna por horario (hyprsunset.conf)
    hl.exec_cmd("kdeconnectd")             -- enlace con el telefono (KDE Connect)
end)

------------------------------------------------------------------ atajos
local M = "SUPER"
local sh = hl.dsp.exec_cmd

-- lanzadores
hl.bind(M .. " + Return", sh(terminal),  { description = "terminal" })
hl.bind(M .. " + space",  sh("pkill -x rofi || rofi -show run"), { description = "lanzador (la misma tecla lo cierra)" })
hl.bind(M .. " + N",      sh("qutebrowser"), { description = "navegador (qutebrowser)" })
hl.bind(M .. " + SHIFT + F", sh("thunar"), { description = "archivos" })

-- menus. En Wayland la tecla la recibe Hyprland y no rofi, asi que el "cerrar con la
-- misma tecla" se hace aqui: si hay un rofi abierto se cierra; si no, se abre el menu.
local function menu(script) return sh("pkill -x rofi || " .. S .. script) end
hl.bind(M .. " + E",         menu("menu.sh"),           { description = "menu central" })
hl.bind(M .. " + SHIFT + E", menu("powermenu.sh"),      { description = "menu de energia" })
hl.bind(M .. " + SHIFT + C", menu("wallpaper.sh"),      { description = "fondos" })
hl.bind(M .. " + SHIFT + A", menu("theme-selector.sh"), { description = "temas" })
hl.bind(M .. " + SHIFT + D", menu("cheatsheet.sh"),     { description = "hoja de atajos" })
hl.bind(M .. " + SHIFT + B", sh(S .. "barra.sh cambiar"), { description = "barra: normal / HTB" })
hl.bind(M .. " + G",         sh(S .. "bluetooth.sh"),     { description = "bluetooth (la misma tecla lo cierra)" })
hl.bind(M .. " + SHIFT + N", sh("makoctl dismiss -a"),    { description = "cerrar las notificaciones" })
hl.bind(M .. " + SHIFT + G", sh(S .. "grabar.sh"),        { description = "grabar la pantalla / detener" })
hl.bind(M .. " + SHIFT + M", menu("musica.sh"),         { description = "musica de YouTube: buscar, detener" })
hl.bind(M .. " + SHIFT + O", menu("vpn.sh"),            { description = "VPN de HTB (OpenVPN)" })
hl.bind(M .. " + SHIFT + V", menu("portapapeles.sh"),   { description = "historial del portapapeles" })
hl.bind(M .. " + SHIFT + R", menu("configs.sh"),        { description = "editar configs" })
hl.bind(M .. " + SHIFT + I", menu("keyboard.sh"),       { description = "distribucion de teclado" })
hl.bind(M .. " + B",         sh("pkill -USR1 -x waybar"),  { description = "ocultar/mostrar la barra" })
hl.bind(M .. " + P",         sh(S .. "captura.sh zona"),     { description = "captura de zona" })
hl.bind(M .. " + SHIFT + P", sh(S .. "captura.sh pantalla"), { description = "captura de pantalla completa" })
hl.bind(M .. " + SHIFT + S", menu("screenshot.sh"),          { description = "menu de capturas y grabacion" })
hl.bind(M .. " + SHIFT + X", sh(S .. "lock.sh"),           { description = "bloquear pantalla" })

-- ventanas
hl.bind(M .. " + W",         hl.dsp.window.close(), { description = "cerrar ventana" })
hl.bind(M .. " + SHIFT + W", hl.dsp.window.kill(),  { description = "matar ventana" })
hl.bind(M .. " + T", hl.dsp.window.float({ action = "disable" }), { description = "ventana en mosaico" })
hl.bind(M .. " + S", hl.dsp.window.float({ action = "enable" }),  { description = "ventana flotante" })
hl.bind(M .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "pantalla completa" })
hl.bind(M .. " + SHIFT + T", hl.dsp.window.pseudo(), { description = "pseudo-mosaico" })

-- foco / intercambio / abrir terminal hacia un lado
local dirs = {
    { foco = "H", abrir = "Y", dir = "left",  pre = "l", es = "izquierda" },
    { foco = "J", abrir = "U", dir = "down",  pre = "d", es = "abajo" },
    { foco = "K", abrir = "I", dir = "up",    pre = "u", es = "arriba" },
    { foco = "L", abrir = "O", dir = "right", pre = "r", es = "derecha" },
}
for _, d in ipairs(dirs) do
    hl.bind(M .. " + " .. d.foco,         hl.dsp.focus({ direction = d.dir }),       { description = "foco a la " .. d.es })
    hl.bind(M .. " + SHIFT + " .. d.foco, hl.dsp.window.swap({ direction = d.dir }), { description = "intercambiar hacia " .. d.es })
    hl.bind(M .. " + " .. d.abrir, function()
        hl.dispatch(hl.dsp.layout("preselect " .. d.pre))
        hl.dispatch(hl.dsp.exec_cmd(terminal))
    end, { description = "terminal hacia " .. d.es })
end

-- escritorios 1 a 5
for i = 1, 5 do
    hl.bind(M .. " + " .. i,         hl.dsp.focus({ workspace = i }),       { description = "ir al escritorio " .. i })
    hl.bind(M .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }), { description = "mandar al escritorio " .. i })
end

-- mover (flotante) y redimensionar con flechas
local flechas = {
    { "left", -40, 0, "izquierda" }, { "down", 0, 40, "abajo" },
    { "up", 0, -40, "arriba" },      { "right", 40, 0, "derecha" },
}
for _, f in ipairs(flechas) do
    hl.bind(M .. " + " .. f[1], hl.dsp.window.move({ x = f[2], y = f[3], relative = true }),
            { repeating = true, description = "mover ventana flotante " .. f[4] })
    hl.bind(M .. " + SHIFT + " .. f[1], hl.dsp.window.resize({ x = f[2], y = f[3], relative = true }),
            { repeating = true, description = "agrandar/achicar " .. f[4] })
end
hl.bind(M .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(M .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ocultar todas las ventanas del escritorio / traerlas de vuelta
local foco_guardado = {}   -- por escritorio: que ventana tenia el foco al ocultar
hl.bind(M .. " + M", function()
    local ws = hl.get_active_workspace()
    if not ws then return end
    local oculto = "special:oculto" .. ws.id
    local ok, guardadas = pcall(hl.get_workspace_windows, oculto)
    if ok and guardadas and #guardadas > 0 then
        local ultima
        for _, v in ipairs(guardadas) do
            ultima = "address:" .. v.address
            hl.dispatch(hl.dsp.window.move({ window = ultima, workspace = ws.id, follow = false }))
        end
        -- al volver nadie queda con el foco: se devuelve a la que lo tenia
        hl.dispatch(hl.dsp.focus({ window = foco_guardado[ws.id] or ultima }))
        foco_guardado[ws.id] = nil
    else
        local activa = hl.get_active_window()
        foco_guardado[ws.id] = activa and ("address:" .. activa.address) or nil
        for _, v in ipairs(hl.get_workspace_windows(ws.id)) do
            hl.dispatch(hl.dsp.window.move({ window = "address:" .. v.address, workspace = oculto, follow = false }))
        end
    end
end, { description = "ocultar todo / traer de vuelta" })

-- terminal desplegable
hl.bind(M .. " + D", function()
    local ok, v = pcall(hl.get_workspace_windows, "special:scratch")
    if not ok or not v or #v == 0 then
        hl.dispatch(hl.dsp.exec_cmd(terminal .. " --class scratchpad"))
    end
    hl.dispatch(hl.dsp.workspace.toggle_special("scratch"))
end, { description = "terminal desplegable" })

-- edicion estilo Mac: en terminales copiar/pegar van con Ctrl+Shift
local function es_terminal()
    local v = hl.get_active_window()
    return v ~= nil and (v.class:find("kitty") ~= nil or v.class == "scratchpad")
end
local function tecla_mac(mods, key, mods_term, key_term)
    return function()
        if es_terminal() then
            if not key_term then return end
            hl.dispatch(hl.dsp.send_shortcut({ mods = mods_term, key = key_term }))
        else
            hl.dispatch(hl.dsp.send_shortcut({ mods = mods, key = key }))
        end
    end
end
hl.bind(M .. " + C", tecla_mac("CTRL", "c", "CTRL SHIFT", "c"), { description = "copiar" })
hl.bind(M .. " + V", tecla_mac("CTRL", "v", "CTRL SHIFT", "v"), { description = "pegar" })
hl.bind(M .. " + X", tecla_mac("CTRL", "x"), { description = "cortar" })
hl.bind(M .. " + A", tecla_mac("CTRL", "a"), { description = "seleccionar todo" })
hl.bind(M .. " + Z", tecla_mac("CTRL", "z"), { description = "deshacer" })
hl.bind(M .. " + SHIFT + Z", tecla_mac("CTRL SHIFT", "z"), { description = "rehacer" })
-- borrar la linea: en la terminal es Ctrl+U; en lo demas no hay una tecla unica,
-- asi que se selecciona hasta el inicio (Shift+Inicio) y se borra lo seleccionado
hl.bind(M .. " + BackSpace", function()
    if es_terminal() then
        hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL", key = "u" }))
    else
        hl.dispatch(hl.dsp.send_shortcut({ mods = "SHIFT", key = "Home" }))
        hl.dispatch(hl.dsp.send_shortcut({ mods = "", key = "BackSpace" }))
    end
end, { description = "borrar la linea" })

-- teclas de funcion del portatil: volumen, brillo de pantalla y del teclado.
-- "locked" las deja funcionar con la pantalla bloqueada; "repeating", al mantenerlas.
local tecla = { locked = true, repeating = true }
local N = S .. "nivel.sh "    -- hace el cambio y muestra el nivel en pantalla
hl.bind("XF86AudioRaiseVolume",  sh(N .. "vol +"),     tecla)
hl.bind("XF86AudioLowerVolume",  sh(N .. "vol -"),     tecla)
hl.bind("XF86AudioMute",         sh(N .. "vol mudo"),  { locked = true })
hl.bind("XF86AudioMicMute",      sh(N .. "mic mudo"),  { locked = true })
hl.bind("XF86AudioPlay",         sh("playerctl play-pause"), { locked = true })
-- si suena la musica de musica.sh, "siguiente" salta de tema ahi; si no, al reproductor
hl.bind("XF86AudioNext",         sh(S .. "musica.sh siguiente || playerctl next"), { locked = true })
hl.bind("XF86AudioPrev",         sh("playerctl previous"),   { locked = true })
hl.bind("XF86MonBrightnessUp",   sh(N .. "brillo +"),  tecla)
hl.bind("XF86MonBrightnessDown", sh(N .. "brillo -"),  tecla)
hl.bind("XF86KbdBrightnessUp",   sh(N .. "teclado +"), tecla)
hl.bind("XF86KbdBrightnessDown", sh(N .. "teclado -"), tecla)
-- el MacBook Air no trae teclas para la luz del teclado: Super + las de brillo
hl.bind(M .. " + XF86MonBrightnessUp",   sh(N .. "teclado +"),
        { locked = true, repeating = true, description = "luz del teclado: subir" })
hl.bind(M .. " + XF86MonBrightnessDown", sh(N .. "teclado -"),
        { locked = true, repeating = true, description = "luz del teclado: bajar" })

-- sesion
hl.bind(M .. " + R", sh("hyprctl reload"), { description = "recargar la configuracion" })
hl.bind(M .. " + Q", sh(S .. "salir.sh"),  { description = "salir de Hyprland (pide confirmacion)" })
