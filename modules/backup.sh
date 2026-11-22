#!/data/data/com.termux/files/usr/bin/bash

BACKUP_DIR="$INSTALL_HOME/Backups"

backup_create() {
    local target="$1"
    local source_path
    local archive
    local timestamp
    local manifest
    local base

    if [[ -z "$target" || "$target" == /* || "$target" == *".."* || "$target" == *\\* ]]; then
        echo "ERROR: Invalid backup path."
        return 1
    fi

    case "$target" in
        OpenCode|Android-SDK|Gradle|Packages|Themes|Modules|Config|Updates|Installation-Details|Tests) ;;
        *)
            echo "ERROR: Backup target is not approved."
            return 1
            ;;
    esac

    if ! declare -F safety_path_is_safe >/dev/null; then
        echo "ERROR: Safety module is not loaded."
        return 1
    fi

    source_path="$INSTALL_HOME/$target"

    for path in "$INSTALL_HOME" "$source_path" "$BACKUP_DIR"; do
        if ! safety_path_is_safe "$path"; then
            echo "ERROR: Unsafe backup path detected."
            return 1
        fi
    done

    if [[ ! -d "$source_path" || -L "$source_path" ]]; then
        echo "ERROR: Backup source is missing or unsafe."
        return 1
    fi

    if [[ -e "$BACKUP_DIR" && ! -d "$BACKUP_DIR" ]]; then
        echo "ERROR: Backup destination is not a directory."
        return 1
    fi

    umask 077
    mkdir -p "$BACKUP_DIR" || return 1
    chmod 700 "$BACKUP_DIR" || return 1

    if ! safety_path_is_safe "$BACKUP_DIR"; then
        echo "ERROR: Backup directory verification failed."
        return 1
    fi

    timestamp="$(date '+%Y%m%d-%H%M%S')"
    archive="$BACKUP_DIR/backup-$target-$timestamp-$$.tar.gz"
    base="$(basename "$archive")"

    if [[ -e "$archive" || -L "$archive" ]]; then
        echo "ERROR: Backup destination already exists."
        return 1
    fi

    manifest="$(mktemp "${TMPDIR:-$PREFIX/tmp}/sufiyan-backup.XXXXXX")" || {
        echo "ERROR: Could not create temporary backup manifest."
        return 1
    }
    chmod 600 "$manifest"

    if ! printf '%s\0' "$target" > "$manifest"; then
        rm -f "$manifest"
        return 1
    fi

    if ! (
        cd "$INSTALL_HOME" &&
        find "$target" -mindepth 1 \
            \( -type d \( \
                -iname Backups -o \
                -iname Logs -o \
                -iname Secrets -o \
                -iname Private \
            \) -prune \) -o \
            \( -type d -print0 \) -o \
            \( -type f ! \( \
                -iname '.env' -o \
                -iname '.env.*' -o \
                -iname '*secret*' -o \
                -iname '*token*' -o \
                -iname '*credential*' -o \
                -iname '*password*' -o \
                -iname 'pin.conf' -o \
                -iname 'user.conf' -o \
                -iname '*.log' -o \
                -iname '*.tar' -o \
                -iname '*.tar.gz' -o \
                -iname '*.zip' -o \
                -iname '*.sha256' -o \
                -iname '*.pem' -o \
                -iname '*.key' -o \
                -iname '*.keystore' \
            \) -print0 \)
    ) >> "$manifest"; then
        rm -f "$manifest"
        echo "ERROR: Could not prepare backup file list."
        return 1
    fi

    if ! tar --no-recursion -C "$INSTALL_HOME" --null -T "$manifest" -czf "$archive"; then
        rm -f "$manifest"
        echo "ERROR: Backup creation failed. Partial archive retained."
        return 1
    fi

    rm -f "$manifest"
    chmod 600 "$archive" || return 1

    if ! tar -tzf "$archive" >/dev/null; then
        echo "ERROR: Backup archive verification failed."
        return 1
    fi

    if ! (
        cd "$BACKUP_DIR" &&
        sha256sum "$base" > "$base.sha256"
    ); then
        echo "ERROR: Checksum creation failed."
        return 1
    fi

    chmod 600 "$archive.sha256" || return 1

    echo "Backup created and verified successfully."
    echo "File: $archive"
}

backup_list() {
    if ! declare -F safety_path_is_safe >/dev/null ||
       ! safety_path_is_safe "$BACKUP_DIR"; then
        echo "ERROR: Backup directory is unsafe."
        return 1
    fi

    if [[ ! -d "$BACKUP_DIR" || -L "$BACKUP_DIR" ]]; then
        echo "No backup directory found."
        return 0
    fi

    echo "Available backups:"
    find "$BACKUP_DIR" -maxdepth 1 -type f -name 'backup-*.tar.gz' -print
}
