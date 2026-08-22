## 23.0.0-13
Released on: 8/22/2026, changelog automatically generated.


### Bug Fixes

- **LdTabNavigation:** restore indicator drag without blocking tab taps ([e114b12](commit/e114b12))
- **LdToolAllowRule:** match absent nested objects pinned to Any ([1d24ad1](commit/1d24ad1))
- **LdInput:** use regular weight for field text ([55e73bc](commit/55e73bc))
- **LdInput:** restore label style for compact control height ([ceeee8b](commit/ceeee8b))
### Features

- **LdFilterBool:** implement equality operator and hashCode method ([c144052](commit/c144052))
- **LdComposeBar:** integrate theme into attach buttons and adjust padding ([61c60f3](commit/61c60f3))
- **LdConversation:** add tool call override functionality and history compacting feature ([9edd17d](commit/9edd17d))
- **LdMarkdown:** add GFM footnote rendering ([f0d2c6a](commit/f0d2c6a))

## 23.0.0-12
Released on: 8/18/2026, changelog automatically generated.


### Bug Fixes

- **LdToolAllowRule:** allow wildcard to match absent args ([#152](issues/152)) ([2e29138](commit/2e29138))
- **LdAppBar:** remove leftover debug print statements in _buildScrim ([05bfb2b](commit/05bfb2b))
- restore tap-through on LdTabNavigation indicator and fix LdDrawerLayout dispose crash ([4ba13c6](commit/4ba13c6))
### Features

- **LdSubmit:** allow scoping exception localization via onException ([b5870b2](commit/b5870b2))

### API Changes

#### 💣 Breaking changes

**`class` AppBarFrame** ([lib/src/appbar/appbar_frame.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-11..liquid_flutter/v23.0.0-12#diff-f5dae86f88f57d7eacd239b0beba44a7a95e301f01ff1dd11b53d1ec43864c92))
- 🔄 Param type changed in default constructor: `scrimColor` (`Color?` → `Color? Function(bool)?`)
- ❌ Property removed: `insetBorderRadius`
- 🔄 Property type changed: `scrimColor`

**`class` LdAppBar** ([lib/src/appbar/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-11..liquid_flutter/v23.0.0-12#diff-3fa4ae735c9f6ca4c26ac958e08eaa30e2da735b6e0f0ed00665eb6c2b2bb49f))
- ❌ Property removed: `insetScreenRadius`

**`class` LdAppBarConfig** ([lib/src/appbar/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-11..liquid_flutter/v23.0.0-12#diff-3fa4ae735c9f6ca4c26ac958e08eaa30e2da735b6e0f0ed00665eb6c2b2bb49f))
- ❌ Property removed: `insetScreenRadius`

**`class` LdAppBarWidget** ([lib/src/appbar/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-11..liquid_flutter/v23.0.0-12#diff-3fa4ae735c9f6ca4c26ac958e08eaa30e2da735b6e0f0ed00665eb6c2b2bb49f))
- ❌ Property removed: `insetScreenRadius`

**`class` _LdCounterDigit** ([lib/src/counter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-11..liquid_flutter/v23.0.0-12#diff-56493e7e7233aac1f95d625ed446d310fe0305379c2e1b4429cd8bc3083c6a4d))
- ❇️ Param added in default constructor: `ascending` (named, required)

#### ✨ Minor changes

**`class` AppBarFrame** ([lib/src/appbar/appbar_frame.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-11..liquid_flutter/v23.0.0-12#diff-f5dae86f88f57d7eacd239b0beba44a7a95e301f01ff1dd11b53d1ec43864c92))
- ❌ Param removed in default constructor: `insetBorderRadius` (named, optional, default: true)
- ❇️ Param added in default constructor: `useAdaptiveRadius` (named, optional, default: true)
- ❇️ Property added: `useAdaptiveRadius`

**`class` LdAppBar** ([lib/src/appbar/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-11..liquid_flutter/v23.0.0-12#diff-3fa4ae735c9f6ca4c26ac958e08eaa30e2da735b6e0f0ed00665eb6c2b2bb49f))
- ❌ Param removed in default constructor: `insetScreenRadius` (named, optional)
- ❇️ Param added in default constructor: `useAdaptiveRadius` (named, optional)
- ❌ Param removed in constructor `top`: `insetScreenRadius` (named, optional)
- ❇️ Param added in constructor `top`: `useAdaptiveRadius` (named, optional)
- ❌ Param removed in constructor `bottom`: `insetScreenRadius` (named, optional)
- ❇️ Param added in constructor `bottom`: `useAdaptiveRadius` (named, optional)
- ❇️ Property added: `useAdaptiveRadius`

**`class` LdAppBarConfig** ([lib/src/appbar/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-11..liquid_flutter/v23.0.0-12#diff-3fa4ae735c9f6ca4c26ac958e08eaa30e2da735b6e0f0ed00665eb6c2b2bb49f))
- ❌ Param removed in default constructor: `insetScreenRadius` (named, optional)
- ❇️ Param added in default constructor: `useAdaptiveRadius` (named, optional)
- ❇️ Property added: `useAdaptiveRadius`
- ❌ Param removed in method `copyWith`: `insetScreenRadius` (named, optional)
- ❇️ Param added in method `copyWith`: `useAdaptiveRadius` (named, optional)

**`class` LdAppBarWidget** ([lib/src/appbar/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-11..liquid_flutter/v23.0.0-12#diff-3fa4ae735c9f6ca4c26ac958e08eaa30e2da735b6e0f0ed00665eb6c2b2bb49f))
- ❌ Param removed in default constructor: `insetScreenRadius` (named, optional, default: true)
- ❇️ Param added in default constructor: `useAdaptiveRadius` (named, optional, default: true)
- ❇️ Property added: `useAdaptiveRadius`

**`class` LdCounter** ([lib/src/counter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-11..liquid_flutter/v23.0.0-12#diff-56493e7e7233aac1f95d625ed446d310fe0305379c2e1b4429cd8bc3083c6a4d))
- ❇️ Params added in default constructor: `size` (named, optional, default: LdSize.m), `type` (named, optional, default: LdTextType.headline)
- ❇️ Properties added: `size`, `type`

**`class` LdCounterDuration** ([lib/src/counter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-11..liquid_flutter/v23.0.0-12#diff-56493e7e7233aac1f95d625ed446d310fe0305379c2e1b4429cd8bc3083c6a4d))
- ❇️ Class added: `LdCounterDuration`

**`class` LdInput** ([lib/src/input.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-11..liquid_flutter/v23.0.0-12#diff-2ffc2d5e6008b31f35c68f6ed0d27138168bf19c95df7c0aab8349787a9a5ef6))
- ❇️ Params added in default constructor: `style` (named, optional), `borderRadius` (named, optional)
- ❇️ Properties added: `style`, `borderRadius`

**`extension` LdModalRouteExtension** ([lib/src/modal/modal.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-11..liquid_flutter/v23.0.0-12#diff-2d55c400b021d628a7e92bc6d07673f3775bac69b40c544c8332ae622d0f715d))
- ❇️ Property added: `isInSheet`

**`class` LdModalRouteInfo** ([lib/src/modal/modal.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-11..liquid_flutter/v23.0.0-12#diff-2d55c400b021d628a7e92bc6d07673f3775bac69b40c544c8332ae622d0f715d))
- ❇️ Class added: `LdModalRouteInfo`

**`class` LdSubmit<T, Arg>** ([lib/src/submit/submit.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-11..liquid_flutter/v23.0.0-12#diff-90dec5a624a3cd55bf16ed8f4d39486f0ad3f7b8e1ff081a9177aedac7ea2802))
- ❇️ Param added in default constructor: `onException` (named, optional)
- ❇️ Property added: `onException`

#### 👀 Patch changes

**`class` _AppBarFrameState** ([lib/src/appbar/appbar_frame.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-11..liquid_flutter/v23.0.0-12#diff-f5dae86f88f57d7eacd239b0beba44a7a95e301f01ff1dd11b53d1ec43864c92))
- ❌ Method removed: `_screenRelativeBorderRadius`
- ❇️ Param added in method `_insidePadding`: `outsideRadius` (positional, required)
- ❌ Param removed in method `_buildScrim`: `scrimColor` (positional, required)
- ❇️ Param added in method `_buildScrim`: `isScrolledUnder` (positional, required)
- ❇️ Method added: `_adaptiveBorderRadius`

**`class` _ButtonShape** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-11..liquid_flutter/v23.0.0-12#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- ❇️ Method added: `_circularSizeBump`

**`class` _DigitSlot** ([lib/src/counter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-11..liquid_flutter/v23.0.0-12#diff-56493e7e7233aac1f95d625ed446d310fe0305379c2e1b4429cd8bc3083c6a4d))
- ❇️ Class added: `_DigitSlot`

**`class` _LdCounterDigit** ([lib/src/counter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-11..liquid_flutter/v23.0.0-12#diff-56493e7e7233aac1f95d625ed446d310fe0305379c2e1b4429cd8bc3083c6a4d))
- ❇️ Property added: `ascending`

**`class` _LdCounterDigitState** ([lib/src/counter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-11..liquid_flutter/v23.0.0-12#diff-56493e7e7233aac1f95d625ed446d310fe0305379c2e1b4429cd8bc3083c6a4d))
- ❌ Properties removed: `_textWidths`, `chars`
- ❇️ Properties added: `_current`, `_outgoing`, `_incoming`, `_springKey`
- ❌ Methods removed: `calculateTextWidth`, `_digitHeight`, `_generateTextWidths`, `_buildDigitColumn`, `_buildInlineDigit`, `_buildStandaloneDigit`
- ❇️ Methods added: `_startTransition`, `_onRollEnd`, `_textWidth`, `_buildRollingContent`, `_buildSettledContent`, `_wrapInline`

**`class` _LdCounterState** ([lib/src/counter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-11..liquid_flutter/v23.0.0-12#diff-56493e7e7233aac1f95d625ed446d310fe0305379c2e1b4429cd8bc3083c6a4d))
- 🔄 Property type changed: `_digits`
- ❇️ Properties added: `_ascending`, `_nextId`, `_initialized`
- ❇️ Method added: `_removeSlot`

**`class` _LdMultiPanelLayoutState** ([lib/src/multi_panel/multi_panel_layout.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-11..liquid_flutter/v23.0.0-12#diff-dcf83dd1348efc710dbc6957e505c08eb421234a466c65f2b9630f2f41b83750))
- 🔄 Property type changed: `_bodyDecoration`
- ❌ Property removed: `_bodyMargin`

**`function` _isRollableDigit** ([lib/src/counter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-11..liquid_flutter/v23.0.0-12#diff-56493e7e7233aac1f95d625ed446d310fe0305379c2e1b4429cd8bc3083c6a4d))
- ❇️ Function added: `_isRollableDigit`

## 23.0.0-11
Released on: 8/11/2026, changelog automatically generated.


### Bug Fixes

- don't write to LdSubmitController after dispose ([675cd26](commit/675cd26))

## 23.0.0-10
Released on: 8/7/2026, changelog automatically generated.


### Bug Fixes

- **ci:** push release tags one-by-one [skip ci] ([6a46d5e](commit/6a46d5e))

## 23.0.0-9
Released on: 8/6/2026, changelog automatically generated.


### Bug Fixes

- **LdSubmitController:** ignore stale results after cancel/retry ([58919d2](commit/58919d2))
- use normal draggable on desktop since we can disambiguate touchables better now ([4bb2af9](commit/4bb2af9))
- spacing for headlines and dividers reduced ([b3512b9](commit/b3512b9))
- request focus for all touchables on tap ([086ee90](commit/086ee90))
- ensure proper focus traversal in multi panel ([54d974c](commit/54d974c))
- modal centering correctly in multi panel ([4283b22](commit/4283b22))
- update disabledAlpha value for shadRed color token ([6018e7f](commit/6018e7f))
- disallow trackpad swipe on multi-panel ([5f36680](commit/5f36680))
- change default appbar behaviour ([6f43fed](commit/6f43fed))
- emoji optical centering ([f1e6778](commit/f1e6778))
- dismissal ([5e20b90](commit/5e20b90))
- tooltip on sliders, extract date_picker to be imperatively called ([bddcb40](commit/bddcb40))
- **ci:** unblock analyze and tests on Flutter 3.44.8 ([4c1b5a5](commit/4c1b5a5))
### Features

- **metaball:** add ForceDemo to showcase varying force multipliers for metaballs ([cd6603e](commit/cd6603e))
- **ld_runner_step:** add customizable left padding for expanded children block ([3e44c13](commit/3e44c13))
- **LdNavigationRail:** add width-responsive rail from shared LdNavigationTab ([7bf2878](commit/7bf2878))
- add labels to sliders ([c523a78](commit/c523a78))
- enhance LdInput and LdButton components with new features and improvements ([a8c526f](commit/a8c526f))
- add swagger identifiable mixin processing ([351176d](commit/351176d))
- add hashtag support to markdown editor/widget, rename enabled->disabled ([a4a7ff8](commit/a4a7ff8))

### API Changes

#### 💣 Breaking changes

**`class` LdCallbackModel<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/data/ld_callback_model.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-bbe6dccbaff1f85db929a2244aa1272b485ea8ef19047f4e87871d9a0c49ee84))
- 🔄 Type parameters changed: `T extends Identifiable<IdType>, IdType` → `T extends Identifiable<IdType>, IdType, TCreate, TUpdate`
- 🔄 Param type changed in default constructor: `updateItem` (`Future<T?> Function(BuildContext, IdType, T)?` → `Future<T?> Function(BuildContext, IdType, TUpdate)?`), `createItem` (`Future<T> Function(BuildContext, T?)?` → `Future<T> Function(BuildContext, TCreate)?`), `updateBatchFn` (`Future<void> Function(BuildContext, Map<IdType, T>)?` → `Future<void> Function(BuildContext, Map<IdType, TUpdate>)?`)
- 🔄 Properties type changed: `updateItem`, `createItem`, `updateBatchFn`
- 🔄 Param type changed in method `persistCreate`: `payload` (`T?` → `TCreate`)
- 🔄 Param type changed in method `persistUpdate`: `payload` (`T` → `TUpdate`)
- 🔄 Param type changed in method `persistUpdateBatch`: `items` (`Map<IdType, T>` → `Map<IdType, TUpdate>`)
- 🔄 Param type changed in method `createPreview`: `payload` (`T?` → `TCreate`)
- 🔄 Param type changed in method `create`: `payload` (`T?` → `TCreate`)
- 🔄 Param type changed in method `update`: `payload` (`T` → `TUpdate`)
- 🔄 Param type changed in method `updateBatch`: `items` (`Map<IdType, T>` → `Map<IdType, TUpdate>`)
- 🔄 Method type changed: `greedy` (`LdCallbackModel<L, IdType>` → `LdCallbackModel<L, IdType, TCreate, TUpdate>`), `fromList` (`LdCallbackModel<L, IdType>` → `LdCallbackModel<L, IdType, L, L>`)
- 🔄 Type parameters changed: `L extends Identifiable<IdType>, IdType` → `L extends Identifiable<IdType>, IdType, TCreate, TUpdate`
- 🔄 Param type changed in method `greedy`: `updateItem` (`Future<L?> Function(BuildContext, IdType, L)?` → `Future<L?> Function(BuildContext, IdType, TUpdate)?`), `createItem` (`Future<L> Function(BuildContext, L?)?` → `Future<L> Function(BuildContext, TCreate)?`), `updateBatch` (`Future<void> Function(BuildContext, Map<IdType, L>)?` → `Future<void> Function(BuildContext, Map<IdType, TUpdate>)?`)

**`class` LdCounter** ([lib/src/counter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-56493e7e7233aac1f95d625ed446d310fe0305379c2e1b4429cd8bc3083c6a4d))
- 🔄 Superclass changed: `StatelessWidget` → `StatefulWidget`
- ❌ Constructors removed: `s`, `l`, `xs`
- ❌ Properties removed: `size`, `type`
- ❌ Method removed: `build`

**`class` LdListController<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/data/list_controller.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-2bd19515e63ce2d64323e30fa8b37fd3ca7fac879e8a0089508961972dcadd7c))
- ❌ Param removed in method `reorder`: `reorderHandler` (named, required)
- ❇️ Param added in method `reorder`: `activeSortOption` (named, required)

**`class` LdMonkeyAppBar<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_app_bar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-1ed77dea165bf61117ba5c39537c923f703bf59c28964a4507ccb301fab79a69))
- ❌ Property removed: `additionalActions`

**`class` LdMonkeyDetailPage<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/detail_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-43d347b03da89e053d770a97150585d0955be32f82540fad5d2ceabd18d33035))
- ❌ Class removed: `LdMonkeyDetailPage`

**`class` LdMonkeyMasterPage<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_master_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-f027b9824ac3c8ae9ddbe6ac353d6cb02c90fe60d3a5d83846b29dbd7ec3c437))
- ❌ Properties removed: `primaryAppBarConfig`, `secondaryAppBarConfig`, `primaryAppBarAdditionalActions`

**`typedef` LdMonkeyReorderHandler<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/ld_monkey_route_definitions.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-364343882a673b5e43d5b6a63b8591f2a9554237699a63d5006bd8bbab610c03))
- ❌ Typedef removed: `LdMonkeyReorderHandler`

**`class` LdMonkeyRouteScope<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_route_scope.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-00b40f9e0517eb15a03249100eaf69b7c20db14e2b2ec72a032292e923048ac2))
- ❌ Property removed: `reorderHandler`

**`class` LdMonkeyScrollableDetailView<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_scrollable_detail_view.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-9400e0cdd55f75ba32cf7749184743cc74a59ce66cb9219b4dd01bcf26064b95))
- ❌ Class removed: `LdMonkeyScrollableDetailView`

**`class` LdMonkeyStackDetailView<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_stack_detail_view.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-859c21b7002de70c6a448c5f9c3ce24edf467197f6ef2bca6c7362c436bf9679))
- ❌ Class removed: `LdMonkeyStackDetailView`

**`class` LdMonkeyStreamSelection<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/detail_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-43d347b03da89e053d770a97150585d0955be32f82540fad5d2ceabd18d33035))
- ❌ Class removed: `LdMonkeyStreamSelection`

**`class` MonkeyRouteNode<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_route_tree.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-5ee5971433b226f5666f1c6e2da4cdd4b73a3416065519e97a778a01e3fae04d))
- ❌ Property removed: `reorderHandler`

**`class` _LdCounterDigit** ([lib/src/counter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-56493e7e7233aac1f95d625ed446d310fe0305379c2e1b4429cd8bc3083c6a4d))
- ❌ Params removed in default constructor: `size` (named, required), `type` (named, required)
- ❇️ Param added in default constructor: `style` (named, required)

**`class` _LdCounterState** ([lib/src/counter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-56493e7e7233aac1f95d625ed446d310fe0305379c2e1b4429cd8bc3083c6a4d))
- 🔄 Param type changed in method `didUpdateWidget`: `oldWidget` (`_LdCounterWidget` → `LdCounter`)

**`class` _LdMonkeyViewingItemLoader<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/detail_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-43d347b03da89e053d770a97150585d0955be32f82540fad5d2ceabd18d33035))
- ❌ Params removed in default constructor: `id` (named, required), `buildItem` (named, required)
- ❇️ Params added in default constructor: `ids` (named, required), `builder` (named, required)

**`class` _LdSliderHandle** ([lib/src/value_slider.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-7547e7e705402d81a528691826a522e6f9f4d8483b3f74be559aa653090961c8))
- ❌ Param removed in default constructor: `tooltipKey` (named, required)
- ❇️ Param added in default constructor: `showTooltip` (named, required)

**`function` ldConfirmModal** ([lib/src/modal/utils.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-f01b6f5832f5bdf2f5a51ef00d415aedca5a29c465181b1e02d5a123527e80e6))
- 🔄 Function type changed: `ldConfirmModal` (`Future<bool>` → `Future<bool?>`)

**`function` ldFormConfirmDiscardEdits** ([lib/src/monkey/detail_editor/ld_monkey_discard_confirm.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-15feafebb4126ecc6852f9b263ff15be62e2881e931ac652a9d56061674155d9))
- 🔄 Function type changed: `ldFormConfirmDiscardEdits` (`Future<bool>` → `Future<bool?>`)

#### ✨ Minor changes

**`class` AppBarFrame** ([lib/src/appbar/appbar_frame.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-f5dae86f88f57d7eacd239b0beba44a7a95e301f01ff1dd11b53d1ec43864c92))
- ❇️ Class added: `AppBarFrame`

**`extension` DoubleToEdgeInsets** ([lib/src/appbar/appbar_frame.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-f5dae86f88f57d7eacd239b0beba44a7a95e301f01ff1dd11b53d1ec43864c92))
- ❇️ Extension added: `DoubleToEdgeInsets`

**`class` LdAppBar** ([lib/src/appbar/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-3fa4ae735c9f6ca4c26ac958e08eaa30e2da735b6e0f0ed00665eb6c2b2bb49f))
- ❇️ Constructor added: `fromConfig`

**`class` LdAppBarConfig** ([lib/src/appbar/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-3fa4ae735c9f6ca4c26ac958e08eaa30e2da735b6e0f0ed00665eb6c2b2bb49f))
- ❇️ Methods added: `copyWith`, `merge`

**`extension` LdAppBarScrollBehaviorExtension** ([lib/src/scaffold.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-35c580af7b94cd13fc78765d9afc1f836ec439643e1a61922b4b6c7a0614553d))
- ❇️ Extension added: `LdAppBarScrollBehaviorExtension`

**`class` LdAvatar** ([lib/src/avatar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-e142afc5a4b71ea7f96a73a1f1b6ac035d2721395f0b2905b345fc22ff602458))
- ❇️ Constructor added: `fromConfig`

**`class` LdAvatarConfig** ([lib/src/avatar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-e142afc5a4b71ea7f96a73a1f1b6ac035d2721395f0b2905b345fc22ff602458))
- ❇️ Methods added: `copyWith`, `merge`

**`class` LdButton** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- ❇️ Constructor added: `fromConfig`

**`class` LdButtonConfig** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- ❇️ Methods added: `copyWith`, `merge`

**`class` LdCallbackModel<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/data/ld_callback_model.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-bbe6dccbaff1f85db929a2244aa1272b485ea8ef19047f4e87871d9a0c49ee84))
- ❇️ Param added in default constructor: `reorderItem` (named, optional)
- ❇️ Properties added: `supportsReorder`, `reorderItem`
- ❇️ Param added in method `greedy`: `reorderItem` (named, optional)
- ❇️ Method added: `persistReorder`

**`class` LdCheckbox** ([lib/src/checkbox.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-212494581d361b843cfc944c41577dc67246a6cfcd3adcc6c8732ec7791c2599))
- ❇️ Constructor added: `fromConfig`

**`class` LdCheckboxConfig** ([lib/src/checkbox.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-212494581d361b843cfc944c41577dc67246a6cfcd3adcc6c8732ec7791c2599))
- ❇️ Methods added: `copyWith`, `merge`

**`class` LdCounter** ([lib/src/counter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-56493e7e7233aac1f95d625ed446d310fe0305379c2e1b4429cd8bc3083c6a4d))
- ❌ Params removed in default constructor: `size` (named, optional, default: LdSize.m), `type` (named, optional, default: LdTextType.headline)
- ❇️ Param added in default constructor: `style` (named, optional)
- ❇️ Property added: `style`
- ❇️ Method added: `createState`

**`class` LdDatePickerModal** ([lib/src/date_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-705cf9a7b3b5d494795266f0d9bd90767b033dd2dc19f3eee04d709951be9dd7))
- ❇️ Class added: `LdDatePickerModal`

**`class` LdInput** ([lib/src/input.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-2ffc2d5e6008b31f35c68f6ed0d27138168bf19c95df7c0aab8349787a9a5ef6))
- ❇️ Param added in default constructor: `padding` (named, optional)
- ❇️ Property added: `padding`

**`class` LdList<T extends Identifiable<IdType>, IdType>** ([lib/src/list/list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-888f80c71ddeacb424418138bd38d5900a4ffe694069cba2af68eb89e66a4a41))
- ❇️ Constructor added: `fromConfig`

**`class` LdListConfig<T extends Identifiable<IdType>, IdType>** ([lib/src/list/list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-888f80c71ddeacb424418138bd38d5900a4ffe694069cba2af68eb89e66a4a41))
- ❇️ Methods added: `copyWith`, `merge`

**`class` LdListItem** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- ❇️ Constructor added: `fromConfig`

**`class` LdListItemConfig** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- ❇️ Methods added: `copyWith`, `merge`

**`class` LdMetaball** ([lib/src/metaball/metaball.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-3f44f81d32a4f6357495811a0ef11ac4b71c58f40a155f27cc5a848a6665677c))
- ❇️ Param added in default constructor: `force` (named, optional, default: 1.0)
- ❇️ Property added: `force`

**`class` LdMetaballBlob** ([lib/src/metaball/metaball_blob.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-5ab2bf79286f1500aa73f06dd57d5ad8636233eea68369fb92fbd871d2758d15))
- ❇️ Param added in default constructor: `force` (named, optional, default: 1.0)
- ❇️ Property added: `force`
- ❇️ Param added in method `copyWith`: `force` (named, optional)

**`class` LdModel<T extends Identifiable<IdType>, IdType, TCreate, TUpdate>** ([lib/src/monkey/data/ld_model.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-44449e404af55a988303764c787a8c8f8f96d93a74e10ed133ffd7252d0b2f68))
- ❇️ Property added: `supportsReorder`
- ❇️ Method added: `persistReorder`

**`class` LdMonkeyAppBar<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_app_bar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-1ed77dea165bf61117ba5c39537c923f703bf59c28964a4507ccb301fab79a69))
- ❌ Param removed in default constructor: `additionalActions` (named, optional, default: const [])
- ❇️ Param added in default constructor: `config` (named, optional)
- ❇️ Property added: `config`

**`class` LdMonkeyAppbarConfig** ([lib/src/monkey/monkey_app_bar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-1ed77dea165bf61117ba5c39537c923f703bf59c28964a4507ccb301fab79a69))
- ❇️ Class added: `LdMonkeyAppbarConfig`

**`class` LdMonkeyDetailAppBars<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/detail_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-43d347b03da89e053d770a97150585d0955be32f82540fad5d2ceabd18d33035))
- ❇️ Class added: `LdMonkeyDetailAppBars`

**`class` LdMonkeyDetailAppbarConfig** ([lib/src/monkey/monkey_app_bar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-1ed77dea165bf61117ba5c39537c923f703bf59c28964a4507ccb301fab79a69))
- ❇️ Class added: `LdMonkeyDetailAppbarConfig`

**`class` LdMonkeyDetailSecondaryAppbarConfig** ([lib/src/monkey/monkey_app_bar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-1ed77dea165bf61117ba5c39537c923f703bf59c28964a4507ccb301fab79a69))
- ❇️ Class added: `LdMonkeyDetailSecondaryAppbarConfig`

**`class` LdMonkeyMasterAppbarConfig** ([lib/src/monkey/monkey_app_bar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-1ed77dea165bf61117ba5c39537c923f703bf59c28964a4507ccb301fab79a69))
- ❇️ Class added: `LdMonkeyMasterAppbarConfig`

**`class` LdMonkeyMasterPage<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_master_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-f027b9824ac3c8ae9ddbe6ac353d6cb02c90fe60d3a5d83846b29dbd7ec3c437))
- ❌ Params removed in default constructor: `primaryAppBarConfig` (named, optional), `primaryAppBarAdditionalActions` (named, optional, default: const []), `secondaryAppBarConfig` (named, optional)

**`class` LdMonkeyMasterSecondaryAppbarConfig** ([lib/src/monkey/monkey_app_bar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-1ed77dea165bf61117ba5c39537c923f703bf59c28964a4507ccb301fab79a69))
- ❇️ Class added: `LdMonkeyMasterSecondaryAppbarConfig`

**`class` LdMonkeyRouteScope<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_route_scope.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-00b40f9e0517eb15a03249100eaf69b7c20db14e2b2ec72a032292e923048ac2))
- ❌ Param removed in default constructor: `reorderHandler` (named, optional)

**`class` LdMonkeyScrollableDetailPage<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/detail_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-43d347b03da89e053d770a97150585d0955be32f82540fad5d2ceabd18d33035))
- ❇️ Class added: `LdMonkeyScrollableDetailPage`

**`class` LdMonkeySingleDetailPage<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/detail_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-43d347b03da89e053d770a97150585d0955be32f82540fad5d2ceabd18d33035))
- ❇️ Class added: `LdMonkeySingleDetailPage`

**`class` LdMonkeyViewingBuilder<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/detail_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-43d347b03da89e053d770a97150585d0955be32f82540fad5d2ceabd18d33035))
- ❇️ Class added: `LdMonkeyViewingBuilder`

**`class` LdNavigationRail** ([lib/src/drawer/navigation_rail.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-ae15dbf15eda67eeb99ea919631bf112402b32bb38f056e675abfe15ef628ae3))
- ❇️ Class added: `LdNavigationRail`

**`class` LdNavigationTab** ([lib/src/appbar/tab_navigation.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-52bf35196752849d0d45f783bb5b24e4217e93ef2ae5ff75caafe39bc5b551fc))
- ❇️ Method added: `matches`

**`typedef` LdReorderItemCallback<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/data/ld_callback_model.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-bbe6dccbaff1f85db929a2244aa1272b485ea8ef19047f4e87871d9a0c49ee84))
- ❇️ Typedef added: `LdReorderItemCallback`

**`class` LdRunnerStep** ([lib/src/runner.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-6b567e02a0af50b04f70212b6f0e9f870e0ed5de80b85853890572d0a7493947))
- ❇️ Param added in default constructor: `childrenLeftPadding` (named, optional, default: 32)
- ❇️ Property added: `childrenLeftPadding`

**`class` LdScaffold** ([lib/src/scaffold.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-35c580af7b94cd13fc78765d9afc1f836ec439643e1a61922b4b6c7a0614553d))
- ❇️ Param added in default constructor: `drawerMinWidth` (named, optional, default: 200)
- ❇️ Property added: `drawerMinWidth`

**`class` LdScaffoldBody** ([lib/src/scaffold_body.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-25fd66a644218adca4f46a542b28e361a2aea16ff32c8a2def5a1819cf1c507b))
- ❇️ Params added in default constructor: `reverse` (named, optional, default: false), `itemBuilder` (named, optional), `itemCount` (named, optional), `findChildIndexCallback` (named, optional)
- ❇️ Properties added: `reverse`, `itemBuilder`, `itemCount`, `findChildIndexCallback`

**`class` LdSlider** ([lib/src/value_slider.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-7547e7e705402d81a528691826a522e6f9f4d8483b3f74be559aa653090961c8))
- ❇️ Params added in default constructor: `onChangeEnd` (named, optional), `valueFormatter` (named, optional)
- ❇️ Params added in constructor `range`: `onRangeChangeEnd` (named, optional), `valueFormatter` (named, optional)
- ❇️ Properties added: `onChangeEnd`, `onRangeChangeEnd`, `valueFormatter`

**`class` LdSwitch<T>** ([lib/src/switch.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-d8b30ecf078361f71ed29b6fb0755c25a0bb96217a1fbb7ba1593d825db75278))
- ❇️ Property added: `activeIndex`

**`class` LdTheme** ([lib/src/theme/theme.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-e230b3066fca6361167b035927f3d5e83cda9a34212c86e2a307ed82bcf0d99e))
- ❇️ Methods added: `controlContentPadding`, `controlHeight`

**`class` LdThemeProvider** ([lib/src/theme/theme_provider.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-bb56e3df14103825a8edc59aa7689986b2bface5596870727b1ab28297f86e57))
- ❇️ Param added in default constructor: `applyWindowDecoration` (named, optional, default: true)
- ❇️ Property added: `applyWindowDecoration`

**`class` MonkeyRouteNode<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_route_tree.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-5ee5971433b226f5666f1c6e2da4cdd4b73a3416065519e97a778a01e3fae04d))
- ❌ Param removed in default constructor: `reorderHandler` (named, optional)

**`function` buildMonkeyRoutes<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_routes.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-5dd41942d7588e4b4e14333a7153952c923f9bc1226bae8302adcf3f9c97ce29))
- ❌ Param removed in function `buildMonkeyRoutes`: `reorderHandler` (named, optional)

