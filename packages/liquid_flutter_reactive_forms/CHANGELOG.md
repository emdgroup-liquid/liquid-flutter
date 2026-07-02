## 0.1.1-2
Released on: 7/2/2026, changelog automatically generated.

### API Changes

#### 💣 Breaking changes

**`class` LdMonkeyReactiveDetailForm<T extends Identifiable<IdType>, IdType, TDetail extends Object, TCreate, TUpdate>** ([lib/src/monkey_detail/ld_monkey_reactive_detail_form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-1..liquid_flutter_reactive_forms/v0.1.1-2#diff-6703bfe01b8395270d0a6fb1fad74d57e4772adab447674396cdc09bf90f5239))
- 🔄 Param type changed in constructor `edit`: `formToUpdatePayload` (`TUpdate Function(FormGroup, TDetail)` → `TUpdate Function(FormGroup, TDetail)?`)
- 🔄 Param type changed in constructor `create`: `formToCreatePayload` (`TCreate Function(FormGroup, TDetail)` → `TCreate Function(FormGroup, TDetail)?`)

#### 👀 Patch changes

**`meta` pubspec.yaml** ([pubspec.yaml](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-1..liquid_flutter_reactive_forms/v0.1.1-2#diff-8b7e9df87668ffa6a04b32e1769a33434999e54ae081c52e5d943c541d4c0d25))
- 📦 Added `collection`: with version `^1.19.0`
- 📦 Added `provider`: with version `^6.1.0`


## 0.1.1-1
Released on: 6/28/2026, changelog automatically generated.

### API Changes

#### 👀 Patch changes

**`meta` pubspec.yaml** ([pubspec.yaml](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.0.1..liquid_flutter_reactive_forms/v0.1.1-1#diff-8b7e9df87668ffa6a04b32e1769a33434999e54ae081c52e5d943c541d4c0d25))
- 📦 `liquid_flutter` version changed: from `^23.0.0-4` to `^23.0.0-5`


## 0.1.0

* Initial release.
* Adds `reactive_forms` extensions for `liquid_flutter`, including monkey detail form helpers.
