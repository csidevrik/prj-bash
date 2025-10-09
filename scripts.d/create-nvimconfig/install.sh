#!/bin/bash

# ============================================
# Script de Despliegue Automático de Neovim
# Para Fedora Linux
# ============================================

set -e  # Detener en caso de error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_message() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# ============================================
# 1. VERIFICAR E INSTALAR NEOVIM
# ============================================

print_message "Verificando instalación de Neovim..."

if ! command -v nvim &> /dev/null; then
    print_warning "Neovim no está instalado. Instalando..."
    sudo dnf install -y neovim git
    print_success "Neovim instalado correctamente"
else
    print_success "Neovim ya está instalado"
    nvim --version | head -n 1
fi

# ============================================
# 2. HACER BACKUP DE CONFIGURACIÓN EXISTENTE
# ============================================

print_message "Verificando configuración existente..."

if [ -d "$HOME/.config/nvim" ]; then
    BACKUP_DIR="$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
    print_warning "Configuración existente encontrada. Creando backup en: $BACKUP_DIR"
    mv "$HOME/.config/nvim" "$BACKUP_DIR"
    print_success "Backup creado exitosamente"
fi

# ============================================
# 3. CREAR ESTRUCTURA DE DIRECTORIOS
# ============================================

print_message "Creando estructura de directorios..."

mkdir -p "$HOME/.config/nvim/lua/plugins"
print_success "Estructura de directorios creada"

# ============================================
# 4. CREAR init.lua
# ============================================

print_message "Creando init.lua..."

cat > "$HOME/.config/nvim/init.lua" << 'EOF'
-- ============================================
-- ~/.config/nvim/init.lua
-- CONFIGURACIÓN PRINCIPAL DE NEOVIM
-- ============================================
--
-- Opciones generales
vim.opt.number = true              -- Números de línea
vim.opt.relativenumber = true      -- Números relativos
vim.opt.mouse = 'a'                -- Habilitar mouse
vim.opt.ignorecase = true          -- Búsqueda sin distinguir mayúsculas
vim.opt.smartcase = true           -- Distinguir si hay mayúsculas en búsqueda
vim.opt.hlsearch = true            -- Resaltar búsquedas
vim.opt.wrap = true                -- Ajuste de línea
vim.opt.breakindent = true         -- Mantener indentación en líneas ajustadas
vim.opt.tabstop = 4                -- Espacios por tab
vim.opt.shiftwidth = 4             -- Espacios para indentación
vim.opt.expandtab = true           -- Usar espacios en vez de tabs
vim.opt.termguicolors = true       -- Colores verdaderos
vim.opt.cursorline = true          -- Resaltar línea actual
vim.opt.signcolumn = 'yes'         -- Columna de signos siempre visible
vim.opt.updatetime = 250           -- Tiempo de actualización más rápido
vim.opt.timeoutlen = 300           -- Tiempo de espera para secuencias
vim.opt.splitright = true          -- Split vertical a la derecha
vim.opt.splitbelow = true          -- Split horizontal abajo
vim.opt.clipboard = 'unnamedplus'  -- Usar clipboard del sistema
vim.opt.scrolloff = 8              -- Mantener líneas visibles arriba/abajo del cursor
vim.opt.undofile = true            -- Guardar historial de deshacer

-- Leader key
vim.g.mapleader = ' '              -- Espacio como tecla líder
vim.g.maplocalleader = ' '

-- ============================================
-- INSTALACIÓN AUTOMÁTICA DE LAZY.NVIM
-- ============================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================
-- CARGAR PLUGINS
-- ============================================

require("lazy").setup("plugins", {
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
})

-- ============================================
-- ATAJOS DE TECLADO ÚTILES
-- ============================================

local keymap = vim.keymap.set

-- Guardar archivo
keymap('n', '<leader>w', ':w<CR>', { desc = 'Guardar archivo' })