**`function` ldAppBarFocusScopeHasInputFocus** ([lib/src/appbar/appbar_frame.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-f5dae86f88f57d7eacd239b0beba44a7a95e301f01ff1dd11b53d1ec43864c92))
- ❇️ Function added: `ldAppBarFocusScopeHasInputFocus`

**`function` neutralGhostColor** ([lib/src/touchable/neutral_ghost_color.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-c649ec6954b3fe7588b76fee551739c41c9bd5bd9e43a26f232992bdb3ea7155))
- ❇️ Function added: `neutralGhostColor`

#### 👀 Patch changes

**`class` LdSubmitController<T, Arg>** ([lib/src/submit/model/submit_controller.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-d921dcc848cbe3ce44f849c2be50e41f4300cb5bddb83fe2c189bea7f63c8f34))
- ❇️ Properties added: `_generation`, `_debugLabel`
- ❇️ Methods added: `_logDebug`, `_isCurrentGeneration`, `_invalidateInFlight`

**`class` LdSwitch<T>** ([lib/src/switch.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-d8b30ecf078361f71ed29b6fb0755c25a0bb96217a1fbb7ba1593d825db75278))
- 🔄 Method type changed: `_buildItem` (`Widget` → `List<Widget>`)

**`class` _AppBarFrameState** ([lib/src/appbar/appbar_frame.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-f5dae86f88f57d7eacd239b0beba44a7a95e301f01ff1dd11b53d1ec43864c92))
- ❇️ Class added: `_AppBarFrameState`

