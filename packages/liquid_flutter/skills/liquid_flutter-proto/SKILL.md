---
name: liquid_flutter-proto
description: Use when working with protobuf-generated Dart classes in Liquid Flutter — covers the identifiable_proto CLI tool, JSON config, workflow, and Identifiable mixin usage.
---

# Protobuf & Identifiable Classes in Liquid Flutter

## Overview

Liquid Flutter's `Identifiable<I>` mixin is used by the Monkey master-detail
system to identify items by their unique ID. When you generate Dart classes
from `.proto` files using `protoc`, the resulting `.pb.dart` classes need
this mixin applied.

The `identifiable_proto` tool post-processes `.pb.dart` files to
automatically add `with Identifiable<T>` to message classes that have an
`id` getter (or a custom field you specify via config).

## Setup

Add `liquid_flutter` to your `pubspec.yaml` (already done if you're using
the design system). The tool is included in the package — no extra
dependency needed.

## Workflow

```
protoc --dart_out=lib/proto *.proto    # 1. Generate .pb.dart files
dart run liquid_flutter:identifiable_proto  # 2. Post-process for Identifiable
```

Run step 2 after every `protoc` invocation. Add it to your build script
or `Makefile` alongside the `protoc` call.

## What the tool does

For each `.pb.dart` file in `lib/proto/`:

1. Scans for classes that extend `$pb.GeneratedMessage`.
2. Checks if the class has a `get id =>` getter — if so, auto-detects the
   return type (`int` or `String`) and adds `Identifiable<int>` or
   `Identifiable<String>`.
3. If no `id` getter is found, checks the optional JSON config file for a
   field override (see below).
4. Adds `import 'package:liquid_flutter/liquid_flutter.dart'` if not
   already present.
5. Skips classes that already have `Identifiable` applied.

## Config file (optional)

Place `identifiable_proto.json` alongside your `.pb.dart` files (default:
`lib/proto/identifiable_proto.json`). Only needed for classes that use
a field *other than* `id` for identity.

```json
{
  "Product": "uuid",
  "Order": "orderId",
  "Customer": "customerId"
}
```

This tells the tool: for the `Product` message class, look for `get uuid`
instead of `get id`. The return type is still auto-detected.

When a field override is used, the tool also adds a forwarding getter so
the `Identifiable` mixin's required `get id` is satisfied:

```dart
// Before
class Product extends $pb.GeneratedMessage {
  $core.String get uuid => '';
}

// After
class Product extends $pb.GeneratedMessage with Identifiable<$core.String> {
  $core.String get id => uuid;  // ← forwarding getter added by the tool
  $core.String get uuid => '';
}
```

## CLI options

```
dart run liquid_flutter:identifiable_proto [options]

Options:
  --proto-dir DIR    Directory containing .pb.dart files (default: lib/proto)
  --config PATH      Path to JSON config file (default: lib/proto/identifiable_proto.json)
  --dry-run          Print changes without modifying files
  --verbose          Log detailed information
  --help             Show this message
```

### Dry-run mode

```bash
dart run liquid_flutter:identifiable_proto --dry-run --verbose
```

Shows what would change without modifying any files. Useful for verifying
a new config file or after upgrading `protoc` versions.

## Using Identifiable with Monkey

Once the mixin is applied, your proto classes can be used directly with
Liquid Flutter's Monkey master-detail routes:

```dart
// Route config for string-identified items
LdMonkeyRouteConfig.identifiableString<User>(
  path: '/users',
  ...
)

// Route config for int-identified items
LdMonkeyRouteConfig.identifiableInt<Order>(
  path: '/orders',
  ...
)
```

## Example

Given a proto definition:

```protobuf
message User {
  int32 id = 1;
  string name = 2;
}

message Product {
  string uuid = 1;
  string name = 2;
}
```

And a config file `lib/proto/identifiable_proto.json`:

```json
{
  "Product": "uuid"
}
```

After running the tool, the generated classes become:

```dart
// user.pb.dart
class User extends $pb.GeneratedMessage with Identifiable<$core.int> {
  ...
}

// product.pb.dart
class Product extends $pb.GeneratedMessage with Identifiable<$core.String> {
  $core.String get id => uuid;  // ← forwarding getter (auto-added)
  ...
}
```