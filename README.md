# Japanese Popup Quiz

A macOS app that helps you learn hiragana and katakana through daily popup quizzes. The app runs in the background and shows 5 random Japanese characters at random intervals — type the correct romaji to answer.

> **Note:** macOS only. Uses Swift/Cocoa for native popup dialogs and LaunchAgent for automatic scheduling.

## Features

- **Popup quiz** with large, readable Japanese characters (Swift/Cocoa)
- **Random intervals** between 10 and 60 minutes
- **Hiragana and katakana** — toggle on/off in settings
- **Fullscreen detection** — won't interrupt games or movies
- **Manual pause** via terminal command
- **Alternative romaji** accepted (e.g., `si` for `し`, `tu` for `つ`)
- Runs automatically at login, no dependencies

## Installation

1. Clone the repo
2. Compile the Swift dialog:
   ```bash
   cd "Japanese popup practice"
   swiftc -o quiz-dialog QuizDialog.swift -framework Cocoa
   chmod +x quiz.sh quiz-loop.sh jquiz.sh
   ```
3. Copy the LaunchAgent for automatic startup:
   ```bash
   cp com.japanese-quiz.plist ~/Library/LaunchAgents/
   launchctl load ~/Library/LaunchAgents/com.japanese-quiz.plist
   ```
4. (Optional) Add a shortcut command — name it whatever you like:
   ```bash
   mkdir -p ~/bin
   ln -s "/full/path/to/jquiz.sh" ~/bin/quiz
   echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
   ```

## Usage

The quiz starts automatically. For manual control, use the shortcut you created in step 4:

| Command | Description |
|---|---|
| `quiz now` | Start a quiz right now |
| `quiz off` | Pause the quiz |
| `quiz on` | Resume the quiz |
| `quiz status` | Check if the quiz is active or paused |

## Settings

Press **Settings** in the welcome dialog to:
- Toggle hiragana on/off
- Toggle katakana on/off

Settings are saved in `~/.japansk-quiz-settings`.

## Files

| File | Description |
|---|---|
| `QuizDialog.swift` | Swift app with all dialogs (welcome, settings, quiz, result) |
| `quiz-dialog` | Compiled Swift binary |
| `quiz.sh` | Main script — runs one quiz round |
| `quiz-loop.sh` | Background loop with random intervals |
| `jquiz.sh` | CLI tool for pause/start/status |

## Configuration

Active hours and intervals can be changed in `quiz-loop.sh`:
- `MIN_WAIT=600` — minimum wait time (seconds)
- `MAX_WAIT=3600` — maximum wait time (seconds)
- Time window: 08:00–22:00

## License

[MIT License](LICENSE)
