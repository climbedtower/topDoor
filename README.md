# topDoor

A macOS Menu Bar launcher for opening project files and URLs in bulk.

## Overview

**topDoor** is a macOS 14+ Menu Bar application that allows you to organize your development projects and launch them with a single click. It reads project configurations from a JSON file and uses the system's `open` command to launch files and URLs.

## Features

- **Menu Bar Integration**: Lives in your menu bar with a hammer.circle icon
- **Project-based Organization**: Group related files and URLs into named projects
- **One-click Launch**: "Open All" button opens all items in a project sequentially
- **Automatic Configuration**: Creates default config on first run
- **Error Handling**: Shows alerts for failed opens but continues processing
- **Manual Reload**: Refresh configuration without restarting the app

## Requirements

- macOS 14 Sonoma or later
- Xcode 15+ (for building)

## Configuration

Configuration file location: `~/Library/Application Support/DevLauncher/config.json`

### Example Configuration

```json
{
  "projects": [
    {
      "id": "myapp",
      "name": "MyApp",
      "items": [
        "file:///Users/you/Dev/MyApp/MyApp.xcworkspace",
        "file:///Users/you/Dev/MyApp/.vscode/myapp.code-workspace",
        "https://github.com/example/MyApp/wiki/Design-Spec"
      ]
    },
    {
      "id": "website",
      "name": "Website Project",
      "items": [
        "file:///Users/you/Sites/website",
        "https://localhost:3000",
        "https://github.com/example/website"
      ]
    }
  ]
}
```

### Configuration Schema

- **projects**: Array of project objects
  - **id**: Unique identifier for the project
  - **name**: Display name shown in the menu
  - **items**: Array of file paths (file://) or URLs (http/https) to open

## Usage

1. Click the hammer.circle icon in your menu bar
2. Select a project from the list
3. Click "Open All" to launch all items in that project
4. Use "Reload Config" to refresh the configuration file
5. Use "Quit" to exit the application

## Installation

1. Clone this repository
2. Open `topDoor.xcodeproj` in Xcode
3. Build and run the project (⌘+R)
4. The app will appear in your menu bar

## Building

```bash
# Build from command line
xcodebuild -project topDoor.xcodeproj -scheme topDoor -configuration Release build
```

## Technical Details

- **Framework**: SwiftUI with MenuBarExtra
- **Minimum Target**: macOS 14.0
- **Memory Usage**: < 50 MB when idle
- **CPU Usage**: ~0% when idle
- **Configuration**: JSON-based with automatic backup (.bak) creation
- **Logging**: Uses OSLog for debugging

## File Structure

```
topDoor/
├── topDoor/
│   ├── topDoorApp.swift           # Main app entry point
│   ├── MenuBarContentView.swift   # Menu bar popup UI
│   ├── Models.swift               # Data models and app state
│   ├── ConfigLoader.swift         # JSON configuration loader
│   ├── ProjectLauncher.swift      # Item opening logic
│   ├── ErrorAlert.swift           # Error handling utilities
│   └── Assets.xcassets/           # App assets
├── topDoorTests/                  # Unit tests
└── topDoorUITests/                # UI tests
```

## Change Log

- v0.1.0 – 2025-06-15 : Initial implementation with MenuBarExtra, JSON config, and project launcher
- v0.2.0 – 2025-06-15 : Added Scrapbox integration with automatic page name extraction for group names
