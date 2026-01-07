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
        child: child,
        color: LdTheme.of(context).success,
        size: size,
        symmetric: symmetric,
        maxLines: maxLines,
        key: key,
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
        child: child,
        color: LdTheme.of(context).warning,
        size: size,
        symmetric: symmetric,
        maxLines: maxLines,
        key: key,
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
        child: child,
        color: LdTheme.of(context).error,
        size: size,
        symmetric: symmetric,
        maxLines: maxLines,
        key: key,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LdBadgeWidget(
      child: child,
      color: color,
      size: size,
      symmetric: symmetric,
      maxLines: maxLines,
    );
  }
}
