#!/bin/sh

# Colores
FMT_RESET=$(tput sgr0)
FMT_BOLD=$(tput bold)
FMT_RED=$(tput setaf 1)
FMT_GREEN=$(tput setaf 2)
FMT_YELLOW=$(tput setaf 3)
FMT_BLUE=$(tput setaf 4)
FMT_PURPLE=$(tput setaf 5)

# ── Helpers ────────────────────────────────────────────────
print_header() {
  printf '\n%s%s%s\n\n' "${FMT_PURPLE}${FMT_BOLD}" "=== Instalador de Go ===" "${FMT_RESET}"
}

print_ok()   { printf '%s%s✔ %s%s\n' "${FMT_GREEN}"  "${FMT_BOLD}" "$1" "${FMT_RESET}"; }
print_info() { printf '%s%s→ %s%s\n' "${FMT_BLUE}"   "${FMT_BOLD}" "$1" "${FMT_RESET}"; }
print_warn() { printf '%s%s⚠ %s%s\n' "${FMT_YELLOW}" "${FMT_BOLD}" "$1" "${FMT_RESET}"; }
print_err()  { printf '%s%s✘ %s%s\n' "${FMT_RED}"    "${FMT_BOLD}" "$1" "${FMT_RESET}"; }

# ── Detectar distro ────────────────────────────────────────
detect_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "$ID"
  elif [ -f /etc/fedora-release ]; then
    echo "fedora"
  elif [ -f /etc/arch-release ]; then
    echo "arch"
  else
    echo "unknown"
  fi
}

# ── Detectar shell activo y su profile ────────────────────
detect_shell_profile() {
  # Detecta el shell del usuario actual, no el que corre el script
  user_shell=$(getent passwd "$(whoami)" | cut -d: -f7)
  case "$user_shell" in
    */zsh)  echo "$HOME/.zshrc" ;;
    */fish) echo "$HOME/.config/fish/config.fish" ;;
    */bash) echo "$HOME/.bashrc" ;;
    *)      echo "$HOME/.profile" ;;  # POSIX fallback universal
  esac
}

# ── Verificar dependencias ─────────────────────────────────
check_dependencies() {
  for cmd in curl python3 tar; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      print_err "Dependencia faltante: $cmd"
      exit 1
    fi
  done
  print_ok "Dependencias verificadas (curl, python3, tar)"
}

# ── Obtener versión recomendada desde API oficial ──────────
get_recommended_version() {
  raw=$(curl -s "https://go.dev/dl/?mode=json" 2>/dev/null)
  if [ -z "$raw" ]; then
    print_err "No se pudo conectar a go.dev"
    exit 1
  fi
  # current-1: la segunda de la lista = soportada y estable
  echo "$raw" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(data[1]['version'].replace('go',''))
"
}

# ── Instalar Go ────────────────────────────────────────────
install_go() {
  version=$1
  tarball="go${version}.linux-amd64.tar.gz"
  url="https://go.dev/dl/${tarball}"
  tmp="/tmp/${tarball}"

  print_info "Descargando Go ${version}..."
  curl -L "$url" -o "$tmp" 2>/dev/null || wget "$url" -O "$tmp" 2>/dev/null
  
  if [ ! -f "$tmp" ]; then
    print_err "Fallo la descarga"
    exit 1
  fi
  print_ok "Descarga completa"

  print_info "Instalando en /usr/local/go..."
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "$tmp"
  rm -f "$tmp"
  print_ok "Instalación completa"
}

# ── Configurar PATH en el perfil del shell ─────────────────
configure_path() {
  profile=$(detect_shell_profile)
  
  # Evitar duplicados
  if grep -q '/usr/local/go/bin' "$profile" 2>/dev/null; then
    print_warn "PATH ya configurado en $profile — omitiendo"
    return
  fi

  if echo "$profile" | grep -q "config.fish"; then
    # fish usa sintaxis diferente
    printf '\nset -gx PATH $PATH /usr/local/go/bin\nset -gx GOPATH $HOME/go\n' >> "$profile"
  else
    printf '\nexport PATH=$PATH:/usr/local/go/bin\nexport GOPATH=$HOME/go\n' >> "$profile"
  fi

  print_ok "PATH configurado en $profile"
  print_warn "Ejecuta: source $profile"
}

# ── Verificar instalación ──────────────────────────────────
verify_go() {
  if /usr/local/go/bin/go version >/dev/null 2>&1; then
    installed=$(/usr/local/go/bin/go version)
    print_ok "Go instalado correctamente: $installed"
  else
    print_err "Algo salió mal — go no responde"
    exit 1
  fi
}

# ── Main ───────────────────────────────────────────────────
main() {
  print_header

  distro=$(detect_distro)
  print_info "Distro detectada: $distro"

  check_dependencies

  print_info "Consultando versión recomendada (current-1)..."
  GO_VERSION=$(get_recommended_version)
  print_ok "Versión seleccionada: Go $GO_VERSION"

  install_go "$GO_VERSION"
  configure_path
  verify_go

  printf '\n%s%s¡Listo! Reinicia tu sesión o ejecuta source en tu profile.%s\n\n' \
    "${FMT_GREEN}" "${FMT_BOLD}" "${FMT_RESET}"
}

main