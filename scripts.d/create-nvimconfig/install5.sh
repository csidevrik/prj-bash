#!/bin/bash

# ============================================
# Script de Despliegue Automático de Neovim
# Con soporte completo para Go
# Para Fedora (dnf) y Ubuntu/Debian (apt)
# ============================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_message() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error()   { echo -e "${RED}[✗]${NC} $1"; }

echo "╔════════════════════════════════════════════════╗"
echo "║   DESPLIEGUE AUTOMÁTICO DE NEOVIM CON GO       ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

# ============================================
# DETECCIÓN DE DISTRO Y GESTOR DE PAQUETES
# ============================================
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_ID="${ID}"
        DISTRO_LIKE="${ID_LIKE:-}"
    else
        print_error "No se pudo detectar la distribución (falta /etc/os-release)"
        exit 1
    fi

    case "$DISTRO_ID" in
        fedora|rhel|centos|rocky|almalinux)
            PKG_MANAGER="dnf"
            PKG_INSTALL="sudo dnf install -y"
            PKG_UPDATE="sudo dnf check-update || true"
            ;;
        ubuntu|debian|linuxmint|pop)
            PKG_MANAGER="apt"
            PKG_INSTALL="sudo apt install -y"
            PKG_UPDATE="sudo apt update"
            ;;
        *)
            # Fallback usando ID_LIKE
            if echo "$DISTRO_LIKE" | grep -qiE "fedora|rhel"; then
                PKG_MANAGER="dnf"
                PKG_INSTALL="sudo dnf install -y"
                PKG_UPDATE="sudo dnf check-update || true"
            elif echo "$DISTRO_LIKE" | grep -qiE "debian|ubuntu"; then
                PKG_MANAGER="apt"
                PKG_INSTALL="sudo apt install -y"
                PKG_UPDATE="sudo apt update"
            else
                print_error "Distribución no soportada: $DISTRO_ID"
                print_message "Soportadas: Fedora, RHEL, Ubuntu, Debian y derivadas"
                exit 1
            fi
            ;;
    esac

    print_success "Distribución detectada: $DISTRO_ID → usando $PKG_MANAGER"
}

detect_distro

# Actualizar repositorios antes de instalar
print_message "Actualizando repositorios..."
eval "$PKG_UPDATE"

# ============================================
# 1. VERIFICAR E INSTALAR NEOVIM
# ============================================
print_message "Verificando instalación de Neovim..."

# Nota: En Ubuntu, el neovim del repo apt suele ser viejo (0.6/0.7).
# Para Ubuntu se recomienda el PPA o snap para obtener la versión estable reciente.
install_neovim() {
    if [ "$PKG_MANAGER" = "apt" ]; then
        print_warning "En Ubuntu/Debian el paquete apt puede ser una versión antigua."
        print_message "Instalando desde el PPA oficial de Neovim (stable)..."
        sudo apt install -y software-properties-common
        sudo add-apt-repository -y ppa:neovim-ppa/stable
        sudo apt update
        sudo apt install -y neovim git
    else
        $PKG_INSTALL neovim git
    fi
}

if ! command -v nvim &> /dev/null; then
    print_warning "Neovim no está instalado. Instalando..."
    install_neovim
    print_success "Neovim instalado: $(nvim --version | head -1)"
else
    print_success "Neovim ya está instalado: $(nvim --version | head -1)"
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

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.clipboard = 'unnamedplus'
vim.opt.scrolloff = 8
vim.opt.undofile = true
vim.opt.swapfile = false

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
})

