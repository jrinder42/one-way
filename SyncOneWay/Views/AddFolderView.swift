import SwiftUI

struct AddFolderView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var sourcePath = ""
    @State private var destinationPath = ""
    @State private var selectedProvider: SyncProvider = .local
    @State private var selectedRemoteId: UUID?
    
    var body: some View {
        Form {
            Section("Source") {
                HStack {
                    TextField("Path", text: $sourcePath)
                        .disabled(true)
                    Button("Browse") {
                        selectDirectory { path in
                            sourcePath = path
                        }
                    }
                }
            }
            
            Section("Destination") {
                Picker("Type", selection: $selectedProvider) {
                    Text("Local Folder").tag(SyncProvider.local)
                    Text("Google Drive").tag(SyncProvider.rclone)
                }
                .pickerStyle(.segmented)
                
                if selectedProvider == .rclone {
                    if viewModel.rcloneRemotes.isEmpty {
                        Text("No Google Drive accounts connected. Please connect one in Settings.")
                            .foregroundColor(.secondary)
                    } else {
                        Picker("Account", selection: $selectedRemoteId) {
                            Text("Select Account").tag(nil as UUID?)
                            ForEach(viewModel.rcloneRemotes) { remote in
                                Text(remote.name).tag(remote.id as UUID?)
                            }
                        }
                    }
                    TextField("Path on Drive (e.g. Backups/MyMac)", text: $destinationPath)
                } else {
                    HStack {
                        TextField("Path", text: $destinationPath)
                            .disabled(true)
                        Button("Browse") {
                            selectDirectory { path in
                                destinationPath = path
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Button("Add Sync Task") {
                    viewModel.addFolder(
                        source: sourcePath,
                        destination: destinationPath,
                        provider: selectedProvider,
                        remoteId: selectedProvider == .rclone ? selectedRemoteId : nil
                    )
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isAddDisabled)
            }
        }
        .padding()
        .frame(width: 450, height: 350)
    }
    
    var isAddDisabled: Bool {
        if sourcePath.isEmpty || destinationPath.isEmpty {
            return true
        }
        if selectedProvider == .rclone && selectedRemoteId == nil {
            return true
        }
        return false
    }
    
    private func selectDirectory(completion: @escaping (String) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.level = .floating
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                completion(url.path)
            }
        }
    }
}
