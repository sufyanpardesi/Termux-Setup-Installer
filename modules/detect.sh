#!/data/data/com.termux/files/usr/bin/bash

# SUFIYAN PARDESI - SMART ARM64 SOFTWARE DETECTION

detect_command() {
    local name="$1"
    local path

    if path="$(command -v "$name" 2>/dev/null)"; then
        printf '%-14s FOUND  %s\n' "$name" "$path"
    else
        printf '%-14s MISSING\n' "$name"
    fi
}

detect_version() {
    local name="$1"
    local output=""

    case "$name" in
        gradle)
            output="$(gradle --version 2>&1 | awk '/^Gradle / {print; exit}')"
            ;;
        java)
            output="$(java -version 2>&1 | head -n 1)"
            ;;
        sdkmanager)
            output="$(sdkmanager --version 2>&1 | awk '/^[0-9]+(\.[0-9]+)*$/ {print; exit}')"
            ;;
        adb)
            output="$(adb version 2>&1 | head -n 1)"
            ;;
        *)
            output="$("$name" --version 2>&1 | head -n 1)"
            ;;
    esac

    printf '%-14s %s\n' "$name" "${output:-VERSION UNAVAILABLE}"
}

detect_android_sdk() {
    local sdk_root="$HOME/android-sdk"
    local build_tools="$sdk_root/build-tools/35.0.0"

    echo
    echo "--- ANDROID SDK ---"

    if [[ ! -d "$sdk_root" || -L "$sdk_root" ]]; then
        echo "Android SDK: NOT FOUND OR UNSAFE"
        return 0
    fi

    export ANDROID_HOME="$sdk_root"
    export ANDROID_SDK_ROOT="$sdk_root"

    if [[ -x "$sdk_root/cmdline-tools/latest/bin/sdkmanager" ]]; then
        export PATH="$sdk_root/cmdline-tools/latest/bin:$PATH"
    fi

    if [[ -d "$build_tools" && ! -L "$build_tools" ]]; then
        export PATH="$build_tools:$PATH"
    fi

    printf 'SDK ROOT: %s\n' "$sdk_root"

    for item in platform-tools build-tools platforms cmdline-tools; do
        if [[ -d "$sdk_root/$item" ]]; then
            printf '  %-18s FOUND\n' "$item"
        else
            printf '  %-18s MISSING\n' "$item"
        fi
    done

    echo
    echo "--- TERMUX ADB ---"
    if command -v adb >/dev/null 2>&1; then
        adb version 2>&1 | head -n 2
    else
        echo "ADB: MISSING"
    fi

    echo
    echo "--- COMPATIBLE BUILD TOOLS ---"

    for tool in aapt aapt2 zipalign apksigner; do
        if [[ -x "$build_tools/$tool" ]]; then
            printf '%-14s FOUND\n' "$tool"
        else
            printf '%-14s MISSING\n' "$tool"
        fi
    done

    if [[ -x "$build_tools/aapt" ]]; then
        "$build_tools/aapt" version 2>&1 | head -n 1
    fi

    if [[ -x "$build_tools/aapt2" ]]; then
        "$build_tools/aapt2" version 2>&1 | head -n 1
    fi

    echo
    echo "--- SDK MANAGER ---"
    if command -v sdkmanager >/dev/null 2>&1; then
        sdk_output="$(sdkmanager --version 2>&1 || true)"
        sdk_version="$(printf '%s\n' "$sdk_output" | awk '$0 ~ /^[0-9]+([.][0-9]+)*$/ {v=$0} END {print v}')"
        if [[ -n "$sdk_version" ]]; then
            printf 'SDK MANAGER VERSION: %s\n' "$sdk_version"
        else
            echo "SDK MANAGER: VERSION UNAVAILABLE"
            printf '%s\n' "$sdk_output" | tail -n 3
        fi
    else
        echo "SDKMANAGER: MISSING"
    fi

    echo
    echo "--- APK SIGNER TEST ---"
    if [[ -x "$build_tools/apksigner" ]]; then
        if signer_output="$("$build_tools/apksigner" version 2>&1)"; then
            printf 'APKSIGNER: WORKING\n'
            printf '%s\n' "$signer_output"
        else
            echo "APKSIGNER: FOUND BUT TEST FAILED"
            printf '%s\n' "$signer_output"
        fi
    else
        echo "APKSIGNER: MISSING"
    fi
}

detect_all() {
    echo "======================================"
    echo " SUFIYAN PARDESI SYSTEM DETECTION"
    echo "======================================"

    detect_android_sdk

    echo
    echo "--- SOFTWARE DETECTION ---"

    for tool in opencode java gradle node npm git adb sdkmanager; do
        detect_command "$tool"
    done

    echo
    echo "--- SOFTWARE VERSIONS ---"

    for tool in opencode java gradle node npm adb sdkmanager; do
        if command -v "$tool" >/dev/null 2>&1; then
            detect_version "$tool"
        fi
    done
}
