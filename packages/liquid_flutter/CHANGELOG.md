## 23.0.0-14
Released on: 11/12/2026, changelog automatically generated.


### Bug Fixes

- **exception:** select the whole error at once in LdExceptionDialog ([66d3029](commit/66d3029))
- **modal:** stop the sheet drag gesture outside dispose ([bb85a3a](commit/bb85a3a))
- **modal:** stop nested modals from tearing down the covered route ([2b28870](commit/2b28870))
- **LdDatePicker:** match compact control height ([adf434d](commit/adf434d))
- **LdRecurrenceForm:** keep times as pairs without cartesian expand ([1175b51](commit/1175b51))
- **LdListWidget:** pad list items via SliverSafeArea only ([d81fcf5](commit/d81fcf5))
- **LdRecurrencePicker:** update open goldens; assert URL hydrate via adapter ([87cd612](commit/87cd612))
- **LdDurationPicker:** label duration wheels ([9a594cc](commit/9a594cc))
- **LdDurationPicker:** stop jumping wheels on scroll ([0b3dc92](commit/0b3dc92))
- **LdTimePicker:** skip rebuilds and absorb wheel scroll ([18be1d2](commit/18be1d2))
- **LdConversation:** restore fling dismiss, drop cupertino_interactive_keyboard ([df347ef](commit/df347ef))
- **overflow:** lay out hidden children instead of skipping them ([24d09e4](commit/24d09e4))
- **LdRawAppBar:** inside and outside decorations are applied again ([3a2de3f](commit/3a2de3f))
- **ci:** analyzer passes again on dev ([46bc62a](commit/46bc62a))
- **LdListReorderScope:** follow the pointer through drag deltas ([1de08f3](commit/1de08f3))
- **list:** hidden drag handle stays out of the row height, loader padding matches the item ([d670bfe](commit/d670bfe))
- **LdListController:** apply the item reorderItem returns, cancel reveal timers on dispose ([989bd05](commit/989bd05))
- **LdSubmit:** cancel the mount delay timer on dispose ([6cc4950](commit/6cc4950))
- **LdSubmit:** a localized error keeps its message, and the dialog closes on any error ([cc88cdf](commit/cc88cdf))
- **LdScaffoldBody:** widget tree dumps no longer assert on its flag properties ([9e5c2d1](commit/9e5c2d1))
- **LdAttachmentPicker:** capture review buttons stay clear of the tab bar ([14d58ba](commit/14d58ba))
- **LdRawAppBar:** enhance app bar decoration with conditional styling for scrolled states ([d8e7e8e](commit/d8e7e8e))
- move padding into animated children to avoid jumping in conversation view ([b9ae7b7](commit/b9ae7b7))
- add spacing to report issue card layout ([84b6b16](commit/84b6b16))
- scroll hiding in conversation when keyboard appears ([28a1dfd](commit/28a1dfd))
- layout issue in gallery tab, refocus of buttons after deactivation ([a692f3a](commit/a692f3a))
- markdown code breaking without language ([fced9fb](commit/fced9fb))
- stop idle web memory leaks in loader, orb, and app bar ([05fcf4a](commit/05fcf4a))
### Features

- **LdRecurrencePicker:** add RFC 5545 recurrence picker ([a7c56e0](commit/a7c56e0))
- **LdRecurrenceForm:** use hour/minute chips with timesMode ([65accf1](commit/65accf1))
- **LdRecurrenceForm:** add BYHOUR/BYMINUTE times of day ([50d1fc1](commit/50d1fc1))
- **LdMonkeyRouterAdapter:** seed builder isOn defaults into URL ([e7f88c5](commit/e7f88c5))
- **liquid_flutter_ai:** tool call detail modal, usage sizing, LdConfirm size ([4ddf7fd](commit/4ddf7fd))
- **LdToolCallDetailModal:** pretty-print JSON args and results ([c296277](commit/c296277))
- **LdEmojiPicker:** extra search keywords ([a1f54eb](commit/a1f54eb))
- **LdRawAppBar:** chrome-less bar; hide only with remaining scroll ([be8752b](commit/be8752b))
- **LdTurnErrorItem:** render turn failures as error cards ([f077320](commit/f077320))
- **LdModalRoute:** wrap modal content with LdAppBarConfigProvider for improved app bar configuration ([4bb4c16](commit/4bb4c16))
- **LdOutgoingScope:** persist/send pipeline and desktop attachment gating ([7ca19fb](commit/7ca19fb))
- choose is always using monkey pattern ([f650524](commit/f650524))

### API Changes

#### 💣 Breaking changes

**`class` AppBarFrame** ([lib/src/appbar/appbar_frame.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-f5dae86f88f57d7eacd239b0beba44a7a95e301f01ff1dd11b53d1ec43864c92))
- ❇️ Params added in default constructor: `insideBuilder` (named, required), `outsideBuilder` (named, required)
- ❌ Properties removed: `insideDecoration`, `outsideDecoration`, `insideDecorationBuilder`, `outsideDecorationBuilder`, `insidePadding`, `useAdaptiveRadius`, `isTabNavigation`

**`class` LdAppBarMetrics** ([lib/src/appbar/appbar_state.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-3e75260b022f83d5ee36c231362f6603999ada7073b656454d1545bcd74b197d))
- ❌ Property removed: `isTabNavigation`

**`class` LdChoosePage<T extends Identifiable<IdType>, IdType>** ([lib/src/choose/choose.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-6ce965d70e5a38c7bb7d300718c981f5dd5c18807dcaf9b633cdc74c1d5c5c74))
- ❌ Class removed: `LdChoosePage`

**`class` LdChoosePageState<T extends Identifiable<IdType>, IdType>** ([lib/src/choose/choose.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-6ce965d70e5a38c7bb7d300718c981f5dd5c18807dcaf9b633cdc74c1d5c5c74))
- ❌ Class removed: `LdChoosePageState`

**`class` LdLocalizedException** ([lib/src/exception/model/exception.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-12c04f03aed1ea809f666cff20093761481831385aa468beea43c61cd27c3dcc))
- 🔄 Method type changed: `copyWith` (`LdException` → `LdLocalizedException`, narrowed)

**`class` LdMonkeyActionScope<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/actions/action_scope.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-8d8d4164833c3126607ed8c0b376d0b7f342466f50145aac25aa8535d5840ef6))
- 🔄 Superclass changed: `Object` → `ChangeNotifier`

**`class` LdMonkeyViewingBuilder<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/detail_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-43d347b03da89e053d770a97150585d0955be32f82540fad5d2ceabd18d33035))
- 🔄 Superclass changed: `StatelessWidget` → `StatefulWidget`
- ❌ Method removed: `build`

**`class` ReflectionPainter** ([lib/src/liquid_orb.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-77302ae24f129be07973b7dedb81c73569eef9d7e22d7c51c0d8c4b7d6813f72))
- 🔄 Param type changed in method `shouldRepaint`: `oldDelegate` (`CustomPainter` → `ReflectionPainter`, narrowed)

