#!/usr/bin/env bash
#
# emoji-selector.sh — выбор эмодзи через rofi с копированием в буфер обмена
# и (опционально) автовставкой в активное окно.
#
# Зависимости:
#   - rofi
#   - xclip (X11) или wl-clipboard (Wayland) — для копирования
#   - xdotool (X11) или ydotool (Wayland) — опционально, для автовставки
#
# Установка (Arch/Debian-подобные):
#   sudo pacman -S rofi xclip xdotool         # X11
#   sudo apt install rofi xclip xdotool       # X11 (Debian/Ubuntu)
#   sudo pacman -S rofi wl-clipboard ydotool  # Wayland
#
# Использование:
#   ./emoji-selector.sh              # выбрать эмодзи, скопировать в буфер
#   ./emoji-selector.sh --type       # выбрать эмодзи и сразу вставить в окно
#
# Файл со списком эмодзи ищется рядом со скриптом (emoji-list.txt).
# Формат строки: "EMOJI ОписаниеНаЯзыке"

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
EMOJI_FILE="${EMOJI_LIST_FILE:-$SCRIPT_DIR/emoji-list.txt}"

ROFI_THEME="${ROFI_EMOJI_THEME:-}"   # можно передать свою тему через переменную окружения
DO_TYPE=false

for arg in "$@"; do
    case "$arg" in
        --type|-t) DO_TYPE=true ;;
        --help|-h)
            echo "Использование: $0 [--type]"
            echo "  --type   вставить эмодзи в активное окно вместо простого копирования"
            exit 0
            ;;
    esac
done

if [[ ! -f "$EMOJI_FILE" ]]; then
    echo "Не найден файл со списком эмодзи: $EMOJI_FILE" >&2
    exit 1
fi

if ! command -v rofi &>/dev/null; then
    echo "rofi не установлен." >&2
    exit 1
fi

# Определяем сессию: Wayland или X11
is_wayland=false
if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    is_wayland=true
fi

copy_to_clipboard() {
    local text="$1"
    if $is_wayland; then
        if command -v wl-copy &>/dev/null; then
            printf '%s' "$text" | wl-copy
        else
            echo "wl-copy не найден (нужен пакет wl-clipboard)." >&2
            exit 1
        fi
    else
        if command -v xclip &>/dev/null; then
            printf '%s' "$text" | xclip -selection clipboard
        else
            echo "xclip не найден." >&2
            exit 1
        fi
    fi
}

type_text() {
    local text="$1"
    if $is_wayland; then
        if command -v ydotool &>/dev/null; then
            ydotool type -- "$text"
        else
            echo "ydotool не найден, эмодзи только скопирован в буфер." >&2
        fi
    else
        if command -v xdotool &>/dev/null; then
            # небольшая задержка, чтобы rofi успел закрыться и фокус вернулся в окно
            sleep 0.1
            xdotool type --clearmodifiers -- "$text"
        else
            echo "xdotool не найден, эмодзи только скопирован в буфер." >&2
        fi
    fi
}

rofi_args=(-dmenu -i -p "Emoji" -markup-rows)
if [[ -n "$ROFI_THEME" ]]; then
    rofi_args+=(-theme "$ROFI_THEME")
fi

selected_line="$(rofi "${rofi_args[@]}" < "$EMOJI_FILE" || true)"

if [[ -z "$selected_line" ]]; then
    exit 0
fi

# Берём первый "символ" строки (сам эмодзи) — до первого пробела
emoji="$(awk '{print $1}' <<< "$selected_line")"

copy_to_clipboard "$emoji"

if $DO_TYPE; then
    type_text "$emoji"
fi

# Уведомление (если есть notify-send)
if command -v notify-send &>/dev/null; then
    notify-send "Emoji" "$emoji скопирован в буфер обмена" -t 1500
fi