-- Salir
keymap('n', '<leader>q', ':q<CR>', { desc = 'Salir' })

-- Guardar y salir
keymap('n', '<leader>x', ':wq<CR>', { desc = 'Guardar y salir' })

-- Limpiar resaltado de búsqueda
keymap('n', '<Esc>', ':noh<CR>', { silent = true })

-- Mejor navegación entre ventanas
keymap('n', '<C-h>', '<C-w>h', { desc = 'Ir a ventana izquierda' })
keymap('n', '<C-j>', '<C-w>j', { desc = 'Ir a ventana abajo' })
keymap('n', '<C-k>', '<C-w>k', { desc = 'Ir a ventana arriba' })
keymap('n', '<C-l>', '<C-w>l', { desc = 'Ir a ventana derecha' })

-- Redimensionar ventanas
keymap('n', '<C-Up>', ':resize +2<CR>', { silent = true })
keymap('n', '<C-Down>', ':resize -2<CR>', { silent = true })
keymap('n', '<C-Left>', ':vertical resize -2<CR>', { silent = true })
keymap('n', '<C-Right>', ':vertical resize +2<CR>', { silent = true })

-- Navegar por buffers
keymap('n', '<Tab>', ':bnext<CR>', { desc = 'Buffer siguiente' })
keymap('n', '<S-Tab>', ':bprevious<CR>', { desc = 'Buffer anterior' })
keymap('n', '<leader>bd', ':bdelete<CR>', { desc = 'Cerrar buffer' })

-- Mover líneas en modo visual
keymap('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Mover línea abajo' })
keymap('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Mover línea arriba' })

-- Mejor indentación en modo visual
keymap('v', '<', '<gv', { desc = 'Indentar izquierda' })
keymap('v', '>', '>gv', { desc = 'Indentar derecha' })

-- Pegar sin perder el contenido del portapapeles
keymap('x', '<leader>p', '"_dP', { desc = 'Pegar sin reemplazar' })

-- Explorador de archivos
keymap('n', '<leader>e', ':Explore<CR>', { desc = 'Abrir explorador' })

-- Split de ventanas
keymap('n', '<leader>sv', ':vsplit<CR>', { desc = 'Split vertical' })
keymap('n', '<leader>sh', ':split<CR>', { desc = 'Split horizontal' })

-- ============================================
-- AUTOCOMANDOS ÚTILES
-- ============================================

-- Resaltar al copiar texto
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 })
  end,
})

-- Recordar posición del cursor
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ============================================
-- TEMA Y COLORES
-- ============================================

-- Esquema de color integrado (puedes cambiarlo)
vim.cmd.colorscheme('habamax')

-- ============================================
-- EXPLORADOR DE ARCHIVOS MEJORADO
-- ============================================

-- Configuración del explorador netrw
vim.g.netrw_banner = 0             -- Ocultar banner
vim.g.netrw_liststyle = 3          -- Vista de árbol
vim.g.netrw_browse_split = 4       -- Abrir en ventana anterior
vim.g.netrw_altv = 1
vim.g.netrw_winsize = 25           -- Ancho del explorador

print("✓ Neovim configurado correctamente")
EOF

print_success "init.lua creado exitosamente"

# ============================================
# 5. CREAR ARCHIVOS DE PLUGINS
# ============================================

print_message "Creando archivos de plugins..."

# tokyonight.lua
cat > "$HOME/.config/nvim/lua/plugins/tokyonight.lua" << 'EOF'
-- ~/.config/nvim/lua/plugins/tokyonight.lua
return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd([[colorscheme tokyonight-night]])
  end,
}
EOF
print_success "tokyonight.lua creado"

# nvim-tree.lua
cat > "$HOME/.config/nvim/lua/plugins/nvim-tree.lua" << 'EOF'
-- ~/.config/nvim/lua/plugins/nvim-tree.lua
return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("nvim-tree").setup({
      view = {
        width = 30,
      },
      renderer = {
        group_empty = true,
      },
      filters = {
        dotfiles = false,
      },
    })
    
    vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle explorador' })
  end,
}
EOF
print_success "nvim-tree.lua creado"

