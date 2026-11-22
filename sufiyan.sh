#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

REPO="https://github.com/sufyanpardesi/termux-setup-installer.git"
TARGET="$HOME/Sufiyan-Pardesi-Installer"

echo "========================================"
echo "       SUFIYAN PARDESI CREATOR"
echo "          TERMUX INSTALLER"
echo "========================================"

if [[ -z "${PREFIX:-}" || ! -d "$PREFIX" ]]; then
    echo "ERROR: This installer requires Termux."
    exit 1
fi

if ! command -v git >/dev/null 2>&1; then
    if ! command -v pkg >/dev/null 2>&1; then
        echo "ERROR: Git and the Termux package manager are unavailable."
        exit 1
    fi

    echo "Git is missing. Installing the required Git package..."
    pkg install -y git || {
        echo "ERROR: Git installation failed."
        exit 1
    }
fi

if ! command -v git >/dev/null 2>&1; then
    echo "ERROR: Git is still unavailable."
    exit 1
fi

if [[ -L "$TARGET" ]]; then
    echo "ERROR: Installer target is a symbolic link. Stopping."
    exit 1
fi

if [[ -L "$TARGET/.git" ]]; then
    echo "ERROR: Git metadata is a symbolic link. Stopping."
    exit 1
fi

if [[ -d "$TARGET/.git" ]]; then
    echo "Existing installer repository found."

    if [[ "$(git -C "$TARGET" rev-parse --show-toplevel 2>/dev/null)" != "$TARGET" ]]; then
        echo "ERROR: Repository root validation failed."
        exit 1
    fi

    REMOTE="$(git -C "$TARGET" remote get-url origin 2>/dev/null || true)"
    if [[ "$REMOTE" != "$REPO" ]]; then
        echo "ERROR: Repository origin does not match the official installer."
        exit 1
    fi

    BRANCH="$(git -C "$TARGET" branch --show-current 2>/dev/null || true)"
    if [[ "$BRANCH" != "main" ]]; then
        echo "ERROR: Current branch is not main. Update cancelled."
        exit 1
    fi

    if [[ -n "$(git -C "$TARGET" status --porcelain 2>/dev/null)" ]]; then
        echo "ERROR: Local changes detected. Update cancelled to protect your work."
        exit 1
    fi

    echo "Checking for safe updates..."
    git -C "$TARGET" pull --ff-only origin main || {
        echo "ERROR: Safe update failed. No forced update was attempted."
        exit 1
    }

elif [[ -e "$TARGET" ]]; then
    echo "ERROR: Target exists but is not a valid installer repository."
    echo "No files were overwritten."
    exit 1
else
    echo "Downloading the installer repository..."
    git clone --branch main --single-branch "$REPO" "$TARGET" || {
        echo "ERROR: Repository download failed."
        exit 1
    }
fi

if [[ -L "$TARGET/.git" || ! -d "$TARGET/.git" ]]; then
    echo "ERROR: Repository metadata is missing or unsafe."
    exit 1
fi

ROOT="$(git -C "$TARGET" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ "$ROOT" != "$TARGET" ]]; then
    echo "ERROR: Downloaded repository root validation failed."
    exit 1
fi

REMOTE="$(git -C "$TARGET" remote get-url origin 2>/dev/null || true)"
if [[ "$REMOTE" != "$REPO" ]]; then
    echo "ERROR: Downloaded repository origin validation failed."
    exit 1
fi

BRANCH="$(git -C "$TARGET" branch --show-current 2>/dev/null || true)"
if [[ "$BRANCH" != "main" ]]; then
    echo "ERROR: Downloaded repository branch validation failed."
    exit 1
fi

if [[ -n "$(git -C "$TARGET" status --porcelain 2>/dev/null)" ]]; then
    echo "ERROR: Downloaded repository is not clean. Stopping."
    exit 1
fi

if [[ ! -f "$TARGET/installer/bootstrap.sh" || -L "$TARGET/installer/bootstrap.sh" ]]; then
    echo "ERROR: Bootstrap entry file is missing or unsafe."
    exit 1
fi

echo "Starting the installer..."
exec bash "$TARGET/installer/bootstrap.sh"
