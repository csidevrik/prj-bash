SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_SCRIPT="$SCRIPT_DIR/../../../scripts.d/install-googledriveP/setup.sh"

if [ ! -f "$SETUP_SCRIPT" ]; then
    printf "Error: no se encontró el script en %s\n" "$SETUP_SCRIPT"
    exit 1
fi

sh "$SETUP_SCRIPT"
