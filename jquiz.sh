#!/bin/bash
# prettier-ignore
#    _____ _     _____ _   _ _   _
#   / ____| |   |  ___| \ | | \ | |
#  | |  __| |   | |__ |  \| |  \| |
#  | | |_ | |   |  __|| . ` | . ` |
#  | |__| | |___| |___| |\  | |\  |
#   \_____|_____|_____|_| \_|_| \_|
#
# CLI tool for controlling the Japanese quiz

PAUSE_FILE="$HOME/.japansk-quiz-pause"

CMD_NAME="$(basename "$0")"

if [ "$1" = "av" ] || [ "$1" = "off" ]; then
    touch "$PAUSE_FILE"
    echo "Quiz paused. Run '$CMD_NAME on' to resume."
elif [ "$1" = "på" ] || [ "$1" = "on" ]; then
    rm -f "$PAUSE_FILE"
    echo "Quiz resumed!"
elif [ "$1" = "nå" ] || [ "$1" = "now" ]; then
    SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
    "$SCRIPT_DIR/quiz.sh" &
    echo "Starting quiz..."
elif [ "$1" = "status" ]; then
    if [ -f "$PAUSE_FILE" ]; then
        echo "Quiz is PAUSED"
    else
        echo "Quiz is ACTIVE"
    fi
else
    echo "Usage: $CMD_NAME [now|off|on|status]"
fi
