#!/bin/bash

# ============================================
# Script de Despliegue Automático de Neovim
# Versión para Neovim >= 0.11 con soporte para Go
# Para Fedora/RHEL (dnf) y Ubuntu/Debian (apt)
#
# Diferencias con install5.sh:
#   - Exige Neovim >= 0.11 (si no, recomienda install5.sh)
#   - LSP con la API nativa de 0.11 (vim.lsp.config / vim.lsp.enable)
#   - nvim-treesitter fijado en la rama "master"
#   - Sin print() que provoquen "Press ENTER"
#   - Agrega which-key y gitsigns
#   - Instala ripgrep, fd y gcc (Telescope y treesitter los necesitan)
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
echo "║   DESPLIEGUE DE NEOVIM 0.11+ CON SOPORTE GO    ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

# No ejecutar como root: la configuración debe quedar a nombre del usuario
if [ "$(id -u)" -eq 0 ]; then
    print_error "No ejecutes este script con sudo ni como root."
    print_message "Ejecútalo con tu usuario normal; el script pedirá sudo solo cuando lo necesite."
    exit 1
fi

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
        fedora|rhel|centos|rocky|almalinux) PKG_MANAGER="dnf" ;;
        ubuntu|debian|linuxmint|pop)        PKG_MANAGER="apt" ;;
        *)
            if echo "$DISTRO_LIKE" | grep -qiE "fedora|rhel"; then
                PKG_MANAGER="dnf"
            elif echo "$DISTRO_LIKE" | grep -qiE "debian|ubuntu"; then
                PKG_MANAGER="apt"
            else
                print_error "Distribución no soportada: $DISTRO_ID"
                print_message "Soportadas: Fedora, RHEL, Rocky, Alma, Ubuntu, Debian y derivadas"
                exit 1
            fi
            ;;
    esac

    if [ "$PKG_MANAGER" = "dnf" ]; then
        PKG_INSTALL="sudo dnf install -y"
    else
        PKG_INSTALL="sudo apt install -y"
    fi

    print_success "Distribución detectada: $DISTRO_ID → usando $PKG_MANAGER"
}

detect_distro

print_message "Actualizando repositorios..."
if [ "$PKG_MANAGER" = "apt" ]; then
    sudo apt update
else
    sudo dnf check-update || true   # devuelve 100 si hay actualizaciones, no es error
fi

# ============================================
# 1. DEPENDENCIAS DEL SISTEMA
# ============================================
# git      → lazy.nvim descarga los plugins con git
# gcc/make → treesitter compila los parsers de cada lenguaje
# ripgrep  → <Space>fg (buscar texto) de Telescope
# fd       → <Space>ff más rápido en Telescope
# curl/unzip → descargas de plugins
print_message "Instalando dependencias del sistema..."
# (en Rocky/RHEL, ripgrep y fd-find requieren tener EPEL habilitado)
$PKG_INSTALL git gcc make ripgrep fd-find curl unzip
print_success "Dependencias instaladas"

# ============================================
# 2. NEOVIM (se exige 0.11 o superior)
# ============================================
install_neovim() {
    if [ "$PKG_MANAGER" = "apt" ]; then
        # El paquete de apt suele ser viejo; el PPA "stable" trae la última estable
        print_message "Instalando Neovim desde el PPA oficial (stable)..."
        sudo apt install -y software-properties-common
        sudo add-apt-repository -y ppa:neovim-ppa/stable
        sudo apt update
        sudo apt install -y neovim
    else
        $PKG_INSTALL neovim
    fi
}

# Devuelve 0 si la versión instalada de nvim es >= 0.11
nvim_is_011_or_newer() {
    local version major minor
    version=$(nvim --version | head -1 | sed -E 's/^NVIM v([0-9]+)\.([0-9]+).*/\1 \2/')
    read -r major minor <<< "$version"
    [ "$major" -gt 0 ] || [ "$minor" -ge 11 ]
}

print_message "Verificando instalación de Neovim..."
if ! command -v nvim &> /dev/null; then
    print_warning "Neovim no está instalado. Instalando..."
    install_neovim
fi

NVIM_VERSION="$(nvim --version | head -1)"
if nvim_is_011_or_newer; then
    print_success "Versión compatible: $NVIM_VERSION"