**`class` _ButtonShape** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- ❌ Property removed: `_circularSizeBump`

**`class` _DatePickerSheet** ([lib/src/date_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-705cf9a7b3b5d494795266f0d9bd90767b033dd2dc19f3eee04d709951be9dd7))
- ❌ Class removed: `_DatePickerSheet`

**`class` _DatePickerSheetState** ([lib/src/date_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-705cf9a7b3b5d494795266f0d9bd90767b033dd2dc19f3eee04d709951be9dd7))
- ❌ Class removed: `_DatePickerSheetState`

**`class` _EmojiRaster** ([lib/src/emoji/emoji.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-77393bdc4901284c6ae0f3f5f7e5bd729c7c49b04576988888bfc893f13ff49d))
- ❇️ Class added: `_EmojiRaster`

**`class` _LdCounterDigit** ([lib/src/counter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-56493e7e7233aac1f95d625ed446d310fe0305379c2e1b4429cd8bc3083c6a4d))
- ❌ Properties removed: `size`, `type`
- ❇️ Property added: `style`

**`class` _LdCounterState** ([lib/src/counter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-56493e7e7233aac1f95d625ed446d310fe0305379c2e1b4429cd8bc3083c6a4d))
- ❇️ Method added: `_getStyle`

**`class` _LdCounterWidget** ([lib/src/counter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-56493e7e7233aac1f95d625ed446d310fe0305379c2e1b4429cd8bc3083c6a4d))
- ❌ Class removed: `_LdCounterWidget`

**`class` _LdDatePickerModalState** ([lib/src/date_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-705cf9a7b3b5d494795266f0d9bd90767b033dd2dc19f3eee04d709951be9dd7))
- ❇️ Class added: `_LdDatePickerModalState`

**`class` _LdDatePickerState** ([lib/src/date_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-705cf9a7b3b5d494795266f0d9bd90767b033dd2dc19f3eee04d709951be9dd7))
- ❌ Property removed: `_selectedDateNotifier`

**`class` _LdEmojiState** ([lib/src/emoji.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-1b3026d5bb3ce997167aa7c05fd472dae31ca624a851db5fe87322766ca879da))
- ❌ Property removed: `_offset`
- ❇️ Property added: `_raster`
- ❌ Method removed: `_compute`

**`class` _LdInputState** ([lib/src/input.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-2ffc2d5e6008b31f35c68f6ed0d27138168bf19c95df7c0aab8349787a9a5ef6))
- ❌ Property removed: `_shortcutBindings`
- ❇️ Property added: `_isMultiline`
- ❇️ Methods added: `_submitFromKeyboard`, `_insertNewline`, `_shouldSubmitOnEnter`, `_shortcutBindings`

**`class` _LdMonkeyViewingItemLoader<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/detail_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-43d347b03da89e053d770a97150585d0955be32f82540fad5d2ceabd18d33035))
- ❌ Properties removed: `id`, `buildItem`
- ❇️ Properties added: `ids`, `builder`

**`class` _LdMonkeyViewingItemSubmitBuilder<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/detail_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-43d347b03da89e053d770a97150585d0955be32f82540fad5d2ceabd18d33035))
- ❌ Class removed: `_LdMonkeyViewingItemSubmitBuilder`

**`class` _LdNavigationRailDestination** ([lib/src/drawer/navigation_rail.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-ae15dbf15eda67eeb99ea919631bf112402b32bb38f056e675abfe15ef628ae3))
- ❇️ Class added: `_LdNavigationRailDestination`

**`class` _LdSliderHandle** ([lib/src/value_slider.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-7547e7e705402d81a528691826a522e6f9f4d8483b3f74be559aa653090961c8))
- ❌ Property removed: `tooltipKey`
- ❇️ Property added: `showTooltip`

**`class` _LdSliderHandleState** ([lib/src/value_slider.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-7547e7e705402d81a528691826a522e6f9f4d8483b3f74be559aa653090961c8))
- ➖ Method annotation removed: `didUpdateWidget` (@override)
- ➕ Methods annotation added: `didUpdateWidget` (@mustCallSuper), `didUpdateWidget` (@protected)

**`class` _LdSliderState** ([lib/src/value_slider.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-7547e7e705402d81a528691826a522e6f9f4d8483b3f74be559aa653090961c8))
- ❌ Properties removed: `_lowTooltipKey`, `_highTooltipKey`

**`meta` pubspec.yaml** ([pubspec.yaml](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-8b7e9df87668ffa6a04b32e1769a33434999e54ae081c52e5d943c541d4c0d25))
- 📦 Added `args`: with version `^2.4.0`
- 📦 Added `path`: with version `^1.9.0`

**`function` _analysisFontSize** ([lib/src/emoji/emoji.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-77393bdc4901284c6ae0f3f5f7e5bd729c7c49b04576988888bfc893f13ff49d))
- ❇️ Function added: `_analysisFontSize`

**`function` _computeTranslation** ([lib/src/emoji.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-1b3026d5bb3ce997167aa7c05fd472dae31ca624a851db5fe87322766ca879da))
- ❌ Function removed: `_computeTranslation`

**`function` _cropImage** ([lib/src/emoji/emoji.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-77393bdc4901284c6ae0f3f5f7e5bd729c7c49b04576988888bfc893f13ff49d))
- ❇️ Function added: `_cropImage`

**`function` _findDeepestPoppableShell** ([lib/src/appbar/implied/back_button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-7e1d936bdce32148d727491647951c9dc105fdf48f2514a06d608a2d213355b0))
- ❇️ Function added: `_findDeepestPoppableShell`

**`function` _getOrCompute** ([lib/src/emoji.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-1b3026d5bb3ce997167aa7c05fd472dae31ca624a851db5fe87322766ca879da))
- 🔄 Function type changed: `_getOrCompute` (`Future<Offset>` → `Future<_EmojiRaster>`)
- 🔄 Param type changed in function `_getOrCompute`: `compute` (`Future<Offset> Function()` → `Future<_EmojiRaster> Function()`)

**`function` _popShellMatch** ([lib/src/appbar/implied/back_button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-7e1d936bdce32148d727491647951c9dc105fdf48f2514a06d608a2d213355b0))
- ❇️ Function added: `_popShellMatch`

**`function` _rasterizeEmoji** ([lib/src/emoji/emoji.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-77393bdc4901284c6ae0f3f5f7e5bd729c7c49b04576988888bfc893f13ff49d))
- ❇️ Function added: `_rasterizeEmoji`

