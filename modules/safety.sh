#!/data/data/com.termux/files/usr/bin/bash

# SUFIYAN PARDESI - HARDENED SAFETY MODULE

safety_path_is_safe() {
    local path="$1"
    local current="/"
    local part
    local -a parts

    [[ "$path" == /* ]] || return 1
    [[ "$path" != *$'\n'* && "$path" != *$'\r'* ]] || return 1

    case "$path" in
        *"/../"*|*/..|../*|..) return 1 ;;
    esac

    IFS='/' read -r -a parts <<< "$path"

    for part in "${parts[@]}"; do
        [[ -z "$part" || "$part" == "." ]] && continue
        current="${current%/}/$part"
        [[ -L "$current" ]] && return 1
    done

    return 0
}

safety_load_config() {
    local config_file="$DEV_HOME/config/safety.conf"

    if [[ ! -f "$config_file" || -L "$config_file" ]] ||
       ! safety_path_is_safe "$config_file"; then
        echo "ERROR: Safety configuration is missing or unsafe."
        return 1
    fi

    source "$config_file" || {
        echo "ERROR: Safety configuration could not be loaded."
        return 1
    }
}

safety_create_directories() {
    local directory

    case "$INSTALL_HOME" in
        "$HOME"/*) ;;
        *)
            echo "ERROR: Installation directory must be inside HOME."
            return 1
            ;;
    esac

    if ! safety_path_is_safe "$INSTALL_HOME"; then
        echo "ERROR: Unsafe installation directory path."
        return 1
    fi

    local directories=(
        "$INSTALL_HOME"
        "$INSTALL_HOME/OpenCode"
        "$INSTALL_HOME/Android-SDK"
        "$INSTALL_HOME/Gradle"
        "$INSTALL_HOME/Packages"
        "$INSTALL_HOME/Themes"
        "$INSTALL_HOME/Settings"
        "$INSTALL_HOME/Modules"
        "$INSTALL_HOME/Config"
        "$INSTALL_HOME/Updates"
        "$INSTALL_HOME/Backups"
        "$INSTALL_HOME/Logs"
        "$INSTALL_HOME/Installation-Details"
        "$INSTALL_HOME/Tests"
    )

    for directory in "${directories[@]}"; do
        if ! safety_path_is_safe "$directory"; then
            echo "ERROR: Unsafe directory path detected."
            return 1
        fi

        if [[ -e "$directory" && ! -d "$directory" ]]; then
            echo "ERROR: Expected directory is not a directory."
            return 1
        fi

        mkdir -p "$directory" || {
            echo "ERROR: Could not create a required directory."
            return 1
        }

        if ! safety_path_is_safe "$directory" || [[ ! -d "$directory" ]]; then
            echo "ERROR: Directory safety verification failed."
            return 1
        fi
    done
}

safety_check_protected_paths() {
    local path

    for path in "${PROTECTED_PATHS[@]}"; do
        if [[ -e "$path" ]]; then
            printf 'PROTECTED: %s\n' "$path"
        fi
    done
}

safety_report() {
    echo "Safety module loaded."
    echo "Installation directory: $INSTALL_HOME"
    echo "Existing user data will be preserved."
    echo "Automatic deletion is disabled."
    echo "Symbolic-link path checks are enabled."
}
