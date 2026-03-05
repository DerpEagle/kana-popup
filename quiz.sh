#!/bin/bash
# prettier-ignore
#    _____ _     _____ _   _ _   _
#   / ____| |   |  ___| \ | | \ | |
#  | |  __| |   | |__ |  \| |  \| |
#  | | |_ | |   |  __|| . ` | . ` |
#  | |__| | |___| |___| |\  | |\  |
#   \_____|_____|_____|_| \_|_| \_|
#
# Daily Japanese quiz - all dialogs via Swift (top-right corner)

SETTINGS_FILE="$HOME/.japansk-quiz-settings"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIALOG="$SCRIPT_DIR/quiz-dialog"

# Default settings
HIRAGANA_ON=true
KATAKANA_ON=false

# Load settings
if [ -f "$SETTINGS_FILE" ]; then
    source "$SETTINGS_FILE"
fi

save_settings() {
    echo "HIRAGANA_ON=$HIRAGANA_ON" > "$SETTINGS_FILE"
    echo "KATAKANA_ON=$KATAKANA_ON" >> "$SETTINGS_FILE"
}

# All characters
HIRAGANA_CHARS=(
"あ|a" "い|i" "う|u" "え|e" "お|o"
"か|ka" "き|ki" "く|ku" "け|ke" "こ|ko"
"さ|sa" "し|shi" "す|su" "せ|se" "そ|so"
"た|ta" "ち|chi" "つ|tsu" "て|te" "と|to"
"な|na" "に|ni" "ぬ|nu" "ね|ne" "の|no"
"は|ha" "ひ|hi" "ふ|fu" "へ|he" "ほ|ho"
"ま|ma" "み|mi" "む|mu" "め|me" "も|mo"
"や|ya" "ゆ|yu" "よ|yo"
"ら|ra" "り|ri" "る|ru" "れ|re" "ろ|ro"
"わ|wa" "を|wo" "ん|n"
"が|ga" "ぎ|gi" "ぐ|gu" "げ|ge" "ご|go"
"ざ|za" "じ|ji" "ず|zu" "ぜ|ze" "ぞ|zo"
"だ|da" "ぢ|di" "づ|du" "で|de" "ど|do"
"ば|ba" "び|bi" "ぶ|bu" "べ|be" "ぼ|bo"
"ぱ|pa" "ぴ|pi" "ぷ|pu" "ぺ|pe" "ぽ|po"
)

KATAKANA_CHARS=(
"ア|a" "イ|i" "ウ|u" "エ|e" "オ|o"
"カ|ka" "キ|ki" "ク|ku" "ケ|ke" "コ|ko"
"サ|sa" "シ|shi" "ス|su" "セ|se" "ソ|so"
"タ|ta" "チ|chi" "ツ|tsu" "テ|te" "ト|to"
"ナ|na" "ニ|ni" "ヌ|nu" "ネ|ne" "ノ|no"
"ハ|ha" "ヒ|hi" "フ|fu" "ヘ|he" "ホ|ho"
"マ|ma" "ミ|mi" "ム|mu" "メ|me" "モ|mo"
"ヤ|ya" "ユ|yu" "ヨ|yo"
"ラ|ra" "リ|ri" "ル|ru" "レ|re" "ロ|ro"
"ワ|wa" "ヲ|wo" "ン|n"
"ガ|ga" "ギ|gi" "グ|gu" "ゲ|ge" "ゴ|go"
"ザ|za" "ジ|ji" "ズ|zu" "ゼ|ze" "ゾ|zo"
"ダ|da" "ヂ|di" "ヅ|du" "デ|de" "ド|do"
"バ|ba" "ビ|bi" "ブ|bu" "ベ|be" "ボ|bo"
"パ|pa" "ピ|pi" "プ|pu" "ペ|pe" "ポ|po"
)

