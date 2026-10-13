-- arch-dotfiles: Neovim liviano, sin complementos, con los colores del tema activo.
-- (La linea de arriba la usa instalar.sh para saber que este archivo es el suyo.)
-- Los colores salen de colors/tema.lua, que escribe set-theme.sh al cambiar de tema.
-- Si prefieres NvChad: sh extras/instalar-nvchad.sh (respalda esta configuracion).

vim.g.mapleader = " "

local o = vim.opt
o.number = true
o.relativenumber = true
o.cursorline = true
o.signcolumn = "yes"
o.termguicolors = true
o.mouse = "a"
o.clipboard = "unnamedplus"     -- copiar y pegar usan el portapapeles del sistema
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.smartindent = true
o.ignorecase = true
o.smartcase = true
o.wrap = false
o.scrolloff = 6
o.splitright = true
o.splitbelow = true
o.undofile = true
o.updatetime = 300
o.showmode = false              -- el modo ya sale en la barra de abajo
o.laststatus = 3                -- una sola barra de estado para todas las ventanas
o.fillchars = { eob = " " }     -- sin "~" en las lineas vacias del final
o.completeopt = { "menuone", "noselect", "popup" }

pcall(vim.cmd.colorscheme, "tema")

-- Barra de estado: modo, archivo y posicion, con los colores del tema
local modos = {
    n = "NORMAL", i = "INSERTAR", v = "VISUAL", V = "V-LINEA", ["\22"] = "V-BLOQUE",
    c = "COMANDO", R = "REEMPLAZAR", t = "TERMINAL", s = "SELECCION",
}
function _G.barra_estado()
    local m = modos[vim.fn.mode()] or vim.fn.mode()
    return table.concat({
        "%#StatusLineModo# ", m, " %#StatusLine# %f %m%r%=",
        "%{&filetype} ", "%#StatusLineModo# %l:%c %#StatusLine#",
    })
end
o.statusline = "%!v:lua.barra_estado()"

-- Atajos (la tecla lider es Espacio)
local map = vim.keymap.set
map("n", "<leader>w", "<cmd>write<cr>", { desc = "guardar" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "cerrar" })
map("n", "<leader>e", "<cmd>Explore<cr>", { desc = "explorador de archivos" })
map("n", "<leader>b", "<cmd>buffers<cr>:buffer ", { desc = "cambiar de archivo abierto" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "quitar el resaltado de la busqueda" })
map("n", "<C-h>", "<C-w>h"); map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k"); map("n", "<C-l>", "<C-w>l")
map("v", "<", "<gv"); map("v", ">", ">gv")      -- seguir indentando sin perder la seleccion

-- Resaltar un instante lo que se copia
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})

-- En kitty, quitar el margen de la terminal mientras Neovim esta abierto, para que
-- el archivo llegue hasta los bordes; al salir vuelve. (kitty.conf permite solo esa orden.)
if vim.env.KITTY_WINDOW_ID and not vim.env.TMUX then
    local function margen(valor)
        vim.fn.system({ "kitty", "@", "set-spacing", "padding=" .. valor })
    end
    vim.api.nvim_create_autocmd("VimEnter", { callback = function() margen("0") end })
    vim.api.nvim_create_autocmd("VimLeavePre", { callback = function() margen("default") end })
end