**`class` _LoadingPainter** ([lib/src/loading.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-ebcc4b4214d20bfb03a2fbeee643fc07dae381788b8f53a32f1ab77c6a1fd9c3))
- ❇️ Modifier `final` added to properties: `animation`, `loaderSize`
- 🔄 Param type changed in method `shouldRepaint`: `oldDelegate` (`CustomPainter` → `_LoadingPainter`, narrowed)

**`class` _OrbPainter** ([lib/src/liquid_orb.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-77302ae24f129be07973b7dedb81c73569eef9d7e22d7c51c0d8c4b7d6813f72))
- ❌ Params removed in default constructor: `_orbSize` (positional, required), `animationProgress` (positional, required)
- ❇️ Params added in default constructor: `animation` (named, required), `orbSize` (named, required)
- 🔄 Param type changed in method `shouldRepaint`: `oldDelegate` (`CustomPainter` → `_OrbPainter`, narrowed)

**`function` ldChooseCanConfirmSelection<IdType>** ([lib/src/choose/choose.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-6ce965d70e5a38c7bb7d300718c981f5dd5c18807dcaf9b633cdc74c1d5c5c74))
- ❌ Params removed in function `ldChooseCanConfirmSelection`: `current` (named, required), `initial` (named, required)
- ❇️ Params added in function `ldChooseCanConfirmSelection`: `selection` (named, required), `allowEmpty` (named, required)

**`function` ldChooseCanDismissPicker<IdType>** ([lib/src/choose/choose.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-6ce965d70e5a38c7bb7d300718c981f5dd5c18807dcaf9b633cdc74c1d5c5c74))
- ❌ Param removed in function `ldChooseCanDismissPicker`: `current` (named, required)

**`function` ldHasParentTopAppBar** ([lib/src/appbar/appbar_state.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-3e75260b022f83d5ee36c231362f6603999ada7073b656454d1545bcd74b197d))
- ❌ Function removed: `ldHasParentTopAppBar`

#### ✨ Minor changes

**`extension` AdaptiveRadiusExtension** ([lib/src/theme/adaptive_radius.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-706e354ff68acf035dbf6735a630ba540cc1d11f41d3e2732198d245c4483c45))
- ❇️ Extension added: `AdaptiveRadiusExtension`

**`extension` AdjustToRadius** ([lib/src/theme/adaptive_radius.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-706e354ff68acf035dbf6735a630ba540cc1d11f41d3e2732198d245c4483c45))
- ❇️ Extension added: `AdjustToRadius`

**`class` AppBarFrame** ([lib/src/appbar/appbar_frame.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-f5dae86f88f57d7eacd239b0beba44a7a95e301f01ff1dd11b53d1ec43864c92))
- ❌ Params removed in default constructor: `insideDecoration` (named, optional), `outsideDecoration` (named, optional), `insideDecorationBuilder` (named, optional), `outsideDecorationBuilder` (named, optional), `useAdaptiveRadius` (named, optional, default: true), `insidePadding` (named, optional), `isTabNavigation` (named, optional, default: false)
- ❇️ Properties added: `insideBuilder`, `outsideBuilder`

**`class` LdAdaptiveRadius** ([lib/src/theme/adaptive_radius.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-706e354ff68acf035dbf6735a630ba540cc1d11f41d3e2732198d245c4483c45))
- ❇️ Class added: `LdAdaptiveRadius`

**`class` LdAppBarActionGroup** ([lib/src/appbar/appbar_action_group.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-dd312b93254ed5e7b7a91b2f96bd76b08f06caef1468508ac83719dfd21d2bf7))
- ❇️ Class added: `LdAppBarActionGroup`

**`enum` LdAppBarActionOverflowMode** ([lib/src/appbar/appbar_action.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-794db106d4f7693d7c1084b7103a07eaab28bb6e2ae95034930d7d423bc07135))
- ❇️ Property added: `always`

**`class` LdAppBarFrameMetrics** ([lib/src/appbar/appbar_frame.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-f5dae86f88f57d7eacd239b0beba44a7a95e301f01ff1dd11b53d1ec43864c92))
- ❇️ Class added: `LdAppBarFrameMetrics`

**`class` LdAppBarMetrics** ([lib/src/appbar/appbar_state.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-3e75260b022f83d5ee36c231362f6603999ada7073b656454d1545bcd74b197d))
- ❌ Param removed in default constructor: `isTabNavigation` (named, optional, default: false)
- ❇️ Property added: `rootMetricsOfSide`

**`class` LdButton** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- ❇️ Param added in default constructor: `noFocusOnTap` (named, optional, default: false)
- ❇️ Param added in constructor `fromConfig`: `noFocusOnTap` (named, optional, default: false)
- ❇️ Param added in constructor `ghost`: `noFocusOnTap` (named, optional, default: false)
- ❇️ Param added in constructor `vague`: `noFocusOnTap` (named, optional, default: false)
- ❇️ Param added in constructor `outline`: `noFocusOnTap` (named, optional, default: false)
- ❇️ Param added in constructor `filled`: `noFocusOnTap` (named, optional, default: false)
- ❇️ Property added: `noFocusOnTap`
- ❇️ Param added in method `warning`: `noFocusOnTap` (named, optional, default: false)
- ❇️ Param added in method `error`: `noFocusOnTap` (named, optional, default: false)
- ❇️ Param added in method `success`: `noFocusOnTap` (named, optional, default: false)

**`class` LdCallbackModel<T extends Identifiable<IdType>, IdType, TCreate, TUpdate>** ([lib/src/monkey/data/ld_callback_model.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-bbe6dccbaff1f85db929a2244aa1272b485ea8ef19047f4e87871d9a0c49ee84))
- ❇️ Param added in method `fromList`: `searchText` (named, optional)

**`class` LdControlGroupScope** ([lib/src/input_group.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-c654b60a9d1bdeadc55e3f2104021a9a99aca812f1a465caa15942aa7db199fe))
- ❇️ Class added: `LdControlGroupScope`

**`class` LdDatePicker** ([lib/src/date_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-705cf9a7b3b5d494795266f0d9bd90767b033dd2dc19f3eee04d709951be9dd7))
- ❇️ Param added in default constructor: `size` (named, optional, default: LdSize.m)
- ❇️ Property added: `size`

**`class` LdDrawerState** ([lib/src/drawer_state.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-8859c797a9078257b005903427308c3be052192a4c3b80263208f3058254f555))
- ❇️ Param added in default constructor: `isCollapsible` (named, optional, default: true)
- ❇️ Property added: `isCollapsible`

**`class` LdDuration** ([lib/src/duration/ld_duration.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-99acd71f2e1ee28f4a15a678ed9c328dda3497bf31c1915c48d3a6f1edca8790))
- ❇️ Class added: `LdDuration`