**`function` _renderEmoji** ([lib/src/emoji.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-8..liquid_flutter/v23.0.0-9#diff-1b3026d5bb3ce997167aa7c05fd472dae31ca624a851db5fe87322766ca879da))
- ❌ Function removed: `_renderEmoji`

## 23.0.0-8
Released on: 7/10/2026, changelog automatically generated.


### Bug Fixes

- use gesture detector for touchables again, but disable double tap on app bars since it adds touch delays. ([bf9d097](commit/bf9d097))
- **touchable:** extract trackPan flag; honour hitTestBehavior in non-trackPan path ([bd921b6](commit/bd921b6))
- **list:** remove spurious border on LdListItemLoading; fix timer leak in LdSlidableListItem; restrict marquee drag to mouse ([a3aadf7](commit/a3aadf7))
- **selectable_list:** move child argument last in GestureDetector (sort_child_properties_last) ([c8745a5](commit/c8745a5))
### Features

- linked list choose ([74f8aa3](commit/74f8aa3))

### API Changes

#### 💣 Breaking changes

**`class` LdListItemWidget** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- 🔄 Superclass changed: `StatelessWidget` → `StatefulWidget`
- ❌ Method removed: `build`

**`class` LdMetaball** ([lib/src/metaball/metaball.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-3f44f81d32a4f6357495811a0ef11ac4b71c58f40a155f27cc5a848a6665677c))
- ❌ Params removed in default constructor: `children` (named, required), `surfaceColor` (named, required), `borderColor` (named, required)
- ❇️ Param added in default constructor: `child` (named, required)
- ❌ Properties removed: `children`, `blend`, `surfaceColor`, `borderColor`, `borderWidth`, `interactive`

**`class` LdMetaballChild** ([lib/src/metaball/metaball.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-3f44f81d32a4f6357495811a0ef11ac4b71c58f40a155f27cc5a848a6665677c))
- ❌ Class removed: `LdMetaballChild`

**`class` LdMetaballMask** ([lib/src/metaball/metaball_mask.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-6f3c60daed9da62bd711d1411765f7c1b19493924f4b32ca88db0c1436df7b09))
- 🔄 Param type changed in default constructor: `borderShader` (`FragmentShader` → `FragmentShader?`), `borderColor` (`Color` → `Color?`)
- 🔄 Properties type changed: `borderShader`, `borderColor`

**`class` LdMetaballMaskScoped** ([lib/src/metaball/metaball_mask.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-6f3c60daed9da62bd711d1411765f7c1b19493924f4b32ca88db0c1436df7b09))
- ❌ Class removed: `LdMetaballMaskScoped`

**`class` LdMetaballShaderScope** ([lib/src/metaball/metaball_shader_scope.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-36d3e099d8e35fd786b1d1cfc58ced2cf2ed02ef582778d4961e245a39b3dca4))
- ❌ Class removed: `LdMetaballShaderScope`

**`class` LdMetaballShaders** ([lib/src/metaball/metaball_shader_scope.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-36d3e099d8e35fd786b1d1cfc58ced2cf2ed02ef582778d4961e245a39b3dca4))
- ❌ Class removed: `LdMetaballShaders`

#### ✨ Minor changes

**`class` LdChooseLinkedListTrigger<T extends Identifiable<IdType>, IdType>** ([lib/src/choose/choose_linked_list_trigger.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-07d8676c2fbefeb0ecd9af3e80fa5f8c81a03e1c74e8056bd5d121edb90c55ee))
- ❇️ Class added: `LdChooseLinkedListTrigger`

**`class` LdChooseTriggerConfig<T extends Identifiable<IdType>, IdType>** ([lib/src/choose/choose.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-6ce965d70e5a38c7bb7d300718c981f5dd5c18807dcaf9b633cdc74c1d5c5c74))
- ❇️ Params added in default constructor: `onRemoveItem` (named, optional), `allowEmpty` (named, optional, default: false)
- ❇️ Properties added: `onRemoveItem`, `allowEmpty`

**`class` LdExceptionView** ([lib/src/exception/exception_view.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-3b9caa32d813b4accee332539fa3d1e44ecc015a406dd715143f70a5e7c96088))
- ❇️ Param added in default constructor: `showIndicator` (named, optional, default: true)
- ❇️ Property added: `showIndicator`

**`class` LdListItem** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- ❇️ Param added in default constructor: `shadow` (named, optional)
- ❇️ Param added in constructor `trailingForward`: `shadow` (named, optional)
- ❇️ Property added: `shadow`

**`class` LdListItemConfig** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- ❇️ Param added in default constructor: `shadow` (named, optional)
- ❇️ Property added: `shadow`

**`class` LdListItemWidget** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- ❇️ Param added in default constructor: `shadow` (named, optional)
- ❇️ Property added: `shadow`
- ❇️ Method added: `createState`

**`class` LdMetaball** ([lib/src/metaball/metaball.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-3f44f81d32a4f6357495811a0ef11ac4b71c58f40a155f27cc5a848a6665677c))
- ❌ Params removed in default constructor: `blend` (named, optional, default: 40), `borderWidth` (named, optional, default: 1), `interactive` (named, optional, default: true)
- ❇️ Params added in default constructor: `shape` (named, optional, default: LdMetaballShape.roundedRect), `cornerRadius` (named, optional, default: 16)
- ❇️ Properties added: `child`, `shape`, `cornerRadius`

**`class` LdMetaballMask** ([lib/src/metaball/metaball_mask.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-6f3c60daed9da62bd711d1411765f7c1b19493924f4b32ca88db0c1436df7b09))
- ✅ Params became optional in default constructor: `borderShader` (named, required), `borderColor` (named, required)
- ❌ Param removed in method `setUniforms`: `expand` (named, optional, default: 0)
- ❇️ Methods added: `setFillUniforms`, `setBorderUniforms`

**`class` LdMetaballScope** ([lib/src/metaball/metaball.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-3f44f81d32a4f6357495811a0ef11ac4b71c58f40a155f27cc5a848a6665677c))
- ❇️ Class added: `LdMetaballScope`

**`class` LdSlidableListItem** ([lib/src/list/slidable_list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-fcb34fc43152cea4985180d7f43b5d8266ca996e5bb0ce02005764e0bfb7ebc9))
- ❇️ Param added in default constructor: `initialPeek` (named, optional, default: true)
- ❇️ Property added: `initialPeek`

**`class` LdTheme** ([lib/src/theme/theme.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-e230b3066fca6361167b035927f3d5e83cda9a34212c86e2a307ed82bcf0d99e))
- ❇️ Properties added: `monoFontFamily`, `monoFontFamilyPackage`

**`class` LdTouchableSurface** ([lib/src/touchable/touchable.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-390c2ec1e7b0ebec409f605c4cdc4ea7ef337cf7876bdca7a87de6f2c647ea96))
- ❇️ Param added in default constructor: `trackPan` (named, optional, default: false)
- ❇️ Property added: `trackPan`

**`function` ldButtonCircularPreview** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- ❇️ Function added: `ldButtonCircularPreview`

**`function` ldButtonDisabledPreview** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- ❇️ Function added: `ldButtonDisabledPreview`

**`function` ldButtonFilledPreview** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- ❇️ Function added: `ldButtonFilledPreview`

**`function` ldButtonGhostPreview** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- ❇️ Function added: `ldButtonGhostPreview`

**`function` ldButtonLeadingPreview** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- ❇️ Function added: `ldButtonLeadingPreview`

**`function` ldButtonOutlinePreview** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- ❇️ Function added: `ldButtonOutlinePreview`

**`function` ldHintPreview** ([lib/src/hint.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-dfc92525de9815f786b74d0fb4e4a920602109f9db1ffe185778ade2d4295570))
- ❇️ Function added: `ldHintPreview`

**`function` ldHintWithBackgroundPreview** ([lib/src/hint.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-dfc92525de9815f786b74d0fb4e4a920602109f9db1ffe185778ade2d4295570))
- ❇️ Function added: `ldHintWithBackgroundPreview`

#### 👀 Patch changes

**`class` LdListItemWidget** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- ❌ Methods removed: `_buildSelectionControls`, `_buildIconTheme`, `_buildLeading`, `_buildTrailing`, `_buildTitle`, `_buildSubtitle`, `_buildSubContent`

**`class` LdMetaballMask** ([lib/src/metaball/metaball_mask.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-6f3c60daed9da62bd711d1411765f7c1b19493924f4b32ca88db0c1436df7b09))
- ❌ Method removed: `_maskedLayer`
- ❇️ Method added: `_writeCommon`

**`class` LdTheme** ([lib/src/theme/theme.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-e230b3066fca6361167b035927f3d5e83cda9a34212c86e2a307ed82bcf0d99e))
- ❇️ Properties added: `_monoFontFamily`, `_monoFontFamilyPackage`

**`class` _LdListItemWidgetState** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- ❇️ Class added: `_LdListItemWidgetState`

**`class` _LdMetaballScopeData** ([lib/src/metaball/metaball.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-3f44f81d32a4f6357495811a0ef11ac4b71c58f40a155f27cc5a848a6665677c))
- ❇️ Class added: `_LdMetaballScopeData`

**`class` _LdMetaballScopeState** ([lib/src/metaball/metaball.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-3f44f81d32a4f6357495811a0ef11ac4b71c58f40a155f27cc5a848a6665677c))
- ❇️ Class added: `_LdMetaballScopeState`

**`class` _LdMetaballShaderData** ([lib/src/metaball/metaball_shader_scope.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-36d3e099d8e35fd786b1d1cfc58ced2cf2ed02ef582778d4961e245a39b3dca4))
- ❌ Class removed: `_LdMetaballShaderData`

**`class` _LdMetaballShaderScopeState** ([lib/src/metaball/metaball_shader_scope.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-36d3e099d8e35fd786b1d1cfc58ced2cf2ed02ef582778d4961e245a39b3dca4))
- ❌ Class removed: `_LdMetaballShaderScopeState`

**`class` _LdMetaballState** ([lib/src/metaball/metaball.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-3f44f81d32a4f6357495811a0ef11ac4b71c58f40a155f27cc5a848a6665677c))
- ➖ Mixin removed: SingleTickerProviderStateMixin
- ❌ Properties removed: `_ticker`, `_tickerModeNotifier`, `_fill`, `_border`, `_ownedShaders`, `_children`, `_blobs`, `_pointerPos`, `_pointerDown`, `_radiusSpring`, `_radiusPeak`, `_radiusRest`, `_radiusOff`, `_bounceTimer`, `_lastTick`
- ❇️ Properties added: `_key`, `_scope`
- ➖ Methods annotation removed: `activate` (@override), `debugFillProperties` (@override)
- ➕ Methods annotation added: `activate` (@protected), `activate` (@mustCallSuper), `debugFillProperties` (@protected), `debugFillProperties` (@mustCallSuper)
- ❌ Methods removed: `createTicker`, `_updateTicker`, `_updateTickerModeNotifier`, `_rebuildChildren`, `_tryBorrowShaders`, `_loadOwnShaders`, `_onTick`, `_measureBlobs`, `_blobListEqual`, `_onPointerDown`, `_onPointerMove`, `_onPointerUp`
- ❇️ Method added: `_measure`

**`class` _LdSlidableGroupState** ([lib/src/list/slidable_list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-fcb34fc43152cea4985180d7f43b5d8266ca996e5bb0ce02005764e0bfb7ebc9))
- ❇️ Property added: `_hintClaimed`
- ❇️ Method added: `claimHint`

**`class` _LdSlidableListItemState** ([lib/src/list/slidable_list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-fcb34fc43152cea4985180d7f43b5d8266ca996e5bb0ce02005764e0bfb7ebc9))
- ❌ Properties removed: `_animationStart`, `_animationEnd`, `_isAnimating`, `_animationKey`
- ❇️ Properties added: `_peekDelay`, `_peekDuration`, `_peekCompleted`, `_peekRunning`, `_peekDelayTimer`, `_peekDurationTimer`, `_contextMenuKey`
- ➖ Methods annotation removed: `initState` (@protected), `initState` (@mustCallSuper), `didUpdateWidget` (@mustCallSuper), `didUpdateWidget` (@protected)
- ➕ Methods annotation added: `initState` (@override), `didUpdateWidget` (@override)
- ❇️ Methods added: `_maybeRunPeek`, `_handleSecondaryTapDown`

**`class` _LdSubmitDialogState<T, Arg>** ([lib/src/submit/builders/dialog_builder.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-667617a61b037cae73c86a02fac20c0c80283ad8dc680535c250ada7f9ae994a))
- ➖ Methods annotation removed: `didChangeDependencies` (@protected), `didChangeDependencies` (@mustCallSuper)
- ➕ Method annotation added: `didChangeDependencies` (@override)
- ❌ Methods removed: `buildLoadingDialog`, `buildErrorDialog`
- ❇️ Method added: `buildDialog`

**`class` _LdTouchableSurfaceState** ([lib/src/touchable/touchable.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-390c2ec1e7b0ebec409f605c4cdc4ea7ef337cf7876bdca7a87de6f2c647ea96))
- ❌ Property removed: `_pointerDownOffset`
- ❇️ Method added: `_buildGestureLayer`

**`class` _MetaballBorderPainter** ([lib/src/metaball/metaball_mask.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-6f3c60daed9da62bd711d1411765f7c1b19493924f4b32ca88db0c1436df7b09))
- ❇️ Class added: `_MetaballBorderPainter`

**`class` _MetaballChild** ([lib/src/metaball/metaball.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-7..liquid_flutter/v23.0.0-8#diff-3f44f81d32a4f6357495811a0ef11ac4b71c58f40a155f27cc5a848a6665677c))
- ❌ Class removed: `_MetaballChild`

## 23.0.0-7
Released on: 7/7/2026, changelog automatically generated.


### Bug Fixes

- remove shaders/ from assets section in liquid_flutter pubspec ([152e4ea](commit/152e4ea))
- resolve --fatal-infos analyzer warnings across packages ([dcabf46](commit/dcabf46))
- update reactive forms tests to match current API ([af496a7](commit/af496a7))
- minor appbar issues, and adjust sizing slightly ([42c8fbc](commit/42c8fbc))
- **tests:** fix all failing tests across liquid_flutter package ([13572f3](commit/13572f3))
- **tests:** fix reactive-forms test failures and regenerate golden trees ([eec4716](commit/eec4716))
### Features

- add Tab + PageView component and update routing for new demo ([fb02cab](commit/fb02cab))
- add new skills for Liquid Flutter including EMD theme, Markdown rendering, reactive forms, and window utilities ([7c5aae1](commit/7c5aae1))
- emoji pickers, markdown editor, refactor details forms etc. ([7dc69bd](commit/7dc69bd))

### API Changes

#### 💣 Breaking changes

**`class` LdAvatar** ([lib/src/avatar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-e142afc5a4b71ea7f96a73a1f1b6ac035d2721395f0b2905b345fc22ff602458))
- ❌ Property removed: `emoji`

**`class` LdCallbackModel<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/data/ld_callback_model.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-bbe6dccbaff1f85db929a2244aa1272b485ea8ef19047f4e87871d9a0c49ee84))
- 🔄 Method type changed: `update` (`Future<void>` → `Future<T?>`)

**`class` LdForm** ([lib/src/form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-ab3d738b21791b69d0a5b557ff458148fb04dae3ed14766eb5b31ec1c0a285f0))
- ❌ Class removed: `LdForm`

**`class` LdFormHint** ([lib/src/form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-ab3d738b21791b69d0a5b557ff458148fb04dae3ed14766eb5b31ec1c0a285f0))
- ❌ Class removed: `LdFormHint`

**`class` LdFormItem** ([lib/src/form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-ab3d738b21791b69d0a5b557ff458148fb04dae3ed14766eb5b31ec1c0a285f0))
- ❌ Class removed: `LdFormItem`

**`class` LdHint** ([lib/src/hint.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-dfc92525de9815f786b74d0fb4e4a920602109f9db1ffe185778ade2d4295570))
- ❌ Param removed in constructor `info`: `type` (named, required)
- ❌ Param removed in constructor `warning`: `type` (named, required)
- ❌ Param removed in constructor `success`: `type` (named, required)
- ❌ Param removed in constructor `error`: `type` (named, required)
- ❌ Param removed in constructor `canceled`: `type` (named, required)
- ❌ Param removed in constructor `loading`: `type` (named, required)
- ❌ Param removed in constructor `pending`: `type` (named, required)
- ❌ Param removed in constructor `ongoing`: `type` (named, required)

**`class` LdIndicator** ([lib/src/indicators.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-d795289d9c186887b0644807b9f5bf48ef75099f590cff62f4a832c3d6d85b3b))
- ❌ Param removed in constructor `info`: `type` (named, required)
- ❌ Param removed in constructor `warning`: `type` (named, required)
- ❌ Param removed in constructor `canceled`: `type` (named, required)
- ❌ Param removed in constructor `error`: `type` (named, required)
- ❌ Param removed in constructor `success`: `type` (named, required)
- ❌ Param removed in constructor `loading`: `type` (named, required)
- ❌ Param removed in constructor `pending`: `type` (named, required)
- ❌ Param removed in constructor `ongoing`: `type` (named, required)

**`class` LdListController<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/data/list_controller.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-2bd19515e63ce2d64323e30fa8b37fd3ca7fac879e8a0089508961972dcadd7c))
- 🔄 Method type changed: `updateFromModel` (`Future<void>` → `Future<T?>`)

