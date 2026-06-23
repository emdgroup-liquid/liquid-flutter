part of 'badge.dart';

class LdBadge extends StatelessWidget {
  const LdBadge({
    required this.child,
    this.color,
    this.size = LdSize.m,
    this.symmetric = false,
    this.maxLines = 1,
    super.key,
  });

  final Widget child;

  final LdColor? color;

  final bool symmetric;

  final int? maxLines;

  final LdSize size;

  static Widget success({
    required Widget child,
    LdColor? color,
    LdSize size = LdSize.m,
    bool symmetric = false,
    int? maxLines = 1,
    Key? key,
  }) {
    return Builder(
      builder: (BuildContext context) => LdBadge(
        color: LdTheme.of(context).success,
        size: size,
        symmetric: symmetric,
        maxLines: maxLines,
        child: child,
      ),
    );
  }

  static Widget warning({
    required Widget child,
    LdColor? color,
    LdSize size = LdSize.m,
    bool symmetric = false,
    int? maxLines = 1,
    Key? key,
  }) {
    return Builder(
      builder: (BuildContext context) => LdBadge(
        color: LdTheme.of(context).warning,
        size: size,
        symmetric: symmetric,
        maxLines: maxLines,
        child: child,
      ),
    );
  }

  static Widget error({
    required Widget child,
    LdColor? color,
    LdSize size = LdSize.m,
    bool symmetric = false,
    int? maxLines = 1,
    Key? key,
  }) {
    return Builder(
      builder: (BuildContext context) => LdBadge(
        color: LdTheme.of(context).error,
        size: size,
        symmetric: symmetric,
        maxLines: maxLines,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LdBadgeWidget(
      color: color,
      size: size,
      symmetric: symmetric,
      maxLines: maxLines,
      child: child,
    );
  }
}