**`class` LdDurationConfig** ([lib/src/duration_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-1ccb326244a8ea9acd286914510c8e65c1eaf4773bb12b532c549dd6d9575123))
- ❇️ Class added: `LdDurationConfig`

**`extension` LdDurationDateTime** ([lib/src/duration/ld_duration.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-99acd71f2e1ee28f4a15a678ed9c328dda3497bf31c1915c48d3a6f1edca8790))
- ❇️ Extension added: `LdDurationDateTime`

**`class` LdDurationPicker** ([lib/src/duration_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-1ccb326244a8ea9acd286914510c8e65c1eaf4773bb12b532c549dd6d9575123))
- ❇️ Class added: `LdDurationPicker`

**`class` LdDurationPickerModal** ([lib/src/duration_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-1ccb326244a8ea9acd286914510c8e65c1eaf4773bb12b532c549dd6d9575123))
- ❇️ Class added: `LdDurationPickerModal`

**`class` LdDurationPickerWidget** ([lib/src/duration_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-1ccb326244a8ea9acd286914510c8e65c1eaf4773bb12b532c549dd6d9575123))
- ❇️ Class added: `LdDurationPickerWidget`

**`enum` LdDurationUnit** ([lib/src/duration/ld_duration.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-99acd71f2e1ee28f4a15a678ed9c328dda3497bf31c1915c48d3a6f1edca8790))
- ❇️ Enum added: `LdDurationUnit`

**`class` LdEphemeralMonkeyController<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/ld_ephemeral_monkey_controller.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-c234ffcde54c4e78067e39ba5d805f7fff0db37da12ef431fc7bcfcdfa5e8898))
- ❇️ Property added: `initialSelection`

**`class` LdFieldFrame** ([lib/src/field_frame.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-35bb9eaafb459ff19907fbd42b8f06f7eae2491d1c3625701c2859de24e861bd))
- ❇️ Class added: `LdFieldFrame`

**`class` LdInput** ([lib/src/input.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-2ffc2d5e6008b31f35c68f6ed0d27138168bf19c95df7c0aab8349787a9a5ef6))
- ❇️ Param added in default constructor: `clipboardHasData` (named, optional)
- ❇️ Property added: `clipboardHasData`

**`class` LdInputGroup** ([lib/src/input_group.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-c654b60a9d1bdeadc55e3f2104021a9a99aca812f1a465caa15942aa7db199fe))
- ❇️ Class added: `LdInputGroup`

**`class` LdInputGroupText** ([lib/src/input_group.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-c654b60a9d1bdeadc55e3f2104021a9a99aca812f1a465caa15942aa7db199fe))
- ❇️ Class added: `LdInputGroupText`

**`class` LdListController<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/data/list_controller.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-2bd19515e63ce2d64323e30fa8b37fd3ca7fac879e8a0089508961972dcadd7c))
- ❇️ Method added: `setItemState`

**`class` LdListItem** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- ❇️ Params added in default constructor: `showDragHandle` (named, optional), `dragCallbacks` (named, optional), `tradeTrailingForDragHandle` (named, optional)
- ❇️ Params added in constructor `trailingForward`: `showDragHandle` (named, optional), `dragCallbacks` (named, optional), `tradeTrailingForDragHandle` (named, optional)
- ❇️ Properties added: `showDragHandle`, `dragCallbacks`, `tradeTrailingForDragHandle`

**`class` LdListItemAnimation** ([lib/src/list/ld_list_item_animation.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-761d55a256a89f0d592feb46f083fe873ecca89623c6113198e3af75db69e71d))
- ❇️ Param added in default constructor: `onAnimationEnd` (named, optional)
- ❇️ Property added: `onAnimationEnd`

**`class` LdListItemConfig** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- ❇️ Params added in default constructor: `showDragHandle` (named, optional), `dragCallbacks` (named, optional), `tradeTrailingForDragHandle` (named, optional)
- ❇️ Properties added: `showDragHandle`, `dragCallbacks`, `tradeTrailingForDragHandle`
- ❇️ Params added in method `copyWith`: `showDragHandle` (named, optional), `dragCallbacks` (named, optional), `tradeTrailingForDragHandle` (named, optional)

**`class` LdListItemDragConfig** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- ❇️ Class added: `LdListItemDragConfig`

**`class` LdListItemWidget** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- ❇️ Params added in default constructor: `showDragHandle` (named, optional, default: false), `dragCallbacks` (named, optional), `tradeTrailingForDragHandle` (named, optional, default: true)
- ❇️ Properties added: `showDragHandle`, `dragCallbacks`, `tradeTrailingForDragHandle`

**`class` LdListReorderScope<T extends Identifiable<IdType>, IdType>** ([lib/src/list/reorderable_list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-7fba1dfd3dfe7dce17c728b3b6196db4d04769e588d7de2b34901f5b0567fa1f))
- ❇️ Param added in default constructor: `velocityScalar` (named, optional, default: 50)
- ❇️ Property added: `velocityScalar`

**`class` LdMonkeyActionGroup<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/actions/actions.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-250ba08dbbe05925449c761878d3265c71d99d63e119d34feda97f183532dd30))
- ❇️ Class added: `LdMonkeyActionGroup`

**`class` LdMonkeyActionScope<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/actions/action_scope.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-8d8d4164833c3126607ed8c0b376d0b7f342466f50145aac25aa8535d5840ef6))
- ❇️ Property added: `hasListeners`
- ❇️ Methods added: `addListener`, `removeListener`, `dispose`, `notifyListeners`

**`class` LdMonkeyRouteConfig<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_route_config.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-e1d4248f5b3581ffaf1a1d2cb4d4b3d63b7e479e22aacc0bb35c483da737b1f2))
- ❇️ Methods added: `pushDetailRoute`, `replaceDetailRoute`, `pushCreateRoute`, `pushMasterRoute`

**`class` LdMonkeyViewingBuilder<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/detail_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-43d347b03da89e053d770a97150585d0955be32f82540fad5d2ceabd18d33035))
- ❇️ Method added: `createState`

**`class` LdNavigationTab** ([lib/src/navigation/navigation_tab.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-1124dd22eb8d2fd60da94a631835fa608f0a560ef0334aa3c4663d228c8776dc))
- ❇️ Param added in default constructor: `badge` (named, optional)
- ❇️ Property added: `badge`

**`class` LdNavigationTabBadge** ([lib/src/navigation/navigation_tab.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-1124dd22eb8d2fd60da94a631835fa608f0a560ef0334aa3c4663d228c8776dc))
- ❇️ Class added: `LdNavigationTabBadge`

**`class` LdOverflowAlwaysChild** ([lib/src/overflow/always_child.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-7ca10594f81b83d216be83e2bf855b2c2809c23a4429eb4087e795e2d8748ec1))
- ❇️ Class added: `LdOverflowAlwaysChild`

