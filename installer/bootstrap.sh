#!/data/data/com.termux/files/usr/bin/bash
set -Ee

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DEV_HOME="$ROOT_DIR"

if [ -z "${PREFIX:-}" ] || [ ! -d "$PREFIX" ]; then
    echo "This installer is designed for Termux."
    exit 1
fi

echo "======================================"
echo "       SUFIYAN PARDESI CREATOR"
echo "          TERMUX INSTALLER"
echo "======================================"
echo "CHECKING REQUIRED BASE PACKAGES..."

declare -A REQUIRED=(
    [curl]=curl
    [git]=git
    [openssl]=openssl
    [tar]=tar
    [sha256sum]=coreutils
    [find]=findutils
)

MISSING=()
for cmd in "${!REQUIRED[@]}"; do
    command -v "$cmd" >/dev/null 2>&1 || MISSING+=("${REQUIRED[$cmd]}")
done

if ((${#MISSING[@]})); then
    if ! command -v pkg >/dev/null 2>&1; then
        echo "Termux package manager (pkg) is unavailable."
        exit 1
    fi
    mapfile -t UNIQUE_MISSING < <(printf '%s\n' "${MISSING[@]}" | sort -u)
    pkg install -y "${UNIQUE_MISSING[@]}" || exit 1
fi

exec bash "$ROOT_DIR/installer/main.sh"