build_char_list() {
    CHARS=()
    if [ "$HIRAGANA_ON" = true ]; then
        for c in "${HIRAGANA_CHARS[@]}"; do
            CHARS+=("${c}|hiragana")
        done
    fi
    if [ "$KATAKANA_ON" = true ]; then
        for c in "${KATAKANA_CHARS[@]}"; do
            CHARS+=("${c}|katakana")
        done
    fi
}

# Settings loop
show_settings() {
    while true; do
        CHOICE=$("$DIALOG" settings "$HIRAGANA_ON" "$KATAKANA_ON" 2>/dev/null)
        case "$CHOICE" in
            hiragana)
                if [ "$HIRAGANA_ON" = true ]; then HIRAGANA_ON=false; else HIRAGANA_ON=true; fi
                save_settings
                ;;
            katakana)
                if [ "$KATAKANA_ON" = true ]; then KATAKANA_ON=false; else KATAKANA_ON=true; fi
                save_settings
                ;;
            *) break ;;
        esac
    done
}

# Welcome
WELCOME=$("$DIALOG" welcome 2>/dev/null)

if [ "$WELCOME" = "__CANCEL__" ]; then
    exit 0
fi

if [ "$WELCOME" = "settings" ]; then
    show_settings
fi

# Ensure at least one type is enabled
if [ "$HIRAGANA_ON" = false ] && [ "$KATAKANA_ON" = false ]; then
    HIRAGANA_ON=true
    save_settings
fi

build_char_list

# Pick 5 random characters
TOTAL=${#CHARS[@]}
SELECTED=()
USED=()

for i in {1..5}; do
    while true; do
        IDX=$((RANDOM % TOTAL))
        DUPLICATE=false
        for u in "${USED[@]}"; do
            if [ "$u" = "$IDX" ]; then
                DUPLICATE=true
                break
            fi
        done
        if [ "$DUPLICATE" = false ]; then
            USED+=("$IDX")
            SELECTED+=("${CHARS[$IDX]}")
            break
        fi
    done
done

# Quiz
CORRECT=0
WRONG_LIST=""

for i in {0..4}; do
    IFS='|' read -r CHAR ROMAJI TYPE <<< "${SELECTED[$i]}"
    NR=$((i + 1))

    ANSWER=$("$DIALOG" quiz "$CHAR" "$TYPE" "$NR" 2>/dev/null)

    if [ "$ANSWER" = "__CANCEL__" ]; then
        exit 0
    fi

    ANSWER_LOWER=$(echo "$ANSWER" | tr '[:upper:]' '[:lower:]' | xargs)

    CORRECT_ANS=false
    if [ "$ANSWER_LOWER" = "$ROMAJI" ]; then
        CORRECT_ANS=true
    fi

    case "$ROMAJI" in
        shi) [ "$ANSWER_LOWER" = "si" ] && CORRECT_ANS=true ;;
        chi) [ "$ANSWER_LOWER" = "ti" ] && CORRECT_ANS=true ;;
        tsu) [ "$ANSWER_LOWER" = "tu" ] && CORRECT_ANS=true ;;
        fu)  [ "$ANSWER_LOWER" = "hu" ] && CORRECT_ANS=true ;;
        ji)  [ "$ANSWER_LOWER" = "zi" ] && CORRECT_ANS=true ;;
        wo)  [ "$ANSWER_LOWER" = "o" ] && CORRECT_ANS=true ;;
        di)  [ "$ANSWER_LOWER" = "ji" ] || [ "$ANSWER_LOWER" = "zi" ] && CORRECT_ANS=true ;;
        du)  [ "$ANSWER_LOWER" = "zu" ] || [ "$ANSWER_LOWER" = "dzu" ] && CORRECT_ANS=true ;;
    esac

    if [ "$CORRECT_ANS" = true ]; then
        CORRECT=$((CORRECT + 1))
    else
        WRONG_LIST="${WRONG_LIST}${CHAR} = ${ROMAJI} (you: ${ANSWER_LOWER})\n"
    fi
done

# Result
WRONG_MSG=$(echo -e "$WRONG_LIST")
"$DIALOG" result "$CORRECT" 5 "$WRONG_MSG" 2>/dev/null
