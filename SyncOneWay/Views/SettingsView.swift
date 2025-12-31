import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel = SettingsViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.headline)
                
                VStack(alignment: .leading) {
                    Text("Source Directory")
                    HStack {
                        TextField("Select source...", text: $viewModel.sourcePath)
                            .disabled(true)
                        Button("Browse...") {
                            selectDirectory { path in
                                viewModel.sourcePath = path
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Destination Directory")
                    HStack {
                        TextField("Select destination...", text: $viewModel.destinationPath)
                            .disabled(true)
                        Button("Browse...") {
                            selectDirectory { path in
                                viewModel.destinationPath = path
                            }
                        }
                    }
                }
                
                Toggle("Delete files at destination if missing from source", isOn: $viewModel.shouldDeleteFiles)
                    .toggleStyle(.checkbox)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Cloud Integration (via rclone)")
                        .font(.headline)
                    
                    if viewModel.isRcloneAvailable {
                        if viewModel.rcloneRemotes.isEmpty {
                            Button("Connect Google Drive") {
                                Task {
                                    await viewModel.connectGoogleDrive()
                                }
                            }
                        } else {
                            VStack(alignment: .leading) {
                                ForEach(viewModel.rcloneRemotes) { remote in
                                    HStack {
                                        Image(systemName: "icloud.fill")
                                        Text(remote.name)
                                        Spacer()
                                        Text(remote.type)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                }
                                
                                Button("Add Another Account") {
                                    Task {
                                        await viewModel.connectGoogleDrive()
                                    }
                                }
                                .buttonStyle(.link)
                                .padding(.top, 4)
                            }
                        }
                    } else {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("rclone not found. Please install rclone to use cloud features.")
                                .font(.caption)
                        }
                        .padding(8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                
                Spacer()
                
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    Spacer()
                    Button("Save") {
                        viewModel.save()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .frame(minWidth: 400, maxWidth: .infinity, minHeight: 300, maxHeight: 600)
        .onAppear {
            viewModel.load()
        }
    }
    
    private func selectDirectory(completion: @escaping (String) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        
        // Ensure the panel appears on top of the floating settings window
        panel.level = .floating
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                completion(url.path)
            }
        }
    }
}