**`class` LdPaginator<T extends Identifiable<IdType>, IdType>** ([lib/src/list/list_paginator.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-c279977c526f2e1ad42c33e9e9f5451f323d228e7974b6ae305a16daa9ff8dc8))
- ❇️ Method added: `setItemState`

**`enum` LdPaginatorItemState** ([lib/src/list/list_paginator.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-c279977c526f2e1ad42c33e9e9f5451f323d228e7974b6ae305a16daa9ff8dc8))
- ❇️ Property added: `moved`

**`class` LdRawAppBar** ([lib/src/appbar/raw_appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-ac463f9d06464e197d8e52173fb23271ba390a387227668510800da28c657f0d))
- ❇️ Class added: `LdRawAppBar`

**`enum` LdRawAppBarLayout** ([lib/src/appbar/raw_appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-ac463f9d06464e197d8e52173fb23271ba390a387227668510800da28c657f0d))
- ❇️ Enum added: `LdRawAppBarLayout`

**`class` LdRecurrenceConfig** ([lib/src/rrule/recurrence_config.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-54821d31a230174a3f2190de8a2e0855334502fed71819ee7eb040461855067a))
- ❇️ Class added: `LdRecurrenceConfig`

**`class` LdRecurrenceDraft** ([lib/src/rrule/rrule_draft.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-0e9f52cae888744190cd2e922904aac1cb710448140259354db146f6d5f14f7c))
- ❇️ Class added: `LdRecurrenceDraft`

**`enum` LdRecurrenceEndMode** ([lib/src/rrule/rrule_draft.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-0e9f52cae888744190cd2e922904aac1cb710448140259354db146f6d5f14f7c))
- ❇️ Enum added: `LdRecurrenceEndMode`

**`class` LdRecurrenceForm** ([lib/src/rrule/recurrence_form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-da19c9691aa50460bf60d73b3014e6df0c0d36f38ffb09bee6504aa908ff178e))
- ❇️ Class added: `LdRecurrenceForm`

**`enum` LdRecurrenceMonthlyMode** ([lib/src/rrule/rrule_draft.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-0e9f52cae888744190cd2e922904aac1cb710448140259354db146f6d5f14f7c))
- ❇️ Enum added: `LdRecurrenceMonthlyMode`

**`class` LdRecurrenceMultiPicker** ([lib/src/rrule/recurrence_multi_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-c23a7ea47e504750fd8cf861bce190543a0934dbafaeb8c17439a00b55b308da))
- ❇️ Class added: `LdRecurrenceMultiPicker`

**`class` LdRecurrencePicker** ([lib/src/rrule/recurrence_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-4eda84644402cd4ac4911790652a64ac92ae7f1fc8a9748a831ce4edd0795fa3))
- ❇️ Class added: `LdRecurrencePicker`

**`class` LdRecurrencePickerModal** ([lib/src/rrule/recurrence_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-4eda84644402cd4ac4911790652a64ac92ae7f1fc8a9748a831ce4edd0795fa3))
- ❇️ Class added: `LdRecurrencePickerModal`

**`class` LdRecurrenceTime** ([lib/src/rrule/rrule_draft.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-0e9f52cae888744190cd2e922904aac1cb710448140259354db146f6d5f14f7c))
- ❇️ Class added: `LdRecurrenceTime`

**`enum` LdRecurrenceTimesMode** ([lib/src/rrule/rrule_draft.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-0e9f52cae888744190cd2e922904aac1cb710448140259354db146f6d5f14f7c))
- ❇️ Enum added: `LdRecurrenceTimesMode`

**`class` LdScaffold** ([lib/src/scaffold.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-35c580af7b94cd13fc78765d9afc1f836ec439643e1a61922b4b6c7a0614553d))
- ❇️ Param added in default constructor: `drawerCollapsible` (named, optional, default: true)
- ❇️ Property added: `drawerCollapsible`

**`class` LdScaffoldBody** ([lib/src/scaffold_body.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-25fd66a644218adca4f46a542b28e361a2aea16ff32c8a2def5a1819cf1c507b))
- ❇️ Param added in default constructor: `keyboardDismissBehavior` (named, optional)
- ❇️ Property added: `keyboardDismissBehavior`

**`class` LdSubmit<T, Arg>** ([lib/src/submit/submit.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-90dec5a624a3cd55bf16ed8f4d39486f0ad3f7b8e1ff081a9177aedac7ea2802))
- ❇️ Param added in default constructor: `mountChildImmediately` (named, optional, default: false)
- ❇️ Property added: `mountChildImmediately`

**`class` LdTabNavigation** ([lib/src/appbar/tab_navigation.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-52bf35196752849d0d45f783bb5b24e4217e93ef2ae5ff75caafe39bc5b551fc))
- ❇️ Params added in default constructor: `trailing` (named, optional), `leading` (named, optional)
- ❇️ Properties added: `trailing`, `leading`

**`class` LdTimePicker** ([lib/src/time_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-fb045078ea903e4c0c3ae338b38f895d4245816be0481759aeb4cfc98122b476))
- ❇️ Param added in default constructor: `size` (named, optional, default: LdSize.m)
- ❇️ Property added: `size`

**`class` LdTimeline** ([lib/src/timeline.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-79c106f74d8f461be24a03c4d86f8b5b070d4cc5344cb33f7fd477309cc2d3d0))
- ❇️ Class added: `LdTimeline`

**`class` LdTimelineItem** ([lib/src/timeline.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-79c106f74d8f461be24a03c4d86f8b5b070d4cc5344cb33f7fd477309cc2d3d0))
- ❇️ Class added: `LdTimelineItem`

**`enum` LdTimelineLineType** ([lib/src/timeline.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-79c106f74d8f461be24a03c4d86f8b5b070d4cc5344cb33f7fd477309cc2d3d0))
- ❇️ Enum added: `LdTimelineLineType`

**`class` LdTouchableSurface** ([lib/src/touchable/touchable.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-390c2ec1e7b0ebec409f605c4cdc4ea7ef337cf7876bdca7a87de6f2c647ea96))
- ❇️ Param added in default constructor: `noFocusOnTap` (named, optional, default: false)
- ❇️ Property added: `noFocusOnTap`