**`class` LdModel<T extends Identifiable<IdType>, IdType, TCreate, TUpdate>** ([lib/src/monkey/data/ld_model.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-44449e404af55a988303764c787a8c8f8f96d93a74e10ed133ffd7252d0b2f68))
- 🔄 Method type changed: `update` (`Future<void>` → `Future<T?>`)

**`class` LdSubmitController<T, Arg>** ([lib/src/submit/model/submit_controller.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-d921dcc848cbe3ce44f849c2be50e41f4300cb5bddb83fe2c189bea7f63c8f34))
- ❌ Property removed: `canRetrigger`

**`class` LdTabNavigation** ([lib/src/appbar/tab_navigation.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-52bf35196752849d0d45f783bb5b24e4217e93ef2ae5ff75caafe39bc5b551fc))
- 🔄 Param type changed in default constructor: `activeRoute` (`String` → `String?`)
- 🔄 Property type changed: `activeRoute`

**`class` LdWrapConditional** ([lib/src/conditional_parent.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-0c2f88e1b8a773abd704b4c32c032e744ff4b949fa2aa00cd8a54ef2522eda09))
- 🔄 Superclass changed: `StatelessWidget` → `StatefulWidget`
- ❌ Method removed: `build`

**`class` LiquidLocalizations** ([lib/src/l10n/generated/liquid_localizations.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-355d12226806e42fbe28958594669ec350c927c0fc7c9226bf2b78c89f288995))
- ❌ Properties removed: `fieldConflictYours`, `fieldConflictServer`

**`function` ldMonkeyConfirmDiscardEdits** ([lib/src/monkey/detail_editor/ld_monkey_discard_confirm.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-15feafebb4126ecc6852f9b263ff15be62e2881e931ac652a9d56061674155d9))
- ❌ Function removed: `ldMonkeyConfirmDiscardEdits`

#### ✨ Minor changes

**`class` LdAppBar** ([lib/src/appbar/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-3fa4ae735c9f6ca4c26ac958e08eaa30e2da735b6e0f0ed00665eb6c2b2bb49f))
- ❌ Param removed in constructor `top`: `positionMode` (named, optional)
- ❌ Param removed in constructor `bottom`: `positionMode` (named, optional)

**`class` LdAvatar** ([lib/src/avatar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-e142afc5a4b71ea7f96a73a1f1b6ac035d2721395f0b2905b345fc22ff602458))
- ❌ Param removed in default constructor: `emoji` (named, optional, default: false)
- ❌ Param removed in method `success`: `emoji` (named, optional, default: false)
- ❌ Param removed in method `warning`: `emoji` (named, optional, default: false)
- ❌ Param removed in method `error`: `emoji` (named, optional, default: false)

**`class` LdButton** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- ❇️ Param added in default constructor: `onHover` (named, optional)
- ❌ Param removed in constructor `ghost`: `mode` (named, optional)
- ❇️ Param added in constructor `ghost`: `onHover` (named, optional)
- ❌ Param removed in constructor `vague`: `mode` (named, optional)
- ❇️ Param added in constructor `vague`: `onHover` (named, optional)
- ❌ Param removed in constructor `outline`: `mode` (named, optional)
- ❇️ Param added in constructor `outline`: `onHover` (named, optional)
- ❌ Param removed in constructor `filled`: `mode` (named, optional)
- ❇️ Param added in constructor `filled`: `onHover` (named, optional)
- ❇️ Property added: `onHover`
- ❇️ Param added in method `warning`: `onHover` (named, optional)
- ❇️ Param added in method `error`: `onHover` (named, optional)
- ❇️ Param added in method `success`: `onHover` (named, optional)

**`class` LdButtonConfig** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- ❇️ Param added in default constructor: `onHover` (named, optional)
- ❇️ Property added: `onHover`

**`class` LdCheckboxConfig** ([lib/src/checkbox.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-212494581d361b843cfc944c41577dc67246a6cfcd3adcc6c8732ec7791c2599))
- ❇️ Param added in default constructor: `label` (named, optional)
- ❇️ Property added: `label`

**`class` LdChoose<T extends Identifiable<IdType>, IdType>** ([lib/src/choose/choose.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-6ce965d70e5a38c7bb7d300718c981f5dd5c18807dcaf9b633cdc74c1d5c5c74))
- ❇️ Param added in default constructor: `actions` (named, optional, default: const [])
- ❇️ Property added: `actions`

**`class` LdColorBundle** ([lib/src/touchable/touchable_colors.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-d352685a32b99170cf72e9ee6ea5672f6832866aa981169ba764bce80ab7d154))
- ❇️ Class added: `LdColorBundle`

**`class` LdCounter** ([lib/src/counter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-56493e7e7233aac1f95d625ed446d310fe0305379c2e1b4429cd8bc3083c6a4d))
- ❌ Param removed in constructor `s`: `size` (named, optional, default: LdSize.m)
- ❌ Param removed in constructor `l`: `size` (named, optional, default: LdSize.m)
- ❌ Param removed in constructor `xs`: `size` (named, optional, default: LdSize.m)

**`class` LdEmoji** ([lib/src/emoji.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-1b3026d5bb3ce997167aa7c05fd472dae31ca624a851db5fe87322766ca879da))
- ❇️ Class added: `LdEmoji`

**`class` LdEmojiCategory** ([lib/src/emoji_picker/emoji_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-bdaa0011d74a18c692b051bce50476ac41303c4a58559cffa2cda3c65dd9dc25))
- ❇️ Class added: `LdEmojiCategory`

**`class` LdEmojiEntry** ([lib/src/emoji_picker/emoji_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-bdaa0011d74a18c692b051bce50476ac41303c4a58559cffa2cda3c65dd9dc25))
- ❇️ Class added: `LdEmojiEntry`

**`class` LdEmojiPickerModal** ([lib/src/emoji_picker/emoji_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-bdaa0011d74a18c692b051bce50476ac41303c4a58559cffa2cda3c65dd9dc25))
- ❇️ Class added: `LdEmojiPickerModal`

**`class` LdFilterSearch<T extends Identifiable<IdType>, IdType, Suggestion>** ([lib/src/monkey/filter/ld_filter_search.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-4d71fc5bfdc4b0254470d2133519e55d28aa4013ef9ab8eeb02f139201fe0f73))
- ❇️ Param added in method `searchConfig`: `inputFocusNode` (named, optional)

**`class` LdListController<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/data/list_controller.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-2bd19515e63ce2d64323e30fa8b37fd3ca7fac879e8a0089508961972dcadd7c))
- ❇️ Properties added: `deletedItems`, `detachedItemsById`
- ❇️ Method added: `removeItemById`

**`class` LdListItem** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- ❌ Param removed in constructor `trailingForward`: `trailing` (named, optional)

**`class` LdMetaball** ([lib/src/metaball/metaball.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-3f44f81d32a4f6357495811a0ef11ac4b71c58f40a155f27cc5a848a6665677c))
- ❇️ Class added: `LdMetaball`

**`class` LdMetaballBlob** ([lib/src/metaball/metaball_blob.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-5ab2bf79286f1500aa73f06dd57d5ad8636233eea68369fb92fbd871d2758d15))
- ❇️ Class added: `LdMetaballBlob`

**`class` LdMetaballChild** ([lib/src/metaball/metaball.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-3f44f81d32a4f6357495811a0ef11ac4b71c58f40a155f27cc5a848a6665677c))
- ❇️ Class added: `LdMetaballChild`

**`class` LdMetaballMask** ([lib/src/metaball/metaball_mask.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-6f3c60daed9da62bd711d1411765f7c1b19493924f4b32ca88db0c1436df7b09))
- ❇️ Class added: `LdMetaballMask`

**`class` LdMetaballMaskScoped** ([lib/src/metaball/metaball_mask.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-6f3c60daed9da62bd711d1411765f7c1b19493924f4b32ca88db0c1436df7b09))
- ❇️ Class added: `LdMetaballMaskScoped`

**`class` LdMetaballShaderScope** ([lib/src/metaball/metaball_shader_scope.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-36d3e099d8e35fd786b1d1cfc58ced2cf2ed02ef582778d4961e245a39b3dca4))
- ❇️ Class added: `LdMetaballShaderScope`

**`class` LdMetaballShaders** ([lib/src/metaball/metaball_shader_scope.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-36d3e099d8e35fd786b1d1cfc58ced2cf2ed02ef582778d4961e245a39b3dca4))
- ❇️ Class added: `LdMetaballShaders`

**`enum` LdMetaballShape** ([lib/src/metaball/metaball_blob.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-5ab2bf79286f1500aa73f06dd57d5ad8636233eea68369fb92fbd871d2758d15))
- ❇️ Enum added: `LdMetaballShape`

**`class` LdMonkeySearchFocusNode** ([lib/src/monkey/monkey_shell.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-f58e8426a3074373d1a4d8d50d0d7467233933c3ceffe3098ffc530558a3aa9b))
- ❇️ Class added: `LdMonkeySearchFocusNode`

**`class` LdMonkeySelection<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_selection.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-72f93ee9d49683aa9512af7176bb6780ce73d1f63dbc8674a08fd06e0297bacf))
- ❇️ Method added: `toString`

**`class` LdPaginator<T extends Identifiable<IdType>, IdType>** ([lib/src/list/list_paginator.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-c279977c526f2e1ad42c33e9e9f5451f323d228e7974b6ae305a16daa9ff8dc8))
- ❇️ Method added: `removeItemById`

**`class` LdSearchConfig** ([lib/src/appbar/search_config.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-368436926193fa74e40419890eb7131dcaf98ec1be8f7ecbe1493423a3d59d6d))
- ❇️ Property added: `inputFocusNode`

**`class` LdSubmit<T, Arg>** ([lib/src/submit/submit.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-90dec5a624a3cd55bf16ed8f4d39486f0ad3f7b8e1ff081a9177aedac7ea2802))
- ❇️ Param added in default constructor: `disabled` (named, optional)
- ❇️ Property added: `disabled`

**`class` LdSubmitController<T, Arg>** ([lib/src/submit/model/submit_controller.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-d921dcc848cbe3ce44f849c2be50e41f4300cb5bddb83fe2c189bea7f63c8f34))
- ❇️ Properties added: `isDisabled`, `disabled`

**`class` LdTabNavigation** ([lib/src/appbar/tab_navigation.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-52bf35196752849d0d45f783bb5b24e4217e93ef2ae5ff75caafe39bc5b551fc))
- ✅ Param became optional in default constructor: `activeRoute` (named, required)
- ❇️ Param added in default constructor: `pageController` (named, optional)
- ❇️ Property added: `pageController`

**`class` LdText** ([lib/src/text.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-ce7342ea9aebd0be91a6fd6597751ce9b68c0040b4cd9db2386764d2efceb9a2))
- ❌ Param removed in constructor `caption`: `type` (named, optional, default: LdTextType.paragraph)
- ❌ Params removed in constructor `h`: `size` (named, optional, default: LdSize.m), `type` (named, optional, default: LdTextType.paragraph)
- ❌ Params removed in constructor `hl`: `size` (named, optional, default: LdSize.m), `type` (named, optional, default: LdTextType.paragraph)
- ❌ Params removed in constructor `hs`: `size` (named, optional, default: LdSize.m), `type` (named, optional, default: LdTextType.paragraph)
- ❌ Params removed in constructor `hxs`: `size` (named, optional, default: LdSize.m), `type` (named, optional, default: LdTextType.paragraph)
- ❌ Param removed in constructor `l`: `type` (named, optional, default: LdTextType.paragraph)
- ❌ Params removed in constructor `ll`: `size` (named, optional, default: LdSize.m), `type` (named, optional, default: LdTextType.paragraph)
- ❌ Params removed in constructor `ls`: `size` (named, optional, default: LdSize.m), `type` (named, optional, default: LdTextType.paragraph)
- ❌ Params removed in constructor `lxs`: `size` (named, optional, default: LdSize.m), `type` (named, optional, default: LdTextType.paragraph)
- ❌ Param removed in constructor `p`: `type` (named, optional, default: LdTextType.paragraph)
- ❌ Params removed in constructor `pl`: `size` (named, optional, default: LdSize.m), `type` (named, optional, default: LdTextType.paragraph)
- ❌ Params removed in constructor `ps`: `size` (named, optional, default: LdSize.m), `type` (named, optional, default: LdTextType.paragraph)
- ❌ Params removed in constructor `pxs`: `size` (named, optional, default: LdSize.m), `type` (named, optional, default: LdTextType.paragraph)