# telescope.lua
cat > "$HOME/.config/nvim/lua/plugins/telescope.lua" << 'EOF'
-- ~/.config/nvim/lua/plugins/telescope.lua
return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.5',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Buscar archivos' })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Buscar texto' })
    vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Buscar buffers' })
    vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Buscar ayuda' })
  end,
}
EOF
print_success "telescope.lua creado"

# treesitter.lua
cat > "$HOME/.config/nvim/lua/plugins/treesitter.lua" << 'EOF'
-- ~/.config/nvim/lua/plugins/treesitter.lua
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "lua", "vim", "python", "javascript", "html", "css", "bash" },
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
    })
  end,
}
EOF
print_success "treesitter.lua creado"

# cmp.lua
cat > "$HOME/.config/nvim/lua/plugins/cmp.lua" << 'EOF'
-- ~/.config/nvim/lua/plugins/cmp.lua
return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          else
            fallback()
          end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_previous_item()
          else
            fallback()
          end
        end, { 'i', 's' }),
      }),
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' },
      }),
    })
  end,
}
EOF
print_success "cmp.lua creado"

# lualine.lua
cat > "$HOME/.config/nvim/lua/plugins/lualine.lua" << 'EOF'
-- ~/.config/nvim/lua/plugins/lualine.lua
return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('lualine').setup({
      options = {
        theme = 'tokyonight',
      },
    })
  end,
}
EOF
print_success "lualine.lua creado"

# comment.lua
cat > "$HOME/.config/nvim/lua/plugins/comment.lua" << 'EOF'
-- ~/.config/nvim/lua/plugins/comment.lua
return {
  'numToStr/Comment.nvim',
  config = function()
    require('Comment').setup()
  end,
}
EOF
print_success "comment.lua creado"

# autopairs.lua
cat > "$HOME/.config/nvim/lua/plugins/autopairs.lua" << 'EOF'
-- ~/.config/nvim/lua/plugins/autopairs.lua
return {
  'windwp/nvim-autopairs',
  event = "InsertEnter",
  config = function()
    require("nvim-autopairs").setup({})
  end,
}
EOF
print_success "autopairs.lua creado"

# ============================================
# 6. INSTALAR PLUGINS
# ============================================

print_message "Instalando plugins de Neovim..."
print_warning "Esto puede tardar unos minutos..."

# Ejecutar nvim de forma no interactiva para instalar plugins
nvim --headless "+Lazy! sync" +qa

print_success "Plugins instalados exitosamente"

# ============================================
# 7. RESUMEN
# ============================================

echo ""
echo "============================================"
print_success "INSTALACIÓN COMPLETADA"
echo "============================================"
echo ""
echo "Configuración instalada en: $HOME/.config/nvim"
echo ""
echo "Plugins instalados:"
echo "  • TokyoNight (tema)"
echo "  • nvim-tree (explorador de archivos)"
echo "  • Telescope (búsqueda difusa)"
echo "  • Treesitter (syntax highlighting)"
echo "  • nvim-cmp (autocompletado)"
echo "  • lualine (barra de estado)"
echo "  • Comment.nvim (comentarios)"
echo "  • nvim-autopairs (auto pares)"
echo ""
echo "Atajos principales:"
echo "  • <Space>e - Toggle explorador de archivos"
echo "  • <Space>ff - Buscar archivos"
echo "  • <Space>fg - Buscar texto"
echo "  • gcc - Comentar/descomentar línea"
echo "  • <Space>w - Guardar archivo"
echo "  • <Space>q - Salir"
echo ""
print_success "¡Listo para usar Neovim!"
echo ""

if [ -n "$BACKUP_DIR" ]; then
    print_warning "Tu configuración anterior fue respaldada en: $BACKUP_DIR"
fi