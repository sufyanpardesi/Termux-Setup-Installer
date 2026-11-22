#!/data/data/com.termux/files/usr/bin/bash

# SUFIYAN PARDESI - TYPEWRITER ANIMATION ENGINE

TYPEWRITER_ENABLED=1
TYPEWRITER_SPEED=0.012

type_text() {
    local message="$1"

    if [[ "$TYPEWRITER_ENABLED" != "1" ]]; then
        printf '%s' "$message"
        return
    fi

    local character
    while IFS= read -r -n1 character; do
        printf '%s' "$character"
        sleep "$TYPEWRITER_SPEED"
    done <<< "$message"
}

type_line() {
    type_text "$1"
    printf '\n'
}

type_prompt() {
    local variable_name="$1"
    local message="$2"
    local answer

    type_text "$message"
    IFS= read -r answer
    printf -v "$variable_name" '%s' "$answer"
}

animation_set_speed() {
    TYPEWRITER_SPEED="$1"
}

animation_disable() {
    TYPEWRITER_ENABLED=0
}

animation_enable() {
    TYPEWRITER_ENABLED=1
}
