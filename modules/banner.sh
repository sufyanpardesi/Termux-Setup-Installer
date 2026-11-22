#!/data/data/com.termux/files/usr/bin/bash

BANNER_NAME="ＳＵＦＩＹＡＮ　ＰＡＲＤＥＳＩ"
BANNER_SUBTITLE="CREATOR"

banner_select() {
    local choice custom_name

    echo
    echo "========== BANNER SELECTION =========="
    echo "1. Default Banner"
    echo "2. Custom Display Name"
    echo "======================================"
    printf "Choose an option [1]: "
    IFS= read -r choice

    case "$choice" in
        2)
            printf "Enter your display name: "
            IFS= read -r custom_name

            if [[ -n "$custom_name" ]]; then
                DISPLAY_NAME="$custom_name"
                BANNER_NAME="$custom_name"
            else
                DISPLAY_NAME="SUFIYAN PARDESI"
                BANNER_NAME="ＳＵＦＩＹＡＮ　ＰＡＲＤＥＳＩ"
            fi
            ;;
        *)
            DISPLAY_NAME="SUFIYAN PARDESI"
            BANNER_NAME="ＳＵＦＩＹＡＮ　ＰＡＲＤＥＳＩ"
            ;;
    esac

    echo
    printf 'Selected Display Name: %s\n' "$DISPLAY_NAME"
}

banner_render() {
    local cols width left

    cols="$(tput cols 2>/dev/null || true)"
    [[ "$cols" =~ ^[0-9]+$ ]] || cols="${COLUMNS:-40}"
    [[ "$cols" =~ ^[0-9]+$ ]] || cols=40
    if (( cols < 10 )); then cols=10; fi

    width=$(printf '%s' "$BANNER_NAME" | wc -L)
    [[ "$width" =~ ^[0-9]+$ ]] || width=20
    left=$(( (cols - width) / 2 ))
    if (( left < 0 )); then left=0; fi

    printf '\n\033[1;38;5;220m'
    printf '%*s\n' "$cols" '' | tr ' ' '='
    printf '%*s%s\033[0m\n' "$left" '' "$BANNER_NAME"

    left=$(( (cols - 7) / 2 ))
    if (( left < 0 )); then left=0; fi
    printf '%*s\033[1;38;5;45m\033[1mCREATOR\033[0m\n' "$left" ''

    printf '\033[1;38;5;220m'
    printf '%*s\n' "$cols" '' | tr ' ' '='
    printf '\033[0m\n'
}