**`class` LdTheme** ([lib/src/theme/theme.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-e230b3066fca6361167b035927f3d5e83cda9a34212c86e2a307ed82bcf0d99e))
- ❇️ Property added: `fontFamilyFallback`

**`class` LdTouchableStatus** ([lib/src/touchable/touchable_status.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-93fa329a5cd9dde387ded484086657e338aa10c5140d47c04bf9417a459132fd))
- ❇️ Class added: `LdTouchableStatus`

**`class` LdTouchableSurface** ([lib/src/touchable/touchable.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-390c2ec1e7b0ebec409f605c4cdc4ea7ef337cf7876bdca7a87de6f2c647ea96))
- ❇️ Param added in default constructor: `onHover` (named, optional)
- ❇️ Property added: `onHover`

**`class` LdWrapConditional** ([lib/src/conditional_parent.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-0c2f88e1b8a773abd704b4c32c032e744ff4b949fa2aa00cd8a54ef2522eda09))
- ❇️ Method added: `createState`

**`class` LiquidLocalizations** ([lib/src/l10n/generated/liquid_localizations.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-355d12226806e42fbe28958594669ec350c927c0fc7c9226bf2b78c89f288995))
- ❇️ Properties added: `fieldConflictKeepMine`, `fieldConflictUseServer`, `save`, `saving`, `create`, `creating`, `discardChanges`

**`class` _LdAvatarWidget** ([lib/src/avatar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-e142afc5a4b71ea7f96a73a1f1b6ac035d2721395f0b2905b345fc22ff602458))
- ❌ Param removed in default constructor: `emoji` (named, optional, default: false)

**`class` _LdButtonWidget** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- ❇️ Param added in default constructor: `onHover` (named, optional)

**`function` ghostColor** ([lib/src/touchable/ghost_color.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-35692811854a6b34c1dfeda9c02ab8bc041e4f8af586c3f961be0cb5f9b14b5c))
- ❇️ Function added: `ghostColor`

**`function` inputColor** ([lib/src/touchable/input_color.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-a85c641d5e8b2b2cadee043650ce27bb4bbe50cb0dc27ca1c7d348f7b9b1f16e))
- ❇️ Function added: `inputColor`

**`function` ldFormConfirmDiscardEdits** ([lib/src/monkey/detail_editor/ld_monkey_discard_confirm.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-15feafebb4126ecc6852f9b263ff15be62e2881e931ac652a9d56061674155d9))
- ❇️ Function added: `ldFormConfirmDiscardEdits`

**`function` solidColor** ([lib/src/touchable/solid_color.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-33a5f5b01b44f660ad18d32c06decd8bcd49fe3d6e10bb28ab8053fcc1d4ff80))
- ❇️ Function added: `solidColor`

#### 👀 Patch changes

**`class` LdListController<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/data/list_controller.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-2bd19515e63ce2d64323e30fa8b37fd3ca7fac879e8a0089508961972dcadd7c))
- ❌ Methods removed: `_confirmDeletionForId`, `_confirmPagedDeletion`
- ❇️ Method added: `_maybeRefreshPostDeletion`

**`class` LdSubmitController<T, Arg>** ([lib/src/submit/model/submit_controller.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-d921dcc848cbe3ce44f849c2be50e41f4300cb5bddb83fe2c189bea7f63c8f34))
- ❇️ Property added: `_isDisabled`

**`class` LdTheme** ([lib/src/theme/theme.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-e230b3066fca6361167b035927f3d5e83cda9a34212c86e2a307ed82bcf0d99e))
- ❇️ Property added: `_fontFamilyFallback`

**`class` _EmojiCell** ([lib/src/emoji_picker/emoji_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-bdaa0011d74a18c692b051bce50476ac41303c4a58559cffa2cda3c65dd9dc25))
- ❇️ Class added: `_EmojiCell`

**`class` _EmojiGrid** ([lib/src/emoji_picker/emoji_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-bdaa0011d74a18c692b051bce50476ac41303c4a58559cffa2cda3c65dd9dc25))
- ❇️ Class added: `_EmojiGrid`

**`class` _LdAvatarWidget** ([lib/src/avatar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-e142afc5a4b71ea7f96a73a1f1b6ac035d2721395f0b2905b345fc22ff602458))
- ❌ Property removed: `emoji`

**`class` _LdButtonWidget** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- ❇️ Property added: `onHover`

**`class` _LdCheckboxWidget** ([lib/src/checkbox.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-212494581d361b843cfc944c41577dc67246a6cfcd3adcc6c8732ec7791c2599))
- ➕ Constructor annotation added: `new` (@ContextConfigurable())
- ➖ Params annotation removed: `` (@ContextConfigurable()), `` (@ContextConfigurable()), `` (@ContextConfigurable()), `` (@ContextConfigurable()), `` (@ContextConfigurable()), `` (@ContextConfigurable())

**`class` _LdEmojiPickerModalState** ([lib/src/emoji_picker/emoji_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-bdaa0011d74a18c692b051bce50476ac41303c4a58559cffa2cda3c65dd9dc25))
- ❇️ Class added: `_LdEmojiPickerModalState`

**`class` _LdEmojiState** ([lib/src/emoji.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-1b3026d5bb3ce997167aa7c05fd472dae31ca624a851db5fe87322766ca879da))
- ❇️ Class added: `_LdEmojiState`

**`class` _LdFormState** ([lib/src/form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-ab3d738b21791b69d0a5b557ff458148fb04dae3ed14766eb5b31ec1c0a285f0))
- ❌ Class removed: `_LdFormState`

**`class` _LdMetaballShaderData** ([lib/src/metaball/metaball_shader_scope.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-36d3e099d8e35fd786b1d1cfc58ced2cf2ed02ef582778d4961e245a39b3dca4))
- ❇️ Class added: `_LdMetaballShaderData`

**`class` _LdMetaballShaderScopeState** ([lib/src/metaball/metaball_shader_scope.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-36d3e099d8e35fd786b1d1cfc58ced2cf2ed02ef582778d4961e245a39b3dca4))
- ❇️ Class added: `_LdMetaballShaderScopeState`

**`class` _LdMetaballState** ([lib/src/metaball/metaball.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-3f44f81d32a4f6357495811a0ef11ac4b71c58f40a155f27cc5a848a6665677c))
- ❇️ Class added: `_LdMetaballState`

**`class` _LdMonkeyShellState<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_shell.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-f58e8426a3074373d1a4d8d50d0d7467233933c3ceffe3098ffc530558a3aa9b))
- ❇️ Property added: `_searchFocusNode`
- ➖ Methods annotation removed: `dispose` (@protected), `dispose` (@mustCallSuper)
- ➕ Method annotation added: `dispose` (@override)

**`class` _LdSearchInputState** ([lib/src/appbar/search_components.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-c7750a1ad0e6a79e8cd9a447bd3f31dd1c31866d30873339df5d2bea4b410ecd))
- ❌ Modifier `final` removed from property: `_inputFocusNode`
- ❇️ Modifier `late` added to property: `_inputFocusNode`

**`class` _LdTabNavigationState** ([lib/src/appbar/tab_navigation.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-52bf35196752849d0d45f783bb5b24e4217e93ef2ae5ff75caafe39bc5b551fc))
- ❇️ Properties added: `_currentPageIndex`, `_springOverridden`
- ➖ Methods annotation removed: `initState` (@protected), `initState` (@mustCallSuper)
- ➕ Method annotation added: `initState` (@override)
- ❌ Param removed in method `_onTabTap`: `route` (positional, required)
- ❇️ Param added in method `_onTabTap`: `tabIndex` (positional, required)
- ❇️ Methods added: `_attachPageController`, `_detachPageController`, `_onPageControllerUpdate`, `_updateIndicatorFromPage`

**`class` _LdTouchableSurfaceState** ([lib/src/touchable/touchable.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-390c2ec1e7b0ebec409f605c4cdc4ea7ef337cf7876bdca7a87de6f2c647ea96))
- ❇️ Property added: `_isHovering`

**`class` _LdWrapConditionalState** ([lib/src/conditional_parent.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-0c2f88e1b8a773abd704b4c32c032e744ff4b949fa2aa00cd8a54ef2522eda09))
- ❇️ Class added: `_LdWrapConditionalState`

**`class` _MetaballChild** ([lib/src/metaball/metaball.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-3f44f81d32a4f6357495811a0ef11ac4b71c58f40a155f27cc5a848a6665677c))
- ❇️ Class added: `_MetaballChild`

**`class` _SkinTonePicker** ([lib/src/emoji_picker/emoji_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-bdaa0011d74a18c692b051bce50476ac41303c4a58559cffa2cda3c65dd9dc25))
- ❇️ Class added: `_SkinTonePicker`

**`class` _SpringSim** ([lib/src/metaball/metaball.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-3f44f81d32a4f6357495811a0ef11ac4b71c58f40a155f27cc5a848a6665677c))
- ❇️ Class added: `_SpringSim`

**`function` _computeTranslation** ([lib/src/emoji.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-1b3026d5bb3ce997167aa7c05fd472dae31ca624a851db5fe87322766ca879da))
- ❇️ Function added: `_computeTranslation`

**`function` _getOrCompute** ([lib/src/emoji.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-1b3026d5bb3ce997167aa7c05fd472dae31ca624a851db5fe87322766ca879da))
- ❇️ Function added: `_getOrCompute`

**`function` _isInputLike** ([lib/src/autospace.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-f17bdf0d5830aa5697a0e806f3c3035e3563b69cdf810372144eae69594248a3))
- ❇️ Function added: `_isInputLike`

**`function` _renderEmoji** ([lib/src/emoji.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-1b3026d5bb3ce997167aa7c05fd472dae31ca624a851db5fe87322766ca879da))
- ❇️ Function added: `_renderEmoji`

**`function` _resolveSize** ([lib/src/emoji.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-6..liquid_flutter/v23.0.0-7#diff-1b3026d5bb3ce997167aa7c05fd472dae31ca624a851db5fe87322766ca879da))
- ❇️ Function added: `_resolveSize`

## 23.0.0-6
Released on: 7/2/2026, changelog automatically generated.


### Bug Fixes

- edge cases for monkey pattern ([#149](issues/149)) ([8ab8efe](commit/8ab8efe))

### API Changes

#### 💣 Breaking changes

**`class` CloseDrawerButton** ([lib/src/appbar/drawer_buttons.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-998051ffbe5c2156247ec3ddd0dae8857b52454fad9991da3821f6ba5e3cdc1b))
- ❌ Class removed: `CloseDrawerButton`

**`class` LdAppBar** ([lib/src/appbar/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-3fa4ae735c9f6ca4c26ac958e08eaa30e2da735b6e0f0ed00665eb6c2b2bb49f))
- ❌ Properties removed: `implyLeading`, `showWindowControls`, `implyCloseModalButton`

**`class` LdAppBarConfig** ([lib/src/appbar/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-3fa4ae735c9f6ca4c26ac958e08eaa30e2da735b6e0f0ed00665eb6c2b2bb49f))
- ❌ Properties removed: `implyCloseModalButton`, `implyLeading`, `showWindowControls`

**`class` LdAppBarParentShowsImpliedLeading** ([lib/src/appbar/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-3fa4ae735c9f6ca4c26ac958e08eaa30e2da735b6e0f0ed00665eb6c2b2bb49f))
- ❌ Class removed: `LdAppBarParentShowsImpliedLeading`

**`class` LdAppBarScrollNotification** ([lib/src/appbar/appbar_scroll_notifier.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-63a4629b74bb8cfffe808706c50a1945d309e7b59bacc2ef3325cf1fe5534f79))
- ❇️ Param added in default constructor: `momentumVelocity` (named, required)

**`class` LdAppBarWidget** ([lib/src/appbar/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-3fa4ae735c9f6ca4c26ac958e08eaa30e2da735b6e0f0ed00665eb6c2b2bb49f))
- ❌ Properties removed: `implyLeading`, `showWindowControls`, `implyCloseModalButton`

**`class` LdBottomBar** ([lib/src/appbar/bottom_bar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-178e06f6e9bcb5b603d39a4524326f7e1f8ea90bd5bd2d3256b53845237111b2))
- ❌ Class removed: `LdBottomBar`

**`class` LdCallbackModel<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/data/ld_callback_model.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-bbe6dccbaff1f85db929a2244aa1272b485ea8ef19047f4e87871d9a0c49ee84))
- 🔄 Param type changed in default constructor: `updateBatchFn` (`Future<void> Function(BuildContext, Set<T>)?` → `Future<void> Function(BuildContext, Map<IdType, T>)?`)
- 🔄 Properties type changed: `cache`, `updateBatchFn`
- 🔄 Param type changed in method `persistUpdateBatch`: `items` (`Set<T>` → `Map<IdType, T>`)
- 🔄 Param type changed in method `updateBatch`: `items` (`Set<T>` → `Map<IdType, T>`)
- 🔄 Param type changed in method `greedy`: `updateBatch` (`Future<void> Function(BuildContext, Set<L>)?` → `Future<void> Function(BuildContext, Map<IdType, L>)?`)

**`class` LdChooseTriggerConfig<T extends Identifiable<IdType>, IdType>** ([lib/src/choose/choose.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-6ce965d70e5a38c7bb7d300718c981f5dd5c18807dcaf9b633cdc74c1d5c5c74))
- 🔄 Param type changed in default constructor: `hint` (`Widget?` → `Widget`)
- 🔄 Property type changed: `hint`

**`class` LdList<T extends Identifiable<IdType>, IdType>** ([lib/src/list/list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-888f80c71ddeacb424418138bd38d5900a4ffe694069cba2af68eb89e66a4a41))
- ❌ Property removed: `assumedItemHeight`

**`class` LdListConfig<T extends Identifiable<IdType>, IdType>** ([lib/src/list/list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-888f80c71ddeacb424418138bd38d5900a4ffe694069cba2af68eb89e66a4a41))
- ❌ Property removed: `assumedItemHeight`

**`class` LdListController<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/data/list_controller.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-2bd19515e63ce2d64323e30fa8b37fd3ca7fac879e8a0089508961972dcadd7c))
- 🔄 Properties type changed: `fetchListFunction`, `model`
- ❌ Methods removed: `ensureSelectionAnchored`, `ensureSelectionLoaded`
- 🔄 Param type changed in method `updateBatchFromModel`: `items` (`Set<TUpdate>` → `Map<IdType, TUpdate>`)

