import 'dart:ui';

class LdTouchableStatus {
  bool hovering;
  bool focus;
  bool active;
  bool disabled;
  bool pressed;
  Offset? panOffset;
  LdTouchableStatus({
    this.hovering = false,
    this.focus = false,
    this.active = false,
    this.disabled = false,
    this.pressed = false,
    this.panOffset,
  });
}
