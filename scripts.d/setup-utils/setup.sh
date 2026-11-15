#!/bin/sh
# Instalador de paquetes base para Ubuntu/Debian, Fedora y Rocky/Alma/RHEL
set -u

# ---------------------------------------------------------------------------
# Paquetes por familia (los nombres cambian entre distros)
# ---------------------------------------------------------------------------
PKGS_DEBIAN="neovim curl git ncdu zsh htop screenfetch openssh-server openssl sqlite3"
PKGS_FEDORA="neovim curl git ncdu zsh htop fastfetch openssh-server openssl sqlite"
# En Rocky: neovim, ncdu, htop y fastfetch vienen de EPEL
PKGS_RHEL="neovim curl git ncdu zsh htop fastfetch openssh-server openssl sqlite"

# ---------------------------------------------------------------------------
# Colores (sin fallar si no hay terminal, p. ej. vía Terraform/cloud-init)
# ---------------------------------------------------------------------------
if [ -t 1 ] && command -v tput >/dev/null 2>&1 && tput colors >/dev/null 2>&1; then
  FMT_RESET=$(tput sgr0); FMT_BOLD=$(tput bold)
  FMT_RED=$(tput setaf 1); FMT_GREEN=$(tput setaf 2); FMT_YELLOW=$(tput setaf 3)
  FMT_BLUE=$(tput setaf 4); FMT_PURPLE=$(tput setaf 5)
else
  FMT_RESET=""; FMT_BOLD=""; FMT_RED=""; FMT_GREEN=""; FMT_YELLOW=""; FMT_BLUE=""; FMT_PURPLE=""
fi

info()  { printf '%s%s%s\n' "${FMT_YELLOW}" "$*" "${FMT_RESET}"; }
ok()    { printf '%s✓ %s%s\n' "${FMT_GREEN}" "$*" "${FMT_RESET}"; }
fail()  { printf '%s✗ %s%s\n' "${FMT_RED}" "$*" "${FMT_RESET}"; }

INSTALLED_PACKAGES=""
SKIPPED_PACKAGES=""
FAILED_PACKAGES=""

# Usar sudo solo si no somos root (en una VM recién creada puedes ser root)
if [ "$(id -u)" -eq 0 ]; then SUDO=""; else SUDO="sudo"; fi

# ---------------------------------------------------------------------------
# Detección de distro con /etc/os-release (estándar en todas las modernas)
# ---------------------------------------------------------------------------
detect_distro() {
  if [ ! -r /etc/os-release ]; then
    fail "No existe /etc/os-release; no se puede detectar la distribución"
    exit 1
  fi
  # shellcheck disable=SC1091
  . /etc/os-release
  DISTRO_ID="${ID:-}"
  DISTRO_LIKE="${ID_LIKE:-}"
  DISTRO_VERSION="${VERSION_ID%%.*}"   # "9.4" -> "9"

  case "$DISTRO_ID" in
    ubuntu|debian|linuxmint|pop) FAMILY="debian" ;;
    fedora)                      FAMILY="fedora" ;;
    rocky|almalinux|rhel|centos|ol) FAMILY="rhel" ;;
    *)
      # Respaldo: derivadas que declaran su "padre" en ID_LIKE
      case " $DISTRO_LIKE " in
        *" debian "*|*" ubuntu "*) FAMILY="debian" ;;
        *" rhel "*|*" centos "*)   FAMILY="rhel" ;;
        *" fedora "*)              FAMILY="fedora" ;;
        *) fail "Distribución no soportada: ${PRETTY_NAME:-$DISTRO_ID}"; exit 1 ;;
      esac
      ;;
  esac
  printf '%s%sDetectado: %s (familia %s)%s\n' "${FMT_PURPLE}" "${FMT_BOLD}" \
    "${PRETTY_NAME:-$DISTRO_ID}" "$FAMILY" "${FMT_RESET}"
}

# ---------------------------------------------------------------------------
# Funciones genéricas de "¿está instalado?" e "instalar"
# ---------------------------------------------------------------------------
is_installed() {
  case "$FAMILY" in
    debian) dpkg -s "$1" >/dev/null 2>&1 ;;
    *)      rpm -q "$1" >/dev/null 2>&1 ;;
  esac
}

pkg_install() {
  case "$FAMILY" in
    debian) DEBIAN_FRONTEND=noninteractive $SUDO apt-get install -y "$1" ;;
    *)      $SUDO dnf install -y "$1" ;;
  esac
}

