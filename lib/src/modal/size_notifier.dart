import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  void Function(Size) onSizeChange;

  MeasureSizeRenderObject(this.onSizeChange);

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child!.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onSizeChange(newSize);
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final Function(Size) onSizeChange;

  const MeasureSize({
    Key? key,
    required this.onSizeChange,
    required Widget child,
  }) : super(child: child, key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onSizeChange);
  }

  @override
  void updateRenderObject(BuildContext context, covariant MeasureSizeRenderObject renderObject) {
    renderObject.onSizeChange = onSizeChange;
  }
}
