import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  ValueNotifier<Size> sizeNotifier;

  MeasureSizeRenderObject(this.sizeNotifier);

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child!.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sizeNotifier.value = newSize;
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final ValueNotifier<Size> sizeNotifier;

  const MeasureSize({
    Key? key,
    required this.sizeNotifier,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(sizeNotifier);
  }

  @override
  void updateRenderObject(BuildContext context, covariant MeasureSizeRenderObject renderObject) {
    renderObject.sizeNotifier = sizeNotifier;
  }
}
