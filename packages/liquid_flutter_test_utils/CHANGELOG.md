## 1.7.0-9
Released on: 8/6/2026, changelog automatically generated.

## 1.7.0-8
Released on: 7/10/2026, changelog automatically generated.

### API Changes

#### 👀 Patch changes

**`meta` pubspec.yaml** ([pubspec.yaml](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.7.0-7..liquid_flutter_test_utils/v1.7.0-8#diff-8b7e9df87668ffa6a04b32e1769a33434999e54ae081c52e5d943c541d4c0d25))
- 📦 `liquid_flutter` version changed: from `^23.0.0-4` to `^23.0.0-8`


## 1.7.0-7
Released on: 7/7/2026, changelog automatically generated.

## 1.7.0-6
Released on: 7/2/2026, changelog automatically generated.

## 1.7.0-5
Released on: 6/28/2026, changelog automatically generated.

## 1.7.0-3
Released on: 6/23/2026.

Republish after pub.dev baseline alignment.

## 1.7.0-1
Released on: 6/23/2026, changelog automatically generated.

### API Changes

#### ✨ Minor changes

**`class` WidgetTreeNode** ([lib/widget_tree_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..liquid_flutter_test_utils/v1.7.0-1#diff-77b28609619dfae489094fba8fbddd46a48f5313fb6d155bb662ffb03626aa6a))
- ❇️ Params added in method `toXmlString`: `parentBounds` (named, optional), `parentConstraints` (named, optional)

**`function` loadAppFonts** ([lib/golden_utils.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..liquid_flutter_test_utils/v1.7.0-1#diff-8c3a1ff205506441531a88e3d816d6e74e548fbadfa9c1d2c50c556ff7f90093))
- ❇️ Function added: `loadAppFonts`

**`function` multiGolden** ([lib/multi_golden_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..liquid_flutter_test_utils/v1.7.0-1#diff-896c93e95156fde96bcb36f862d111612f7b76f8281665a5c8732fe176917496))
- ❇️ Param added in function `multiGolden`: `widgetTreeOptionsOverrides` (named, optional, default: const {})

**`function` resetTester** ([lib/multi_golden_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..liquid_flutter_test_utils/v1.7.0-1#diff-896c93e95156fde96bcb36f862d111612f7b76f8281665a5c8732fe176917496))
- ❇️ Function added: `resetTester`

**`function` setupGoldenTest** ([lib/golden_utils.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..liquid_flutter_test_utils/v1.7.0-1#diff-8c3a1ff205506441531a88e3d816d6e74e548fbadfa9c1d2c50c556ff7f90093))
- ❌ Param removed in function `setupGoldenTest`: `fileComparatorThreshold` (named, optional, default: 0.05)

**`function` writeFailureScreenshot** ([lib/multi_golden_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..liquid_flutter_test_utils/v1.7.0-1#diff-896c93e95156fde96bcb36f862d111612f7b76f8281665a5c8732fe176917496))
- ❇️ Function added: `writeFailureScreenshot`

#### 👀 Patch changes

**`function` _allowedPropertyNames** ([lib/widget_tree_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..liquid_flutter_test_utils/v1.7.0-1#diff-77b28609619dfae489094fba8fbddd46a48f5313fb6d155bb662ffb03626aa6a))
- ❇️ Function added: `_allowedPropertyNames`

**`function` _boundsMatchParent** ([lib/widget_tree_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..liquid_flutter_test_utils/v1.7.0-1#diff-77b28609619dfae489094fba8fbddd46a48f5313fb6d155bb662ffb03626aa6a))
- ❇️ Function added: `_boundsMatchParent`

**`function` _captureElementImage** ([lib/multi_golden_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..liquid_flutter_test_utils/v1.7.0-1#diff-896c93e95156fde96bcb36f862d111612f7b76f8281665a5c8732fe176917496))
- ❇️ Function added: `_captureElementImage`

**`function` _colorToHex** ([lib/widget_tree_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..liquid_flutter_test_utils/v1.7.0-1#diff-77b28609619dfae489094fba8fbddd46a48f5313fb6d155bb662ffb03626aa6a))
- ❇️ Function added: `_colorToHex`

**`function` _constraintsMatchParent** ([lib/widget_tree_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..liquid_flutter_test_utils/v1.7.0-1#diff-77b28609619dfae489094fba8fbddd46a48f5313fb6d155bb662ffb03626aa6a))
- ❇️ Function added: `_constraintsMatchParent`

**`function` _getPropertyValueString** ([lib/widget_tree_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..liquid_flutter_test_utils/v1.7.0-1#diff-77b28609619dfae489094fba8fbddd46a48f5313fb6d155bb662ffb03626aa6a))
- ❇️ Function added: `_getPropertyValueString`

**`function` _sanitizeAttributeValue** ([lib/widget_tree_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..liquid_flutter_test_utils/v1.7.0-1#diff-77b28609619dfae489094fba8fbddd46a48f5313fb6d155bb662ffb03626aa6a))
- ❇️ Function added: `_sanitizeAttributeValue`

**`function` _serializeBorder** ([lib/widget_tree_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..liquid_flutter_test_utils/v1.7.0-1#diff-77b28609619dfae489094fba8fbddd46a48f5313fb6d155bb662ffb03626aa6a))
- ❇️ Function added: `_serializeBorder`

**`function` _serializeBorderRadius** ([lib/widget_tree_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..liquid_flutter_test_utils/v1.7.0-1#diff-77b28609619dfae489094fba8fbddd46a48f5313fb6d155bb662ffb03626aa6a))
- ❇️ Function added: `_serializeBorderRadius`

**`function` _serializeBoxDecoration** ([lib/widget_tree_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..liquid_flutter_test_utils/v1.7.0-1#diff-77b28609619dfae489094fba8fbddd46a48f5313fb6d155bb662ffb03626aa6a))
- ❇️ Function added: `_serializeBoxDecoration`

**`meta` dependency `liquid_flutter`** ([pubspec.yaml](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..liquid_flutter_test_utils/v1.7.0-1#diff-8b7e9df87668ffa6a04b32e1769a33434999e54ae081c52e5d943c541d4c0d25))
- 📦 Dependency version changed: from `^23.0.0-1` to `^23.0.0-3`


## 1.7.0-1
Released on: 6/23/2026, changelog automatically generated.

### API Changes

#### ✨ Minor changes

**`class` WidgetTreeNode** ([lib/widget_tree_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..6f2cb500414387bca362687520bb6fa71425a1f6#diff-77b28609619dfae489094fba8fbddd46a48f5313fb6d155bb662ffb03626aa6a))
- ❇️ Params added in method `toXmlString`: `parentBounds` (named, optional), `parentConstraints` (named, optional)

**`function` loadAppFonts** ([lib/golden_utils.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..6f2cb500414387bca362687520bb6fa71425a1f6#diff-8c3a1ff205506441531a88e3d816d6e74e548fbadfa9c1d2c50c556ff7f90093))
- ❇️ Function added: `loadAppFonts`

**`function` multiGolden** ([lib/multi_golden_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..6f2cb500414387bca362687520bb6fa71425a1f6#diff-896c93e95156fde96bcb36f862d111612f7b76f8281665a5c8732fe176917496))
- ❇️ Param added in function `multiGolden`: `widgetTreeOptionsOverrides` (named, optional, default: const {})

**`function` resetTester** ([lib/multi_golden_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..6f2cb500414387bca362687520bb6fa71425a1f6#diff-896c93e95156fde96bcb36f862d111612f7b76f8281665a5c8732fe176917496))
- ❇️ Function added: `resetTester`

**`function` setupGoldenTest** ([lib/golden_utils.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..6f2cb500414387bca362687520bb6fa71425a1f6#diff-8c3a1ff205506441531a88e3d816d6e74e548fbadfa9c1d2c50c556ff7f90093))
- ❌ Param removed in function `setupGoldenTest`: `fileComparatorThreshold` (named, optional, default: 0.05)

**`function` writeFailureScreenshot** ([lib/multi_golden_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..6f2cb500414387bca362687520bb6fa71425a1f6#diff-896c93e95156fde96bcb36f862d111612f7b76f8281665a5c8732fe176917496))
- ❇️ Function added: `writeFailureScreenshot`

#### 👀 Patch changes

**`function` _allowedPropertyNames** ([lib/widget_tree_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..6f2cb500414387bca362687520bb6fa71425a1f6#diff-77b28609619dfae489094fba8fbddd46a48f5313fb6d155bb662ffb03626aa6a))
- ❇️ Function added: `_allowedPropertyNames`

**`function` _boundsMatchParent** ([lib/widget_tree_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..6f2cb500414387bca362687520bb6fa71425a1f6#diff-77b28609619dfae489094fba8fbddd46a48f5313fb6d155bb662ffb03626aa6a))
- ❇️ Function added: `_boundsMatchParent`

**`function` _captureElementImage** ([lib/multi_golden_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..6f2cb500414387bca362687520bb6fa71425a1f6#diff-896c93e95156fde96bcb36f862d111612f7b76f8281665a5c8732fe176917496))
- ❇️ Function added: `_captureElementImage`

**`function` _colorToHex** ([lib/widget_tree_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..6f2cb500414387bca362687520bb6fa71425a1f6#diff-77b28609619dfae489094fba8fbddd46a48f5313fb6d155bb662ffb03626aa6a))
- ❇️ Function added: `_colorToHex`

**`function` _constraintsMatchParent** ([lib/widget_tree_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..6f2cb500414387bca362687520bb6fa71425a1f6#diff-77b28609619dfae489094fba8fbddd46a48f5313fb6d155bb662ffb03626aa6a))
- ❇️ Function added: `_constraintsMatchParent`

**`function` _getPropertyValueString** ([lib/widget_tree_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..6f2cb500414387bca362687520bb6fa71425a1f6#diff-77b28609619dfae489094fba8fbddd46a48f5313fb6d155bb662ffb03626aa6a))
- ❇️ Function added: `_getPropertyValueString`

**`function` _sanitizeAttributeValue** ([lib/widget_tree_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..6f2cb500414387bca362687520bb6fa71425a1f6#diff-77b28609619dfae489094fba8fbddd46a48f5313fb6d155bb662ffb03626aa6a))
- ❇️ Function added: `_sanitizeAttributeValue`

**`function` _serializeBorder** ([lib/widget_tree_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..6f2cb500414387bca362687520bb6fa71425a1f6#diff-77b28609619dfae489094fba8fbddd46a48f5313fb6d155bb662ffb03626aa6a))
- ❇️ Function added: `_serializeBorder`

**`function` _serializeBorderRadius** ([lib/widget_tree_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..6f2cb500414387bca362687520bb6fa71425a1f6#diff-77b28609619dfae489094fba8fbddd46a48f5313fb6d155bb662ffb03626aa6a))
- ❇️ Function added: `_serializeBorderRadius`

**`function` _serializeBoxDecoration** ([lib/widget_tree_test.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..6f2cb500414387bca362687520bb6fa71425a1f6#diff-77b28609619dfae489094fba8fbddd46a48f5313fb6d155bb662ffb03626aa6a))
- ❇️ Function added: `_serializeBoxDecoration`

**`meta` dependency `liquid_flutter`** ([pubspec.yaml](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_test_utils/v1.6.3-1..6f2cb500414387bca362687520bb6fa71425a1f6#diff-8b7e9df87668ffa6a04b32e1769a33434999e54ae081c52e5d943c541d4c0d25))
- 📦 Dependency version changed: from `^23.0.0-1` to `^23.0.0-2`


# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

### 1.7.0-2 Compatibility with Liquid Flutter 23 


### [1.6.2](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/compare/v1.6.1...v1.6.2) (2025-09-25)

### [1.6.1](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/compare/v1.6.0...v1.6.1) (2025-09-25)

## [1.6.0](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/compare/v1.5.1...v1.6.0) (2025-09-10)


### Features

* enhance LdFrameOptions with additional copyWith parameters for customization ([d5ed140](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/d5ed140ca2bf53caba7a664cb0857473b761fce6))
* enhance LdFrameOptions with additional copyWith parameters for customization ([924f4cb](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/924f4cb9a968029e1bdf3020ae8869f030701d00))


### Bug Fixes

* escape ampersands in widget tree test output ([9e14003](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/9e14003ca9c7ce140836b75dfe1ea75f4bbe4a8e))

### [1.5.1](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/compare/v1.5.0...v1.5.1) (2025-05-16)


### Bug Fixes

* correct logic for dark mode in ldFrame and add package reference for status bar assets ([#8](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/issues/8)) ([6d5b837](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/6d5b83705d1d1e7720bbc9ed92c33cf3905ceaf0))

## [1.5.0](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/compare/v1.4.1...v1.5.0) (2025-05-15)


### Features

* allow for different device frames ([#7](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/issues/7)) ([5cfdac3](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/5cfdac36597d5825c8ebb20b1036c590ad5502fb))

### [1.4.1](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/compare/v1.4.0...v1.4.1) (2025-04-25)


### Bug Fixes

* correct default device dimensions to be in portrait ([4e5f77b](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/4e5f77b12f87f518474e571fff05e15bba779f80))
* enhance status bar notch looks ([34e6852](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/34e6852226930901bfd337777535ccad9f8fea41))

## [1.4.0](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/compare/v1.3.1...v1.4.0) (2025-04-23)


### Features

* add possibility to generate landscape golden screens ([4a784bd](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/4a784bd5541bde1a2d03b97aca8fa1b115e58ff4))
* add some factory constructors for common device screen sizes in LdFrameOptions ([997430a](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/997430a18b091f0a4a383548d5d6810f9be8a603))
* add status bar notch to screenWithSystemUi mode ([f52adff](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/f52adfffce8fe3bdae2156edb7a4d1b32699334a))


### Bug Fixes

* make system UI elements overlap screen UI ([123bef1](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/123bef1c48fac42d2bc610fe4d18c51f5a27b2ad))

### [1.3.1](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/compare/v1.3.0...v1.3.1) (2025-04-15)


### Bug Fixes

* correct argument order in HTML diff generation for widget tree tests ([72d5990](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/72d5990fc03385459ba3a549e2a3479d010ae6a9))

## [1.3.0](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/compare/v1.2.0...v1.3.0) (2025-04-15)


### Features

* add comprehensive HTML diff generation for failed widget tree tests ([5f99213](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/5f99213067a544ecd1e5b16d614aafa9faad8e10))

## 1.2.0 (2025-04-15)


### Features

* add 'showGoBackButton' and 'height' frame option ([b476add](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/b476adddc835355d2c84f0d668df45bf4d783d57))
* add "screenWithSystemUi" GoldenUiMode and according test case ([32a5168](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/32a5168adc0a26a4fec1de7a09ecfef7ec0e922c))
* add bounds precision option for XML widget tree serialization ([ff0b4ee](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/ff0b4ee7cf98455966d349779f734732ba46d818))
* add bounds to widget tree test ([982a784](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/982a78418763f6203cec7670cc57be9c6bd55402))


### Bug Fixes

* correctly sanitize widget type tags in XML widget tree creation ([721741a](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/721741afa4c9313a743e56967c10aa90b1ce5635))
* provide some form of widget bounds calculation for RenderSliverList ([d25e445](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/d25e4452ba3fef5a82561181877ce18e5e20a43b))
* update regex to correctly match UID hash codes in widget tree serialization ([eef1068](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/eef10686312def4f60393e9e89a5c76502a9e063))

## 1.1.0 (2025-04-15)


### Features

* add 'showGoBackButton' and 'height' frame option ([b476add](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/b476adddc835355d2c84f0d668df45bf4d783d57))
* add "screenWithSystemUi" GoldenUiMode and according test case ([32a5168](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/32a5168adc0a26a4fec1de7a09ecfef7ec0e922c))
* add bounds precision option for XML widget tree serialization ([ff0b4ee](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/ff0b4ee7cf98455966d349779f734732ba46d818))
* add bounds to widget tree test ([982a784](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/982a78418763f6203cec7670cc57be9c6bd55402))


### Bug Fixes

* correctly sanitize widget type tags in XML widget tree creation ([721741a](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/721741afa4c9313a743e56967c10aa90b1ce5635))
* provide some form of widget bounds calculation for RenderSliverList ([d25e445](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/d25e4452ba3fef5a82561181877ce18e5e20a43b))
* update regex to correctly match UID hash codes in widget tree serialization ([eef1068](https://github.com/emdgroup-liquid/liquid-flutter-test-utils/commit/eef10686312def4f60393e9e89a5c76502a9e063))

## 1.0.0

- Initial release