**`class` LdListItem** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- 🔄 Param type changed in default constructor: `selectDisabled` (`bool` → `bool?`), `tradeLeadingForSelectionControl` (`bool` → `bool?`)
- 🔄 Param type changed in constructor `trailingForward`: `selectDisabled` (`bool` → `bool?`), `tradeLeadingForSelectionControl` (`bool` → `bool?`)
- 🔄 Properties type changed: `selectDisabled`, `tradeLeadingForSelectionControl`

**`class` LdListWidget<T extends Identifiable<IdType>, IdType>** ([lib/src/list/list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-888f80c71ddeacb424418138bd38d5900a4ffe694069cba2af68eb89e66a4a41))
- ❌ Property removed: `assumedItemHeight`

**`class` LdModel<T extends Identifiable<IdType>, IdType, TCreate, TUpdate>** ([lib/src/monkey/data/ld_model.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-44449e404af55a988303764c787a8c8f8f96d93a74e10ed133ffd7252d0b2f68))
- 🔄 Property type changed: `cache`
- 🔄 Param type changed in method `persistUpdateBatch`: `items` (`Set<TUpdate>` → `Map<IdType, TUpdate>`)
- 🔄 Param type changed in method `updateBatch`: `items` (`Set<TUpdate>` → `Map<IdType, TUpdate>`)

**`class` LdMonkeyAppBar<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_app_bar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-1ed77dea165bf61117ba5c39537c923f703bf59c28964a4507ccb301fab79a69))
- ❌ Property removed: `implyLeading`

**`class` LdMonkeyRouteScope<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_route_scope.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-00b40f9e0517eb15a03249100eaf69b7c20db14e2b2ec72a032292e923048ac2))
- ❌ Property removed: `detailPanelFlex`

**`class` LdMonkeyShell<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_shell.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-f58e8426a3074373d1a4d8d50d0d7467233933c3ceffe3098ffc530558a3aa9b))
- ❌ Property removed: `detailPanelFlex`

**`class` LdPaginator<T extends Identifiable<IdType>, IdType>** ([lib/src/list/list_paginator.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-c279977c526f2e1ad42c33e9e9f5451f323d228e7974b6ae305a16daa9ff8dc8))
- 🔄 Param type changed in default constructor: `fetchListFunction` (`Future<LdListPage<T>> Function(FetchPageParameters<T, IdType>)?` → `Future<LdListPage<T>> Function(FetchPageParameters<T, IdType>)`)
- ⚠️ Param became required in default constructor: `fetchListFunction` (named, optional)
- 🔄 Property type changed: `fetchListFunction`

**`class` LdSelectableList<T extends Identifiable<IdType>, IdType>** ([lib/src/list/selectable_list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-f78a865a5b517b6892730363bb581f1e53588fb39b9bc88417dea463806327c7))
- ❌ Param removed in default constructor: `paginator` (named, required)
- ❇️ Param added in default constructor: `listController` (named, required)
- ❌ Property removed: `paginator`

**`class` MonkeyRouteNode<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_route_tree.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-5ee5971433b226f5666f1c6e2da4cdd4b73a3416065519e97a778a01e3fae04d))
- ❌ Property removed: `detailPanelFlex`

**`class` OpenDrawerButton** ([lib/src/appbar/drawer_buttons.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-998051ffbe5c2156247ec3ddd0dae8857b52454fad9991da3821f6ba5e3cdc1b))
- ❌ Class removed: `OpenDrawerButton`

**`class` _MonkeyShellLayoutBuilder<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_shell.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-f58e8426a3074373d1a4d8d50d0d7467233933c3ceffe3098ffc530558a3aa9b))
- ❌ Param removed in default constructor: `detailPanelFlex` (named, required)
- ❇️ Param added in default constructor: `detailPanelFraction` (named, required)

#### ✨ Minor changes

**`class` LdAppBar** ([lib/src/appbar/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-3fa4ae735c9f6ca4c26ac958e08eaa30e2da735b6e0f0ed00665eb6c2b2bb49f))
- ❌ Params removed in default constructor: `implyCloseModalButton` (named, optional), `implyLeading` (named, optional), `showWindowControls` (named, optional)
- ❇️ Param added in default constructor: `implyFeatures` (named, optional)
- ❌ Params removed in constructor `top`: `implyCloseModalButton` (named, optional), `implyLeading` (named, optional), `showWindowControls` (named, optional)
- ❇️ Param added in constructor `top`: `implyFeatures` (named, optional)
- ❌ Params removed in constructor `bottom`: `implyCloseModalButton` (named, optional), `implyLeading` (named, optional), `showWindowControls` (named, optional)
- ❇️ Param added in constructor `bottom`: `implyFeatures` (named, optional)
- ❇️ Property added: `implyFeatures`

**`class` LdAppBarBackButton** ([lib/src/appbar/implied/back_button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-7e1d936bdce32148d727491647951c9dc105fdf48f2514a06d608a2d213355b0))
- ❇️ Class added: `LdAppBarBackButton`

**`class` LdAppBarCloseModalButton** ([lib/src/appbar/implied/close_modal_button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-69f412aac8d31ba909107a2403043591e80a50825ac7249c2309c3f2470c24f7))
- ❇️ Class added: `LdAppBarCloseModalButton`

**`class` LdAppBarConfig** ([lib/src/appbar/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-3fa4ae735c9f6ca4c26ac958e08eaa30e2da735b6e0f0ed00665eb6c2b2bb49f))
- ❌ Params removed in default constructor: `implyCloseModalButton` (named, optional), `implyLeading` (named, optional), `showWindowControls` (named, optional)
- ❇️ Param added in default constructor: `implyFeatures` (named, optional)
- ❇️ Property added: `implyFeatures`

**`enum` LdAppBarImpliedFeature** ([lib/src/appbar/implied/implied_features.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-b3c404c6a9fe207062878cbde59f322e4ec3a9091ae09d1de578d72672b83eac))
- ❇️ Enum added: `LdAppBarImpliedFeature`

**`class` LdAppBarImpliedFeatures** ([lib/src/appbar/implied/implied_features.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-b3c404c6a9fe207062878cbde59f322e4ec3a9091ae09d1de578d72672b83eac))
- ❇️ Class added: `LdAppBarImpliedFeatures`

**`extension` LdAppBarImpliedFeaturesExtension** ([lib/src/appbar/implied/implied_features.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-b3c404c6a9fe207062878cbde59f322e4ec3a9091ae09d1de578d72672b83eac))
- ❇️ Extension added: `LdAppBarImpliedFeaturesExtension`

**`class` LdAppBarMetrics** ([lib/src/appbar/appbar_state.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-3e75260b022f83d5ee36c231362f6603999ada7073b656454d1545bcd74b197d))
- ❇️ Property added: `isModal`
- ❇️ Method added: `reset`

**`extension` LdAppBarPositionExtension** ([lib/src/appbar/appbar_state.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-3e75260b022f83d5ee36c231362f6603999ada7073b656454d1545bcd74b197d))
- ❇️ Extension added: `LdAppBarPositionExtension`

**`class` LdAppBarScrollNotification** ([lib/src/appbar/appbar_scroll_notifier.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-63a4629b74bb8cfffe808706c50a1945d309e7b59bacc2ef3325cf1fe5534f79))
- ❇️ Property added: `momentumVelocity`

**`class` LdAppBarWidget** ([lib/src/appbar/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-3fa4ae735c9f6ca4c26ac958e08eaa30e2da735b6e0f0ed00665eb6c2b2bb49f))
- ❌ Params removed in default constructor: `implyCloseModalButton` (named, optional, default: true), `implyLeading` (named, optional), `showWindowControls` (named, optional, default: true)
- ❇️ Param added in default constructor: `implyFeatures` (named, optional, default: const {LdAppBarImpliedFeature.back, LdAppBarImpliedFeature.close, LdAppBarImpliedFeature.windowControls, LdAppBarImpliedFeature.drawerToggle})
- ❇️ Property added: `implyFeatures`

**`class` LdCallbackModel<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/data/ld_callback_model.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-bbe6dccbaff1f85db929a2244aa1272b485ea8ef19047f4e87871d9a0c49ee84))
- ❌ Modifier `final` removed from property: `cache`
- ❇️ Methods added: `fetchListWithParametersCached`, `invalidateCacheOnMutation`

**`class` LdDrawerButton** ([lib/src/appbar/implied/drawer_buttons.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-f7a28a7ef5a5f8cbe3161476e8e6b235bfc48881932e597e19aaa98f2279514f))
- ❇️ Class added: `LdDrawerButton`

**`enum` LdDrawerButtonType** ([lib/src/appbar/implied/drawer_buttons.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-f7a28a7ef5a5f8cbe3161476e8e6b235bfc48881932e597e19aaa98f2279514f))
- ❇️ Enum added: `LdDrawerButtonType`

**`extension` LdDrawerSlotExtension** ([lib/src/scaffold.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-35c580af7b94cd13fc78765d9afc1f836ec439643e1a61922b4b6c7a0614553d))
- ❇️ Extension added: `LdDrawerSlotExtension`

**`class` LdList<T extends Identifiable<IdType>, IdType>** ([lib/src/list/list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-888f80c71ddeacb424418138bd38d5900a4ffe694069cba2af68eb89e66a4a41))
- ❌ Param removed in default constructor: `assumedItemHeight` (named, optional)

**`class` LdListCacheKeyPart** ([lib/src/monkey/data/ld_list_cache_key.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-c2dd9b794bf55e14f63062a0c1baeb9f502d36d666a1f9ecda1d0dc871c374f4))
- ❇️ Class added: `LdListCacheKeyPart`

**`class` LdListConfig<T extends Identifiable<IdType>, IdType>** ([lib/src/list/list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-888f80c71ddeacb424418138bd38d5900a4ffe694069cba2af68eb89e66a4a41))
- ❌ Param removed in default constructor: `assumedItemHeight` (named, optional)

**`class` LdListController<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/data/list_controller.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-2bd19515e63ce2d64323e30fa8b37fd3ca7fac879e8a0089508961972dcadd7c))
- ❌ Modifier `factory` removed from constructor: `fromModel`
- ❇️ Constructor added: `new`
- ❇️ Method added: `onTransientItemsEvictedByRefresh`

**`class` LdListEmpty** ([lib/src/list/list_empty.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-3acf2a0268f75f5c094dbd095f10e4b2ffd09cdfc410f0d25829c3e84e8954e6))
- ❇️ Params added in default constructor: `hasActiveFilters` (named, optional, default: false), `onClearFilters` (named, optional)
- ❇️ Properties added: `hasActiveFilters`, `onClearFilters`

**`class` LdListItem** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- ❇️ Param added in default constructor: `isOdd` (named, optional)
- ❇️ Param added in constructor `trailingForward`: `isOdd` (named, optional)
- ❇️ Property added: `isOdd`

**`class` LdListItemConfig** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- ❇️ Params added in default constructor: `leading` (named, optional), `selectDisabled` (named, optional), `subContent` (named, optional), `subtitle` (named, optional), `title` (named, optional), `tradeLeadingForSelectionControl` (named, optional), `width` (named, optional), `isOdd` (named, optional)
- ❇️ Properties added: `leading`, `selectDisabled`, `subContent`, `subtitle`, `title`, `tradeLeadingForSelectionControl`, `width`, `isOdd`

**`class` LdListItemWidget** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- ❇️ Param added in default constructor: `isOdd` (named, optional, default: false)
- ❇️ Property added: `isOdd`

**`enum` LdListMutationKind** ([lib/src/monkey/data/ld_list_cache_key.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-c2dd9b794bf55e14f63062a0c1baeb9f502d36d666a1f9ecda1d0dc871c374f4))
- ❇️ Enum added: `LdListMutationKind`

**`class` LdListWidget<T extends Identifiable<IdType>, IdType>** ([lib/src/list/list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-888f80c71ddeacb424418138bd38d5900a4ffe694069cba2af68eb89e66a4a41))
- ❌ Param removed in default constructor: `assumedItemHeight` (named, optional)

**`extension` LdModalRouteExtension** ([lib/src/modal/modal.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-2d55c400b021d628a7e92bc6d07673f3775bac69b40c544c8332ae622d0f715d))
- ❇️ Extension added: `LdModalRouteExtension`

**`class` LdModel<T extends Identifiable<IdType>, IdType, TCreate, TUpdate>** ([lib/src/monkey/data/ld_model.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-44449e404af55a988303764c787a8c8f8f96d93a74e10ed133ffd7252d0b2f68))
- ❇️ Methods added: `fetchListWithParametersCached`, `invalidateCacheOnMutation`

