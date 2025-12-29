import SwiftUI

@main
struct SyncOneWayApp: App {
    @State private var settingsWindow: NSWindow?
    
    var body: some Scene {
        MenuBarExtra("Sync One-Way", systemImage: "arrow.triangle.2.circlepath") {
            Button("Sync Now") {
                // TODO: Trigger SyncService
                print("Sync triggered")
            }
            
            Divider()
            
            Button("Settings...") {
                openSettings()
            }
            .keyboardShortcut(",", modifiers: .command)
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }
    
    private func openSettings() {
        if settingsWindow == nil {
            let view = SettingsView()
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.title = "Sync One-Way Settings"
            window.contentView = NSHostingView(rootView: view)
            window.center()
            settingsWindow = window
        }
        
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