install_list() {
  for pkg in $1; do
    printf '%sProcesando: %s%s\n' "${FMT_BLUE}" "$pkg" "${FMT_RESET}"

    if is_installed "$pkg"; then
      SKIPPED_PACKAGES="$SKIPPED_PACKAGES $pkg"
      ok "$pkg ya estaba instalado"
      continue
    fi

    # curl: Rocky/Fedora traen curl-minimal, que entra en conflicto con "curl".
    # Si el comando ya existe, no tiene sentido forzar el cambio.
    if [ "$pkg" = "curl" ] && command -v curl >/dev/null 2>&1; then
      SKIPPED_PACKAGES="$SKIPPED_PACKAGES curl(minimal)"
      ok "curl ya disponible (curl-minimal)"
      continue
    fi

    # No se pre-busca el paquete: el gestor ya devuelve error si no existe,
    # y así evitamos parsear la salida de "dnf search", que cambió en dnf5.
    if pkg_install "$pkg" >/tmp/setup-install.log 2>&1; then
      INSTALLED_PACKAGES="$INSTALLED_PACKAGES $pkg"
      ok "$pkg instalado"
    else
      FAILED_PACKAGES="$FAILED_PACKAGES $pkg"
      fail "No se pudo instalar $pkg (última línea: $(tail -n 1 /tmp/setup-install.log))"
    fi
  done
}

# ---------------------------------------------------------------------------
# Preparación de repositorios por familia
# ---------------------------------------------------------------------------
prepare_debian() {
  info "Actualizando índice de paquetes (apt)..."
  $SUDO apt-get update || { fail "Error en apt-get update"; exit 1; }
}

prepare_fedora() {
  info "Actualizando metadatos (dnf)..."
  $SUDO dnf makecache || { fail "Error en dnf makecache"; exit 1; }

  # RPM Fusion ANTES de instalar (no es necesario para esta lista, pero se deja
  # porque estaba en tu script original). rpm -E %fedora da la versión exacta.
  if ! rpm -q rpmfusion-free-release >/dev/null 2>&1; then
    info "Instalando RPM Fusion..."
    FEDVER=$(rpm -E %fedora)
    if $SUDO dnf install -y \
      "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDVER}.noarch.rpm" \
      "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDVER}.noarch.rpm"; then
      ok "RPM Fusion instalado"
    else
      fail "No se pudo instalar RPM Fusion (se continúa sin él)"
    fi
  fi
}

prepare_rhel() {
  info "Preparando Rocky/RHEL ${DISTRO_VERSION}: CRB + EPEL..."

  # config-manager viene en dnf-plugins-core
  $SUDO dnf install -y dnf-plugins-core >/dev/null 2>&1

  # El repo de "extras" de desarrollo se llama distinto según la versión
  case "$DISTRO_VERSION" in
    8) CRB_REPO="powertools" ;;
    *) CRB_REPO="crb" ;;          # 9 y 10
  esac

  if [ "$DISTRO_ID" = "rhel" ]; then
    # En RHEL real CRB se habilita con subscription-manager
    $SUDO subscription-manager repos \
      --enable "codeready-builder-for-rhel-${DISTRO_VERSION}-$(uname -m)-rpms" \
      || fail "No se pudo habilitar CodeReady Builder"
    EPEL_PKG="https://dl.fedoraproject.org/pub/epel/epel-release-latest-${DISTRO_VERSION}.noarch.rpm"
  else
    if $SUDO dnf config-manager --set-enabled "$CRB_REPO"; then
      ok "Repositorio $CRB_REPO habilitado"
    else
      fail "No se pudo habilitar $CRB_REPO"
    fi
    EPEL_PKG="epel-release"       # Rocky/Alma lo traen en su repo "extras"
  fi

  if ! rpm -q epel-release >/dev/null 2>&1; then
    if $SUDO dnf install -y "$EPEL_PKG"; then
      ok "EPEL instalado"
    else
      fail "No se pudo instalar EPEL; neovim/htop/ncdu fallarán"
    fi
  else
    ok "EPEL ya estaba instalado"
  fi

  $SUDO dnf makecache || { fail "Error en dnf makecache"; exit 1; }
}

# ---------------------------------------------------------------------------
# Resumen final
# ---------------------------------------------------------------------------
print_summary() {
  printf '\n%s%sProceso terminado%s\n' "${FMT_GREEN}" "${FMT_BOLD}" "${FMT_RESET}"
  [ -n "$INSTALLED_PACKAGES" ] && { printf 'Instalados ahora:'; printf ' %s' $INSTALLED_PACKAGES; echo; }
  [ -n "$SKIPPED_PACKAGES" ]   && { printf 'Ya presentes:';     printf ' %s' $SKIPPED_PACKAGES;   echo; }
  if [ -n "$FAILED_PACKAGES" ]; then
    printf '%sFallaron:' "${FMT_RED}"; printf ' %s' $FAILED_PACKAGES; printf '%s\n' "${FMT_RESET}"
    info "Revisa el nombre del paquete en tu distro o el log /tmp/setup-install.log"
  fi
  info 'Ejecuta "zsh" para probar el shell, o "chsh -s $(command -v zsh)" para dejarlo por defecto.'
  [ -n "$FAILED_PACKAGES" ] && return 1 || return 0
}

main() {
  detect_distro
  case "$FAMILY" in
    debian) prepare_debian; install_list "$PKGS_DEBIAN" ;;
    fedora) prepare_fedora; install_list "$PKGS_FEDORA" ;;
    rhel)   prepare_rhel;   install_list "$PKGS_RHEL" ;;
  esac
  print_summary
}

main "$@"