import Cocoa
import FlutterMacOS
import Carbon.HIToolbox

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    // setup clipboard method channel
    let clipboardChannel = FlutterMethodChannel(
      name: "com.clipmunk.clipboard",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )

    clipboardChannel.setMethodCallHandler { (call, result) in
      if call.method == "simulatePaste" {
        self.simulatePaste()
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    // setup template sync channel (flutter -> UserDefaults for NSServices)
    let templateChannel = FlutterMethodChannel(
      name: "com.clipmunk.templates",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )

    templateChannel.setMethodCallHandler { (call, result) in
      if call.method == "syncTemplates" {
        guard let args = call.arguments as? [String: String] else {
          result(FlutterError(code: "INVALID_ARGS", message: "expected map of index->content", details: nil))
          return
        }
        let defaults = UserDefaults.standard
        for (key, value) in args {
          defaults.set(value, forKey: key)
        }
        defaults.synchronize()
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    super.awakeFromNib()
  }

  // simulate Cmd+V keystroke using CGEvent
  private func simulatePaste() {
    // create key down event for 'v' with command modifier
    let source = CGEventSource(stateID: .hidSystemState)

    // key code for 'v' is 9
    let keyDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: true)
    let keyUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: false)

    // add command modifier
    keyDown?.flags = .maskCommand
    keyUp?.flags = .maskCommand

    // post events to system
    keyDown?.post(tap: .cghidEventTap)
    keyUp?.post(tap: .cghidEventTap)
  }
}
