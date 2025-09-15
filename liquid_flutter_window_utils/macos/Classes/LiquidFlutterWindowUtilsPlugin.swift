import Cocoa
import FlutterMacOS

public class LiquidFlutterWindowUtilsPlugin: NSObject, FlutterPlugin, WindowUtilsApi {
  private var registrar: FlutterPluginRegistrar?
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = LiquidFlutterWindowUtilsPlugin()
    instance.registrar = registrar
    WindowUtilsApiSetup.setUp(binaryMessenger: registrar.messenger, api: instance)

    guard let window = LiquidFlutterWindowUtilsPlugin.getCurrentWindow() else {
      print("Error getting current window")
      return
    }
  }



  // MARK: - WindowUtilsApi Implementation#


  public func configureWindow() throws {
    guard let window = LiquidFlutterWindowUtilsPlugin.getCurrentWindow() else {
      print("Error getting current window")
      return
    }

    try setWindowSize(width: 500, height: 500)

    
    
    // Remove the window frame by making the window borderless
    window.styleMask.remove(.titled)
    window.styleMask.remove(.closable)
    window.styleMask.remove(.miniaturizable)
    
    window.titleVisibility = .hidden
    window.titlebarAppearsTransparent = true

    // Make the window background transparent
    window.isOpaque = false
    window.backgroundColor = NSColor.clear
    
    // Additional transparency settings
    window.hasShadow = false
    window.isMovableByWindowBackground = true
    
    // Set the window level to floating to ensure proper transparency
    
    
    // Force the window to update its appearance
    window.invalidateShadow()
    window.display()
    
    // Also set the Flutter view controller background to clear
    if let flutterViewController = getFlutterViewController() {
      flutterViewController.backgroundColor = .clear
    }
  }
  
  public func setWindowSize(width: Int64, height: Int64) throws -> Bool {
    guard let window = LiquidFlutterWindowUtilsPlugin.getCurrentWindow() else {
      return false
    }
    
    let newFrame = NSRect(x: window.frame.origin.x, y: window.frame.origin.y, width: CGFloat(width), height: CGFloat(height))
    window.setFrame(newFrame, display: true, animate: true)
    return true
  }
  
  public func setWindowTitle(title: String) throws {
    guard let window = LiquidFlutterWindowUtilsPlugin.getCurrentWindow() else {
      return
    }
    
    window.title = title
  }
  
  public func setWindowPosition(x: Int64, y: Int64) throws -> Bool {
    guard let window = LiquidFlutterWindowUtilsPlugin.getCurrentWindow() else {
      return false
    }
    
    let newFrame = NSRect(x: CGFloat(x), y: CGFloat(y), width: window.frame.width, height: window.frame.height)
    window.setFrame(newFrame, display: true, animate: true)
    return true
  }
  
  public func startDragging() throws {
    guard let window = LiquidFlutterWindowUtilsPlugin.getCurrentWindow() else {
      return
    }
    
    guard let currentEvent = window.currentEvent else {
      return
    }
    
    // Start dragging the window from its current position
    window.performDrag(with: currentEvent)
  }
  
  // MARK: - Helper Methods
  
  private static func getCurrentWindow() -> NSWindow? {
    // Get the key window (currently active window)
    if let keyWindow = NSApplication.shared.keyWindow {
      return keyWindow
    }
    
    // Fallback to main window if no key window
    if let mainWindow = NSApplication.shared.mainWindow {
      return mainWindow
    }
    
    // Fallback to any visible window
    return NSApplication.shared.windows.first { $0.isVisible }
  }
  
  private func getFlutterViewController() -> FlutterViewController? {
    guard let registrar = self.registrar else { return nil }
    
    // Try to get the view controller from the registrar's view
    if let view = registrar.view {
      var responder: NSResponder? = view
      while let currentResponder = responder {
        if let flutterViewController = currentResponder as? FlutterViewController {
          return flutterViewController
        }
        responder = currentResponder.nextResponder
      }
    }
    
    // Fallback: try to find it from the current window
    if let window = LiquidFlutterWindowUtilsPlugin.getCurrentWindow(),
       let contentView = window.contentView {
      var responder: NSResponder? = contentView
      while let currentResponder = responder {
        if let flutterViewController = currentResponder as? FlutterViewController {
          return flutterViewController
        }
        responder = currentResponder.nextResponder
      }
    }
    
    return nil
  }
}