**`class` LiquidLocalizations** ([lib/src/l10n/generated/liquid_localizations.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-355d12226806e42fbe28958594669ec350c927c0fc7c9226bf2b78c89f288995))
- ❇️ Properties added: `deleting`, `selectRecurrence`, `recurrenceFrequency`, `recurrenceSecondly`, `recurrenceMinutely`, `recurrenceHourly`, `recurrenceDaily`, `recurrenceWeekly`, `recurrenceMonthly`, `recurrenceYearly`, `recurrenceEvery`, `recurrenceOnDay`, `recurrenceOnThe`, `recurrenceLastDay`, `recurrenceNthFirst`, `recurrenceNthSecond`, `recurrenceNthThird`, `recurrenceNthFourth`, `recurrenceNthLast`, `recurrenceEnds`, `recurrenceEndsNever`, `recurrenceEndsOn`, `recurrenceEndsAfter`, `recurrenceNextOccurrences`, `recurrenceUnsupportedHint`, `recurrenceOn`, `recurrenceIn`, `recurrenceUntil`, `recurrenceViewAllOccurrences`, `recurrenceAllOccurrences`, `recurrenceAt`, `recurrenceHours`, `recurrenceMinutes`, `recurrenceTimesMatrixHint`, `selectRecurrences`, `recurrenceAddRule`, `selectDuration`, `durationHintYears`, `durationHintMonths`, `durationHintWeeks`, `durationHintDays`, `durationHintHours`, `durationHintMinutes`, `durationHintSeconds`
- ❇️ Methods added: `recurrenceUnitSeconds`, `recurrenceUnitMinutes`, `recurrenceUnitHours`, `recurrenceUnitDays`, `recurrenceUnitWeeks`, `recurrenceUnitMonths`, `recurrenceUnitYears`, `recurrenceOccurrences`, `recurrenceTimes`, `recurrenceNthOccurrence`, `recurrenceLastNthOccurrence`, `recurrenceShowingFirstN`, `recurrenceNMore`, `recurrenceAtTimes`, `recurrenceRulesCount`, `durationCompactYears`, `durationCompactMonths`, `durationCompactWeeks`, `durationCompactDays`, `durationCompactHours`, `durationCompactMinutes`, `durationCompactSeconds`, `durationUnitYears`, `durationUnitMonths`, `durationUnitWeeks`, `durationUnitDays`, `durationUnitHours`, `durationUnitMinutes`, `durationUnitSeconds`

**`class` _LdButtonWidget** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- ❇️ Param added in default constructor: `noFocusOnTap` (named, optional, default: false)

**`function` ldAppBarActionGroupMenuChildren** ([lib/src/appbar/appbar_action_group.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-dd312b93254ed5e7b7a91b2f96bd76b08f06caef1468508ac83719dfd21d2bf7))
- ❇️ Function added: `ldAppBarActionGroupMenuChildren`

**`function` ldClampRecurrenceTimes** ([lib/src/rrule/rrule_draft.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-0e9f52cae888744190cd2e922904aac1cb710448140259354db146f6d5f14f7c))
- ❇️ Function added: `ldClampRecurrenceTimes`

**`function` ldDurationUnitHint** ([lib/src/duration/ld_duration_format.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-cc04f0e8e30f17bb70560e370bda58d5e2e8d510c61079cc5745ee6b3e4218cb))
- ❇️ Function added: `ldDurationUnitHint`

**`function` ldFlattenMonkeyActions<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/actions/actions.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-250ba08dbbe05925449c761878d3265c71d99d63e119d34feda97f183532dd30))
- ❇️ Function added: `ldFlattenMonkeyActions`

**`function` ldFormatDuration** ([lib/src/duration/ld_duration_format.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-cc04f0e8e30f17bb70560e370bda58d5e2e8d510c61079cc5745ee6b3e4218cb))
- ❇️ Function added: `ldFormatDuration`

**`function` ldFromRruleUtc** ([lib/src/rrule/rrule_draft.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-0e9f52cae888744190cd2e922904aac1cb710448140259354db146f6d5f14f7c))
- ❇️ Function added: `ldFromRruleUtc`

**`function` ldGroupLabelTooltip** ([lib/src/input_group.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-c654b60a9d1bdeadc55e3f2104021a9a99aca812f1a465caa15942aa7db199fe))
- ❇️ Function added: `ldGroupLabelTooltip`

**`function` ldInputGroupAddonsPreview** ([lib/src/input_group.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-c654b60a9d1bdeadc55e3f2104021a9a99aca812f1a465caa15942aa7db199fe))
- ❇️ Function added: `ldInputGroupAddonsPreview`

**`function` ldInputGroupBasicPreview** ([lib/src/input_group.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-c654b60a9d1bdeadc55e3f2104021a9a99aca812f1a465caa15942aa7db199fe))
- ❇️ Function added: `ldInputGroupBasicPreview`

**`function` ldLocaleOrderedWeekdays** ([lib/src/rrule/rrule_summary.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-77309a182cfeb22ab4840b8e33924ba39dec261b8f74c5d9992f4589c8ef28b8))
- ❇️ Function added: `ldLocaleOrderedWeekdays`

**`function` ldMonkeyAppBarActionWidgets<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/actions/app_bar_actions.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-7e2580b61094599c12a19178307a1c7658a88a5fa9242b062552d217710e3c5d))
- ❇️ Function added: `ldMonkeyAppBarActionWidgets`

**`function` ldNthWeekdayOccurrence** ([lib/src/rrule/rrule_draft.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-0e9f52cae888744190cd2e922904aac1cb710448140259354db146f6d5f14f7c))
- ❇️ Function added: `ldNthWeekdayOccurrence`

**`function` ldRecurrenceDeltaLabel** ([lib/src/rrule/rrule_summary.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-77309a182cfeb22ab4840b8e33924ba39dec261b8f74c5d9992f4589c8ef28b8))
- ❇️ Function added: `ldRecurrenceDeltaLabel`

**`function` ldRecurrenceFrequencyIsSubDaily** ([lib/src/rrule/rrule_draft.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-0e9f52cae888744190cd2e922904aac1cb710448140259354db146f6d5f14f7c))
- ❇️ Function added: `ldRecurrenceFrequencyIsSubDaily`

**`function` ldRecurrenceIntervalLabel** ([lib/src/rrule/rrule_summary.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-77309a182cfeb22ab4840b8e33924ba39dec261b8f74c5d9992f4589c8ef28b8))
- ❇️ Function added: `ldRecurrenceIntervalLabel`

**`function` ldRecurrenceMinuteOptions** ([lib/src/rrule/rrule_draft.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-0e9f52cae888744190cd2e922904aac1cb710448140259354db146f6d5f14f7c))
- ❇️ Function added: `ldRecurrenceMinuteOptions`

**`function` ldRecurrenceMonthLabel** ([lib/src/rrule/rrule_summary.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-77309a182cfeb22ab4840b8e33924ba39dec261b8f74c5d9992f4589c8ef28b8))
- ❇️ Function added: `ldRecurrenceMonthLabel`

**`function` ldRecurrenceMonthShortLabel** ([lib/src/rrule/rrule_summary.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-77309a182cfeb22ab4840b8e33924ba39dec261b8f74c5d9992f4589c8ef28b8))
- ❇️ Function added: `ldRecurrenceMonthShortLabel`

**`function` ldRecurrenceNthLabel** ([lib/src/rrule/rrule_summary.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-77309a182cfeb22ab4840b8e33924ba39dec261b8f74c5d9992f4589c8ef28b8))
- ❇️ Function added: `ldRecurrenceNthLabel`

