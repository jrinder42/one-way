import SwiftUI

@main
struct SyncOneWayApp: App {
    var body: some Scene {
        MenuBarExtra("Sync One-Way", systemImage: "arrow.triangle.2.circlepath") {
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }
}