**`class` LdMonkeyAppBar<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_app_bar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-1ed77dea165bf61117ba5c39537c923f703bf59c28964a4507ccb301fab79a69))
- ❌ Param removed in default constructor: `implyLeading` (named, optional)

**`class` LdMonkeyRouteScope<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_route_scope.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-00b40f9e0517eb15a03249100eaf69b7c20db14e2b2ec72a032292e923048ac2))
- ❌ Param removed in default constructor: `detailPanelFlex` (named, optional)
- ❇️ Param added in default constructor: `detailPanelFraction` (named, optional)
- ❇️ Property added: `detailPanelFraction`

**`class` LdMonkeyShell<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_shell.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-f58e8426a3074373d1a4d8d50d0d7467233933c3ceffe3098ffc530558a3aa9b))
- ❌ Param removed in default constructor: `detailPanelFlex` (named, optional, default: 2)
- ❇️ Param added in default constructor: `detailPanelFraction` (named, optional, default: 0.3)
- ❇️ Property added: `detailPanelFraction`

**`class` LdMultiPanelLayout** ([lib/src/multi_panel/multi_panel_layout.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-dcf83dd1348efc710dbc6957e505c08eb421234a466c65f2b9630f2f41b83750))
- ❇️ Params added in default constructor: `minBodyWidth` (named, optional), `insetBody` (named, optional, default: false)
- ❇️ Properties added: `minBodyWidth`, `insetBody`

**`class` LdPaginator<T extends Identifiable<IdType>, IdType>** ([lib/src/list/list_paginator.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-c279977c526f2e1ad42c33e9e9f5451f323d228e7974b6ae305a16daa9ff8dc8))
- ❇️ Method added: `onTransientItemsEvictedByRefresh`

**`class` LdPartialBatchDeleteException<IdType>** ([lib/src/monkey/data/ld_list_cache_key.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-c2dd9b794bf55e14f63062a0c1baeb9f502d36d666a1f9ecda1d0dc871c374f4))
- ❇️ Class added: `LdPartialBatchDeleteException`

**`class` LdSelectableList<T extends Identifiable<IdType>, IdType>** ([lib/src/list/selectable_list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-f78a865a5b517b6892730363bb581f1e53588fb39b9bc88417dea463806327c7))
- ❇️ Property added: `listController`

**`class` LiquidLocalizations** ([lib/src/l10n/generated/liquid_localizations.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-355d12226806e42fbe28958594669ec350c927c0fc7c9226bf2b78c89f288995))
- ❇️ Properties added: `noItemsMatchFilter`, `clearFilters`

**`class` MacOSWindowControls** ([lib/src/appbar/implied/macos_window_controls.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-5618493c48c92a6f1beaf7b88e3b34f6b67d749e9a04545fd6ead0ac8acae1ce))
- ❇️ Class added: `MacOSWindowControls`

**`class` MonkeyRouteNode<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_route_tree.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-5ee5971433b226f5666f1c6e2da4cdd4b73a3416065519e97a778a01e3fae04d))
- ❌ Param removed in default constructor: `detailPanelFlex` (named, optional)
- ❇️ Param added in default constructor: `detailPanelFraction` (named, optional)
- ❇️ Property added: `detailPanelFraction`

**`class` WindowsWindowControls** ([lib/src/appbar/implied/windows_window_controls.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-fc922da4536be59880c71e67a04ca821005f466d692ccfbb779887db3d11f2fb))
- ❇️ Class added: `WindowsWindowControls`

**`class` _LdMonkeySelectionHydrator<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_router_adapter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-38733ea6a1cce5fbf22de0240816bf176f58d0e504bf36a2b06519fe5f9a108d))
- ❇️ Param added in default constructor: `key` (named, optional)

**`function` buildMonkeyRoutes<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_routes.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-5dd41942d7588e4b4e14333a7153952c923f9bc1226bae8302adcf3f9c97ce29))
- ❌ Param removed in function `buildMonkeyRoutes`: `detailPanelFlex` (named, optional)
- ❇️ Param added in function `buildMonkeyRoutes`: `detailPanelFraction` (named, optional)

**`function` ldListCacheKey<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/data/ld_list_cache_key.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-c2dd9b794bf55e14f63062a0c1baeb9f502d36d666a1f9ecda1d0dc871c374f4))
- ❇️ Function added: `ldListCacheKey`

**`function` parseLdListCacheKey** ([lib/src/monkey/data/ld_list_cache_key.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-c2dd9b794bf55e14f63062a0c1baeb9f502d36d666a1f9ecda1d0dc871c374f4))
- ❇️ Function added: `parseLdListCacheKey`

#### 👀 Patch changes

**`class` LdCallbackModel<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/data/ld_callback_model.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-bbe6dccbaff1f85db929a2244aa1272b485ea8ef19047f4e87871d9a0c49ee84))
- ➖ Property annotation removed: `cache` (@override)
- ❇️ Properties added: `_ownedCache`, `_providedCache`

**`class` LdListController<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/data/list_controller.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-2bd19515e63ce2d64323e30fa8b37fd3ca7fac879e8a0089508961972dcadd7c))
- ❌ Constructor removed: `_`
- ❌ Properties removed: `_isGreedy`, `_autoCache`, `_autoInvalidateCache`, `_autoInvalidateCacheOnMutation`
- 🔄 Property type changed: `_attachedModel`
- ❇️ Property added: `_refreshInProgress`
- ❇️ Param added in method `_addToOffsetQueue`: `immediate` (named, optional, default: false)
- 🔄 Method type changed: `_fetchItems` (`Future<List<T>>` → `Future<bool>`), `_insertPageItems` (`List<T>` → `bool`)
- ❌ Methods removed: `_fetchWithAutoCache`, `_maybeInvalidateOnMutation`, `_idFromUpdatePayload`
- ✏️ Param renamed in method `initWithSelection`: `selection` → `selectedIds`

**`class` LdListItemWidget** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- ➕ Constructor annotation added: `new` (@ContextConfigurable())
- ➖ Params annotation removed: `` (@ContextConfigurable()), `` (@ContextConfigurable()), `` (@ContextConfigurable()), `` (@ContextConfigurable()), `` (@ContextConfigurable()), `` (@ContextConfigurable()), `` (@ContextConfigurable()), `` (@ContextConfigurable()), `` (@ContextConfigurable()), `` (@ContextConfigurable()), `` (@ContextConfigurable())

**`class` LdModel<T extends Identifiable<IdType>, IdType, TCreate, TUpdate>** ([lib/src/monkey/data/ld_model.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-44449e404af55a988303764c787a8c8f8f96d93a74e10ed133ffd7252d0b2f68))
- ❇️ Property added: `_ownedCache`

**`class` LdPaginator<T extends Identifiable<IdType>, IdType>** ([lib/src/list/list_paginator.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-c279977c526f2e1ad42c33e9e9f5451f323d228e7974b6ae305a16daa9ff8dc8))
- ❇️ Param added in method `_addToOffsetQueue`: `immediate` (named, optional, default: false)
- 🔄 Method type changed: `_fetchItems` (`Future<List<T>>` → `Future<bool>`), `_insertPageItems` (`List<T>` → `bool`)

**`class` LdScaffoldState** ([lib/src/scaffold.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-35c580af7b94cd13fc78765d9afc1f836ec439643e1a61922b4b6c7a0614553d))
- ❌ Property removed: `_isSurface`
- 🔄 Property type changed: `_scaffoldDecoration`

**`class` LdSelectableListState<T extends Identifiable<IdType>, IdType>** ([lib/src/list/selectable_list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-f78a865a5b517b6892730363bb581f1e53588fb39b9bc88417dea463806327c7))
- ❇️ Method added: `_tryScrollToInitialSelection`

**`class` _LdAppBarScrollNotifierState** ([lib/src/appbar/appbar_scroll_notifier.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-63a4629b74bb8cfffe808706c50a1945d309e7b59bacc2ef3325cf1fe5534f79))
- ❇️ Property added: `_lastMomentumFrameTime`
- ❇️ Method added: `_momentumVelocity`

**`class` _LdAppBarWidgetState** ([lib/src/appbar/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-3fa4ae735c9f6ca4c26ac958e08eaa30e2da735b6e0f0ed00665eb6c2b2bb49f))
- ❌ Properties removed: `_isModal`, `_canDismissModal`, `_drawerBlocksImplyLeading`, `_canPopParentRoute`, `_drawerSlot`, `_isDrawer`
- ❌ Methods removed: `_closeModalButton`, `_popParentRoute`, `_findDrawerParent`, `_buildLeading`, `_shouldImplyRouteBack`, `_showWindowsWindowControls`

**`class` _LdListReorderScopeState<T extends Identifiable<IdType>, IdType>** ([lib/src/list/reorderable_list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-7fba1dfd3dfe7dce17c728b3b6196db4d04769e588d7de2b34901f5b0567fa1f))
- ❌ Property removed: `_isMobile`

**`class` _LdListState<T extends Identifiable<IdType>, IdType>** ([lib/src/list/list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-888f80c71ddeacb424418138bd38d5900a4ffe694069cba2af68eb89e66a4a41))
- ❌ Properties removed: `_performedInitialScroll`, `_pendingScrollAttempts`, `_maxPendingScrollAttempts`
- ❌ Methods removed: `_getAverageItemHeight`, `_maybeScrollToPendingItem`, `_scrollPendingItemIntoView`, `_maybePerformInitialScroll`

**`class` _LdMultiPanelLayoutState** ([lib/src/multi_panel/multi_panel_layout.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-dcf83dd1348efc710dbc6957e505c08eb421234a466c65f2b9630f2f41b83750))
- ❇️ Properties added: `_internalPanelFraction`, `_appliedPanelWidth`, `_bodyBorderSide`, `_panelIsLeft`, `_insetBody`, `_bodyDecoration`, `_insetPadding`, `_bodyMargin`, `_additionalDrawerPadding`

**`class` _LdToggleState** ([lib/src/toggle.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-3be9fabf9ea8105794cfaa3898af4f8abed89551a1e963a7ee9183a05649ce25))
- ❌ Property removed: `_controller`
- ➖ Method annotation removed: `didUpdateWidget` (@override)
- ➕ Methods annotation added: `didUpdateWidget` (@mustCallSuper), `didUpdateWidget` (@protected)
- ❌ Method removed: `_updateStatus`

**`class` _MonkeyShellLayoutBuilder<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_shell.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-f58e8426a3074373d1a4d8d50d0d7467233933c3ceffe3098ffc530558a3aa9b))
- ❌ Property removed: `detailPanelFlex`
- ❇️ Property added: `detailPanelFraction`

**`meta` pubspec.yaml** ([pubspec.yaml](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-8b7e9df87668ffa6a04b32e1769a33434999e54ae081c52e5d943c541d4c0d25))
- 📦 Added `meta`: with version `^1.9.0`

**`function` _goRouterCanPop** ([lib/src/appbar/implied/back_button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-7e1d936bdce32148d727491647951c9dc105fdf48f2514a06d608a2d213355b0))
- ❇️ Function added: `_goRouterCanPop`

**`function` _goRouterShellNavigatorCanPop** ([lib/src/appbar/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-3fa4ae735c9f6ca4c26ac958e08eaa30e2da735b6e0f0ed00665eb6c2b2bb49f))
- ❌ Function removed: `_goRouterShellNavigatorCanPop`

**`function` _isDescendant** ([lib/src/appbar/implied/back_button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-5..liquid_flutter/v23.0.0-6#diff-7e1d936bdce32148d727491647951c9dc105fdf48f2514a06d608a2d213355b0))
- ❇️ Function added: `_isDescendant`

## 23.0.0-5
Released on: 6/28/2026, changelog automatically generated.

## 23.0.0-4
Released on: 6/23/2026, changelog automatically generated.

## Unreleased

### Breaking changes

- **LdListCache:** rename `LdRepositoryCache` / `LdRepositoryCacheEntry` / `LdRepositoryCacheKeyPart` / `LdRepositoryMutationKind` to `LdListCache*` / `LdListMutationKind`; rename `ldRepositoryCacheKey` / `parseLdRepositoryCacheKey` to `ldListCacheKey` / `parseLdListCacheKey`
- **LdPaginator:** rename `repositoryCache` parameter and field to `listCache`
- **LdMonkeyDetailState:** rename `repository` field to `listController`
- **LdMonkeyListFilterAdapter:** rename from `LdMonkeyRepositoryFilterAdapter` (`monkey_list_filter_adapter.dart`)
- **Tests:** rename `createTestRepository` to `createTestListController`; rename `repository_test.dart` to `list_controller_test.dart`
- Remove deprecated `mutationAffectsCache` on filter/sort options, `LdMutationAffectsCache` typedef, and `LdMonkeyAction.build()` — use `affectedByUpdate` and `buildTrigger` instead
- Stop exporting internal monkey helpers: `resolveMonkeyRouteDefinitions`, `ldListCacheKey`, `parseLdListCacheKey`, `LdListCacheKeyPart`, and `LdListMutationKind`

## 23.0.0-3
Released on: automatic fallback dev bump to avoid duplicate 23.0.0-2 publish.

### Features

- **LdRepository:** add `affectedByUpdate` on filter/sort options (replaces deprecated `mutationAffectsCache`) for shared cache invalidation and paginator layout decisions
- **LdPaginator:** add `repositionItemById`, safe delete compaction (`canCompactIndicesAfterDeletion` / `compactIndicesAfterDeletion`), and reposition-or-refresh mutation flows in `LdRepository`

### Deprecations

- `mutationAffectsCache` on `LdFilterOption` / `LdSortOption` — use `affectedByUpdate` instead
- `LdMutationAffectsCache` typedef — use `LdAffectedByUpdate` instead

---

## Older versions

See [CHANGELOG_ARCHIVE.md](CHANGELOG_ARCHIVE.md) for earlier releases.
