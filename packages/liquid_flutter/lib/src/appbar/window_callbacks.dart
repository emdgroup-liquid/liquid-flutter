class LdWindowCallbacks {
  void Function()? onClose;
  void Function()? onMinimize;
  void Function()? onMaximize;
  void Function()? onMove;

  LdWindowCallbacks({this.onClose, this.onMinimize, this.onMaximize, this.onMove});
}
