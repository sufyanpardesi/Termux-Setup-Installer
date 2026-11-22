#!/data/data/com.termux/files/usr/bin/bash

LOG_DIR="$INSTALL_HOME/Logs"
LOG_FILE=""

log_redact() {
    printf '%s' "$*" | sed -E \
      -e 's/([Pp][Aa][Ss][Ss][Ww][Oo][Rr][Dd]|[Pp][Ii][Nn]|[Aa][Pp][Ii]_[Kk][Ee][Yy]|[Tt][Oo][Kk][Ee][Nn]|[Ss][Ee][Cc][Rr][Ee][Tt]|[Aa][Cc][Cc][Ee][Ss][Ss]_[Tt][Oo][Kk][Ee][Nn])[[:space:]]*[:=][[:space:]]*[^[:space:]]+/\1=[REDACTED]/g' \
      -e 's/AIza[0-9A-Za-z_-]{20,}/[REDACTED_API_KEY]/g' \
      -e 's/[Bb]earer[[:space:]]+[A-Za-z0-9._-]+/Bearer [REDACTED]/g'
}

log_init() {
    umask 077

    if ! declare -F safety_path_is_safe >/dev/null ||
       ! safety_path_is_safe "$LOG_DIR"; then
        echo "ERROR: Unsafe logging directory."
        return 1
    fi

    mkdir -p "$LOG_DIR" || return 1

    if ! safety_path_is_safe "$LOG_DIR" || [[ ! -d "$LOG_DIR" ]]; then
        echo "ERROR: Logging directory verification failed."
        return 1
    fi

    LOG_FILE="$LOG_DIR/installer-$(date '+%Y%m%d-%H%M%S')-$$.log"

    if [[ -e "$LOG_FILE" || -L "$LOG_FILE" ]]; then
        echo "ERROR: Log file already exists."
        return 1
    fi

    (set -o noclobber; : > "$LOG_FILE") || return 1
    chmod 600 "$LOG_FILE" || return 1

    echo "Logging system initialized."
}

log_write() {
    local level="$1"
    shift
    local message

    [[ -n "$LOG_FILE" ]] || return 0
    safety_path_is_safe "$LOG_FILE" || return 1
    [[ -f "$LOG_FILE" && ! -L "$LOG_FILE" ]] || return 1

    message="$(log_redact "$*")"

    printf '[%s] [%s] %s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$message" >> "$LOG_FILE"
}

log_info() {
    local message
    message="$(log_redact "$*")"
    log_write INFO "$message"
    printf '\033[38;5;45m[INFO]\033[0m %s\n' "$message"
}

log_success() {
    local message
    message="$(log_redact "$*")"
    log_write SUCCESS "$message"
    printf '\033[38;5;46m[SUCCESS]\033[0m %s\n' "$message"
}

log_warning() {
    local message
    message="$(log_redact "$*")"
    log_write WARNING "$message"
    printf '\033[38;5;220m[WARNING]\033[0m %s\n' "$message"
}

log_error() {
    local message
    message="$(log_redact "$*")"
    log_write ERROR "$message"
    printf '\033[38;5;196m[ERROR]\033[0m %s\n' "$message" >&2
}

log_show_location() {
    printf 'Log file: %s\n' "$LOG_FILE"
}
