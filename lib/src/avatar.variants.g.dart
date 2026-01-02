part of 'avatar.dart';

class LdAvatarConfig {
  const LdAvatarConfig({
    this.color,
    this.circular,
    this.size,
  });

  final LdColor? color;

  final bool? circular;

  final LdSize? size;
}

class LdAvatarConfigProvider extends StatelessWidget {
  const LdAvatarConfigProvider(
    this.config,
    this.child, {
    super.key,
  });

  final LdAvatarConfig config;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final parentConfig = Provider.of<LdAvatarConfig?>(context, listen: true);
    final mergedConfig = parentConfig != null
        ? LdAvatarConfig(
            color: config.color ?? parentConfig.color,
            circular: config.circular ?? parentConfig.circular,
            size: config.size ?? parentConfig.size)
        : config;
    return Provider<LdAvatarConfig>.value(
      value: mergedConfig,
      child: child,
    );
  }
}

class LdAvatar extends StatelessWidget {
  const LdAvatar({
    super.key,
    required this.child,
    this.color,
    this.circular,
    this.size,
  });

  final Widget child;

  final LdColor? color;

  final bool? circular;

  final LdSize? size;

  static Widget success({
    Key? key,
    required Widget child,
    LdColor? color,
    bool? circular,
    LdSize? size,
  }) {
    return Builder(
      builder: (BuildContext context) => LdAvatar(
        key: key,
        child: child,
        color: LdTheme.of(context).success,
        circular: circular,
        size: size,
      ),
    );
  }

  static Widget warning({
    Key? key,
    required Widget child,
    LdColor? color,
    bool? circular,
    LdSize? size,
  }) {
    return Builder(
      builder: (BuildContext context) => LdAvatar(
        key: key,
        child: child,
        color: LdTheme.of(context).warning,
        circular: circular,
        size: size,
      ),
    );
  }

  static Widget error({
    Key? key,
    required Widget child,
    LdColor? color,
    bool? circular,
    LdSize? size,
  }) {
    return Builder(
      builder: (BuildContext context) => LdAvatar(
        key: key,
        child: child,
        color: LdTheme.of(context).error,
        circular: circular,
        size: size,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<LdAvatarConfig?>(context, listen: true);
    return LdAvatarWidget(
      child: child,
      color: color ?? config?.color,
      circular: circular ?? config?.circular ?? false,
      size: size ?? config?.size ?? LdSize.m,
    );
  }
}
