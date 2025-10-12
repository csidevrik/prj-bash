#!/bin/bash

# ============================================
# Script de Despliegue Automático de Neovim
# Versión Extendida con Plugins Adicionales
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
# 1. VERIFICAR E INSTALAR DEPENDENCIAS
# ============================================

print_message "Verificando instalación de dependencias..."

# Instalar Neovim y herramientas necesarias
if ! command -v nvim &> /dev/null; then
    print_warning "Neovim no está instalado. Instalando..."
    sudo dnf install -y neovim git ripgrep fd-find
    print_success "Neovim y dependencias instalados correctamente"
else
    print_success "Neovim ya está instalado"
    nvim --version | head -n 1
    
    # Verificar ripgrep y fd (útiles para Telescope)
    if ! command -v rg &> /dev/null; then
        print_warning "Instalando ripgrep (búsqueda rápida)..."
        sudo dnf install -y ripgrep
    fi
    
    if ! command -v fd &> /dev/null; then
        print_warning "Instalando fd-find (búsqueda de archivos)..."
        sudo dnf install -y fd-find
    fi
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
vim.opt.swapfile = false           -- No crear archivos swap

-- Leader key (debe ir antes de cargar plugins)
vim.g.mapleader = ' '
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
-- ATAJOS DE TECLADO
-- ============================================

local keymap = vim.keymap.set

-- Guardar y salir
keymap('n', '<leader>w', ':w<CR>', { desc = 'Guardar archivo' })
keymap('n', '<leader>q', ':q<CR>', { desc = 'Salir' })
keymap('n', '<leader>x', ':wq<CR>', { desc = 'Guardar y salir' })

-- Limpiar búsqueda
keymap('n', '<Esc>', ':noh<CR>', { silent = true })

-- Navegación entre ventanas
keymap('n', '<C-h>', '<C-w>h', { desc = 'Ventana izquierda' })
keymap('n', '<C-j>', '<C-w>j', { desc = 'Ventana abajo' })
keymap('n', '<C-k>', '<C-w>k', { desc = 'Ventana arriba' })
keymap('n', '<C-l>', '<C-w>l', { desc = 'Ventana derecha' })

-- Redimensionar ventanas
keymap('n', '<C-Up>', ':resize +2<CR>', { silent = true })
keymap('n', '<C-Down>', ':resize -2<CR>', { silent = true })
keymap('n', '<C-Left>', ':vertical resize -2<CR>', { silent = true })
keymap('n', '<C-Right>', ':vertical resize +2<CR>', { silent = true })

-- Buffers
keymap('n', '<Tab>', ':bnext<CR>', { desc = 'Buffer siguiente' })
keymap('n', '<S-Tab>', ':bprevious<CR>', { desc = 'Buffer anterior' })
keymap('n', '<leader>bd', ':bdelete<CR>', { desc = 'Cerrar buffer' })

-- Mover líneas
keymap('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Mover abajo' })
keymap('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Mover arriba' })

-- Indentación
keymap('v', '<', '<gv')
keymap('v', '>', '>gv')

-- Pegar sin reemplazar
keymap('x', '<leader>p', '"_dP')

-- Split
keymap('n', '<leader>sv', ':vsplit<CR>', { desc = 'Split vertical' })
keymap('n', '<leader>sh', ':split<CR>', { desc = 'Split horizontal' })

-- ============================================
-- AUTOCOMANDOS
-- ============================================

vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

print("✓ Neovim configurado correctamente")
EOF

print_success "init.lua creado exitosamente"

# ============================================
# 5. CREAR ARCHIVOS DE PLUGINS
# ============================================

print_message "Creando archivos de plugins..."

# ========== TEMAS DE COLORES ==========
cat > "$HOME/.config/nvim/lua/plugins/colorschemes.lua" << 'EOF'
-- ~/.config/nvim/lua/plugins/colorschemes.lua
-- Para cambiar de tema, cambia lazy = false en el que quieras usar
return {
  -- Catppuccin (TEMA ACTIVO)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        transparent_background = false,
      })
      vim.cmd([[colorscheme catppuccin-mocha]])
    end,
  },
  
  -- TokyoNight (disponible pero no activo)
  {
    "folke/tokyonight.nvim",
    lazy = true,
    priority = 1000,
  },
  
  -- Gruvbox (disponible pero no activo)
  {
    "ellisonleao/gruvbox.nvim",
    lazy = true,
    priority = 1000,
  },
  
  -- Rose Pine (disponible pero no activo)
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
  },
}
EOF
print_success "colorschemes.lua creado (Catppuccin activo)"

