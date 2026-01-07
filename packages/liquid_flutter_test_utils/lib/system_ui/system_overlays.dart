import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Returns the [SystemUiOverlayStyle] found at the top (status bar) and bottom (navigation bar)
/// of the screen, as Flutter would use for system chrome adjustment.
///
/// Returns a tuple: (upper, lower), where either may be null if not found.
///
/// [renderView] should be the current [RenderView] (e.g., RendererBinding.instance.renderView).
///
/// This function does not apply the styles, it only reads them.
SystemUiOverlayStyle? readSystemUiOverlayStyles(BuildContext context) {
  final Size screenSize = MediaQuery.of(context).size;

  // Define the status bar and navigation bar regions in global coordinates
  final Rect statusBarRect = Rect.fromLTWH(
    0,
    0,
    screenSize.width,
    64,
  );

  SystemUiOverlayStyle? upper;

  void visitor(Element element) {
    final widget = element.widget;
    if (widget is AnnotatedRegion<SystemUiOverlayStyle>) {
      final renderObject = element.renderObject;
      if (renderObject is RenderBox && renderObject.hasSize) {
        final Offset topLeft = renderObject.localToGlobal(Offset.zero);
        final Size size = renderObject.size;
        final regionRect = Rect.fromLTWH(
          topLeft.dx,
          topLeft.dy,
          size.width,
          size.height,
        );

        final style = widget.value;
        // Check for overlap with status bar and nav bar regions
        if (regionRect.overlaps(statusBarRect)) {
          upper = style;
        }
      }
    }
    element.visitChildren(visitor);
  }

  context.visitChildElements(visitor);

  return upper;
}

class SystemOverlayDetector extends StatefulWidget {
  const SystemOverlayDetector({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, SystemUiOverlayStyle?) builder;
  @override
  State<SystemOverlayDetector> createState() => _SystemOverlayDetectorState();
}

class _SystemOverlayDetectorState extends State<SystemOverlayDetector> {
  SystemUiOverlayStyle? _style;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final style = readSystemUiOverlayStyles(
        context,
      );
      setState(() {
        _style = style;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _style);
  }
}
