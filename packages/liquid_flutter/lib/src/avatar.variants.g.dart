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

  LdAvatarConfig copyWith({
    LdColor? color,
    bool? circular,
    LdSize? size,
  }) {
    return LdAvatarConfig(
      color: color ?? this.color,
      circular: circular ?? this.circular,
      size: size ?? this.size,
    );
  }

  LdAvatarConfig merge(LdAvatarConfig? other) {
    if (other == null) return this;
    return LdAvatarConfig(
      color: other.color ?? this.color,
      circular: other.circular ?? this.circular,
      size: other.size ?? this.size,
    );
  }
}

class LdAvatarConfigProvider extends StatelessWidget {
  const LdAvatarConfigProvider({
    required this.config,
    required this.child,
    this.ignoreParent = false,
    super.key,
  });

  final LdAvatarConfig config;

  final Widget child;

  final bool ignoreParent;

  @override
  Widget build(BuildContext context) {
    if (ignoreParent) {
      return Provider<LdAvatarConfig>.value(
        value: config,
        child: child,
      );
    }
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
    required this.child,
    this.color,
    this.circular,
    this.size,
    super.key,
  });

  final Widget child;

  final LdColor? color;

  final bool? circular;

  final LdSize? size;

  static Widget success({
    required Widget child,
    LdColor? color,
    bool? circular,
    LdSize? size,
    Key? key,
  }) {
    return Builder(
      builder: (BuildContext context) => LdAvatar(
        color: LdTheme.of(context).success,
        circular: circular,
        size: size,
        key: key,
        child: child,
      ),
    );
  }

  static Widget warning({
    required Widget child,
    LdColor? color,
    bool? circular,
    LdSize? size,
    Key? key,
  }) {
    return Builder(
      builder: (BuildContext context) => LdAvatar(
        color: LdTheme.of(context).warning,
        circular: circular,
        size: size,
        key: key,
        child: child,
      ),
    );
  }

  static Widget error({
    required Widget child,
    LdColor? color,
    bool? circular,
    LdSize? size,
    Key? key,
  }) {
    return Builder(
      builder: (BuildContext context) => LdAvatar(
        color: LdTheme.of(context).error,
        circular: circular,
        size: size,
        key: key,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<LdAvatarConfig?>(context, listen: true);
    return _LdAvatarWidget(
      color: color ?? config?.color,
      circular: circular ?? config?.circular ?? false,
      size: size ?? config?.size ?? LdSize.m,
      child: child,
    );
  }
}
