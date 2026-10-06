// SimpleBar — a tiny menu bar icon hider.
//
// Two menu bar items:
//   [ | ]  the divider. Everything to the LEFT of it gets hidden.
//   [ ‹ ]  the arrow. Click it to hide / show.
// Hold ⌘ and drag icons to put them on either side of the divider.
// Right-click the arrow for options (start at login, quit).

import Cocoa
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var arrow: NSStatusItem!
    private var divider: NSStatusItem!
    private var isCollapsed = false

    // Big enough to shove everything to its left off the screen.
    private let collapsedLength: CGFloat = 10_000

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Created first, so macOS places it furthest right.
        arrow = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        arrow.autosaveName = "SimpleBarArrow"

        // Created second, so it lands just to the left of the arrow.
        divider = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        divider.autosaveName = "SimpleBarDivider"

        if let button = arrow.button {
            button.target = self
            button.action = #selector(arrowClicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        expand()

        // Hide icons shortly after launch, once the menu bar has laid itself out.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.collapse(showWarning: false)
        }
    }

    // MARK: - Clicks

    @objc private func arrowClicked() {
        let event = NSApp.currentEvent
        let isRightClick = event?.type == .rightMouseUp
            || event?.modifierFlags.contains(.control) == true

        if isRightClick {
            showMenu()
        } else if isCollapsed {
            expand()
        } else {
            collapse(showWarning: true)
        }
    }

    // MARK: - Hide / show

    private func expand() {
        isCollapsed = false
        divider.length = NSStatusItem.variableLength
        if let button = divider.button {
            button.image = symbol("poweron", fallback: "|")
            button.appearsDisabled = true
        }
        setArrow(pointingLeft: false) // "›" = click to hide them again
    }

    private func collapse(showWarning: Bool) {
        guard dividerIsLeftOfArrow() else {
            if showWarning { explainOrder() }
            return
        }
        isCollapsed = true
        divider.button?.image = nil
        divider.length = collapsedLength
        setArrow(pointingLeft: true) // "‹" = click to bring them back
    }

    private func setArrow(pointingLeft: Bool) {
        arrow.button?.image = symbol(pointingLeft ? "chevron.left" : "chevron.right",
                                     fallback: pointingLeft ? "<" : ">")
    }

    /// If someone drags the divider to the right of the arrow, collapsing would
    /// hide the arrow too and you'd be stuck. So we refuse in that case.
    private func dividerIsLeftOfArrow() -> Bool {
        guard let a = arrow.button?.window?.frame.minX,
              let d = divider.button?.window?.frame.minX else { return true }
        return d < a
    }

    private func explainOrder() {
        let alert = NSAlert()
        alert.messageText = "Move the divider first"
        alert.informativeText = "Hold ⌘ and drag the  |  divider so it sits to the LEFT of the arrow. Icons left of the divider get hidden."
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }

    // MARK: - Right-click menu

    private func showMenu() {
        let menu = NSMenu()

        let login = NSMenuItem(title: "Start at Login", action: #selector(toggleLogin), keyEquivalent: "")
        login.target = self
        login.state = SMAppService.mainApp.status == .enabled ? .on : .off
        menu.addItem(login)

        let help = NSMenuItem(title: "How to Use…", action: #selector(showHelp), keyEquivalent: "")
        help.target = self
        menu.addItem(help)

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit SimpleBar", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        // Attach the menu just for this click, then detach so left-click keeps working.
        arrow.menu = menu
        arrow.button?.performClick(nil)
        arrow.menu = nil
    }

    @objc private func toggleLogin() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            let alert = NSAlert(error: error)
            NSApp.activate(ignoringOtherApps: true)
            alert.runModal()
        }
    }

    @objc private func showHelp() {
        let alert = NSAlert()
        alert.messageText = "SimpleBar"
        alert.informativeText = """
        • Hold ⌘ and drag menu bar icons to the LEFT of the  |  divider to hide them.
        • Click the arrow to show / hide them.
        • Right-click the arrow for options.
        """
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }

    // MARK: - Helpers

    private func symbol(_ name: String, fallback: String) -> NSImage {
        if let img = NSImage(systemSymbolName: name, accessibilityDescription: fallback) {
            img.isTemplate = true
            return img
        }
        let img = NSImage(size: NSSize(width: 10, height: 16), flipped: false) { rect in
            (fallback as NSString).draw(in: rect, withAttributes: [.font: NSFont.menuBarFont(ofSize: 0)])
            return true
        }
        img.isTemplate = true
        return img
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory) // no Dock icon
app.run()
