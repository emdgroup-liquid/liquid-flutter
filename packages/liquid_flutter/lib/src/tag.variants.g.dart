part of 'tag.dart';

class LdTag extends StatelessWidget {
  const LdTag({
    required this.child,
    this.color,
    this.onDismiss,
    this.size = LdSize.m,
    super.key,
  });

  final Widget child;

  final Function? onDismiss;

  final LdSize size;

  final LdColor? color;

  static Widget success({
    required Widget child,
    LdColor? color,
    Function? onDismiss,
    LdSize size = LdSize.m,
    Key? key,
  }) {
    return Builder(
      builder: (BuildContext context) => LdTag(
        color: LdTheme.of(context).success,
        onDismiss: onDismiss,
        size: size,
        key: key,
        child: child,
      ),
    );
  }

  static Widget warning({
    required Widget child,
    LdColor? color,
    Function? onDismiss,
    LdSize size = LdSize.m,
    Key? key,
  }) {
    return Builder(
      builder: (BuildContext context) => LdTag(
        color: LdTheme.of(context).warning,
        onDismiss: onDismiss,
        size: size,
        key: key,
        child: child,
      ),
    );
  }

  static Widget error({
    required Widget child,
    LdColor? color,
    Function? onDismiss,
    LdSize size = LdSize.m,
    Key? key,
  }) {
    return Builder(
      builder: (BuildContext context) => LdTag(
        color: LdTheme.of(context).error,
        onDismiss: onDismiss,
        size: size,
        key: key,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _LdTagWidget(
      color: color,
      onDismiss: onDismiss,
      size: size,
      child: child,
    );
  }
}