else
    print_error "Versión no compatible: $NVIM_VERSION (este script necesita 0.11 o superior)"
    print_message "Opciones:"
    print_message "  - Usa install5.sh, pensado para versiones anteriores de Neovim"
    print_message "  - O instala una versión más nueva de Neovim y vuelve a ejecutar este script"
    exit 1
fi

# ============================================
# 3. BACKUP DE CONFIGURACIÓN EXISTENTE
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
# 4. ESTRUCTURA DE DIRECTORIOS
# ============================================
print_message "Creando estructura de directorios..."
mkdir -p "$CONFIG_DIR/lua/plugins" "$CONFIG_DIR/lua/config"
print_success "Estructura creada"

# ============================================
# 5. init.lua
# ============================================
print_message "Creando init.lua..."
cat > "$CONFIG_DIR/init.lua" << 'EOF'
-- ============================================
-- ~/.config/nvim/init.lua  (generado por install6.sh)
-- Configuración principal de Neovim 0.11+
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

-- En Neovim 0.11 los errores ya no se muestran al lado del código por defecto;
-- esto los vuelve a mostrar (más parecido a un IDE)
vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
  float = { border = 'rounded' },
})

-- Lazy.nvim (gestor de plugins)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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

-- Comandos para Go (:GoRun, :GoTest, :GoBuild, :GoTestFunc)
require("config.go")

-- Keymaps
local keymap = vim.keymap.set
keymap('n', '<leader>w', '<cmd>w<CR>',   { desc = 'Guardar' })
keymap('n', '<leader>q', '<cmd>q<CR>',   { desc = 'Salir' })
keymap('n', '<leader>x', '<cmd>wq<CR>',  { desc = 'Guardar y salir' })
keymap('n', '<Esc>', '<cmd>nohlsearch<CR>', { silent = true })
keymap('n', '<C-h>', '<C-w>h', { desc = 'Ventana izquierda' })
keymap('n', '<C-j>', '<C-w>j', { desc = 'Ventana abajo' })
keymap('n', '<C-k>', '<C-w>k', { desc = 'Ventana arriba' })
keymap('n', '<C-l>', '<C-w>l', { desc = 'Ventana derecha' })
keymap('n', '<C-Up>',    '<cmd>resize +2<CR>',          { silent = true })
keymap('n', '<C-Down>',  '<cmd>resize -2<CR>',          { silent = true })
keymap('n', '<C-Left>',  '<cmd>vertical resize -2<CR>', { silent = true })
keymap('n', '<C-Right>', '<cmd>vertical resize +2<CR>', { silent = true })
keymap('n', '<Tab>',   '<cmd>bnext<CR>',     { desc = 'Buffer siguiente' })
keymap('n', '<S-Tab>', '<cmd>bprevious<CR>', { desc = 'Buffer anterior' })
keymap('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = 'Cerrar buffer' })
keymap('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Mover selección abajo' })
keymap('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Mover selección arriba' })
keymap('v', '<', '<gv')
keymap('v', '>', '>gv')
keymap('x', '<leader>p', '"_dP', { desc = 'Pegar sin perder el portapapeles' })
keymap('n', '<leader>sv', '<cmd>vsplit<CR>', { desc = 'Split vertical' })
keymap('n', '<leader>sh', '<cmd>split<CR>',  { desc = 'Split horizontal' })
keymap('n', '<leader>t', '<cmd>botright split | resize 12 | terminal<CR>', { desc = 'Terminal abajo' })
keymap('t', '<Esc><Esc>', [[<C-\><C-n>]], { desc = 'Salir del modo terminal' })

-- Autocommands
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.hl.on_yank({ timeout = 200 }) end,
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
EOF
print_success "init.lua creado"

# ============================================
# 6. COMANDOS DE GO (módulo propio, no es un plugin)
# ============================================
cat > "$CONFIG_DIR/lua/config/go.lua" << 'EOF'
-- ~/.config/nvim/lua/config/go.lua
local cmd = vim.api.nvim_create_user_command
cmd('GoRun',      function() vim.cmd('!go run %') end,     { desc = 'Ejecutar archivo Go' })
cmd('GoTest',     function() vim.cmd('!go test ./...') end, { desc = 'Tests Go' })
cmd('GoBuild',    function() vim.cmd('!go build') end,      { desc = 'Compilar Go' })
cmd('GoTestFunc', function()
  vim.cmd('!go test -run ' .. vim.fn.expand('<cword>'))
end, { desc = 'Test bajo el cursor' })
EOF

