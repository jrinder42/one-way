import SwiftUI

class WindowManager: NSObject, ObservableObject, NSWindowDelegate {
    var settingsWindow: NSWindow?
    
    func openSettings() {
        if settingsWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.title = "Sync One-Way Settings"
            window.center()
            window.isReleasedWhenClosed = false
            window.minSize = NSSize(width: 400, height: 250) // Enforce min size at window level
            
            // Fix 1: Ensure window floats above others (Stage Manager / Focus issues)
            window.level = .floating
            
            // Fix 2: Allow joining all spaces
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            
            window.delegate = self
            settingsWindow = window
        }
        
        // Always reset the content view to ensure fresh state (discarding cancelled changes)
        settingsWindow?.contentView = NSHostingView(rootView: SettingsView())
        
        // Fix 3: "Activation Sandwich" - Force app to regular policy to seize focus
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        settingsWindow?.makeKeyAndOrderFront(nil)
    }
    
    // Delegate method to handle window closing
    func windowWillClose(_ notification: Notification) {
        // Revert to accessory (menu bar only) mode when settings window closes
        NSApp.setActivationPolicy(.accessory)
    }
}

@main
struct SyncOneWayApp: App {
    @StateObject private var windowManager = WindowManager()
    
    var body: some Scene {
        MenuBarExtra("Sync One-Way", systemImage: "arrow.triangle.2.circlepath") {
            Button("Sync Now") {
                // TODO: Trigger SyncService
                print("Sync triggered")
            }
            
            Divider()
            
            Button("Settings...") {
                windowManager.openSettings()
            }
            .keyboardShortcut(",", modifiers: .command)
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }
}
