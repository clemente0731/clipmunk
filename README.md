# Clipmunk

```
    ╔══════════════════════════════════════╗
    ║            ▄▄      ▄▄               ║
    ║           █░░█    █░░█              ║
    ║          █░░░░████░░░░█             ║
    ║         █░░░░░░░░░░░░░░█            ║
    ║        █░░░░░░░░░░░░░░░░█           ║
    ║       █░░░▓░░░░░░░░░▓░░░█          ║
    ║       █░░░░░░░▄▄▄░░░░░░░█          ║
    ║       █░░░░░░█===█░░░░░░█          ║
    ║        █░░░██=====██░░░█           ║
    ║     ▄▄██░░█ CLIPMUNK █░░██▄▄      ║
    ║    █░░░░░░█===========█░░░░░░█     ║
    ║     ▀▀██░░░█=========█░░░██▀▀      ║
    ║         ▀▀░░░▀▀▀▀▀▀▀░░░▀▀          ║
    ║            ▀▀░░░░░░░▀▀             ║
    ║              ▀▀▀▀▀▀▀               ║
    ║  ◆ clip(board) + chip(munk)        ║
    ║  ◆ store in cheeks, paste on key   ║
    ╚══════════════════════════════════════╝
```

A chipmunk-fast cross-platform paste toolbox with retro-futuristic 16-bit UI.

Store text templates in your cheeks, spit them out with a hotkey.

## Features

- 5 text template slots with custom titles
- Global hotkeys for instant paste:
  - `Ctrl+Alt+1/2/3/4/5` (Windows)
  - `⌘+⌥+1/2/3/4/5` (macOS)
- macOS Services integration (right-click paste for first 3 templates)
- System tray for quick access
- Hive local storage
- Retro-futurism 16-bit dot-matrix interface

## Behavior

- **No auto-start on boot**
- **Close window hides to tray by default** (configurable in Settings)
- Hotkeys active while app is running, deactivated on quit
- `Cmd+S` / `Ctrl+S` to save templates

## Usage

```bash
flutter pub get
flutter run -d macos   # or windows
```

## Build

```bash
flutter build macos --release
flutter build windows --release
```

## macOS Permissions

- Allow Clipmunk in System Settings → Privacy & Security → Accessibility
- Enable right-click services in System Settings → Keyboard → Keyboard Shortcuts → Services

## License

MIT
