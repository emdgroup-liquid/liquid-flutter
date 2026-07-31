import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension Animate on Widget {
  Widget conditionallyAnimateScaleXY(bool animate) {
    return animate ? this.animate().scaleXY() : this;
  }
}
