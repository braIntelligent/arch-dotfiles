-- Hyprland: replica del escritorio bspwm (mismos atajos).
-- Sintaxis Lua de Hyprland 0.55+. Referencia: https://wiki.hypr.land/Configuring/

local HOME = os.getenv("HOME")
local S = HOME .. "/.config/hypr/scripts/"
-- dofile y no require: asi los colores se releen en cada "hyprctl reload"
local c = dofile(HOME .. "/.config/hypr/colores.lua")

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
    -- Pantalla Retina del portatil: resolucion propia, todo al doble de tamano.
    hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 2 })
end

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

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
    },
    input = {
        kb_layout    = "latam",
        follow_mouse = 1,
        -- desplazamiento: "natural" es el sentido del Mac (el contenido sigue a los dedos).
        -- scroll_factor es la velocidad: 1.0 normal, menos es mas lento, mas es mas rapido.
        natural_scroll = true,          -- mouse
        scroll_factor  = 1.0,
        touchpad = {
            natural_scroll = true,      -- trackpad
            scroll_factor  = 1.0,
        },
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

------------------------------------------------------------------ arranque
hl.on("hyprland.start", function()
    hl.exec_cmd(S .. "aplicar-fondo.sh")
    hl.exec_cmd(S .. "barra.sh")
end)

------------------------------------------------------------------ atajos
local M = "SUPER"
local sh = hl.dsp.exec_cmd

-- lanzadores
hl.bind(M .. " + Return", sh(terminal),  { description = "terminal" })
hl.bind(M .. " + space",  sh("pkill -x rofi || rofi -show run"), { description = "lanzador (la misma tecla lo cierra)" })
hl.bind(M .. " + N",      sh("firefox"), { description = "navegador" })

-- menus. En Wayland la tecla la recibe Hyprland y no rofi, asi que el "cerrar con la
-- misma tecla" se hace aqui: si hay un rofi abierto se cierra; si no, se abre el menu.
local function menu(script) return sh("pkill -x rofi || " .. S .. script) end
hl.bind(M .. " + E",         menu("menu.sh"),           { description = "menu central" })
hl.bind(M .. " + SHIFT + E", menu("powermenu.sh"),      { description = "menu de energia" })
hl.bind(M .. " + SHIFT + C", menu("wallpaper.sh"),      { description = "fondos" })
hl.bind(M .. " + SHIFT + A", menu("theme-selector.sh"), { description = "temas" })
hl.bind(M .. " + SHIFT + D", menu("cheatsheet.sh"),     { description = "hoja de atajos" })
hl.bind(M .. " + SHIFT + B", sh(S .. "barra.sh cambiar"), { description = "barra: normal / HTB" })
hl.bind(M .. " + SHIFT + R", menu("configs.sh"),        { description = "editar configs" })
hl.bind(M .. " + SHIFT + I", menu("keyboard.sh"),       { description = "distribucion de teclado" })
hl.bind(M .. " + B",         sh("pkill -USR1 -x waybar"),  { description = "ocultar/mostrar la barra" })
hl.bind(M .. " + P",         sh(S .. "captura.sh zona"),     { description = "captura de zona" })
hl.bind(M .. " + SHIFT + P", sh(S .. "captura.sh pantalla"), { description = "captura de pantalla completa" })
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
hl.bind(M .. " + BackSpace", tecla_mac("SHIFT", "Home", "CTRL", "u"), { description = "borrar la linea" })

-- teclas de funcion del portatil: volumen, brillo de pantalla y del teclado.
-- "locked" las deja funcionar con la pantalla bloqueada; "repeating", al mantenerlas.
local tecla = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume",  sh("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), tecla)
hl.bind("XF86AudioLowerVolume",  sh("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      tecla)
hl.bind("XF86AudioMute",         sh("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",      sh("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })
hl.bind("XF86MonBrightnessUp",   sh("brightnessctl -e4 -n2 set 5%+"),                  tecla)
hl.bind("XF86MonBrightnessDown", sh("brightnessctl -e4 -n2 set 5%-"),                  tecla)
hl.bind("XF86KbdBrightnessUp",   sh("brightnessctl --device='*kbd_backlight' set 10%+"), tecla)
hl.bind("XF86KbdBrightnessDown", sh("brightnessctl --device='*kbd_backlight' set 10%-"), tecla)
-- el MacBook Air no trae teclas para la luz del teclado: Super + las de brillo
hl.bind(M .. " + XF86MonBrightnessUp",   sh("brightnessctl --device='*kbd_backlight' set 10%+"),
        { locked = true, repeating = true, description = "luz del teclado: subir" })
hl.bind(M .. " + XF86MonBrightnessDown", sh("brightnessctl --device='*kbd_backlight' set 10%-"),
        { locked = true, repeating = true, description = "luz del teclado: bajar" })

-- sesion
hl.bind(M .. " + R", sh("hyprctl reload"), { description = "recargar la configuracion" })
hl.bind(M .. " + Q", sh(S .. "salir.sh"),  { description = "salir de Hyprland (pide confirmacion)" })
