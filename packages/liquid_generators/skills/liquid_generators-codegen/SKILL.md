---
name: liquid_generators-codegen
description: Use when creating new Liquid Flutter widgets with variants or context-configurable parameters — covers the @Variants annotation, @ContextConfigurable, the generated public wrapper class, ButtonConfig, and ButtonConfigProvider patterns.
---

# Liquid Generators — Variant Code Generation

`liquid_generators` is a `build_runner` source generator used internally by the `liquid_flutter` monorepo. It reads `@Variants(...)` and `@ContextConfigurable()` annotations on private widget classes and generates a public wrapper with factory constructors, an optional config data class, and a config provider widget.

> This package is an internal monorepo tool and is not published to pub.dev.

---

## How it works

1. Annotate a **private** class ending in `Widget` (e.g. `_ButtonWidget`) with `@Variants(...)`.
2. Run `build_runner`: `dart run build_runner build`.
3. A `.variants.g.dart` part file is generated next to your source file.

---

## @Variants annotation

```dart
@Variants([
  Variant('filled', defaults: {'mode': 'LdButtonMode.filled'}),
  Variant('outline', defaults: {'mode': 'LdButtonMode.outline'}),
  Variant('ghost',   defaults: {'mode': 'LdButtonMode.ghost'}),
])
class _ButtonWidget extends StatelessWidget {
  const _ButtonWidget({
    required this.child,
    required this.mode,
    this.size = LdSize.m,
    this.onPressed,
  });

  final Widget child;
  final LdButtonMode mode;
  final LdSize size;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) { ... }
}
```

The generator produces:

```dart
// Public wrapper — mirrors all fields
class Button extends StatelessWidget {
  const Button({required this.child, required this.mode, ...});

  // Factory constructors for each non-context-dependent variant:
  factory Button.filled({required Widget child, LdSize size = LdSize.m, ...}) =>
      Button(child: child, mode: LdButtonMode.filled, size: size, ...);

  factory Button.outline({...}) => ...;
  factory Button.ghost({...})   => ...;
}
```

---

## @ContextConfigurable — context-aware defaults

Mark parameters whose defaults should come from a `ConfigProvider` in the widget tree:

```dart
@Variants([Variant('primary')])
class _BadgeWidget extends StatelessWidget {
  const _BadgeWidget({
    required this.label,
    @ContextConfigurable() this.size,   // nullable — filled from provider
  });

  final String label;
  final LdSize? size;
  ...
}
```

The generator additionally produces:

```dart
// Config data class — all fields nullable
class BadgeConfig {
  const BadgeConfig({this.size});
  final LdSize? size;
}

// Config provider widget — merges with parent provider
class BadgeConfigProvider extends StatelessWidget {
  const BadgeConfigProvider({
    required this.config,
    required this.child,
    this.ignoreParent = false,
  });

  final BadgeConfig config;
  final Widget child;
  final bool ignoreParent;

  @override
  Widget build(BuildContext context) { ... }
}
```

In `Badge.build()` the resolved value is `size ?? config?.size ?? LdSize.m`.

### Applying a provider

```dart
BadgeConfigProvider(
  config: BadgeConfig(size: LdSize.s),
  child: Column(
    children: [
      Badge.primary(label: 'One'),    // uses LdSize.s from provider
      Badge.primary(label: 'Two'),    // same
      Badge.primary(label: 'Three', size: LdSize.l), // override
    ],
  ),
)
```

---

## Context-dependent variants

When a `Variant`'s `defaults` map contains a value that references `context`, the generator emits a **static method** returning a `Builder` instead of a factory constructor:

```dart
// In annotation:
Variant('themed', defaults: {'color': 'LdTheme.of(context).primaryColor'})

// Generated:
static Widget themed({required Widget child, ...}) {
  return Builder(builder: (context) => Button(
    color: LdTheme.of(context).primaryColor,
    child: child,
    ...
  ));
}
```

---

## Generic widgets

Type parameters propagate fully:

```dart
@Variants([Variant('default')])
class _ItemWidget<T extends Identifiable<IdType>, IdType> extends StatelessWidget { ... }
```

Generates `Item<T extends Identifiable<IdType>, IdType>`, `ItemConfig<T, IdType>`, and `ItemConfigProvider<T, IdType>`.

---

## Build runner

```bash
# One-shot build
dart run build_runner build

# Watch mode
dart run build_runner watch

# Force rebuild (clean first)
dart run build_runner build --delete-conflicting-outputs
```

Generated files end in `.variants.g.dart` and are committed to source control (`build_to: source`).

---

## Notes

- Only files under `lib/src/` are processed — files in `lib/` root or outside `lib/` are skipped.
- Class name must end in `Widget` to be picked up by the builder.
- Do not edit `.variants.g.dart` files manually — they are fully regenerated on each build.
- The `@ContextConfigurable` annotation can be placed on the constructor (all optional params become configurable) or on individual parameters.
