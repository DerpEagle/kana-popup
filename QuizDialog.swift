/* prettier-ignore */
/*
 *    _____ _     _____ _   _ _   _
 *   / ____| |   |  ___| \ | | \ | |
 *  | |  __| |   | |__ |  \| |  \| |
 *  | | |_ | |   |  __|| . ` | . ` |
 *  | |__| | |___| |___| |\  | |\  |
 *   \_____|_____|_____|_| \_|_| \_|
 */

import Cocoa

let darkBg = NSColor(red: 0.1, green: 0.1, blue: 0.18, alpha: 1.0)
let accentColor = NSColor(red: 0.91, green: 0.27, blue: 0.37, alpha: 1.0)

// Helper: position window top-right
func topRightRect(w: CGFloat, h: CGFloat) -> NSRect {
    let screen = NSScreen.main!.visibleFrame
    return NSMakeRect(screen.maxX - w - 20, screen.maxY - h - 10, w, h)
}

func makeWindow(title: String, width: CGFloat, height: CGFloat) -> NSWindow {
    let win = NSWindow(
        contentRect: topRightRect(w: width, h: height),
        styleMask: [.titled, .closable],
        backing: .buffered,
        defer: false
    )
    win.title = title
    win.level = .floating
    win.backgroundColor = darkBg
    return win
}

func whiteLabel(_ text: String, size: CGFloat) -> NSTextField {
    let label = NSTextField(labelWithString: text)
    label.alignment = .center
    label.font = NSFont.systemFont(ofSize: size)
    label.textColor = .white
    return label
}

func grayLabel(_ text: String, size: CGFloat) -> NSTextField {
    let label = NSTextField(labelWithString: text)
    label.alignment = .center
    label.font = NSFont.systemFont(ofSize: size)
    label.textColor = .gray
    return label
}

func makeButton(_ title: String, width: CGFloat = 120) -> NSButton {
    let btn = NSButton(frame: NSMakeRect(0, 0, width, 38))
    btn.title = title
    btn.bezelStyle = .rounded
    btn.font = NSFont.systemFont(ofSize: 15)
    return btn
}

// MARK: - Base dialog class

class DialogBase: NSObject, NSWindowDelegate {
    let window: NSWindow
    var result = "__CANCEL__"

    init(window: NSWindow) {
        self.window = window
        super.init()
        window.delegate = self
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        result = "__CANCEL__"
        NSApp.stopModal()
        return true
    }

    func show() -> String {
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        NSApp.runModal(for: window)
        window.orderOut(nil)
        return result
    }
}

// MARK: - Welcome dialog

class WelcomeDialog: DialogBase {
    init() {
        let win = makeWindow(title: "Japanese Quiz", width: 340, height: 180)
        super.init(window: win)

        let content = win.contentView!
        let w: CGFloat = 340

        let title = whiteLabel("Daily Japanese Quiz", size: 22)
        title.frame = NSMakeRect(0, 120, w, 30)
        content.addSubview(title)

        let sub = grayLabel("Ready for 5 characters?", size: 14)
        sub.frame = NSMakeRect(0, 92, w, 22)
        content.addSubview(sub)

        let settingsBtn = makeButton("Settings", width: 130)
        settingsBtn.frame = NSMakeRect(30, 28, 130, 38)
        settingsBtn.tag = 1
        settingsBtn.target = self
        settingsBtn.action = #selector(buttonClicked(_:))
        content.addSubview(settingsBtn)

        let startBtn = makeButton("Start!", width: 130)
        startBtn.frame = NSMakeRect(180, 28, 130, 38)
        startBtn.keyEquivalent = "\r"
        startBtn.tag = 2
        startBtn.target = self
        startBtn.action = #selector(buttonClicked(_:))
        content.addSubview(startBtn)
    }

    @objc func buttonClicked(_ sender: NSButton) {
        result = sender.tag == 1 ? "settings" : "start"
        NSApp.stopModal()
    }
}

// MARK: - Settings dialog

class SettingsDialog: DialogBase {
    init(hiraganaOn: Bool, katakanaOn: Bool) {
        let win = makeWindow(title: "Settings", width: 340, height: 220)
        super.init(window: win)

        let content = win.contentView!
        let w: CGFloat = 340

        let title = whiteLabel("Settings", size: 20)
        title.frame = NSMakeRect(0, 170, w, 28)
        content.addSubview(title)

        let hStatus = hiraganaOn ? "ON" : "OFF"
        let kStatus = katakanaOn ? "ON" : "OFF"

        let hLabel = whiteLabel("Hiragana: \(hStatus)", size: 16)
        hLabel.frame = NSMakeRect(0, 130, w, 24)
        content.addSubview(hLabel)

        let kLabel = whiteLabel("Katakana: \(kStatus)", size: 16)
        kLabel.frame = NSMakeRect(0, 100, w, 24)
        content.addSubview(kLabel)

        let hBtn = makeButton("Hiragana \(hStatus)", width: 140)
        hBtn.frame = NSMakeRect(20, 45, 140, 38)
        hBtn.tag = 1
        hBtn.target = self
        hBtn.action = #selector(buttonClicked(_:))
        content.addSubview(hBtn)

        let kBtn = makeButton("Katakana \(kStatus)", width: 140)
        kBtn.frame = NSMakeRect(180, 45, 140, 38)
        kBtn.tag = 2
        kBtn.target = self
        kBtn.action = #selector(buttonClicked(_:))
        content.addSubview(kBtn)

        let backBtn = makeButton("Back", width: 100)
        backBtn.frame = NSMakeRect(120, 5, 100, 32)
        backBtn.keyEquivalent = "\r"
        backBtn.tag = 3
        backBtn.target = self
        backBtn.action = #selector(buttonClicked(_:))
        content.addSubview(backBtn)
    }

