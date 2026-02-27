import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {

  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)
    // register this app as the system services provider
    NSApp.servicesProvider = self
    NSUpdateDynamicServices()
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  // MARK: - NSServices handlers

  /// handler for "Clipmunk - Paste 1" service
  @objc func pasteTemplate1(
    _ pboard: NSPasteboard,
    userData: String?,
    error: AutoreleasingUnsafeMutablePointer<NSString?>
  ) {
    pasteTemplate(at: 0, pboard: pboard, error: error)
  }

  /// handler for "Clipmunk - Paste 2" service
  @objc func pasteTemplate2(
    _ pboard: NSPasteboard,
    userData: String?,
    error: AutoreleasingUnsafeMutablePointer<NSString?>
  ) {
    pasteTemplate(at: 1, pboard: pboard, error: error)
  }

  /// handler for "Clipmunk - Paste 3" service
  @objc func pasteTemplate3(
    _ pboard: NSPasteboard,
    userData: String?,
    error: AutoreleasingUnsafeMutablePointer<NSString?>
  ) {
    pasteTemplate(at: 2, pboard: pboard, error: error)
  }

  /// read template content from UserDefaults and write to pasteboard
  private func pasteTemplate(
    at index: Int,
    pboard: NSPasteboard,
    error: AutoreleasingUnsafeMutablePointer<NSString?>
  ) {
    let key = "paste_template_\(index)"
    guard let content = UserDefaults.standard.string(forKey: key),
          !content.isEmpty else {
      error.pointee = "Template \(index + 1) is empty" as NSString
      return
    }
    pboard.clearContents()
    pboard.setString(content, forType: .string)
  }
}
