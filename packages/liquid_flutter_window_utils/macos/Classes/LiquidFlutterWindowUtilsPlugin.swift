import Cocoa
import FlutterMacOS

public class LiquidFlutterWindowUtilsPlugin: NSObject, FlutterPlugin, WindowUtilsApi {
    func setSystemGestureExclusionRects(rects: [Rect]) throws {
        throw FlutterError(code: "UNAVAILABLE_API", message: "This API is not supported on macos", details: nil)
    }
    
  private var registrar: FlutterPluginRegistrar?
  private var eventApi: WindowStateEventApi?
  private var currentWindow: NSWindow?
  private var frameBeforeMaximize: NSRect?
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = LiquidFlutterWindowUtilsPlugin()
    instance.registrar = registrar
    WindowUtilsApiSetup.setUp(binaryMessenger: registrar.messenger, api: instance)
    
    // Set up the FlutterApi for events
    instance.eventApi = WindowStateEventApi(binaryMessenger: registrar.messenger)

    // Set up application-level notifications
    instance.setupApplicationNotifications()
    
    // Try to get current window and set up notifications
    if let window = LiquidFlutterWindowUtilsPlugin.getCurrentWindow() {
      instance.setupWindowNotifications(window: window)
      // Notify Flutter that the window is ready
      instance.eventApi?.onWindowReady { _ in }
    }
  }



  // MARK: - WindowUtilsApi Implementation#


  public func configureWindow() throws {
    guard let window = LiquidFlutterWindowUtilsPlugin.getCurrentWindow() else {
      throw FlutterError(code: "WINDOW_NOT_AVAILABLE", message: "No window is currently available for configuration", details: nil)
    }

    ensureWindowHasUsableFrame(window: window)
    
    
    
    // Remove the window frame by making the window borderless
    window.styleMask.remove(.titled)
    window.styleMask.remove(.closable)
    // Keep miniaturizable to allow programmatic minimizing
    // window.styleMask.remove(.miniaturizable)
    
    window.titleVisibility = .hidden
    window.titlebarAppearsTransparent = true

    // Make the window background transparent
    window.isOpaque = false
    window.backgroundColor = NSColor.clear
    
    // Additional transparency settings
    //window.hasShadow = false
    window.isMovableByWindowBackground = true
    
    // Set the window level to floating to ensure proper transparency
    
    
    // Force the window to update its appearance
    window.invalidateShadow()
    window.display()

    if window.isMiniaturized {
      window.deminiaturize(nil)
    }

    NSApplication.shared.activate(ignoringOtherApps: true)
    window.makeKeyAndOrderFront(nil)
    window.orderFrontRegardless()
    
    // Also set the Flutter view controller background to clear
    if let flutterViewController = getFlutterViewController() {
      flutterViewController.backgroundColor = .clear
    }
    
    emitWindowStateChange()
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
  
  public func closeWindow() throws {
    guard let window = LiquidFlutterWindowUtilsPlugin.getCurrentWindow() else {
      return
    }
    
    window.close()
  }
  
  public func minimizeWindow() throws {
    guard let window = LiquidFlutterWindowUtilsPlugin.getCurrentWindow() else {
      return
    }
    
    // Ensure the window can be minimized
    if !window.styleMask.contains(.miniaturizable) {
      window.styleMask.insert(.miniaturizable)
    }
    
    window.miniaturize(nil)
  }
  
  public func maximizeWindow() throws {
    guard let window = LiquidFlutterWindowUtilsPlugin.getCurrentWindow() else {
      return
    }
    
    if isWindowEffectivelyMaximized(window) {
      if let savedFrame = frameBeforeMaximize {
        window.setFrame(savedFrame, display: true, animate: true)
        frameBeforeMaximize = nil
      } else {
        window.zoom(nil)
      }
    } else {
      frameBeforeMaximize = window.frame
      if let screen = window.screen ?? NSScreen.main {
        window.setFrame(screen.visibleFrame, display: true, animate: true)
      } else {
        window.zoom(nil)
      }
    }
    
    emitWindowStateChange()
  }
  
  public func isWindowMaximized() throws -> Bool {
    guard let window = LiquidFlutterWindowUtilsPlugin.getCurrentWindow() else {
      return false
    }
    
    return isWindowEffectivelyMaximized(window)
  }
  
  public func getScreenRadius() throws -> Double {
    let osVersion = ProcessInfo.processInfo.operatingSystemVersion
    let majorVersion = osVersion.majorVersion
    
    // macOS 26 "Tahoe" introduced "Liquid Glass" design with increased corner radius
    if majorVersion >= 26 {
      return 26.0
    }
    
    // Standard corner radius for macOS versions prior to 26
    return 10.0
  }
  
  internal func getWindowState() throws -> WindowState {
    guard let window = LiquidFlutterWindowUtilsPlugin.getCurrentWindow() else {
      return WindowState(
        x: 0,
        y: 0,
        width: 0,
        height: 0,
        isMaximized: false,
        isMinimized: false
      )
    }
    
    let frame = window.frame
    return WindowState(
        x: Int64(Int(frame.origin.x)),
        y: Int64(Int(frame.origin.y)),
        width: Int64(Int(frame.width)),
        height: Int64(Int(frame.height)),
      isMaximized: isWindowEffectivelyMaximized(window),
      isMinimized: window.isMiniaturized
    )
  }
  
  // MARK: - Application Notifications
  
  private func setupApplicationNotifications() {
    // Listen for application-level events
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(applicationDidFinishLaunching(_:)),
      name: NSApplication.didFinishLaunchingNotification,
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(applicationDidBecomeActive(_:)),
      name: NSApplication.didBecomeActiveNotification,
      object: nil
    )
    
    // Listen for when any window becomes key (focused)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(windowDidBecomeKey(_:)),
      name: NSWindow.didBecomeKeyNotification,
      object: nil
    )
    
    // Listen for when any window becomes main
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(windowDidBecomeMain(_:)),
      name: NSWindow.didBecomeMainNotification,
      object: nil
    )
  }
  
  @objc private func applicationDidFinishLaunching(_ notification: Notification) {
    // App finished launching, check for windows
    if let window = LiquidFlutterWindowUtilsPlugin.getCurrentWindow() {
      setupWindowNotifications(window: window)
      eventApi?.onWindowReady { _ in }
    }
  }
  
  @objc private func applicationDidBecomeActive(_ notification: Notification) {
    // App became active, check for windows
    if let window = LiquidFlutterWindowUtilsPlugin.getCurrentWindow(), currentWindow == nil {
      setupWindowNotifications(window: window)
      eventApi?.onWindowReady { _ in }
    }
  }
  
  @objc private func windowDidBecomeKey(_ notification: Notification) {
    guard let window = notification.object as? NSWindow else { return }
    
    // If this is a new window or we don't have a current window, set it up
    if currentWindow != window {
      setupWindowNotifications(window: window)
      eventApi?.onWindowReady { _ in }
    }
  }
  
  @objc private func windowDidBecomeMain(_ notification: Notification) {
    guard let window = notification.object as? NSWindow else { return }
    
    // If this is a new window or we don't have a current window, set it up
    if currentWindow != window {
      setupWindowNotifications(window: window)
      eventApi?.onWindowReady { _ in }
    }
  }

  // MARK: - Window Notifications
  
  private func setupWindowNotifications(window: NSWindow) {
    currentWindow = window
    
    // Listen for window state changes
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(windowDidMove(_:)),
      name: NSWindow.didMoveNotification,
      object: window
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(windowDidResize(_:)),
      name: NSWindow.didResizeNotification,
      object: window
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(windowDidMiniaturize(_:)),
      name: NSWindow.didMiniaturizeNotification,
      object: window
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(windowDidDeminiaturize(_:)),
      name: NSWindow.didDeminiaturizeNotification,
      object: window
    )
  }
  
  @objc private func windowDidMove(_ notification: Notification) {
    emitWindowStateChange()
  }
  
  @objc private func windowDidResize(_ notification: Notification) {
    emitWindowStateChange()
  }
  
  @objc private func windowDidMiniaturize(_ notification: Notification) {
    emitWindowStateChange()
  }
  
  @objc private func windowDidDeminiaturize(_ notification: Notification) {
    emitWindowStateChange()
  }
  
  private func emitWindowStateChange() {
    guard let window = currentWindow else { 
      return 
    }
    
    let frame = window.frame
    let state = WindowState(
      x: Int64(frame.origin.x),
      y: Int64(frame.origin.y),
      width: Int64(frame.width),
      height: Int64(frame.height),
      isMaximized: isWindowEffectivelyMaximized(window),
      isMinimized: window.isMiniaturized
    )
    
    eventApi?.onWindowStateChanged(state: state) { _ in }
  }
  
  /// Borderless windows may fill the screen without setting [NSWindow.isZoomed].
  private func isWindowEffectivelyMaximized(_ window: NSWindow) -> Bool {
    if window.isZoomed {
      return true
    }
    guard let screen = window.screen ?? NSScreen.main else {
      return false
    }
    let visible = screen.visibleFrame
    let frame = window.frame
    let tolerance: CGFloat = 4.0
    return abs(frame.width - visible.width) <= tolerance
      && abs(frame.height - visible.height) <= tolerance
      && abs(frame.origin.x - visible.origin.x) <= tolerance
      && abs(frame.origin.y - visible.origin.y) <= tolerance
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
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

  private func ensureWindowHasUsableFrame(window: NSWindow) {
    let minWidth: CGFloat = 900
    let minHeight: CGFloat = 600

    var frame = window.frame
    var frameChanged = false

    if frame.width < 200 || frame.height < 200 {
      if let screen = window.screen ?? NSScreen.main {
        let visibleFrame = screen.visibleFrame
        let width = min(max(minWidth, frame.width), visibleFrame.width)
        let height = min(max(minHeight, frame.height), visibleFrame.height)
        frame = NSRect(
          x: visibleFrame.midX - (width / 2),
          y: visibleFrame.midY - (height / 2),
          width: width,
          height: height
        )
      } else {
        frame.size = NSSize(width: max(minWidth, frame.width), height: max(minHeight, frame.height))
      }
      frameChanged = true
    }

    if let screen = window.screen ?? NSScreen.main {
      let visibleFrame = screen.visibleFrame
      if !frame.intersects(visibleFrame) {
        frame.origin.x = visibleFrame.midX - (frame.width / 2)
        frame.origin.y = visibleFrame.midY - (frame.height / 2)
        frameChanged = true
      }
    }

    if frameChanged {
      window.setFrame(frame, display: true, animate: false)
      window.layoutIfNeeded()
    }
  }
}
