# Sync One-Way

A MacOS menu bar application that performs a one-way sync from a local watched folder to a Google Drive destination using `rsync`.

## Features
- **Menu Bar App:** Runs discreetly in the MacOS menu bar.
- **Configurable Paths:** Set a source directory and a destination directory via the Settings window.
- **One-Way Sync:** Uses `rsync` to mirror the source to the destination.

## Developer Instructions

### Prerequisites
- macOS 14.0 or later.
- **Xcode 15 or later** (Full application required for `swift test`; Command Line Tools are insufficient).
- Swift 5.9 or later.

If you run into issues, do this
```
Resolution Steps for You:
   1. Install Xcode from the Mac App Store or the Apple Developer website.
   2. After installation, run this command in your terminal to point xcode-select to the app:
   1     sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

### Building the Project
To build the project from the command line:
```bash
swift build
```

### Running Tests
To run the test suite:
```bash
swift test
```

### Running the App
To run the app directly:
```bash
swift run
```

## End-User Instructions

1.  **Launch the App:** Open the application. You will see a new icon in your menu bar (top right of the screen).
2.  **Open Settings:** Click the menu bar icon and select "Settings".
3.  **Configure Paths:**
    *   **Source:** Select the local folder you want to sync.
    *   **Destination:** Select the Google Drive folder where you want files to go.
4.  **Sync:** Click "Sync Now" in the menu bar to start the synchronization process.
5.  **Quit:** To exit the application, click the menu bar icon and select "Quit".
