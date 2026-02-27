import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

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
}