-- Keymaps
local keymap = vim.keymap.set
keymap('n', '<leader>w', ':w<CR>',   { desc = 'Guardar' })
keymap('n', '<leader>q', ':q<CR>',   { desc = 'Salir' })
keymap('n', '<leader>x', ':wq<CR>',  { desc = 'Guardar y salir' })
keymap('n', '<Esc>', ':noh<CR>',     { silent = true })
keymap('n', '<C-h>', '<C-w>h')
keymap('n', '<C-j>', '<C-w>j')
keymap('n', '<C-k>', '<C-w>k')
keymap('n', '<C-l>', '<C-w>l')
keymap('n', '<C-Up>',    ':resize +2<CR>',          { silent = true })
keymap('n', '<C-Down>',  ':resize -2<CR>',           { silent = true })
keymap('n', '<C-Left>',  ':vertical resize -2<CR>',  { silent = true })
keymap('n', '<C-Right>', ':vertical resize +2<CR>',  { silent = true })
keymap('n', '<Tab>',   ':bnext<CR>',    { desc = 'Buffer siguiente' })
keymap('n', '<S-Tab>', ':bprevious<CR>', { desc = 'Buffer anterior' })
keymap('n', '<leader>bd', ':bdelete<CR>', { desc = 'Cerrar buffer' })
keymap('v', 'J', ":m '>+1<CR>gv=gv")
keymap('v', 'K', ":m '<-2<CR>gv=gv")
keymap('v', '<', '<gv')
keymap('v', '>', '>gv')
keymap('x', '<leader>p', '"_dP')
keymap('n', '<leader>sv', ':vsplit<CR>', { desc = 'Split vertical' })
keymap('n', '<leader>sh', ':split<CR>',  { desc = 'Split horizontal' })

-- Autocommands
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.highlight.on_yank({ timeout = 200 }) end,
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
# 5. CREAR PLUGINS (sin cambios respecto al original)
# ============================================
print_message "Creando archivos de plugins..."

cat > "$CONFIG_DIR/lua/plugins/autopairs.lua" << 'EOF'
return {
  'windwp/nvim-autopairs',
  event = "InsertEnter",
  config = function()
    require("nvim-autopairs").setup({})
  end,
}
EOF

cat > "$CONFIG_DIR/lua/plugins/cmp.lua" << 'EOF'
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
        expand = function(args) luasnip.lsp_expand(args.body) end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-b>']     = cmp.mapping.scroll_docs(-4),
        ['<C-f>']     = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>']     = cmp.mapping.abort(),
        ['<CR>']      = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then cmp.select_next_item() else fallback() end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then cmp.select_previous_item() else fallback() end
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

cat > "$CONFIG_DIR/lua/plugins/comment.lua" << 'EOF'
return {
  'numToStr/Comment.nvim',
  config = function() require('Comment').setup() end,
}
EOF

cat > "$CONFIG_DIR/lua/plugins/colorschemes.lua" << 'EOF'
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
      })
      vim.cmd([[colorscheme catppuccin-mocha]])
    end,
  },
  { "folke/tokyonight.nvim",   lazy = true, priority = 1000 },
  { "ellisonleao/gruvbox.nvim", lazy = true, priority = 1000 },
  { "rose-pine/neovim", name = "rose-pine", lazy = true },
}
EOF

cat > "$CONFIG_DIR/lua/plugins/lualine.lua" << 'EOF'
return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('lualine').setup({ options = { theme = 'auto' } })
  end,
}
EOF

cat > "$CONFIG_DIR/lua/plugins/nvim-tree.lua" << 'EOF'
return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("nvim-tree").setup({
      view = { width = 30 },
      renderer = { group_empty = true },
      filters = { dotfiles = false },
    })
    vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle explorador' })
  end,
}
EOF

cat > "$CONFIG_DIR/lua/plugins/telescope.lua" << 'EOF'
return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.5',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>ff', builtin.find_files,  { desc = 'Buscar archivos' })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep,   { desc = 'Buscar texto' })
    vim.keymap.set('n', '<leader>fb', builtin.buffers,     { desc = 'Buscar buffers' })
    vim.keymap.set('n', '<leader>fh', builtin.help_tags,   { desc = 'Buscar ayuda' })
  end,
}
EOF

cat > "$CONFIG_DIR/lua/plugins/treesitter.lua" << 'EOF'
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "lua", "vim", "python", "javascript", "html", "css", "bash", "json", "yaml", "go" },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
EOF

