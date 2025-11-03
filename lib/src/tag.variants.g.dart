part of 'tag.dart';

class LdTag extends StatelessWidget {
  const LdTag({
    super.key,
    required this.child,
    this.color,
    this.onDismiss,
    this.size = LdSize.m,
  });

  final Widget child;

  final Function? onDismiss;

  final LdSize size;

  final LdColor? color;

  static Widget success({
    Key? key,
    required Widget child,
    LdColor? color,
    Function? onDismiss,
    LdSize size = LdSize.m,
  }) {
    return Builder(
      builder: (BuildContext context) => LdTag(
        key: key,
        child: child,
        color: LdTheme.of(context).success,
        onDismiss: onDismiss,
        size: size,
      ),
    );
  }

  static Widget warning({
    Key? key,
    required Widget child,
    LdColor? color,
    Function? onDismiss,
    LdSize size = LdSize.m,
  }) {
    return Builder(
      builder: (BuildContext context) => LdTag(
        key: key,
        child: child,
        color: LdTheme.of(context).warning,
        onDismiss: onDismiss,
        size: size,
      ),
    );
  }

  static Widget error({
    Key? key,
    required Widget child,
    LdColor? color,
    Function? onDismiss,
    LdSize size = LdSize.m,
  }) {
    return Builder(
      builder: (BuildContext context) => LdTag(
        key: key,
        child: child,
        color: LdTheme.of(context).error,
        onDismiss: onDismiss,
        size: size,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LdTagWidget(
      child: child,
      color: color,
      onDismiss: onDismiss,
      size: size,
    );
  }
}