**`function` ldRecurrenceOccurrenceFormat** ([lib/src/rrule/rrule_summary.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-77309a182cfeb22ab4840b8e33924ba39dec261b8f74c5d9992f4589c8ef28b8))
- ❇️ Function added: `ldRecurrenceOccurrenceFormat`

**`function` ldRecurrenceOrdinal** ([lib/src/rrule/rrule_summary.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-77309a182cfeb22ab4840b8e33924ba39dec261b8f74c5d9992f4589c8ef28b8))
- ❇️ Function added: `ldRecurrenceOrdinal`

**`function` ldRecurrenceRuleHasUnsupportedParts** ([lib/src/rrule/rrule_draft.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-0e9f52cae888744190cd2e922904aac1cb710448140259354db146f6d5f14f7c))
- ❇️ Function added: `ldRecurrenceRuleHasUnsupportedParts`

**`function` ldRecurrenceRuleSummary** ([lib/src/rrule/rrule_summary.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-77309a182cfeb22ab4840b8e33924ba39dec261b8f74c5d9992f4589c8ef28b8))
- ❇️ Function added: `ldRecurrenceRuleSummary`

**`function` ldRecurrenceTimesFromParts** ([lib/src/rrule/rrule_draft.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-0e9f52cae888744190cd2e922904aac1cb710448140259354db146f6d5f14f7c))
- ❇️ Function added: `ldRecurrenceTimesFromParts`

**`function` ldRecurrenceTimesFromRule** ([lib/src/rrule/rrule_draft.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-0e9f52cae888744190cd2e922904aac1cb710448140259354db146f6d5f14f7c))
- ❇️ Function added: `ldRecurrenceTimesFromRule`

**`function` ldRecurrenceUnitLabel** ([lib/src/rrule/rrule_summary.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-77309a182cfeb22ab4840b8e33924ba39dec261b8f74c5d9992f4589c8ef28b8))
- ❇️ Function added: `ldRecurrenceUnitLabel`

**`function` ldRecurrenceWeekdayLabel** ([lib/src/rrule/rrule_summary.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-77309a182cfeb22ab4840b8e33924ba39dec261b8f74c5d9992f4589c8ef28b8))
- ❇️ Function added: `ldRecurrenceWeekdayLabel`

**`function` ldRecurrenceWeekdayShortLabel** ([lib/src/rrule/rrule_summary.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-77309a182cfeb22ab4840b8e33924ba39dec261b8f74c5d9992f4589c8ef28b8))
- ❇️ Function added: `ldRecurrenceWeekdayShortLabel`

**`function` ldToRruleUtc** ([lib/src/rrule/rrule_draft.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-0e9f52cae888744190cd2e922904aac1cb710448140259354db146f6d5f14f7c))
- ❇️ Function added: `ldToRruleUtc`

#### 👀 Patch changes

**`class` LdChoose<T extends Identifiable<IdType>, IdType>** ([lib/src/choose/choose.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-6ce965d70e5a38c7bb7d300718c981f5dd5c18807dcaf9b633cdc74c1d5c5c74))
- ❌ Property removed: `_usesMonkeyPicker`
- ❇️ Method added: `_selectItemSearchText`

**`class` LdChooseInputTrigger<T extends Identifiable<IdType>, IdType>** ([lib/src/choose/choose_input_trigger.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-a4c64776859f48de2224df3ce1a2dcf5fadc39b3f8c64225643ab1cdcd3abbff))
- ❇️ Method added: `_selection`

**`class` LdListController<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/data/list_controller.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-2bd19515e63ce2d64323e30fa8b37fd3ca7fac879e8a0089508961972dcadd7c))
- ❇️ Property added: `_revealTimers`
- ➖ Method annotation removed: `dispose` (@mustCallSuper)
- ➕ Method annotation added: `dispose` (@override)
- ❇️ Method added: `_scheduleRevealAnimation`

**`class` LdLocalizedException** ([lib/src/exception/model/exception.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-12c04f03aed1ea809f666cff20093761481831385aa468beea43c61cd27c3dcc))
- ➕ Method annotation added: `copyWith` (@override)

**`class` LdModalRoute<T>** ([lib/src/modal/modal.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-2d55c400b021d628a7e92bc6d07673f3775bac69b40c544c8332ae622d0f715d))
- ❇️ Method added: `_screenConstraints`

**`class` LdMonkeyActionScope<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/actions/action_scope.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-8d8d4164833c3126607ed8c0b376d0b7f342466f50145aac25aa8535d5840ef6))
- ❇️ Properties added: `_count`, `_listeners`, `_notificationCallStackDepth`, `_reentrantlyRemovedListeners`, `_debugDisposed`, `_debugCreationDispatched`
- ❇️ Method added: `_removeAt`

**`class` LdMonkeyRouterAdapterState<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_router_adapter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-38733ea6a1cce5fbf22de0240816bf176f58d0e504bf36a2b06519fe5f9a108d))
- ❇️ Properties added: `_definitionDefaultsSeeded`, `_awaitingDefaultsUrlSync`
- ❇️ Methods added: `_scheduleDefaultsUrlSync`, `_hydrateSortAndFilterState`

**`class` LdScaffoldBody** ([lib/src/scaffold_body.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-25fd66a644218adca4f46a542b28e361a2aea16ff32c8a2def5a1819cf1c507b))
- ➖ Methods annotation removed: `debugFillProperties` (@protected), `debugFillProperties` (@mustCallSuper)
- ➕ Method annotation added: `debugFillProperties` (@override)

**`class` LdSwitch<T>** ([lib/src/switch.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-d8b30ecf078361f71ed29b6fb0755c25a0bb96217a1fbb7ba1593d825db75278))
- ❇️ Param added in method `_buildItem`: `size` (positional, required)

**`class` _AppBarFrameState** ([lib/src/appbar/appbar_frame.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-f5dae86f88f57d7eacd239b0beba44a7a95e301f01ff1dd11b53d1ec43864c92))
- ❇️ Property added: `_barFocused`
- ❌ Methods removed: `_adaptiveBorderRadius`, `_insidePadding`

**`class` _LdAppBarActionGroupDivider** ([lib/src/appbar/appbar_action_group.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-dd312b93254ed5e7b7a91b2f96bd76b08f06caef1468508ac83719dfd21d2bf7))
- ❇️ Class added: `_LdAppBarActionGroupDivider`

**`class` _LdAppBarWidgetState** ([lib/src/appbar/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-3fa4ae735c9f6ca4c26ac958e08eaa30e2da735b6e0f0ed00665eb6c2b2bb49f))
- ❇️ Properties added: `_barHasFocusedInputCache`, `_lastViewMetrics`
- ❇️ Method added: `_snappedInsets`

**`class` _LdButtonState** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- ❇️ Properties added: `_scope`, `_size`