# ========== EXPLORADOR DE ARCHIVOS ==========
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

# ========== BÚSQUEDA DIFUSA ==========
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

# ========== SYNTAX HIGHLIGHTING ==========
cat > "$HOME/.config/nvim/lua/plugins/treesitter.lua" << 'EOF'
-- ~/.config/nvim/lua/plugins/treesitter.lua
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "lua", "vim", "python", "javascript", "html", "css", "bash", "json", "yaml" },
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

# ========== AUTOCOMPLETADO ==========
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

# ========== LÍNEA DE ESTADO ==========
cat > "$HOME/.config/nvim/lua/plugins/lualine.lua" << 'EOF'
-- ~/.config/nvim/lua/plugins/lualine.lua
return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('lualine').setup({
      options = {
        theme = 'auto',
      },
    })
  end,
}
EOF
print_success "lualine.lua creado"

# ========== COMENTARIOS ==========
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

# ========== AUTO PARES ==========
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

# ========== WHICH-KEY (Menú de atajos) ==========
cat > "$HOME/.config/nvim/lua/plugins/which-key.lua" << 'EOF'
-- ~/.config/nvim/lua/plugins/which-key.lua
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    require("which-key").setup()
  end,
}
EOF
print_success "which-key.lua creado"

# ========== GITSIGNS (Integración Git) ==========
cat > "$HOME/.config/nvim/lua/plugins/gitsigns.lua" << 'EOF'
-- ~/.config/nvim/lua/plugins/gitsigns.lua
return {
  'lewis6991/gitsigns.nvim',
  config = function()
    require('gitsigns').setup({
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end
        
        -- Navegación entre cambios
        map('n', ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, {expr=true, desc = 'Siguiente cambio'})

        map('n', '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, {expr=true, desc = 'Cambio anterior'})
      end
    })
  end,
}
EOF
print_success "gitsigns.lua creado"

# ========== INDENT BLANKLINE ==========
cat > "$HOME/.config/nvim/lua/plugins/indent-blankline.lua" << 'EOF'
-- ~/.config/nvim/lua/plugins/indent-blankline.lua
return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  config = function()
    require("ibl").setup()
  end,
}
EOF
print_success "indent-blankline.lua creado"

# ========== SURROUND ==========
cat > "$HOME/.config/nvim/lua/plugins/surround.lua" << 'EOF'
-- ~/.config/nvim/lua/plugins/surround.lua
return {
  "kylechui/nvim-surround",
  version = "*",
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup()
  end,
}
EOF
print_success "surround.lua creado"

# ========== BUFFERLINE (Pestañas de buffers) ==========
cat > "$HOME/.config/nvim/lua/plugins/bufferline.lua" << 'EOF'
-- ~/.config/nvim/lua/plugins/bufferline.lua
return {
  'akinsho/bufferline.nvim',
  version = "*",
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    require("bufferline").setup{
      options = {
        mode = "buffers",
        separator_style = "slant",
        always_show_bufferline = true,
        show_buffer_close_icons = true,
        show_close_icon = false,
        color_icons = true,
      },
    }
  end,
}
EOF
print_success "bufferline.lua creado"

# ========== TOGGLETERM (Terminal integrada) ==========
cat > "$HOME/.config/nvim/lua/plugins/toggleterm.lua" << 'EOF'
-- ~/.config/nvim/lua/plugins/toggleterm.lua
return {
  'akinsho/toggleterm.nvim',
  version = "*",
  config = function()
    require("toggleterm").setup({
      open_mapping = [[<c-\>]],
      direction = 'float',
      float_opts = {
        border = 'curved',
      },
    })
  end,
}
EOF
print_success "toggleterm.lua creado"

# ========== TROUBLE (Diagnósticos elegantes) ==========
cat > "$HOME/.config/nvim/lua/plugins/trouble.lua" << 'EOF'
-- ~/.config/nvim/lua/plugins/trouble.lua
return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("trouble").setup()
    vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnósticos" })
    vim.keymap.set("n", "<leader>xq", "<cmd>Trouble quickfix toggle<cr>", { desc = "Quickfix" })
  end,
}
EOF
print_success "trouble.lua creado"

# ========== FUGITIVE (Git) ==========
cat > "$HOME/.config/nvim/lua/plugins/fugitive.lua" << 'EOF'
-- ~/.config/nvim/lua/plugins/fugitive.lua
return {
  "tpope/vim-fugitive",
}
EOF
print_success "fugitive.lua creado"