    @objc func buttonClicked(_ sender: NSButton) {
        switch sender.tag {
        case 1: result = "hiragana"
        case 2: result = "katakana"
        default: result = "back"
        }
        NSApp.stopModal()
    }
}

// MARK: - Quiz dialog

class QuizDialog: DialogBase {
    let inputField: NSTextField

    init(char: String, charType: String, number: String) {
        let win = makeWindow(title: "Japanese Quiz (\(number)/5)", width: 380, height: 310)
        inputField = NSTextField(frame: NSMakeRect(90, 80, 200, 34))
        super.init(window: win)

        let content = win.contentView!
        let w: CGFloat = 380

        let typeLabel = grayLabel(charType, size: 15)
        typeLabel.frame = NSMakeRect(0, 255, w, 25)
        content.addSubview(typeLabel)

        let charLabel = whiteLabel(char, size: 100)
        charLabel.frame = NSMakeRect(0, 130, w, 130)
        content.addSubview(charLabel)

        inputField.alignment = .center
        inputField.font = NSFont.systemFont(ofSize: 20)
        inputField.placeholderString = "romaji"
        inputField.isBezeled = true
        inputField.bezelStyle = .roundedBezel
        inputField.focusRingType = .exterior
        content.addSubview(inputField)

        let btn = makeButton("Answer")
        btn.frame = NSMakeRect(130, 28, 120, 38)
        btn.keyEquivalent = "\r"
        btn.target = self
        btn.action = #selector(submitAnswer)
        content.addSubview(btn)
    }

    @objc func submitAnswer() {
        result = inputField.stringValue
        NSApp.stopModal()
    }

    override func show() -> String {
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(inputField)
        NSApp.activate(ignoringOtherApps: true)
        NSApp.runModal(for: window)
        window.orderOut(nil)
        return result
    }
}

// MARK: - Result dialog

class ResultDialog: DialogBase {
    init(correct: Int, total: Int, wrongList: String) {
        let isPerfect = correct == total
        let h: CGFloat = isPerfect ? 160 : 160 + CGFloat(wrongList.components(separatedBy: "\n").filter { !$0.isEmpty }.count) * 22 + 30
        let win = makeWindow(title: "Result", width: 380, height: min(h, 400))
        super.init(window: win)

        let content = win.contentView!
        let w: CGFloat = 380
        var y = h - 50

        if isPerfect {
            let msg = whiteLabel("Perfect! \(correct)/\(total) correct!", size: 22)
            msg.textColor = NSColor(red: 0.31, green: 0.80, blue: 0.64, alpha: 1.0)
            msg.frame = NSMakeRect(0, y, w, 30)
            content.addSubview(msg)
        } else {
            let msg = whiteLabel("\(correct)/\(total) correct", size: 22)
            msg.frame = NSMakeRect(0, y, w, 30)
            content.addSubview(msg)

            y -= 35
            let wrongTitle = grayLabel("Wrong answers:", size: 13)
            wrongTitle.frame = NSMakeRect(0, y, w, 20)
            content.addSubview(wrongTitle)

            let lines = wrongList.components(separatedBy: "\n").filter { !$0.isEmpty }
            for line in lines {
                y -= 22
                let l = whiteLabel(line, size: 14)
                l.frame = NSMakeRect(0, y, w, 20)
                content.addSubview(l)
            }
        }

        let btnTitle = isPerfect ? "Awesome!" : "OK"
        let btn = makeButton(btnTitle)
        btn.frame = NSMakeRect(130, 15, 120, 38)
        btn.keyEquivalent = "\r"
        btn.target = self
        btn.action = #selector(okClicked)
        content.addSubview(btn)
    }

    @objc func okClicked() {
        result = "ok"
        NSApp.stopModal()
    }
}

// MARK: - Main

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let args = CommandLine.arguments
guard args.count >= 2 else {
    print("__CANCEL__")
    exit(1)
}

let mode = args[1]

switch mode {
case "welcome":
    let dialog = WelcomeDialog()
    print(dialog.show())

case "settings":
    guard args.count >= 4 else { print("__CANCEL__"); exit(1) }
    let hOn = args[2] == "true"
    let kOn = args[3] == "true"
    let dialog = SettingsDialog(hiraganaOn: hOn, katakanaOn: kOn)
    print(dialog.show())

case "quiz":
    guard args.count >= 5 else { print("__CANCEL__"); exit(1) }
    let dialog = QuizDialog(char: args[2], charType: args[3], number: args[4])
    print(dialog.show())

case "result":
    guard args.count >= 4 else { print("__CANCEL__"); exit(1) }
    let correct = Int(args[2]) ?? 0
    let total = Int(args[3]) ?? 5
    let wrongList = args.count >= 5 ? args[4] : ""
    let dialog = ResultDialog(correct: correct, total: total, wrongList: wrongList)
    print(dialog.show())

default:
    print("__CANCEL__")
    exit(1)
}
