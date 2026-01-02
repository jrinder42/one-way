import SwiftUI

class WindowManager: NSObject, ObservableObject, NSWindowDelegate {
    var settingsWindow: NSWindow?
    var addFolderWindow: NSWindow?
    
    func openSettings(viewModel: SettingsViewModel) {
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
        // Inject WindowManager as environment object
        settingsWindow?.contentView = NSHostingView(
            rootView: SettingsView(viewModel: viewModel)
                .environmentObject(self)
        )
        
        // Fix 3: "Activation Sandwich" - Force app to regular policy to seize focus
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        settingsWindow?.makeKeyAndOrderFront(nil)
    }
    
    func openAddFolder(viewModel: SettingsViewModel) {
        if addFolderWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 500),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.title = "Add Sync Folder"
            window.center()
            window.isReleasedWhenClosed = false
            window.minSize = NSSize(width: 400, height: 400)
            window.level = .floating
            window.delegate = self
            addFolderWindow = window
        }
        
        addFolderWindow?.contentView = NSHostingView(rootView: AddFolderView(viewModel: viewModel))
        addFolderWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    // Delegate method to handle window closing
    func windowWillClose(_ notification: Notification) {
        // If settings window closed, revert policy if no other windows open?
        // Ideally we check if *all* windows are closed.
        // For simplicity, if settings window closes, we revert. 
        // AddFolderWindow is transient.
        
        if let window = notification.object as? NSWindow, window == settingsWindow {
             NSApp.setActivationPolicy(.accessory)
        }
    }
}

@main
struct SyncOneWayApp: App {
    @StateObject private var windowManager = WindowManager()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @State private var isSyncing = false
    @State private var lastSyncStatus: String?
    
    private let syncService = SyncService()
    
    var body: some Scene {
        MenuBarExtra("Sync One-Way", systemImage: isSyncing ? "arrow.triangle.2.circlepath.circle.fill" : "arrow.triangle.2.circlepath") {
            if isSyncing {
                Text("Syncing...")
            } else if let status = lastSyncStatus {
                Text(status)
            }
            
            Button("Sync Now") {
                triggerSync()
            }
            .disabled(isSyncing)
            
            Divider()
            
            Button("Settings...") {
                windowManager.openSettings(viewModel: settingsViewModel)
            }
            .keyboardShortcut(",", modifiers: .command)
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }
    
    private func triggerSync() {
        isSyncing = true
        lastSyncStatus = nil
        
        Task {
            do {
                try await syncService.sync()
                isSyncing = false
                lastSyncStatus = "Last sync: \(Date().formatted(date: .omitted, time: .shortened))"
            } catch {
                isSyncing = false
                lastSyncStatus = "Sync failed"
                print("Sync error: \(error.localizedDescription)")
            }
            
            // Reload settings view model to reflect status changes
            await MainActor.run {
                settingsViewModel.load()
            }
        }
    }
}
