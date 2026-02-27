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

## How It Works

1. Set up your text templates in the app
2. Press a global hotkey (e.g. `⌘⌥1`) — template is copied to clipboard
3. Press `⌘V` / `Ctrl+V` to paste anywhere

## Features

- 5 text template slots with custom titles
- Global hotkeys to instantly copy templates to clipboard:
  - `Ctrl+Alt+1/2/3/4/5` (Windows)
  - `⌘+⌥+1/2/3/4/5` (macOS)
- macOS Services integration (right-click copy for first 3 templates)
- System tray for quick access
- Local storage (Hive) — no cloud, no accounts
- App Store Sandbox compatible
- Retro-futurism 16-bit dot-matrix interface

## Behavior

- **No auto-start on boot**
- **Close window hides to tray by default** (configurable in Settings)
- Hotkeys active while app is running, deactivated on quit
- `Cmd+S` / `Ctrl+S` to save templates
- **No Accessibility permission required** — uses clipboard only

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

## macOS Notes

- Enable right-click services in System Settings → Keyboard → Keyboard Shortcuts → Services (optional)
- App runs in Sandbox — no special permissions needed

## License

MIT
