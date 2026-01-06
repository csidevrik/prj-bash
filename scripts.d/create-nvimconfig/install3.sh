#!/bin/bash

# ============================================
# Script de Despliegue Automático de Neovim
# Con soporte completo para Go
# Para Fedora Linux
# ============================================

set -e  # Detener en caso de error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Funciones para imprimir mensajes
print_message() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

echo "╔════════════════════════════════════════════════╗"
echo "║   DESPLIEGUE AUTOMÁTICO DE NEOVIM CON GO       ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

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
fi

# ============================================
# 2. BACKUP DE CONFIGURACIÓN EXISTENTE
# ============================================
CONFIG_DIR="$HOME/.config/nvim"
if [ -d "$CONFIG_DIR" ]; then
    BACKUP_DIR="$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
    print_warning "Configuración existente detectada"
    print_message "Creando backup en: $BACKUP_DIR"
    mv "$CONFIG_DIR" "$BACKUP_DIR"
    print_success "Backup creado"
fi

# ============================================
# 3. CREAR ESTRUCTURA DE DIRECTORIOS
# ============================================
print_message "Creando estructura de directorios..."
mkdir -p "$CONFIG_DIR/lua/plugins"
print_success "Estructura creada"

# ============================================
# 4. CREAR ARCHIVO init.lua
# ============================================
print_message "Creando init.lua..."
cat > "$CONFIG_DIR/init.lua" << 'EOF'
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
print_success "init.lua creado"

# ============================================
# 5. CREAR PLUGINS
# ============================================
print_message "Creando archivos de plugins..."

# autopairs.lua
cat > "$CONFIG_DIR/lua/plugins/autopairs.lua" << 'EOF'
-- ~/.config/nvim/lua/plugins/autopairs.lua
return {
  'windwp/nvim-autopairs',
  event = "InsertEnter",
  config = function()
    require("nvim-autopairs").setup({})
  end,
}
EOF

# cmp.lua
cat > "$CONFIG_DIR/lua/plugins/cmp.lua" << 'EOF'
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

# comment.lua
cat > "$CONFIG_DIR/lua/plugins/comment.lua" << 'EOF'
-- ~/.config/nvim/lua/plugins/comment.lua
return {
  'numToStr/Comment.nvim',
  config = function()
    require('Comment').setup()
  end,
}
EOF

# colorschemes.lua (CON CATPPUCCIN ACTIVO)
cat > "$CONFIG_DIR/lua/plugins/colorschemes.lua" << 'EOF'
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

# lualine.lua
cat > "$CONFIG_DIR/lua/plugins/lualine.lua" << 'EOF'
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

# nvim-tree.lua
cat > "$CONFIG_DIR/lua/plugins/nvim-tree.lua" << 'EOF'
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

# telescope.lua
cat > "$CONFIG_DIR/lua/plugins/telescope.lua" << 'EOF'
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

# treesitter.lua
cat > "$CONFIG_DIR/lua/plugins/treesitter.lua" << 'EOF'
-- ~/.config/nvim/lua/plugins/treesitter.lua
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "lua", "vim", "python", "javascript", "html", "css", "bash", "json", "yaml", "go" },
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

# ============================================
# 6. CREAR PLUGIN PARA GO (NUEVO)
# ============================================
cat > "$CONFIG_DIR/lua/plugins/go.lua" << 'EOF'
-- ~/.config/nvim/lua/plugins/go.lua
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    local lspconfig = require('lspconfig')
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    
    -- Función común para on_attach
    local on_attach = function(client, bufnr)
      local opts = { buffer = bufnr, silent = true }
      
      -- Keybindings para LSP
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
      vim.keymap.set('n', '<leader>f', function()
        vim.lsp.buf.format({ async = true })
      end, opts)
      
      print("✓ LSP activado para " .. vim.bo.filetype)
    end
    
    -- Configuración de gopls (Go Language Server)
    lspconfig.gopls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        gopls = {
          analyses = {
            unusedparams = true,
            shadow = true,
          },
          staticcheck = true,
          gofumpt = true,
        },
      },
    })
    
    -- Auto-formato al guardar archivos Go
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.go",
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
    
    -- Comandos útiles para Go
    vim.api.nvim_create_user_command('GoRun', function()
      vim.cmd('!go run %')
    end, {})
    
    vim.api.nvim_create_user_command('GoTest', function()
      vim.cmd('!go test ./...')
    end, {})
    
    vim.api.nvim_create_user_command('GoBuild', function()
      vim.cmd('!go build')
    end, {})
  end,
}
EOF

print_success "Todos los plugins creados"

# ============================================
# 7. VERIFICAR INSTALACIÓN DE GO
# ============================================
print_message "Verificando instalación de Go..."
if command -v go &> /dev/null; then
    GO_VERSION=$(go version)
    print_success "Go está instalado: $GO_VERSION"
else
    print_warning "Go no está instalado"
    print_message "Instalando Go..."
    sudo dnf install -y golang
    print_success "Go instalado"
fi

# ============================================
# 8. INSTALAR GOPLS
# ============================================
print_message "Instalando gopls (Go Language Server)..."
if command -v gopls &> /dev/null; then
    print_success "gopls ya está instalado"
else
    go install golang.org/x/tools/gopls@latest
    print_success "gopls instalado"
fi

# Asegurar que $GOPATH/bin está en PATH
if [[ ":$PATH:" != *":$HOME/go/bin:"* ]]; then
    print_warning "Agregando $HOME/go/bin al PATH"
    echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
    export PATH=$PATH:$HOME/go/bin
    print_success "PATH actualizado"
fi

# ============================================
# 9. RESUMEN FINAL
# ============================================
echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║            INSTALACIÓN COMPLETADA              ║"
echo "╚════════════════════════════════════════════════╝"
echo ""
print_success "Neovim configurado correctamente"
print_success "Tema: Catppuccin Mocha"
print_success "Soporte para Go agregado con gopls"
echo ""
echo "📋 PRÓXIMOS PASOS:"
echo ""
echo "1. Abre Neovim:"
echo "   nvim"
echo ""
echo "2. Espera a que Lazy instale los plugins automáticamente"
echo "   (La primera vez tomará unos minutos)"
echo ""
echo "3. Cierra y vuelve a abrir Neovim"
echo ""
echo "4. Prueba con un archivo Go:"
echo "   nvim test.go"
echo ""
echo "🎯 ATAJOS PRINCIPALES:"
echo "   <leader> = Espacio"
echo "   <leader>e  - Toggle explorador de archivos"
echo "   <leader>ff - Buscar archivos"
echo "   <leader>fg - Buscar texto"
echo "   gcc        - Comentar/descomentar"
echo "   gd         - Ir a definición (Go)"
echo "   K          - Ver documentación (Go)"
echo "   <leader>rn - Renombrar símbolo (Go)"
echo "   <leader>ca - Code actions (Go)"
echo "   <leader>f  - Formatear código"
echo ""
echo "📝 COMANDOS GO:"
echo "   :GoRun   - Ejecutar archivo actual"
echo "   :GoTest  - Ejecutar tests"
echo "   :GoBuild - Compilar proyecto"
echo ""
echo "🎨 TEMAS DISPONIBLES:"
echo "   - Catppuccin (activo)"
echo "   - TokyoNight"
echo "   - Gruvbox"
echo "   - Rose Pine"
echo "   Edita ~/.config/nvim/lua/plugins/colorschemes.lua para cambiar"
echo ""
print_success "¡Listo para programar en Go!"
echo ""