**`class` _LdButtonWidget** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- ❇️ Property added: `noFocusOnTap`

**`class` _LdChainedSpringsState** ([lib/src/spring.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-5ac3b6f3d42047bf8fafd8bf82ad0f1c13e3a0b4d3f9b6e6cbb1c2788647f15a))
- ❇️ Property added: `_chainedShouldTick`
- ❇️ Methods added: `_syncChainedTicker`, `_onChainedTick`

**`class` _LdChooseState<T extends Identifiable<IdType>, IdType>** ([lib/src/choose/choose.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-6ce965d70e5a38c7bb7d300718c981f5dd5c18807dcaf9b633cdc74c1d5c5c74))
- ❌ Property removed: `_effectiveSearchText`
- ❌ Method removed: `_resolveSearchText`
- ❇️ Methods added: `_getSearchSuggestions`, `_effectiveFiltersBuilder`

**`class` _LdDurationPickerModalState** ([lib/src/duration_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-1ccb326244a8ea9acd286914510c8e65c1eaf4773bb12b532c549dd6d9575123))
- ❇️ Class added: `_LdDurationPickerModalState`

**`class` _LdDurationPickerWidgetState** ([lib/src/duration_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-1ccb326244a8ea9acd286914510c8e65c1eaf4773bb12b532c549dd6d9575123))
- ❇️ Class added: `_LdDurationPickerWidgetState`

**`class` _LdListItemWidgetState** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- ➕ Mixin added: AutomaticKeepAliveClientMixin
- ❇️ Properties added: `_keepAliveHandle`, `wantKeepAlive`
- ➖ Methods annotation removed: `initState` (@protected), `initState` (@mustCallSuper), `didUpdateWidget` (@mustCallSuper), `didUpdateWidget` (@protected), `deactivate` (@protected), `deactivate` (@mustCallSuper), `dispose` (@protected), `dispose` (@mustCallSuper)
- ➕ Methods annotation added: `initState` (@override), `didUpdateWidget` (@override), `deactivate` (@override), `dispose` (@override)
- ❇️ Methods added: `_ensureKeepAlive`, `_releaseKeepAlive`, `updateKeepAlive`

**`class` _LdListReorderScopeState<T extends Identifiable<IdType>, IdType>** ([lib/src/list/reorderable_list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-7fba1dfd3dfe7dce17c728b3b6196db4d04769e588d7de2b34901f5b0567fa1f))
- ❇️ Properties added: `_scrollable`, `_autoScroller`, `_lastDragPosition`
- ❇️ Methods added: `_ensureAutoScroller`, `_dragTargetRect`, `_onAutoScrollTick`

**`class` _LdLoaderState** ([lib/src/loading.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-ebcc4b4214d20bfb03a2fbeee643fc07dae381788b8f53a32f1ab77c6a1fd9c3))
- ➖ Methods annotation removed: `didUpdateWidget` (@mustCallSuper), `didUpdateWidget` (@protected)
- ➕ Method annotation added: `didUpdateWidget` (@override)

**`class` _LdMonkeyMasterPageState<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_master_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-f027b9824ac3c8ae9ddbe6ac353d6cb02c90fe60d3a5d83846b29dbd7ec3c437))
- ❇️ Property added: `_ldListKey`

**`class` _LdMonkeyPickerScopeState<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_picker_scope.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-d1599e4a12ee6169e95864395fcf14659a019ba7fdaddf746f622a39c34a244a))
- ➖ Methods annotation removed: `didUpdateWidget` (@mustCallSuper), `didUpdateWidget` (@protected)
- ➕ Method annotation added: `didUpdateWidget` (@override)

**`class` _LdMonkeyViewingBuilderState<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/detail_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-43d347b03da89e053d770a97150585d0955be32f82540fad5d2ceabd18d33035))
- ❇️ Class added: `_LdMonkeyViewingBuilderState`

**`class` _LdMultiPanelLayoutState** ([lib/src/multi_panel/multi_panel_layout.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-dcf83dd1348efc710dbc6957e505c08eb421234a466c65f2b9630f2f41b83750))
- ❌ Property removed: `_bodyDecoration`
- ❇️ Method added: `_bodyDecoration`

**`class` _LdOrbState** ([lib/src/liquid_orb.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-77302ae24f129be07973b7dedb81c73569eef9d7e22d7c51c0d8c4b7d6813f72))
- ❌ Properties removed: `_tween`, `_animation`

**`class` _LdOverflowAlwaysChildElement** ([lib/src/overflow/always_child.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-7ca10594f81b83d216be83e2bf855b2c2809c23a4429eb4087e795e2d8748ec1))
- ❇️ Class added: `_LdOverflowAlwaysChildElement`

**`class` _LdRecurrenceFormState** ([lib/src/rrule/recurrence_form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-da19c9691aa50460bf60d73b3014e6df0c0d36f38ffb09bee6504aa908ff178e))
- ❇️ Class added: `_LdRecurrenceFormState`

**`class` _LdRecurrenceMultiPickerModal** ([lib/src/rrule/recurrence_multi_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-c23a7ea47e504750fd8cf861bce190543a0934dbafaeb8c17439a00b55b308da))
- ❇️ Class added: `_LdRecurrenceMultiPickerModal`

**`class` _LdRecurrenceMultiPickerModalState** ([lib/src/rrule/recurrence_multi_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-c23a7ea47e504750fd8cf861bce190543a0934dbafaeb8c17439a00b55b308da))
- ❇️ Class added: `_LdRecurrenceMultiPickerModalState`

**`class` _LdRecurrencePickerModalState** ([lib/src/rrule/recurrence_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-4eda84644402cd4ac4911790652a64ac92ae7f1fc8a9748a831ce4edd0795fa3))
- ❇️ Class added: `_LdRecurrencePickerModalState`

**`class` _LdSearchSuggestionsOverlayState** ([lib/src/appbar/search_components.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-c7750a1ad0e6a79e8cd9a447bd3f31dd1c31866d30873339df5d2bea4b410ecd))
- 🔄 Property type changed: `_fadeAnimation`

**`class` _LdSelectState<T>** ([lib/src/select.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-bc5dd59ffff566f496d4463c5136fdcba05247739d6102d1b7578f12d41e30ac))
- ❇️ Param added in method `_buildInitialItem`: `size` (positional, required)
- ❇️ Param added in method `_buildDropdownButton`: `size` (named, required)

**`class` _LdSpringState** ([lib/src/spring.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-5ac3b6f3d42047bf8fafd8bf82ad0f1c13e3a0b4d3f9b6e6cbb1c2788647f15a))
- ❇️ Property added: `_shouldTick`
- ❇️ Methods added: `_syncTicker`, `_onTick`