# ============================================
# 6. INSTALAR PLUGINS
# ============================================

print_message "Instalando plugins de Neovim..."
print_warning "Esto puede tardar varios minutos en la primera instalación..."

# Ejecutar nvim de forma no interactiva para instalar plugins
nvim --headless "+Lazy! sync" +qa

print_success "Plugins instalados exitosamente"

# ============================================
# 7. CREAR ARCHIVO DE INSTRUCCIONES
# ============================================

cat > "$HOME/.config/nvim/CAMBIAR_TEMA.md" << 'EOF'
# Cómo cambiar el tema de colores en Neovim

## Método rápido (dentro de Neovim)
Abre Neovim y ejecuta estos comandos:

```vim
:colorscheme catppuccin-mocha
:colorscheme tokyonight-night
:colorscheme gruvbox
:colorscheme rose-pine
```

## Método permanente
Edita el archivo: `~/.config/nvim/lua/plugins/colorschemes.lua`

Cambia `lazy = false` en el tema que quieras usar:

```lua
-- Para usar TokyoNight:
{
  "folke/tokyonight.nvim",
  lazy = false,  -- ← Cambia esto a false
  priority = 1000,
  config = function()
    vim.cmd([[colorscheme tokyonight-night]])
  end,
},

-- Y cambia Catppuccin a:
{
  "catppuccin/nvim",
  lazy = true,  -- ← Cambia esto a true
  ...
}
```

Guarda y reinicia Neovim.

## Variantes disponibles:

**Catppuccin:**
- catppuccin-latte (claro)
- catppuccin-frappe (medio)
- catppuccin-macchiato (oscuro suave)
- catppuccin-mocha (oscuro intenso)

**TokyoNight:**
- tokyonight-night
- tokyonight-storm
- tokyonight-day
- tokyonight-moon
EOF

print_success "Archivo de instrucciones creado en ~/.config/nvim/CAMBIAR_TEMA.md"

# ============================================
# 8. RESUMEN
# ============================================

echo ""
echo "============================================"
print_success "INSTALACIÓN COMPLETADA"
echo "============================================"
echo ""
echo "📁 Configuración instalada en: $HOME/.config/nvim"
echo ""
echo "🎨 Plugins instalados:"
echo "  • Catppuccin (tema activo)"
echo "  • TokyoNight, Gruvbox, Rose Pine (temas disponibles)"
echo "  • nvim-tree (explorador de archivos)"
echo "  • Telescope (búsqueda difusa)"
echo "  • Treesitter (syntax highlighting)"
echo "  • nvim-cmp (autocompletado)"
echo "  • lualine (barra de estado)"
echo "  • bufferline (pestañas de buffers)"
echo "  • Comment.nvim (comentarios)"
echo "  • nvim-autopairs (auto pares)"
echo "  • which-key (menú de atajos)"
echo "  • gitsigns (integración Git)"
echo "  • indent-blankline (líneas de indentación)"
echo "  • nvim-surround (edición de comillas/paréntesis)"
echo "  • toggleterm (terminal integrada)"
echo "  • trouble (diagnósticos)"
echo "  • vim-fugitive (comandos Git)"
echo ""
echo "⌨️  Atajos principales:"
echo "  • <Space>      - Ver todos los atajos (which-key)"
echo "  • <Space>e     - Toggle explorador de archivos"
echo "  • <Space>ff    - Buscar archivos"
echo "  • <Space>fg    - Buscar texto"
echo "  • <Space>w     - Guardar archivo"
echo "  • <Space>q     - Salir"
echo "  • gcc          - Comentar/descomentar línea"
echo "  • <Ctrl+\\>    - Abrir terminal flotante"
echo "  • <Space>xx    - Ver diagnósticos"
echo "  • ]c / [c      - Navegar cambios de Git"
echo ""
echo "🎨 Para cambiar de tema:"
echo "  • Dentro de Neovim: :colorscheme tokyonight-night"
echo "  • Lee: ~/.config/nvim/CAMBIAR_TEMA.md"
echo ""
print_success "¡Listo para usar Neovim!"
echo ""

if [ -n "$BACKUP_DIR" ]; then
    print_warning "Tu configuración anterior fue respaldada en: $BACKUP_DIR"
fi

echo ""
print_message "Recomendación: Instala una Nerd Font para ver los iconos correctamente"
echo "  • sudo dnf install fontawesome-fonts"
echo ""