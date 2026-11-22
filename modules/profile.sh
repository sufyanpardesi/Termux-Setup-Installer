#!/data/data/com.termux/files/usr/bin/bash

DEFAULT_DISPLAY_NAME="SUFIYAN PARDESI"
DISPLAY_NAME="$DEFAULT_DISPLAY_NAME"

profile_select_name() {
    local entered_name

    printf '\nEnter your banner name [SUFIYAN PARDESI]: '
    IFS= read -r entered_name

    if [[ -n "$entered_name" ]]; then
        DISPLAY_NAME="$entered_name"
    else
        DISPLAY_NAME="$DEFAULT_DISPLAY_NAME"
    fi

    echo "Selected Display Name: $DISPLAY_NAME"
}

profile_save() {
    local settings_dir="$INSTALL_HOME/Settings"
    local settings_file="$settings_dir/user.conf"

    if ! declare -F safety_path_is_safe >/dev/null ||
       ! safety_path_is_safe "$settings_dir" ||
       [[ ! -d "$settings_dir" || -L "$settings_dir" ]]; then
        echo "ERROR: Unsafe Settings directory."
        return 1
    fi

    if ! safety_path_is_safe "$settings_file" ||
       [[ -e "$settings_file" || -L "$settings_file" ]]; then
        echo "ERROR: Existing or unsafe profile file will not be overwritten."
        return 1
    fi

    umask 077
    if ! (set -o noclobber; printf 'DISPLAY_NAME=%q\\n' "$DISPLAY_NAME" > "$settings_file"); then
        echo "ERROR: Could not safely create profile settings."
        return 1
    fi

    chmod 600 "$settings_file" || return 1
    echo "Display name settings saved."
}
