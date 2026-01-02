# Sync One-Way

A MacOS menu bar application that performs a one-way sync (backup) from local watched folders to Google Drive (or other cloud providers) using `rclone` and `rsync`.

## Features
- **Menu Bar App:** Runs discreetly in the MacOS menu bar.
- **Multi-Folder Support:** Configure multiple "Watched Folder" pairs.
- **Cloud Integration:** True one-way sync to Google Drive via `rclone`.
- **One-Way Sync:** Protects your local data by ensuring cloud deletions/modifications never sync back to your machine.
- **Real-time Status:** Visual feedback (green/red icons) indicating sync success or failure for each folder.

## Developer Instructions

If rclone is still running

```shell
pgrep -fl rclone
```

### Prerequisites
- macOS 14.0 or later.
- **Xcode 15 or later** (Full application required for `swift test`; Command Line Tools are insufficient).
- Swift 5.9 or later.
- **rclone:** Required for cloud synchronization.
  ```bash
  brew install rclone
  ```

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
2.  **Connect Google Drive:**
    *   Click the menu bar icon and select **Settings**.
    *   Scroll down to **Cloud Integration**.
    *   Click **Connect Google Drive**. Your browser will open for authentication.
3.  **Configure Watched Folders:**
    *   In Settings, click the **+** icon next to **Watched Folders**.
    *   Select **Local Folder** or **Google Drive** as the destination type.
    *   Select your source path and destination remote/path.
    *   Click **Add Sync Task**.
4.  **Sync:** Click **Sync Now** in the menu bar to start the synchronization process.
5.  **Status:** Look for the green checkmark next to your folders in Settings to verify success.
6.  **Quit:** To exit the application, click the menu bar icon and select **Quit**.