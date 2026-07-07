import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

// ---------------------------------------------------------------------------
// Shader pair exposed to the tree
// ---------------------------------------------------------------------------

/// A pair of [ui.FragmentShader] instances vended by [LdMetaballShaderScope].
///
/// [fill] is used for the normal-size fill pass; [border] is used for the
/// inflated border pass.  Each call to [LdMetaballShaderScope.of] returns the
/// **same** shader instances for the lifetime of the scope — callers must not
/// dispose them.
class LdMetaballShaders {
  /// The fill-mask shader (natural blob dimensions).
  final ui.FragmentShader fill;

  /// The border-mask shader (blobs inflated by borderWidth).
  final ui.FragmentShader border;

  const LdMetaballShaders({required this.fill, required this.border});
}

// ---------------------------------------------------------------------------
// InheritedWidget that carries the loaded shaders
// ---------------------------------------------------------------------------

class _LdMetaballShaderData extends InheritedWidget {
  final LdMetaballShaders? shaders;

  const _LdMetaballShaderData({required this.shaders, required super.child});

  @override
  bool updateShouldNotify(_LdMetaballShaderData old) => old.shaders != shaders;
}

// ---------------------------------------------------------------------------
// LdMetaballShaderScope
// ---------------------------------------------------------------------------

/// Loads the metaball [ui.FragmentProgram] once and provides a
/// [LdMetaballShaders] pair to all descendants via [LdMetaballShaderScope.of].
///
/// Place this widget near the root of any subtree that contains
/// [LdMetaballMask] or [LdMetaball] widgets.  Nesting multiple scopes is
/// fine — each scope loads independently, but in practice a single scope high
/// in the tree is most efficient.
///
/// While the shader is loading, [of] returns `null`; descendants should
/// render a placeholder (e.g. [SizedBox.expand]).
///
/// ```dart
/// LdMetaballShaderScope(
///   child: MyPage(),
/// )
/// ```
class LdMetaballShaderScope extends StatefulWidget {
  final Widget child;

  const LdMetaballShaderScope({super.key, required this.child});

  /// Returns the [LdMetaballShaders] pair from the nearest
  /// [LdMetaballShaderScope] ancestor, or `null` if the shader has not yet
  /// finished loading.
  ///
  /// Throws a [FlutterError] if no [LdMetaballShaderScope] is found in the
  /// ancestor chain.
  static LdMetaballShaders? of(BuildContext context) {
    final data =
        context.dependOnInheritedWidgetOfExactType<_LdMetaballShaderData>();
    if (data == null) {
      throw FlutterError(
        'LdMetaballShaderScope.of() called with no LdMetaballShaderScope '
        'in the widget tree. Wrap your widget with LdMetaballShaderScope.',
      );
    }
    return data.shaders;
  }

  @override
  State<LdMetaballShaderScope> createState() => _LdMetaballShaderScopeState();
}

class _LdMetaballShaderScopeState extends State<LdMetaballShaderScope> {
  LdMetaballShaders? _shaders;

  @override
  void initState() {
    super.initState();
    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'packages/liquid_flutter/shaders/metaball.frag',
      );
      if (mounted) {
        setState(() {
          _shaders = LdMetaballShaders(
            fill: program.fragmentShader(),
            border: program.fragmentShader(),
          );
        });
      }
    } catch (e, st) {
      debugPrint('LdMetaballShaderScope: shader load failed\n$e\n$st');
    }
  }

  @override
  void dispose() {
    _shaders?.fill.dispose();
    _shaders?.border.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _LdMetaballShaderData(
      shaders: _shaders,
      child: widget.child,
    );
  }
}
