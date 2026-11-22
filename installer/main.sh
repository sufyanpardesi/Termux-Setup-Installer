#!/data/data/com.termux/files/usr/bin/bash
set -Ee

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DEV_HOME="$ROOT_DIR"
export INSTALL_HOME="$HOME/Sufiyan-Pardesi"

source "$ROOT_DIR/modules/safety.sh"

if ! safety_load_config; then
    exit 1
fi

# Load installer modules
MODULES=(
    animation.sh
    logging.sh
    detect.sh
    banner.sh
    theme.sh
    profile.sh
    pin.sh
    startup_lock.sh
    privacy.sh
    backup.sh
    install_plan.sh
)

for module in "${MODULES[@]}"; do
    file="$ROOT_DIR/modules/$module"
    if [ ! -f "$file" ] || [ -L "$file" ]; then
        echo "Required module is missing: $module"
        exit 1
    fi
    source "$file"
done

# Create installer directories only after safety validation
if ! safety_create_directories; then
    exit 1
fi

chmod 700 "$INSTALL_HOME/Settings" || exit 1

if declare -F log_init >/dev/null; then
    log_init
fi

echo
echo "===== FIRST INSTALLATION SETUP ====="

PIN_FILE="$INSTALL_HOME/Settings/pin.conf"
PROFILE_FILE="$INSTALL_HOME/Settings/user.conf"
THEME_FILE="$INSTALL_HOME/Settings/theme.conf"

if ! safety_path_is_safe "$INSTALL_HOME/Settings"; then
    echo "ERROR: Unsafe Settings directory path. Stopping."
    exit 1
fi

for settings_file in "$PIN_FILE" "$PROFILE_FILE" "$THEME_FILE"; do
    if ! safety_path_is_safe "$settings_file"; then
        echo "ERROR: Unsafe Settings file path. Stopping."
        exit 1
    fi

    if [[ -e "$settings_file" || -L "$settings_file" ]]; then
        if [[ ! -f "$settings_file" || -L "$settings_file" ]]; then
            echo "ERROR: Settings entry is not a safe regular file. Stopping."
            exit 1
        fi
    fi
done

if [[ -f "$PROFILE_FILE" ]]; then
    echo "User Profile: EXISTING - PRESERVED"
    profile_value="$(sed -n 's/^DISPLAY_NAME=//p' "$PROFILE_FILE" | head -n 1)"
    DISPLAY_NAME="${profile_value#\\\"}"
    DISPLAY_NAME="${DISPLAY_NAME%\\\"}"
    DISPLAY_NAME="${DISPLAY_NAME//\\\\ / }"
    DISPLAY_NAME="${DISPLAY_NAME:-SUFIYAN PARDESI}"
    BANNER_NAME="$DISPLAY_NAME"
else
    echo "User Profile: FIRST-TIME SETUP"
    banner_select || exit 1
    profile_save || exit 1
fi

echo
echo "===== BANNER ====="
banner_render

echo
echo "===== THEME ====="
if [[ -f "$THEME_FILE" ]]; then
    echo "Existing theme is preserved."
else
    theme_select || exit 1
    theme_save || exit 1
fi

echo
echo "===== SECURITY PIN ====="
if [[ -f "$PIN_FILE" ]]; then
    echo "Existing Security PIN configuration will be preserved."
else
    pin_setup || exit 1
fi

PIN_ENABLED="$(sed -n 's/^PIN_ENABLED=//p' "$PIN_FILE" | head -n 1)"

if [[ "$PIN_ENABLED" == "1" ]]; then
    if grep -Fq '# SUFIYAN PARDESI STARTUP LOCK' "${STARTUP_BASHRC:-$HOME/.bashrc}" 2>/dev/null; then
        echo "Startup Lock Hook: ALREADY INSTALLED - PRESERVED"
    else
        echo "Installing Startup Lock Hook..."
        startup_lock_install || exit 1
    fi
else
    echo "Security PIN is disabled. No new Startup Lock Hook will be installed."
fi

echo
echo "===== SETUP SUMMARY ====="
echo "User Profile: CONFIGURED"
echo "Theme: CONFIGURED"
if [[ "$PIN_ENABLED" == "1" ]]; then
    echo "Security PIN: ENABLED"
    echo "Startup Lock: ENABLED"
else
    echo "Security PIN: DISABLED"
    echo "Startup Lock: DISABLED"
fi

echo "===== SOFTWARE DETECTION ====="
if declare -F detect_all >/dev/null; then
    detect_all
fi

echo
echo "===== INSTALLATION PREFLIGHT ====="
if declare -F install_plan_show >/dev/null; then
    install_plan_show
fi

echo
echo "======================================"
echo "INITIAL SETUP AND DETECTION COMPLETED."
echo "======================================"
echo "Existing PIN, profile and startup hook were not modified."
echo "OpenCode, Android SDK and Gradle installation will be handled in the next phase."
