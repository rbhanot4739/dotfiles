import Cocoa

// Line-buffer stdout so each print() flushes immediately through the pipe.
setvbuf(stdout, nil, _IOLBF, 0)

var lastMode: String = ""
var observation: NSKeyValueObservation?

func currentMode() -> String {
    // NSApp.effectiveAppearance is the authoritative source — it reflects the
    // actual resolved appearance including Auto mode (sunrise/sunset scheduling).
    NSApp.effectiveAppearance.name.rawValue.lowercased().contains("dark") ? "dark" : "light"
}

func emitIfChanged() {
    let mode = currentMode()
    guard mode != lastMode else { return }
    lastMode = mode
    print(mode)
}

// Create a proper NSApplication so we participate in the AppKit appearance
// system. Without this, KVO on effectiveAppearance does not fire for automatic
// (scheduled) appearance switches — only manual System Settings toggles send
// the DistributedNotification that a bare RunLoop can catch.
let app = NSApplication.shared

// .prohibited = background agent: no Dock icon, no menu bar, no activation.
app.setActivationPolicy(.prohibited)

// Capture baseline before the run loop starts.
lastMode = currentMode()

// KVO on NSApp.effectiveAppearance is the same mechanism used by VS Code,
// Slack, and all native macOS apps. It fires for EVERY appearance change:
// manual System Settings toggles, Auto mode sunrise/sunset switches, and
// changes triggered by other apps — with zero latency and no missed events.
observation = NSApp.observe(\.effectiveAppearance, options: [.new]) { _, _ in
    emitIfChanged()
}

app.run()