# ============================================
# 7. PLUGINS
# ============================================
print_message "Creando archivos de plugins..."

cat > "$CONFIG_DIR/lua/plugins/autopairs.lua" << 'EOF'
return {
  'windwp/nvim-autopairs',
  event = "InsertEnter",
  opts = {},
}
EOF

cat > "$CONFIG_DIR/lua/plugins/cmp.lua" << 'EOF'
return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
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
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
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

# Nota: no se instala Comment.nvim porque Neovim 0.10+ ya trae gc / gcc

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
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },
  { "folke/tokyonight.nvim",    lazy = true },
  { "ellisonleao/gruvbox.nvim", lazy = true },
  { "rose-pine/neovim", name = "rose-pine", lazy = true },
}
EOF

cat > "$CONFIG_DIR/lua/plugins/lualine.lua" << 'EOF'
return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = { options = { theme = 'auto' } },
}
EOF

cat > "$CONFIG_DIR/lua/plugins/nvim-tree.lua" << 'EOF'
return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { '<leader>e', '<cmd>NvimTreeToggle<CR>', desc = 'Explorador de archivos' },
  },
  opts = {
    view = { width = 30 },
    renderer = { group_empty = true },
    filters = { dotfiles = false },
  },
}
EOF

cat > "$CONFIG_DIR/lua/plugins/telescope.lua" << 'EOF'
return {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    { '<leader>ff', function() require('telescope.builtin').find_files() end,  desc = 'Buscar archivos' },
    { '<leader>fg', function() require('telescope.builtin').live_grep() end,   desc = 'Buscar texto' },
    { '<leader>fb', function() require('telescope.builtin').buffers() end,     desc = 'Buscar buffers' },
    { '<leader>fh', function() require('telescope.builtin').help_tags() end,   desc = 'Buscar ayuda' },
    { '<leader>fd', function() require('telescope.builtin').diagnostics() end, desc = 'Buscar errores' },
  },
}
EOF

cat > "$CONFIG_DIR/lua/plugins/treesitter.lua" << 'EOF'
return {
  "nvim-treesitter/nvim-treesitter",
  -- La rama "main" es una reescritura incompatible; "master" mantiene
  -- el módulo nvim-treesitter.configs que usa esta configuración
  branch = "master",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "lua", "vim", "vimdoc", "python", "javascript", "html", "css", "bash", "json", "yaml", "go", "gomod", "gosum", "markdown" },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
EOF

cat > "$CONFIG_DIR/lua/plugins/lspconfig.lua" << 'EOF'
-- LSP con la API nativa de Neovim 0.11 (vim.lsp.config / vim.lsp.enable).
-- nvim-lspconfig solo aporta las configuraciones base de cada servidor.
return {
  "neovim/nvim-lspconfig",
  dependencies = { "hrsh7th/cmp-nvim-lsp" },
  config = function()
    -- Atajos: se activan en cualquier buffer donde arranque un LSP.
    -- Neovim 0.11 ya trae por defecto: grr (referencias), gri (implementación),
    -- grn (renombrar), gra (code action), K (documentación), [d / ]d (errores).
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local map = function(keys, fn, desc)
          vim.keymap.set('n', keys, fn, { buffer = args.buf, silent = true, desc = desc })
        end
        map('gd',         vim.lsp.buf.definition,  'Ir a definición')
        map('gD',         vim.lsp.buf.declaration, 'Ir a declaración')
        map('<leader>rn', vim.lsp.buf.rename,      'Renombrar símbolo')
        map('<leader>ca', vim.lsp.buf.code_action, 'Code action')
        map('<leader>lf', function() vim.lsp.buf.format({ async = true }) end, 'Formatear archivo')
        map('<leader>ld', vim.diagnostic.open_float, 'Ver error de la línea')
      end,
    })

    -- Capacidades extra de autocompletado (nvim-cmp) para todos los servidores
    vim.lsp.config('*', {
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
    })

    -- gopls (Go Language Server)
    vim.lsp.config('gopls', {
      settings = {
        gopls = {
          analyses = { unusedparams = true, shadow = true },
          staticcheck = true,
          gofumpt = true,
        },
      },
    })
    vim.lsp.enable('gopls')

    -- Formatear archivos Go al guardar
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.go",
      callback = function() vim.lsp.buf.format({ async = false }) end,
    })
  end,
}
EOF

