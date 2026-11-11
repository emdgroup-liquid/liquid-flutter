import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  /// Whether the Flutter framework used by this build supports desktop
  /// windowing.
  ///
  /// Windowing builds (Flutter master with windowing enabled) create native
  /// windows from Dart, which only works while the engine has no view
  /// controller attached. Older builds expect the runner to host the implicit
  /// view controller instead.
  static let supportsWindowing = NSClassFromString("FlutterWindowOwner") != nil

  var engine: FlutterEngine?
  var mainWindow: NSWindow?

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    if AppDelegate.supportsWindowing {
      // Hand the engine over to the framework. The first window is created by
      // `LdWindowRoot` in Dart.
      let engine = FlutterEngine(name: "project", project: nil)
      engine.run(withEntrypoint: nil)
      RegisterGeneratedPlugins(registry: engine)
      self.engine = engine
    } else {
      // Older Flutter versions render into a view controller provided by the
      // runner, so create the window that hosts it.
      let controller = FlutterViewController()
      RegisterGeneratedPlugins(registry: controller)

      let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
        styleMask: [.titled, .closable, .miniaturizable, .resizable],
        backing: .buffered,
        defer: false)
      window.title = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
      window.contentViewController = controller
      window.center()
      window.makeKeyAndOrderFront(nil)

      self.mainWindow = window
    }
  }
}
