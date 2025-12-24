import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    self.titleVisibility = .hidden
    self.titlebarAppearsTransparent = true
    self.isMovableByWindowBackground = true
    self.styleMask.insert(.fullSizeContentView)
    if #available(macOS 11.0, *) {
      self.standardWindowButton(.closeButton)?.contentTintColor = NSColor.systemRed
      self.standardWindowButton(.miniaturizeButton)?.contentTintColor = NSColor.systemYellow
      self.standardWindowButton(.zoomButton)?.contentTintColor = NSColor.systemGreen
    }

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
