#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/sufiyan-installer-test.XXXXXX")"

echo "========================================"
echo " SUFIYAN PARDESI - LOCAL INSTALLER TEST"
echo "========================================"
echo "Isolated test directory: $TEST_ROOT"
echo "The real user installation will not be modified."

run_case() {
    local name="$1"
    local input="$2"
    local expected_pin="$3"
    local case_home="$TEST_ROOT/$name"
    local install_dir="$case_home/Sufiyan-Pardesi"

    mkdir -p "$case_home"

    echo
    echo "===== TEST: $name ====="

    if ! printf '%b' "$input" |
        env HOME="$case_home" \
            INSTALL_HOME="$install_dir" \
            DEV_HOME="$ROOT_DIR" \
            STARTUP_BASHRC="$case_home/.bashrc" \
            bash "$ROOT_DIR/installer/main.sh" \
            > "$case_home/run.log" 2>&1; then
        cat "$case_home/run.log"
        echo "FAIL: Installer exited with an error."
        return 1
    fi

    for file in \
        "$install_dir/Settings/user.conf" \
        "$install_dir/Settings/theme.conf" \
        "$install_dir/Settings/pin.conf"; do
        if [[ ! -f "$file" || -L "$file" ]]; then
            echo "FAIL: Required settings file missing or unsafe."
            cat "$case_home/run.log"
            return 1
        fi
    done

    local actual_pin
    actual_pin="$(sed -n 's/^PIN_ENABLED=//p' "$install_dir/Settings/pin.conf" | head -n 1)"

    if [[ "$actual_pin" != "$expected_pin" ]]; then
        echo "FAIL: Unexpected PIN state."
        return 1
    fi

    if [[ "$expected_pin" == "1" ]]; then
        if [[ ! -f "$case_home/.bashrc" ]] ||
           ! grep -Fq '# SUFIYAN PARDESI STARTUP LOCK' "$case_home/.bashrc"; then
            echo "FAIL: Isolated startup hook was not created."
            cat "$case_home/run.log"
            return 1
        fi

        if [[ ! -f "$install_dir/Modules/startup-lock.sh" ]]; then
            echo "FAIL: Startup lock runtime module missing."
            return 1
        fi

        if ! grep -Fq "$install_dir/Modules/startup-lock.sh" "$case_home/.bashrc"; then
            echo "FAIL: Startup hook path does not match test installation."
            return 1
        fi
    else
        if [[ -f "$case_home/.bashrc" ]] &&
           grep -Fq '# SUFIYAN PARDESI STARTUP LOCK' "$case_home/.bashrc"; then
            echo "FAIL: Hook created despite PIN being disabled."
            return 1
        fi
    fi

    echo "PASS: Profile, theme and PIN settings verified."
    echo "PASS: PIN state is correct."
    echo "PASS: No real user startup file was used."
}

run_case "pin-disabled" '1\n1\n2\n' "0"
run_case "pin-enabled" '1\n1\n1\n1234\n1234\n' "1"

echo
echo "========================================"
echo "ALL LOCAL INSTALLER TESTS PASSED"
echo "========================================"
echo "Test files and logs retained at:"
echo "$TEST_ROOT"
echo "No test data was written to the real user installation."