cat > "$CONFIG_DIR/lua/plugins/lspconfig.lua" << 'EOF'
return {
  "neovim/nvim-lspconfig",
  dependencies = { "hrsh7th/cmp-nvim-lsp" },
  config = function()
    local lspconfig = require('lspconfig')
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    local on_attach = function(client, bufnr)
      local opts = { buffer = bufnr, silent = true }
      vim.keymap.set('n', 'gd',         vim.lsp.buf.definition,   opts)
      vim.keymap.set('n', 'gD',         vim.lsp.buf.declaration,  opts)
      vim.keymap.set('n', 'gi',         vim.lsp.buf.implementation, opts)
      vim.keymap.set('n', 'gr',         vim.lsp.buf.references,   opts)
      vim.keymap.set('n', 'K',          vim.lsp.buf.hover,        opts)
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename,       opts)
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action,  opts)
      vim.keymap.set('n', '<leader>f',  function()
        vim.lsp.buf.format({ async = true })
      end, opts)
      print("✓ LSP activado: " .. client.name)
    end

    lspconfig.gopls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        gopls = {
          analyses = { unusedparams = true, shadow = true },
          staticcheck = true,
          gofumpt = true,
        },
      },
    })

    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.go",
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  end,
}
EOF

cat > "$CONFIG_DIR/lua/plugins/go-commands.lua" << 'EOF'
return {
  dir = vim.fn.stdpath('config'),
  lazy = false,
  config = function()
    vim.api.nvim_create_user_command('GoRun',      function() vim.cmd('!go run %')       end, { desc = 'Ejecutar archivo Go' })
    vim.api.nvim_create_user_command('GoTest',     function() vim.cmd('!go test ./...')   end, { desc = 'Tests Go' })
    vim.api.nvim_create_user_command('GoBuild',    function() vim.cmd('!go build')        end, { desc = 'Compilar Go' })
    vim.api.nvim_create_user_command('GoTestFunc', function()
      vim.cmd('!go test -run ' .. vim.fn.expand('<cword>'))
    end, { desc = 'Test bajo cursor' })
  end,
}
EOF

print_success "Todos los plugins creados"

# ============================================
# 6. VERIFICAR E INSTALAR GO
# ============================================
print_message "Verificando instalación de Go..."
if command -v go &> /dev/null; then
    print_success "Go ya instalado: $(go version)"
else
    print_warning "Go no está instalado. Instalando..."
    $PKG_INSTALL golang
    print_success "Go instalado: $(go version)"
fi

# ============================================
# 7. INSTALAR GOPLS
# ============================================
print_message "Instalando gopls..."

# Asegurar PATH antes de verificar gopls
if [[ ":$PATH:" != *":$HOME/go/bin:"* ]]; then
    export PATH=$PATH:$HOME/go/bin
fi

if command -v gopls &> /dev/null; then
    print_success "gopls ya está instalado: $(gopls version 2>/dev/null | head -1)"
else
    go install golang.org/x/tools/gopls@v0.20.0
    print_success "gopls instalado"
fi

# Persistir PATH en el shell correspondiente
add_path_to_shell() {
    local line='export PATH=$PATH:$HOME/go/bin'
    for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$rc" ] && ! grep -qF 'go/bin' "$rc"; then
            echo "$line" >> "$rc"
            print_success "PATH agregado a $rc"
        fi
    done
}
add_path_to_shell

# ============================================
# 8. RESUMEN FINAL
# ============================================
echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║            INSTALACIÓN COMPLETADA              ║"
echo "╚════════════════════════════════════════════════╝"
echo ""
print_success "Distribución: $DISTRO_ID — Gestor: $PKG_MANAGER"
print_success "Neovim configurado | Tema: Catppuccin Mocha"
print_success "Go + gopls instalados y listos"
echo ""
echo "📋 PRÓXIMOS PASOS:"
echo "   1. Ejecuta: nvim"
echo "   2. Espera que Lazy.nvim instale los plugins (primera vez)"
echo "   3. Cierra y vuelve a abrir Neovim"
echo "   4. Prueba con: nvim main.go"
echo ""
echo "🎯 ATAJOS PRINCIPALES:"
echo "   <Space>e   - Explorador de archivos"
echo "   <Space>ff  - Buscar archivos"
echo "   <Space>fg  - Buscar texto"
echo "   gcc        - Comentar/descomentar"
echo "   gd / K     - Ir a definición / Ver docs (LSP)"
echo "   <Space>rn  - Renombrar símbolo"
echo "   <Space>ca  - Code actions"
echo "   <Space>f   - Formatear"
echo ""
echo "📝 COMANDOS GO:"
echo "   :GoRun   :GoTest   :GoBuild   :GoTestFunc"
echo ""
print_success "¡Listo para programar!"