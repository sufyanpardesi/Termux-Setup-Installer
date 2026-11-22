#!/data/data/com.termux/files/usr/bin/bash

PIN_FILE="$INSTALL_HOME/Settings/pin.conf"

pin_setup() {
    local choice pin confirm salt hash hash_b64

    echo
    echo "========== SECURITY PIN SETUP =========="
    echo "1. Enable Security PIN"
    echo "2. Disable Security PIN (Default)"
    echo "========================================"
    printf "Choose an option [2]: "
    IFS= read -r choice

    if [[ "$choice" != "1" ]]; then
        mkdir -p "$(dirname "$PIN_FILE")" || return 1
        umask 077
        printf 'PIN_ENABLED=0\nPIN_SALT=\nPIN_HASH_B64=\n' > "$PIN_FILE" || return 1
        chmod 600 "$PIN_FILE"
        echo "Security PIN is disabled."
        return 0
    fi

    command -v openssl >/dev/null 2>&1 || {
        echo "ERROR: OpenSSL command not found."
        return 1
    }

    while true; do
        printf "Create a PIN (4-12 digits): "
        IFS= read -r -s pin
        printf '\n'

        if [[ ! "$pin" =~ ^[0-9]{4,12}$ ]]; then
            echo "Invalid PIN. Use 4 to 12 digits."
            continue
        fi

        printf "Confirm your PIN: "
        IFS= read -r -s confirm
        printf '\n'

        if [[ "$pin" != "$confirm" ]]; then
            echo "PINs do not match. Try again."
            unset confirm
            continue
        fi
        unset confirm
        break
    done

    salt=$(openssl rand -hex 16) || return 1
    hash=$(printf '%s' "$pin" | openssl passwd -6 -salt "$salt" -stdin) || return 1
    unset pin

    hash_b64=$(printf '%s' "$hash" | base64 | tr -d '\n')
    unset hash

    mkdir -p "$(dirname "$PIN_FILE")" || return 1
    umask 077
    {
        printf 'PIN_ENABLED=1\n'
        printf 'PIN_SALT=%s\n' "$salt"
        printf 'PIN_HASH_B64=%s\n' "$hash_b64"
    } > "$PIN_FILE" || return 1

    chmod 600 "$PIN_FILE"
    echo "Security PIN saved securely."
}

pin_verify() {
    local pin enabled salt stored_hash_b64 stored_hash calculated_hash

    [[ -f "$PIN_FILE" && ! -L "$PIN_FILE" ]] || {
        echo "No safe PIN configuration found."
        return 1
    }

    enabled="$(sed -n 's/^PIN_ENABLED=//p' "$PIN_FILE" | head -n 1)"
    [[ "$enabled" == "1" ]] || {
        echo "Security PIN is disabled."
        return 0
    }

    salt="$(sed -n 's/^PIN_SALT=//p' "$PIN_FILE" | head -n 1)"
    stored_hash_b64="$(sed -n 's/^PIN_HASH_B64=//p' "$PIN_FILE" | head -n 1)"

    [[ "$salt" =~ ^[a-fA-F0-9]{32}$ && -n "$stored_hash_b64" ]] || {
        echo "ERROR: PIN configuration is invalid."
        return 1
    }

    stored_hash="$(printf '%s' "$stored_hash_b64" | base64 -d 2>/dev/null)" || {
        echo "ERROR: PIN configuration is invalid."
        return 1
    }

    printf "Enter your Security PIN: "
    IFS= read -r -s pin || return 1
    printf '\n'

    [[ "$pin" =~ ^[0-9]{4,12}$ ]] || {
        unset pin stored_hash stored_hash_b64
        echo "Invalid PIN format."
        return 1
    }

    calculated_hash="$(printf '%s' "$pin" | openssl passwd -6 -salt "$salt" -stdin)" || {
        unset pin stored_hash stored_hash_b64
        return 1
    }
    unset pin

    if [[ "$calculated_hash" == "$stored_hash" ]]; then
        unset calculated_hash stored_hash stored_hash_b64 salt
        echo "PIN verified successfully."
        return 0
    fi

    unset calculated_hash stored_hash stored_hash_b64 salt
    echo "Incorrect PIN."
    return 1
}
