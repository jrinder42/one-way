import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel = SettingsViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
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
        .frame(width: 400)
    }
    
    private func selectDirectory(completion: @escaping (String) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                completion(url.path)
            }
        }
    }
}
