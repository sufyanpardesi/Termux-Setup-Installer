#!/data/data/com.termux/files/usr/bin/bash

THEME_NAME="Cosmic Gold"
THEME_PRIMARY='\033[38;5;220m'
THEME_SECONDARY='\033[38;5;45m'
THEME_ACCENT='\033[38;5;135m'
THEME_RESET='\033[0m'

theme_select() {
    local choice

    echo
    echo "========== SELECT YOUR THEME =========="
    echo "1. Cosmic Gold (Default)"
    echo "2. Ocean Blue"
    echo "3. Royal Purple"
    echo "4. Emerald Green"
    echo "======================================="

    printf "Choose a theme [1]: "
    IFS= read -r choice

    case "$choice" in
        2)
            THEME_NAME="Ocean Blue"
            THEME_PRIMARY='\033[38;5;39m'
            THEME_SECONDARY='\033[38;5;51m'
            THEME_ACCENT='\033[38;5;27m'
            ;;
        3)
            THEME_NAME="Royal Purple"
            THEME_PRIMARY='\033[38;5;135m'
            THEME_SECONDARY='\033[38;5;213m'
            THEME_ACCENT='\033[38;5;99m'
            ;;
        4)
            THEME_NAME="Emerald Green"
            THEME_PRIMARY='\033[38;5;46m'
            THEME_SECONDARY='\033[38;5;220m'
            THEME_ACCENT='\033[38;5;34m'
            ;;
        *)
            THEME_NAME="Cosmic Gold"
            THEME_PRIMARY='\033[38;5;220m'
            THEME_SECONDARY='\033[38;5;45m'
            THEME_ACCENT='\033[38;5;135m'
            ;;
    esac

    echo
    printf "${THEME_PRIMARY}Selected Theme: %s${THEME_RESET}\n" "$THEME_NAME"
}

theme_save() {
    local settings_dir="$INSTALL_HOME/Settings"
    local settings_file="$settings_dir/theme.conf"

    if ! declare -F safety_path_is_safe >/dev/null ||
       ! safety_path_is_safe "$settings_dir" ||
       [[ ! -d "$settings_dir" || -L "$settings_dir" ]]; then
        echo "ERROR: Unsafe Settings directory."
        return 1
    fi

    if ! safety_path_is_safe "$settings_file" ||
       [[ -e "$settings_file" || -L "$settings_file" ]]; then
        echo "ERROR: Existing or unsafe theme file will not be overwritten."
        return 1
    fi

    umask 077
    if ! (
        set -o noclobber
        {
            printf 'THEME_NAME=%q\\n' "$THEME_NAME"
            printf 'THEME_PRIMARY=%q\\n' "$THEME_PRIMARY"
            printf 'THEME_SECONDARY=%q\\n' "$THEME_SECONDARY"
            printf 'THEME_ACCENT=%q\\n' "$THEME_ACCENT"
        } > "$settings_file"
    ); then
        echo "ERROR: Could not safely create theme settings."
        return 1
    fi

    chmod 600 "$settings_file" || return 1
    echo "Theme settings saved."
}
