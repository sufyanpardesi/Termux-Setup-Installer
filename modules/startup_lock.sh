#!/data/data/com.termux/files/usr/bin/bash

INSTALL_HOME="${INSTALL_HOME:-$HOME/Sufiyan-Pardesi}"
STARTUP_BASHRC="${STARTUP_BASHRC:-$HOME/.bashrc}"
STARTUP_LOCK_RUNTIME="$INSTALL_HOME/Modules/startup-lock.sh"
STARTUP_LOCK_MARKER="# SUFIYAN PARDESI STARTUP LOCK"

sufiyan_startup_lock() {
    [[ -n "${BASH_VERSION:-}" && "$-" == *i* ]] || return 0

    local pin_file="$INSTALL_HOME/Settings/pin.conf"
    local profile_file="$INSTALL_HOME/Settings/user.conf"
    local enabled salt stored_hash stored_hash_b64 entered calculated
    local profile_value
    local -a profile_fields
    local display_name="SUFIYAN PARDESI"
    local cols width left

    [[ -f "$pin_file" ]] || return 0

    enabled=$(sed -n 's/^PIN_ENABLED=//p' "$pin_file" | head -n 1)
    [[ "$enabled" == "1" ]] || return 0

    command -v openssl >/dev/null 2>&1 || {
        printf '\nERROR: OpenSSL unavailable. Terminal locked.\n'
        return 1
    }

    salt=$(sed -n 's/^PIN_SALT=//p' "$pin_file" | head -n 1)
    stored_hash_b64=$(sed -n 's/^PIN_HASH_B64=//p' "$pin_file" | head -n 1)
    stored_hash=$(printf '%s' "$stored_hash_b64" | base64 -d 2>/dev/null) || return 1

    if [[ -f "$profile_file" ]]; then
        profile_value=$(sed -n 's/^DISPLAY_NAME=//p' "$profile_file" | head -n 1)
        if [[ -n "$profile_value" ]]; then
            IFS= read -a profile_fields <<< "$profile_value"
            display_name="${profile_fields[0]:-SUFIYAN PARDESI}"
        fi
    fi

    cols=$(tput cols 2>/dev/null)
    [[ "$cols" =~ ^[0-9]+$ ]] || cols="${COLUMNS:-40}"

    width=$(printf '%s' "$display_name" | wc -L)
    left=$(( (cols - width) / 2 ))
    (( left < 0 )) && left=0

    printf '\n\033[1;38;5;220m'
    printf '%*s\n' "$cols" '' | tr ' ' '='
    printf '%*s\033[1;38;5;220m%s\033[0m\n' "$left" '' "$display_name"

    left=$(( (cols - 7) / 2 ))
    (( left < 0 )) && left=0
    printf '%*s\033[1;38;5;45mCREATOR\033[0m\n' "$left" ''

    printf '\033[1;38;5;220m'
    printf '%*s\n' "$cols" '' | tr ' ' '='
    printf '\033[0m\n'

    printf '\n\033[1;38;5;220m       TERMUX SECURITY LOCK\033[0m\n\n'

    while true; do
        printf '\033[1;38;5;45mEnter your Security PIN: \033[0m'
        IFS= read -r -s entered || return 1
        printf '\n'

        if [[ ! "$entered" =~ ^[0-9]{4,12}$ ]]; then
            printf '\033[1;31mInvalid PIN format.\033[0m\n'
            unset entered
            continue
        fi

        calculated=$(printf '%s' "$entered" | openssl passwd -6 -salt "$salt" -stdin 2>/dev/null)
        unset entered

        if [[ "$calculated" == "$stored_hash" ]]; then
            printf '\033[1;32mPIN verified. Welcome!\033[0m\n\n'
            unset calculated stored_hash stored_hash_b64 salt
            return 0
        fi

        printf '\033[1;31mIncorrect PIN. Try again.\033[0m\n'
        sleep 1
    done
}

startup_lock_install() {
    local bashrc="$STARTUP_BASHRC"
    local backup
    local had_bashrc=0

    [[ -n "$INSTALL_HOME" && -n "$DEV_HOME" ]] || return 1
    [[ -f "$DEV_HOME/modules/startup_lock.sh" ]] || return 1
    [[ ! -L "$INSTALL_HOME" ]] || {
        echo "ERROR: Unsafe installation directory."
        return 1
    }

    mkdir -p "$INSTALL_HOME/Modules" || return 1
    STARTUP_LOCK_RUNTIME="$INSTALL_HOME/Modules/startup-lock.sh"

    cp "$DEV_HOME/modules/startup_lock.sh" "$STARTUP_LOCK_RUNTIME" || return 1
    chmod 600 "$STARTUP_LOCK_RUNTIME" || return 1

    if [[ -e "$bashrc" ]]; then
        [[ -f "$bashrc" && ! -L "$bashrc" ]] || {
            echo "ERROR: Unsafe shell startup file."
            return 1
        }
        had_bashrc=1
    else
        touch "$bashrc" || return 1
    fi

    if grep -Fq "$STARTUP_LOCK_MARKER" "$bashrc"; then
        echo "Startup lock hook already exists."
        return 0
    fi

    if (( had_bashrc )); then
        backup="$bashrc.backup-$(date +%Y%m%d-%H%M%S)"
        cp -p "$bashrc" "$backup" || return 1
        echo "Existing shell startup file backed up."
    fi

    {
        printf '\n%s\n' "$STARTUP_LOCK_MARKER"
        printf 'INSTALL_HOME=%q\n' "$INSTALL_HOME"
        printf 'export INSTALL_HOME\n'
        printf 'if [[ "$-" == *i* && -f %q ]]; then\n' "$STARTUP_LOCK_RUNTIME"
        printf '    source %q\n' "$STARTUP_LOCK_RUNTIME"
        printf '    sufiyan_startup_lock || exit\n'
        printf 'fi\n'
    } >> "$bashrc" || return 1

    echo "Startup lock module and hook installed."
}