cat > "$CONFIG_DIR/lua/plugins/which-key.lua" << 'EOF'
-- Muestra un menú con los atajos disponibles al pulsar <Space> (y otras teclas)
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    spec = {
      { "<leader>f", group = "Buscar" },
      { "<leader>s", group = "Split" },
      { "<leader>b", group = "Buffer" },
      { "<leader>l", group = "LSP" },
      { "<leader>h", group = "Git" },
    },
  },
}
EOF

cat > "$CONFIG_DIR/lua/plugins/gitsigns.lua" << 'EOF'
-- Marca en el margen las líneas agregadas, modificadas o borradas según git
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    on_attach = function(bufnr)
      local gs = require('gitsigns')
      local map = function(keys, fn, desc)
        vim.keymap.set('n', keys, fn, { buffer = bufnr, desc = desc })
      end
      map(']h', function() gs.nav_hunk('next') end, 'Siguiente cambio git')
      map('[h', function() gs.nav_hunk('prev') end, 'Cambio git anterior')
      map('<leader>hp', gs.preview_hunk,  'Ver cambio')
      map('<leader>hr', gs.reset_hunk,    'Deshacer cambio')
      map('<leader>hb', gs.blame_line,    'Quién escribió esta línea')
    end,
  },
}
EOF

print_success "Todos los plugins creados"

# ============================================
# 8. GO
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
# 9. GOPLS
# ============================================
GO_BIN_DIR="$(go env GOPATH)/bin"
if [[ ":$PATH:" != *":$GO_BIN_DIR:"* ]]; then
    export PATH="$PATH:$GO_BIN_DIR"
fi

print_message "Instalando gopls..."
if command -v gopls &> /dev/null; then
    print_success "gopls ya está instalado: $(gopls version 2>/dev/null | head -1)"
else
    go install golang.org/x/tools/gopls@v0.20.0
    print_success "gopls instalado en $GO_BIN_DIR"
fi

# Persistir PATH en bash y zsh
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ] && ! grep -qF "$GO_BIN_DIR" "$rc"; then
        echo "export PATH=\"\$PATH:$GO_BIN_DIR\"" >> "$rc"
        print_success "PATH agregado a $rc"
    fi
done

# ============================================
# 10. INSTALAR PLUGINS (para que el primer inicio sea limpio)
# ============================================
print_message "Instalando plugins de Neovim (puede tardar unos minutos)..."
if nvim --headless "+Lazy! sync" +qa; then
    print_success "Plugins instalados"
else
    print_warning "No se pudieron instalar todos los plugins; se reintentará al abrir nvim"
fi

# ============================================
# 11. RESUMEN FINAL
# ============================================
echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║            INSTALACIÓN COMPLETADA              ║"
echo "╚════════════════════════════════════════════════╝"
echo ""
print_success "Distribución: $DISTRO_ID — Gestor: $PKG_MANAGER"
print_success "$NVIM_VERSION | Tema: Catppuccin Mocha"
print_success "Go + gopls instalados"
echo ""
print_warning "IMPORTANTE: recarga tu shell para que encuentre gopls:"
echo "   source ~/.zshrc     (si usas zsh)"
echo "   source ~/.bashrc    (si usas bash)"
echo "   o simplemente abre una terminal nueva"
echo ""
echo "📋 PRÓXIMOS PASOS:"
echo "   1. cd a la carpeta de tu proyecto"
echo "   2. Ejecuta: nvim ."
echo "   3. Pulsa <Space> y espera: which-key te muestra los atajos"
echo ""
echo "🎯 ATAJOS PRINCIPALES:"
echo "   <Space>e        Explorador de archivos"
echo "   <Space>ff / fg  Buscar archivos / buscar texto"
echo "   <Space>fd       Lista de errores del proyecto"
echo "   gd / Ctrl-o     Ir a definición / volver"
echo "   K               Documentación"
echo "   grr / gri       Referencias / implementaciones"
echo "   <Space>rn       Renombrar símbolo"
echo "   <Space>ca       Code actions"
echo "   <Space>lf       Formatear"
echo "   ]d / [d         Siguiente / anterior error"
echo "   ]h / [h         Siguiente / anterior cambio git"
echo "   gcc             Comentar línea"
echo "   <Space>t        Terminal abajo (Esc Esc para salir)"
echo ""
echo "📝 COMANDOS GO:"
echo "   :GoRun   :GoTest   :GoBuild   :GoTestFunc"
echo ""
print_success "¡Listo para programar!"
