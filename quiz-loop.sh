#!/bin/bash
# prettier-ignore
#    _____ _     _____ _   _ _   _
#   / ____| |   |  ___| \ | | \ | |
#  | |  __| |   | |__ |  \| |  \| |
#  | | |_ | |   |  __|| . ` | . ` |
#  | |__| | |___| |___| |\  | |\  |
#   \_____|_____|_____|_| \_|_| \_|
#
# Runs quiz in a loop with random intervals (10-60 min)
# Active between 08:00 and 22:00
# Paused when ~/.japansk-quiz-pause exists

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PAUSE_FILE="$HOME/.japansk-quiz-pause"
MIN_WAIT=600    # 10 minutes (in seconds)
MAX_WAIT=3600   # 60 minutes (in seconds)

while true; do
    HOUR=$(date +%H)

    # Check if paused
    PAUSED=false
    if [ -f "$PAUSE_FILE" ]; then
        PAUSED=true
    fi

    # Check if a fullscreen app is running (games etc.)
    FULLSCREEN=$(osascript -e '
        tell application "System Events"
            set frontApp to first application process whose frontmost is true
            try
                if (value of attribute "AXFullScreen" of window 1 of frontApp) is true then
                    return "true"
                end if
            end try
        end tell
        return "false"
    ' 2>/dev/null)

    # Only run between 08:00 and 22:00, not when paused, not in fullscreen
    if [ "$HOUR" -ge 8 ] && [ "$HOUR" -lt 22 ] && [ "$PAUSED" = false ] && [ "$FULLSCREEN" != "true" ]; then
        "$SCRIPT_DIR/quiz.sh"
    fi

    # Random wait between 10 and 60 minutes
    WAIT=$((MIN_WAIT + RANDOM % (MAX_WAIT - MIN_WAIT)))
    sleep $WAIT
done
