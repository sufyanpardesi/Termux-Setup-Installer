#!/data/data/com.termux/files/usr/bin/bash
# SUFIYAN PARDESI - SAFE SOFTWARE INSTALLATION PREFLIGHT

install_plan_show() {
    local sdk_root="$HOME/android-sdk"
    local build_tools="$sdk_root/build-tools/35.0.0"
    local free_kb=0
    local free_mb=0
    local arch
    local status="READY"

    echo
    echo "======================================"
    echo " SOFTWARE INSTALLATION PREFLIGHT"
    echo "======================================"

    arch="$(uname -m 2>/dev/null || echo UNKNOWN)"
    printf 'DEVICE ARCHITECTURE: %s\n' "$arch"

    echo
    echo "--- EXISTING SOFTWARE ---"

    for tool in opencode java gradle node npm adb; do
        if command -v "$tool" >/dev/null 2>&1; then
            printf '%-14s AVAILABLE\n' "$tool"
        else
            printf '%-14s NOT FOUND\n' "$tool"
        fi
    done

    echo
    echo "--- ANDROID SDK COMPONENTS ---"

    for item in platforms platform-tools build-tools cmdline-tools; do
        if [[ -d "$sdk_root/$item" && ! -L "$sdk_root/$item" ]]; then
            printf '%-18s AVAILABLE\n' "$item"
        else
            printf '%-18s NOT FOUND\n' "$item"
        fi
    done

    echo
    echo "--- BUILD TOOLS 35 ---"

    for tool in aapt aapt2 zipalign apksigner; do
        if [[ -x "$build_tools/$tool" ]]; then
            printf '%-14s AVAILABLE\n' "$tool"
        else
            printf '%-14s NOT FOUND\n' "$tool"
            status="INCOMPLETE"
        fi
    done

    echo
    echo "--- STORAGE PREFLIGHT ---"

    free_kb="$(df -Pk "$HOME" 2>/dev/null | awk 'NR==2 {print $4}')"
    if [[ "$free_kb" =~ ^[0-9]+$ ]]; then
        free_mb=$((free_kb / 1024))
        printf 'AVAILABLE STORAGE: %s MB\n' "$free_mb"
    else
        echo "AVAILABLE STORAGE: UNKNOWN"
        status="STORAGE CHECK FAILED"
    fi

    if (( free_mb < 2048 )); then
        echo "STORAGE STATUS: LOW"
        echo "Large downloads are blocked until more space is available."
        status="LOW STORAGE"
    else
        echo "STORAGE STATUS: SUFFICIENT FOR PREFLIGHT"
    fi

    echo
    echo "--- INSTALLATION DECISION ---"

    if [[ "$arch" != "aarch64" ]]; then
        echo "DEVICE STATUS: ARCHITECTURE NEEDS REVIEW"
        status="ARCHITECTURE REVIEW REQUIRED"
    fi

    if command -v opencode >/dev/null 2>&1 &&
       command -v java >/dev/null 2>&1 &&
       command -v gradle >/dev/null 2>&1 &&
       [[ -d "$sdk_root/platforms" && -d "$build_tools" ]]; then
        echo "EXISTING INSTALLATIONS: REUSE"
        echo "ACTION: No duplicate installation is required."
    else
        echo "EXISTING INSTALLATIONS: INCOMPLETE"
        echo "ACTION: Missing components require compatibility review."
    fi

    echo
    echo "DOWNLOAD ESTIMATE: NOT REQUESTED"
    echo "No verified release download metadata has been collected."
    echo "No downloads, upgrades or deletions were performed."
    printf 'PREFLIGHT RESULT: %s\n' "$status"
    echo "======================================"
}
