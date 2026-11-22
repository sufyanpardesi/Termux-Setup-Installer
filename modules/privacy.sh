#!/data/data/com.termux/files/usr/bin/bash

PRIVACY_PROTECTED_PATHS=(
    "$INSTALL_HOME"
    "$HOME/.ssh"
    "$HOME/.gnupg"
)

PRIVACY_SENSITIVE_PATTERNS=(
    ".env"
    ".env.*"
    "*secret*"
    "*token*"
    "*credential*"
    "*password*"
    "pin.conf"
    "user.conf"
    "*.log"
    "*.tar"
    "*.tar.gz"
    "*.zip"
    "*.sha256"
    "*.pem"
    "*.key"
    "*.keystore"
)

PRIVACY_SENSITIVE_DIRS=(
    "Backups"
    "Logs"
    "Secrets"
    "Private"
)

privacy_check_path() {
    local target="$1"
    local protected
    local resolved
    local root

    [[ -n "$target" ]] || return 1

    target="${target/#\~/$HOME}"

    case "$target" in
        *$'\n'*|*$'\r'*)
            echo "BLOCKED: Invalid path."
            return 1
            ;;
    esac

    if [[ "$target" != /* ]]; then
        echo "BLOCKED: Absolute path required."
        return 1
    fi

    if ! declare -F safety_path_is_safe >/dev/null ||
       ! safety_path_is_safe "$target"; then
        echo "BLOCKED: Unsafe path or symbolic link."
        return 1
    fi

    resolved="$(realpath -m "$target")" || return 1
    root="$(realpath -m "$HOME")" || return 1

    case "$resolved" in
        "$root"/*) ;;
        *)
            echo "BLOCKED: Path is outside HOME."
            return 1
            ;;
    esac

    for protected in "${PRIVACY_PROTECTED_PATHS[@]}"; do
        protected="$(realpath -m "$protected")" || return 1

        if [[ "$resolved" == "$protected" ||
              "$resolved" == "$protected/"* ]]; then
            echo "BLOCKED: Protected path."
            return 1
        fi
    done

    echo "ALLOWED: Path is not on the protected list."
    return 0
}
privacy_check_github_file() {
    local file="$1"
    local pattern
    local component
    local remainder

    [[ -n "$file" ]] || return 1

    if [[ "$file" == /* || "$file" == *".."* || "$file" == *\\* ]]; then
        echo "BLOCKED: Invalid file path."
        return 1
    fi

    if [[ "$file" == *$'\n'* || "$file" == *$'\r'* ]]; then
        echo "BLOCKED: Invalid file name."
        return 1
    fi

    # Reject a symbolic-link repository root.
    if [[ -L "$DEV_HOME" || ! -d "$DEV_HOME" ]]; then
        echo "BLOCKED: Repository root is missing or unsafe."
        return 1
    fi

    # Check every parent directory component without following symlinks.
    local current="$DEV_HOME"
    remainder="$file"

    while [[ "$remainder" == */* ]]; do
        component="${remainder%%/*}"
        current="$current/$component"

        if [[ -L "$current" || ! -d "$current" ]]; then
            echo "BLOCKED: Parent directory is missing or unsafe."
            return 1
        fi

        remainder="${remainder#*/}"
    done

    if [[ -L "$current/$remainder" ]]; then
        echo "BLOCKED: Symbolic link file."
        return 1
    fi

    remainder="$file"

    while [[ "$remainder" == */* ]]; do
        component="${remainder%%/*}"

        for pattern in "${PRIVACY_SENSITIVE_DIRS[@]}"; do
            if [[ "$component" == "$pattern" ]]; then
                echo "BLOCKED: Private directory."
                return 1
            fi
        done

        remainder="${remainder#*/}"
    done

    for pattern in "${PRIVACY_SENSITIVE_DIRS[@]}"; do
        if [[ "$remainder" == "$pattern" ]]; then
            echo "BLOCKED: Private directory."
            return 1
        fi
    done

    for pattern in "${PRIVACY_SENSITIVE_PATTERNS[@]}"; do
        if [[ "$file" == $pattern || "$remainder" == $pattern ]]; then
            echo "BLOCKED: Sensitive file."
            return 1
        fi
    done

    if [[ ! -f "$DEV_HOME/$file" || -L "$DEV_HOME/$file" ]]; then
        echo "BLOCKED: File missing or symbolic link."
        return 1
    fi

    printf 'CHECK REQUIRED: %s\n' "$file"
    echo "File content must be audited before GitHub upload."
    return 0
}

privacy_report() {
    echo "=================================="
    echo " SUFIYAN PARDESI PRIVACY PROTECTION"
    echo "=================================="

    echo "Private installation data is protected."
    echo "Sensitive files and directories are excluded."
    echo "GitHub files require individual review."
    echo "Automatic bulk upload is not permitted."
}