**`class` _LdSubmitNotificationState<T, Arg>** ([lib/src/submit/builders/notification_builder.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-9c6d145646b33b86392036585f3f6e79308af86c2cc191543dd1276b13cbe9c3))
- ❌ Method removed: `_dismissNotification`
- 🔢 Param reordered in method `_onStateChanged`: `controller` (positional, required)
- ❌ Param removed in method `_onStateChanged`: `state` (positional, required)
- ❇️ Method added: `_maybeDismissNotification`

**`class` _LdSubmitState<T, Arg>** ([lib/src/submit/submit.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-90dec5a624a3cd55bf16ed8f4d39486f0ad3f7b8e1ff081a9177aedac7ea2802))
- ❇️ Properties added: `_isInitialRender`, `_initialRenderTimer`

**`class` _LdTabBarScrollArea** ([lib/src/appbar/tab_navigation.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-52bf35196752849d0d45f783bb5b24e4217e93ef2ae5ff75caafe39bc5b551fc))
- ❇️ Class added: `_LdTabBarScrollArea`

**`class` _LdTabNavigationIndicator** ([lib/src/appbar/tab_navigation.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-52bf35196752849d0d45f783bb5b24e4217e93ef2ae5ff75caafe39bc5b551fc))
- ❇️ Class added: `_LdTabNavigationIndicator`

**`class` _LdTabNavigationItem** ([lib/src/appbar/tab_navigation.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-52bf35196752849d0d45f783bb5b24e4217e93ef2ae5ff75caafe39bc5b551fc))
- ❇️ Class added: `_LdTabNavigationItem`

**`class` _LdTabNavigationState** ([lib/src/appbar/tab_navigation.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-52bf35196752849d0d45f783bb5b24e4217e93ef2ae5ff75caafe39bc5b551fc))
- ❌ Properties removed: `_tabSpacing`, `_tabStride`, `_contentWidth`, `_tabWidth`, `_availableWidth`, `_totalSpacing`, `_compactMode`
- ❇️ Properties added: `_pageAnimationDuration`, `_scrollAnimationDuration`, `_metrics`
- ❌ Method removed: `_getClosestTab`
- ❇️ Methods added: `_animateToPage`, `_scheduleNavWidthSync`, `_closestTabIndex`, `_onIndicatorDragStart`, `_selectTab`, `_buildTabBar`, `_buildTabRow`

**`class` _LdTimePickerWidgetState** ([lib/src/time_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-fb045078ea903e4c0c3ae338b38f895d4245816be0481759aeb4cfc98122b476))
- ❇️ Modifier `late` added to properties: `_hourController`, `_minuteController`
- ❌ Modifier `final` removed from property: `_minuteController`
- 🔄 Property type changed: `_time`
- ❇️ Properties added: `_syncingWheels`, `_minuteIndex`
- ➖ Methods annotation removed: `didUpdateWidget` (@mustCallSuper), `didUpdateWidget` (@protected)
- ➕ Method annotation added: `didUpdateWidget` (@override)
- ❌ Methods removed: `_applyWheels`, `_submit`
- ❇️ Methods added: `_jumpWheels`, `_onHourWheelChanged`, `_onMinuteWheelChanged`, `_wheelFrame`, `_wheelItem`

**`class` _LoadingPainter** ([lib/src/loading.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-ebcc4b4214d20bfb03a2fbeee643fc07dae381788b8f53a32f1ab77c6a1fd9c3))
- 🔠 Params became named in default constructor: `animation` (positional, required), `loaderSize` (positional, required)
- ➕ Method annotation added: `shouldRebuildSemantics` (@override)

**`class` _OrbPainter** ([lib/src/liquid_orb.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-77302ae24f129be07973b7dedb81c73569eef9d7e22d7c51c0d8c4b7d6813f72))
- 🔠 Params became named in default constructor: `fillPercentage` (positional, required), `paintBackground` (positional, required), `theme` (positional, required)
- ❌ Property removed: `animationProgress`
- ❇️ Property added: `animation`
- ➕ Method annotation added: `shouldRebuildSemantics` (@override)

**`class` _RenderLdOverflowAlwaysChild** ([lib/src/overflow/always_child.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-7ca10594f81b83d216be83e2bf855b2c2809c23a4429eb4087e795e2d8748ec1))
- ❇️ Class added: `_RenderLdOverflowAlwaysChild`

**`class` _TabBarMetrics** ([lib/src/appbar/tab_navigation.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-52bf35196752849d0d45f783bb5b24e4217e93ef2ae5ff75caafe39bc5b551fc))
- ❇️ Class added: `_TabBarMetrics`

**`meta` pubspec.yaml** ([pubspec.yaml](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-8b7e9df87668ffa6a04b32e1769a33434999e54ae081c52e5d943c541d4c0d25))
- 📦 Added `rrule`: with version `^0.2.18`

**`function` _buildAppBarTrigger<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/actions/app_bar_actions.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-7e2580b61094599c12a19178307a1c7658a88a5fa9242b062552d217710e3c5d))
- ❇️ Function added: `_buildAppBarTrigger`

**`function` _isGroupMenuBoundary** ([lib/src/appbar/appbar_action_group.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-dd312b93254ed5e7b7a91b2f96bd76b08f06caef1468508ac83719dfd21d2bf7))
- ❇️ Function added: `_isGroupMenuBoundary`

**`function` _ldChooseDefaultSearchFilter<T extends Identifiable<IdType>, IdType>** ([lib/src/choose/choose.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-6ce965d70e5a38c7bb7d300718c981f5dd5c18807dcaf9b633cdc74c1d5c5c74))
- ❇️ Function added: `_ldChooseDefaultSearchFilter`

**`function` _recurrenceRulesSummary** ([lib/src/rrule/recurrence_multi_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-c23a7ea47e504750fd8cf861bce190543a0934dbafaeb8c17439a00b55b308da))
- ❇️ Function added: `_recurrenceRulesSummary`

**`function` _rulesIncludeTime** ([lib/src/rrule/recurrence_multi_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-c23a7ea47e504750fd8cf861bce190543a0934dbafaeb8c17439a00b55b308da))
- ❇️ Function added: `_rulesIncludeTime`

**`function` _tabBarItemRadius** ([lib/src/appbar/tab_navigation.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-52bf35196752849d0d45f783bb5b24e4217e93ef2ae5ff75caafe39bc5b551fc))
- ❇️ Function added: `_tabBarItemRadius`

**`function` _unwrap** ([lib/src/input_group.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-c654b60a9d1bdeadc55e3f2104021a9a99aca812f1a465caa15942aa7db199fe))
- ❇️ Function added: `_unwrap`

**`function` _wrapAppBarOverflowMode** ([lib/src/monkey/actions/app_bar_actions.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter/v23.0.0-13..liquid_flutter/v23.0.0-14#diff-7e2580b61094599c12a19178307a1c7658a88a5fa9242b062552d217710e3c5d))
- ❇️ Function added: `_wrapAppBarOverflowMode`

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
