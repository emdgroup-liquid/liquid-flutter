## 23.0.0-4
Released on: 6/23/2026, changelog automatically generated.

## Unreleased

## 23.0.0-3
Released on: automatic fallback dev bump to avoid duplicate 23.0.0-2 publish.

### Features

- **LdRepository:** add `affectedByUpdate` on filter/sort options (replaces deprecated `mutationAffectsCache`) for shared cache invalidation and paginator layout decisions
- **LdPaginator:** add `repositionItemById`, safe delete compaction (`canCompactIndicesAfterDeletion` / `compactIndicesAfterDeletion`), and reposition-or-refresh mutation flows in `LdRepository`

### Deprecations

- `mutationAffectsCache` on `LdFilterOption` / `LdSortOption` — use `affectedByUpdate` instead
- `LdMutationAffectsCache` typedef — use `LdAffectedByUpdate` instead

## 23.0.0
Released on: 5/20/2026, changelog automatically generated.


### Bug Fixes

- **LdRepository:** restore filtered items when optimistic filters broaden ([#71](issues/71)) ([f04c97a](commit/f04c97a))
- address technical debt - memory leaks, stub implementations, refactor AppBar and MultiPanelLayout ([#81](issues/81)) ([f6673fa](commit/f6673fa))
- watch effective layout ([349419c](commit/349419c))
- add key super argument for generated classes ([a454d48](commit/a454d48))
- **tab_navigation:** replace overflow menu with horizontal scrolling ([8ace50a](commit/8ace50a))
- **button:** improve layout, circular sizing, and add debugFillProperties ([e0a7a98](commit/e0a7a98))
- **time_picker:** add LdAppBar with done action and set topGapRatio ([8dd4fd5](commit/8dd4fd5))
- **choose:** use input surface mode and fix placeholder hint styling ([e33b785](commit/e33b785))
- **date_picker:** render day cells as circular buttons ([f93e061](commit/f93e061))
- **form:** use LdAutoSpace for field and form-level spacing ([b5baf9a](commit/b5baf9a))
- **submit:** use LdAutoSpace in vertical loading indicator layout ([f4903ce](commit/f4903ce))
### Features

- **LdRepository:** add LdFetchReason, LdRepositoryCache, and LdRepository.greedy for eager full-dataset loading
- **LdRepository:** add `cacheKey`, page-aware cache (`readPage`/`writePage`/`all`), and auto-cache/auto-invalidate wrappers (default on)
- **liquid_flutter_md:** add markdown package and example demo ([#73](issues/73)) ([ef9eaa3](commit/ef9eaa3))
- **modal:** make topGapRatio configurable on LdModalRoute ([28c41f0](commit/28c41f0))
- **appbar:** rework LdAppBar with wrapper-based composition (Issue [#91](issues/91)) ([#98](issues/98)) ([f3ebc89](commit/f3ebc89))
- **monkey:** add LdMonkeyActionContext, action host/scope split for submit actions; context menu actions use appContext for providers
- **multi_panel:** Stage 1 - add LdPanelPosition, LdPanelRole enums and extend LdMultiPanelChildState ([9285455](commit/9285455))
- Monkey API  ([#90](issues/90)) ([3478bf5](commit/3478bf5))

### API Changes

#### 💣 Breaking changes

**`typedef` FetchListFunction<T>** ([lib/src/list/list_paginator.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-c279977c526f2e1ad42c33e9e9f5451f323d228e7974b6ae305a16daa9ff8dc8))
- 🔄 Typedef type changed: FetchListFunction
- 🔄 Type parameters changed: `T` → `T extends Identifiable<IdType>, IdType`

**`extension` GetItemList<T>** ([lib/src/list/list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-888f80c71ddeacb424418138bd38d5900a4ffe694069cba2af68eb89e66a4a41))
- 🔄 Extension type changed: `GetItemList`
- 🔄 Type parameters changed: `T` → `T extends Identifiable<IdType>, IdType`
- 🔄 Method type changed: `currentList` (`List<_ListItem<T, GroupingCriterion>>` → `List<LdListRenderItem<T>>`)
- 🔄 Type parameters changed: `GroupingCriterion` → ``

**`extension` GoRouterExt** ([lib/src/master_detail.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-80147b9866d7287354dd14c965d448fb4533272c7164e2faa7b4a0f7ed280c60))
- ❌ Extension removed: `GoRouterExt`

**`class` LdAccordion** ([lib/src/accordion.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-d258daf61538439919df0bdb2434133a11f77b8b917079c64ecce8c56883d1d0))
- ❌ Properties removed: `curveExpand`, `curveCollapse`

**`class` LdAppBar** ([lib/src/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-c052cf2a20bf84a3bb43daf0349ef5972bd9083a4a8c318d75c4f3b23c1793c6))
- 🔄 Superclass changed: `StatelessWidget` → `StatefulWidget`
- ➖ Interface removed: PreferredSizeWidget
- 🔄 Param type changed in default constructor: `actions` (`List<Widget>?` → `List<Widget>`)
- ❌ Properties removed: `preferredSize`, `elevation`, `iconTheme`, `primary`, `centerTitle`, `titleSpacing`, `toolbarOpacity`, `bottomOpacity`, `toolbarHeight`, `titleTextStyle`, `actionsIconTheme`, `flexibleSpace`, `foregroundColor`, `automaticallyImplyLeading`, `clipBehavior`, `shape`, `toolbarTextStyle`, `leadingWidth`, `notificationPredicate`, `forceMaterialTransparency`, `scrolledUnderElevation`, `surfaceTintColor`, `excludeHeaderSemantics`, `context`
- 🔄 Property type changed: `actions`
- ❌ Method removed: `build`

**`class` LdAvatar** ([lib/src/avatar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e142afc5a4b71ea7f96a73a1f1b6ac035d2721395f0b2905b345fc22ff602458))
- 🔄 Param type changed in default constructor: `circular` (`bool` → `bool?`), `size` (`LdSize` → `LdSize?`)
- 🔄 Properties type changed: `circular`, `size`

**`class` LdBadgeError** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdBadgeError`

**`class` LdBadgeSuccess** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdBadgeSuccess`

**`class` LdBadgeWarning** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdBadgeWarning`

**`class` LdButton** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- 🔄 Superclass changed: `StatefulWidget` → `StatelessWidget`
- 🔄 Param type changed in default constructor: `onPressed` (`Function` → `FutureOr<void> Function()`), `autoLoading` (`bool` → `bool?`), `disabled` (`bool` → `bool?`), `mode` (`LdButtonMode` → `LdButtonMode?`), `size` (`LdSize` → `LdSize?`)
- 🔄 Properties type changed: `onPressed`, `disabled`, `autoLoading`, `mode`, `size`
- ❌ Method removed: `createState`

**`class` LdButtonError** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdButtonError`

**`class` LdButtonFilled** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdButtonFilled`

**`class` LdButtonGhost** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdButtonGhost`

**`class` LdButtonOutline** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdButtonOutline`

**`class` LdButtonSuccess** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdButtonSuccess`

**`class` LdButtonVague** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdButtonVague`

**`class` LdButtonWarning** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdButtonWarning`

**`class` LdChainedSprings** ([lib/src/spring.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-5ac3b6f3d42047bf8fafd8bf82ad0f1c13e3a0b4d3f9b6e6cbb1c2788647f15a))
- 🔄 Param type changed in default constructor: `builder` (`Widget Function(BuildContext, List<LdSpringState>)` → `Widget Function(BuildContext, List<LdSpringState>, Widget?)`)
- 🔄 Property type changed: `builder`

**`class` LdCheckbox** ([lib/src/checkbox.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-212494581d361b843cfc944c41577dc67246a6cfcd3adcc6c8732ec7791c2599))
- 🔄 Superclass changed: `StatefulWidget` → `StatelessWidget`
- 🔄 Param type changed in default constructor: `checked` (`bool` → `bool?`), `size` (`LdSize` → `LdSize?`), `disabled` (`bool` → `bool?`)
- 🔄 Properties type changed: `checked`, `disabled`, `size`
- ❌ Method removed: `createState`

**`class` LdCheckboxError** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdCheckboxError`

**`class` LdCheckboxSuccess** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdCheckboxSuccess`

**`class` LdCheckboxWarning** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdCheckboxWarning`

**`class` LdChoose<T>** ([lib/src/choose.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-7ac0dbb4a4066cbff0ac50927605c02a4480a89c02fff56480625ff3198d3337))
- 🔄 Type parameters changed: `T` → `T extends Identifiable<IdType>, IdType`
- 🔄 Param type changed in default constructor: `items` (`Iterable<LdSelectItem<T>>` → `List<T>?`), `value` (`Set<T>?` → `Set<IdType>?`)
- ❌ Param removed in default constructor: `onChange` (named, required)
- ❇️ Params added in default constructor: `itemBuilder` (named, required), `selectedItemBuilder` (named, required), `onChanged` (named, required)
- 🔄 Properties type changed: `items`, `value`
- ❌ Properties removed: `onChange`, `placeholder`, `enableSearch`
- 🔄 Method type changed: `createState` (`State<LdChoose<T>>` → `State<LdChoose<T, IdType>>`)

**`class` LdCollapse** ([lib/src/collapse.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e4733e85d67e8f44f8cefc8d0aabc8c867c2a692a838d619e4d819632ae20496))
- 🔄 Method type changed: `createState` (`_LdCollapseState` → `LdCollapseState`)

**`class` LdConfirmNotification** ([lib/src/notifications/notification.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-2d80b837facf3fbfcd94fe48b413804d2488c3bf5b450f85e93c049f19f20fc9))
- ❌ Class removed: `LdConfirmNotification`

**`class` LdContainer** ([lib/src/container.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-0855c980dde3d19bfc99d65777c17622b6f977e91632f223afefb91282aeb495))
- 🔄 Param type changed in default constructor: `maxWidth` (`double` → `double?`)
- 🔄 Property type changed: `maxWidth`

**`class` LdContextMenu** ([lib/src/context_menu.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-bd031ede2f184bbdb13c86e7300dc3ab6f62af650bf3cc1bd5c74ad2fe3e824e))
- 🔄 Param type changed in default constructor: `builder` (`Widget Function(BuildContext, bool, void Function())` → `Widget Function(BuildContext, bool, void Function(), bool, Widget?)`), `menuBuilder` (`Widget Function(BuildContext, void Function())` → `Widget Function(BuildContext)`)
- ❌ Property removed: `blurMode`
- 🔄 Properties type changed: `builder`, `menuBuilder`

**`enum` LdContextMenuBlurMode** ([lib/src/context_menu.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-bd031ede2f184bbdb13c86e7300dc3ab6f62af650bf3cc1bd5c74ad2fe3e824e))
- ❌ Enum removed: `LdContextMenuBlurMode`

**`class` LdDatePicker** ([lib/src/date_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-705cf9a7b3b5d494795266f0d9bd90767b033dd2dc19f3eee04d709951be9dd7))
- 🔄 Superclass changed: `StatelessWidget` → `StatefulWidget`
- 🔄 Param type changed in default constructor: `onChanged` (`void Function(DateTime?)` → `void Function(DateTime)`)
- 🔄 Property type changed: `onChanged`
- ❌ Properties removed: `initialDateJiffy`, `initialDateString`
- ❌ Method removed: `build`

**`class` LdDialogType** ([lib/src/modal/modal_types.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-9b488f59ac86c8380043432f471742ba7365e8cb18e0e7c4eb3f565ef0bc5ea5))
- ❌ Class removed: `LdDialogType`

**`class` LdDrawerHeader** ([lib/src/drawer/header.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-87cb952f8a628aeb0386ac5aa71ad01a8f0daa0750f4cef52d3fdf8545afac24))
- ❌ Class removed: `LdDrawerHeader`

**`class` LdDrawerItemSection** ([lib/src/drawer/section_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-28f28c80e2d46cf11a2f828c1c71e2ea1855ad735a2b4fa745622261f5d31cca))
- ❌ Property removed: `onTap`

**`class` LdException** ([lib/src/exception/model/exception.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-12c04f03aed1ea809f666cff20093761481831385aa468beea43c61cd27c3dcc))
- ❌ Param removed in default constructor: `message` (named, required)
- ❌ Properties removed: `message`, `moreInfo`

**`class` LdExceptionMapper** ([lib/src/exception/exception_mapper.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-28b0c331036e614fa95b8972965b2d236b84f21964859484974eb0decfc7d809))
- ❌ Class removed: `LdExceptionMapper`

**`class` LdExceptionMapperProvider** ([lib/src/exception/exception_mapper.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-28b0c331036e614fa95b8972965b2d236b84f21964859484974eb0decfc7d809))
- ❌ Class removed: `LdExceptionMapperProvider`

**`class` LdExceptionMoreInfoButton** ([lib/src/exception/exception_more_info_button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-93430ed1c604ffea0e892e09e24983dc8a37637de1c4009b01d2a70aabc18483))
- 🔄 Param type changed in default constructor: `error` (`LdException?` → `LdLocalizedException?`)
- 🔄 Property type changed: `error`

**`class` LdExceptionRetryIndicator** ([lib/src/exception/retry_indicator.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-6cc4acc54863d3ead021568a4d6f2ced99eaaaafeca277f4edd88bc4971ea408))
- ❇️ Param added in default constructor: `cancelRetry` (named, required)

**`class` LdExceptionView** ([lib/src/exception/exception_view.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-3b9caa32d813b4accee332539fa3d1e44ecc015a406dd715143f70a5e7c96088))
- 🔄 Param type changed in default constructor: `exception` (`LdException?` → `LdException`)
- ❌ Constructor removed: `fromDynamic`
- 🔄 Property type changed: `exception`

**`class` LdInput** ([lib/src/input.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-2ffc2d5e6008b31f35c68f6ed0d27138168bf19c95df7c0aab8349787a9a5ef6))
- 🔄 Param type changed in default constructor: `onSubmitted` (`dynamic Function(String?)?` → `dynamic Function(String)?`), `onChanged` (`dynamic Function(String?)?` → `dynamic Function(String)?`)
- 🔄 Properties type changed: `onChanged`, `onSubmitted`
- ❌ Property removed: `onBlur`

**`class` LdInputNotification** ([lib/src/notifications/notification.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-2d80b837facf3fbfcd94fe48b413804d2488c3bf5b450f85e93c049f19f20fc9))
- ❌ Class removed: `LdInputNotification`

**`class` LdList<T, GroupingCriterion>** ([lib/src/list/list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-888f80c71ddeacb424418138bd38d5900a4ffe694069cba2af68eb89e66a4a41))
- 🔄 Superclass changed: `StatefulWidget` → `StatelessWidget`
- 🔄 Type parameters changed: `T, GroupingCriterion` → `T extends Identifiable<IdType>, IdType`
- 🔄 Param type changed in default constructor: `emptyBuilder` (`Widget Function(BuildContext, Future<void> Function())?` → `Widget Function(BuildContext, Future<void> Function(BuildContext))?`), `itemBuilder` (`Widget Function(BuildContext, T, int)` → `Widget Function(BuildContext, LdPaginatorLoadedItem<T>, int)?`), `paginator` (`LdPaginator<T>` → `LdPaginator<T, IdType>?`), `groupHeaderBuilder` (`Widget Function(BuildContext, GroupingCriterion)?` → `Widget Function(BuildContext, dynamic, List<LdPaginatorItem<T>>)?`), `groupingCriterion` (`GroupingCriterion Function(T)?` → `dynamic Function(T)?`), `primary` (`bool` → `bool?`), `shrinkWrap` (`bool` → `bool?`)
- 🔄 Properties type changed: `itemBuilder`, `emptyBuilder`, `groupingCriterion`, `groupHeaderBuilder`, `paginator`, `shrinkWrap`, `primary`
- ❌ Method removed: `createState`

**`class` LdListItem** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- 🔄 Param type changed in default constructor: `active` (`bool` → `bool?`), `isSelected` (`bool` → `bool?`), `disabled` (`bool` → `bool?`)
- 🔄 Properties type changed: `active`, `isSelected`, `disabled`
- ❌ Properties removed: `onTap`, `onSelectionChange`, `radioSelection`, `trailingForward`, `showSelectionControls`

**`typedef` LdListItemBuilder<T>** ([lib/src/list/list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-888f80c71ddeacb424418138bd38d5900a4ffe694069cba2af68eb89e66a4a41))
- 🔄 Typedef type changed: LdListItemBuilder
- 🔄 Type parameters changed: `T` → `T extends Identifiable<dynamic>`

**`class` LdListPage<T>** ([lib/src/list/list_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-1a8cac588961ab42d73539922e36de72efd066b5ff2545a8128fd36030a0da92))
- ❌ Property removed: `error`

**`class` LdMasterDetail<T>** ([lib/src/master_detail.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-80147b9866d7287354dd14c965d448fb4533272c7164e2faa7b4a0f7ed280c60))
- ❌ Class removed: `LdMasterDetail`

**`class` LdMasterDetailBuilder<T>** ([lib/src/master_detail.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-80147b9866d7287354dd14c965d448fb4533272c7164e2faa7b4a0f7ed280c60))
- ❌ Class removed: `LdMasterDetailBuilder`

**`typedef` LdMasterDetailOnSelect<T>** ([lib/src/master_detail.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-80147b9866d7287354dd14c965d448fb4533272c7164e2faa7b4a0f7ed280c60))
- ❌ Typedef removed: `LdMasterDetailOnSelect`

**`typedef` LdMasterDetailOnSelectCallback<T>** ([lib/src/master_detail.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-80147b9866d7287354dd14c965d448fb4533272c7164e2faa7b4a0f7ed280c60))
- ❌ Typedef removed: `LdMasterDetailOnSelectCallback`

**`class` LdModal** ([lib/src/modal/modal.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-2d55c400b021d628a7e92bc6d07673f3775bac69b40c544c8332ae622d0f715d))
- ❌ Class removed: `LdModal`

**`class` LdModalBuilder** ([lib/src/modal/modal_builder.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-08bae03dcf5ccaf9504540dfb133095616852dd884f1e07373b5d7bd486a072c))
- 🔄 Param type changed in default constructor: `modal` (`LdModal` → `LdModalRoute<dynamic>`)
- 🔄 Property type changed: `modal`

**`class` LdModalPage** ([lib/src/modal/modal_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-631ab921ead5b8110d200c0106bd500edcd6d089dc8efd32c150f33228e6341c))
- 🔄 Type parameters changed: `` → `T`
- 🔄 Param type changed in default constructor: `builder` (`LdModal` → `LdModalRoute<T> Function(BuildContext)`)
- 🔄 Property type changed: `builder`
- 🔄 Method type changed: `createRoute` (`Route<void>` → `Route<T>`)

**`enum` LdNotificationType** ([lib/src/notifications/notification_type.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-4868d2bee7eb473125c91170fca59174416cb846be3f63f405c786c7f6d1e6b8))
- ❌ Properties removed: `confirm`, `enterText`

**`class` LdNotificationWidget** ([lib/src/notifications/notification_portal.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-5ecbf35c381d0c71f97cc9da48294271c95cf4655da1f141b5a297e4f94765d1))
- ❌ Params removed in default constructor: `onConfirm` (named, required), `onSubmitInput` (named, required), `onCancel` (named, required)
- ❌ Properties removed: `onConfirm`, `onCancel`, `onSubmitInput`

**`class` LdNotificationsController** ([lib/src/notifications/notifications_controller.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-7473196fa6b569fc3a6cdb5236987f2f7abd38e3216144e037039ad7a759e982))
- 🔄 Method type changed: `error` (`Future<LdNotification>` → `LdNotification`), `success` (`Future<LdNotification>` → `LdNotification`), `warning` (`Future<LdNotification>` → `LdNotification`), `addNotification` (`Future<LdNotification>` → `LdNotification`)
- ❌ Methods removed: `confirm`, `enterText`, `onConfirmedNotification`, `onInputSubmitted`, `onCancelledNotification`

**`class` LdPaginator<T>** ([lib/src/list/list_paginator.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-c279977c526f2e1ad42c33e9e9f5451f323d228e7974b6ae305a16daa9ff8dc8))
- 🔄 Type parameters changed: `T` → `T extends Identifiable<IdType>, IdType`
- 🔄 Param type changed in default constructor: `fetchListFunction` (`Future<LdListPage<T>> Function({required int offset, required int pageSize, String? pageToken})` → `Future<LdListPage<T>> Function(FetchPageParameters<T, IdType>)?`)
- 🔄 Properties type changed: `fetchListFunction`, `error`
- 🔄 Method type changed: `getItemAt` (`T?` → `LdPaginatorItem<T>?`)
- ❌ Method removed: `fetchItemsAtOffset`
- 🔢 Param reordered in method `fetchPageAtOffset`: `offset` (positional, required)
- ❇️ Param added in method `fetchPageAtOffset`: `context` (positional, required)
- ❇️ Param added in method `refreshList`: `context` (named, required)

**`class` LdPortal** ([lib/src/portal.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-78adc36d5336fa7b691c38deddf5ce262ac43fab2fc73beb733eea422ecbf2c1))
- ❌ Class removed: `LdPortal`

**`class` LdPortalController** ([lib/src/portal.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-78adc36d5336fa7b691c38deddf5ce262ac43fab2fc73beb733eea422ecbf2c1))
- ❌ Class removed: `LdPortalController`

**`class` LdPortalEntry** ([lib/src/portal.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-78adc36d5336fa7b691c38deddf5ce262ac43fab2fc73beb733eea422ecbf2c1))
- ❌ Class removed: `LdPortalEntry`

**`class` LdRadioError** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdRadioError`

**`class` LdRadioSuccess** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdRadioSuccess`

**`class` LdRadioWarning** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdRadioWarning`

**`class` LdRetryConfig** ([lib/src/exception/model/retry_config.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f109fedccf68e4510b0180d75525074d12139fd40ae01fe8c3ca1d8f80c51056))
- 🔄 Superclass changed: `Object` → `Equatable`

**`class` LdRunnerStep** ([lib/src/runner.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-6b567e02a0af50b04f70212b6f0e9f870e0ed5de80b85853890572d0a7493947))
- 🔄 Param type changed in default constructor: `children` (`List<Widget>` → `List<Widget>?`)
- 🔄 Property type changed: `children`

**`class` LdSelect<T>** ([lib/src/select.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-bc5dd59ffff566f496d4463c5136fdcba05247739d6102d1b7578f12d41e30ac))
- ❌ Property removed: `onChange`

**`class` LdSelectableList<T, GroupingCriterion>** ([lib/src/list/selectable_list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f78a865a5b517b6892730363bb581f1e53588fb39b9bc88417dea463806327c7))
- 🔄 Type parameters changed: `T, GroupingCriterion` → `T extends Identifiable<IdType>, IdType`
- 🔄 Param type changed in default constructor: `itemBuilder` (`Widget Function({required BuildContext context, required int index, required bool isMultiSelect, required T item, required void Function(bool) onSelectionChange, required void Function() onTap, required bool selected})` → `Widget Function(BuildContext, LdPaginatorItem<T>, int)`), `listBuilder` (`LdList<T, GroupingCriterion> Function(BuildContext, ScrollController, Widget Function(BuildContext, T, int))` → `Widget Function(BuildContext, Widget Function(BuildContext, LdPaginatorLoadedItem<T>, int))?`), `onSelectionChange` (`void Function(Set<T>)?` → `void Function(Set<IdType>)?`), `paginator` (`LdPaginator<T>` → `LdPaginator<T, IdType>`)
- 🔄 Properties type changed: `itemBuilder`, `listBuilder`, `paginator`, `onSelectionChange`
- 🔄 Method type changed: `createState` (`State<LdSelectableList<T, GroupingCriterion>>` → `State<LdSelectableList<T, IdType>>`)

**`class` LdSheetType** ([lib/src/modal/modal_types.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-9b488f59ac86c8380043432f471742ba7365e8cb18e0e7c4eb3f565ef0bc5ea5))
- ❌ Class removed: `LdSheetType`

**`class` LdSpring** ([lib/src/spring.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-5ac3b6f3d42047bf8fafd8bf82ad0f1c13e3a0b4d3f9b6e6cbb1c2788647f15a))
- 🔄 Param type changed in default constructor: `builder` (`Widget Function(BuildContext, LdSpringState)` → `Widget Function(BuildContext, LdSpringState, Widget?)`)
- 🔄 Property type changed: `builder`

**`class` LdSubmit<T>** ([lib/src/submit/submit.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-90dec5a624a3cd55bf16ed8f4d39486f0ad3f7b8e1ff081a9177aedac7ea2802))
- 🔄 Superclass changed: `StatelessWidget` → `StatefulWidget`
- 🔄 Type parameters changed: `T` → `T, Arg`
- 🔄 Param type changed in default constructor: `config` (`LdSubmitConfig<T>?` → `LdSubmitConfig<T, Arg>?`), `controller` (`LdSubmitController<T>?` → `LdSubmitController<T, Arg>?`)
- 🔄 Properties type changed: `config`, `controller`
- ❌ Properties removed: `builder`, `submitBuilder`
- ❌ Method removed: `build`

**`class` LdSubmitBuilder<T>** ([lib/src/submit/submit.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-90dec5a624a3cd55bf16ed8f4d39486f0ad3f7b8e1ff081a9177aedac7ea2802))
- 🔄 Type parameters changed: `T` → `T, Arg`
- 🔄 Param type changed in default constructor: `resultBuilder` (`Widget Function(BuildContext, T, LdSubmitController<T>)?` → `Widget Function(BuildContext, T, LdSubmitController<T, Arg>)?`), `submitButtonBuilder` (`Widget Function(BuildContext, LdSubmitController<T>)?` → `Widget Function(BuildContext, LdSubmitController<T, Arg>)?`), `loadingBuilder` (`Widget Function(BuildContext, LdSubmitController<T>)?` → `Widget Function(BuildContext, LdSubmitController<T, Arg>)?`), `errorBuilder` (`Widget Function(BuildContext, LdException, LdSubmitController<T>)?` → `Widget Function(BuildContext, LdException, LdSubmitController<T, Arg>)?`)
- 🔄 Properties type changed: `resultBuilder`, `submitButtonBuilder`, `loadingBuilder`, `errorBuilder`

**`typedef` LdSubmitButtonBuilder<T>** ([lib/src/submit/submit.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-90dec5a624a3cd55bf16ed8f4d39486f0ad3f7b8e1ff081a9177aedac7ea2802))
- 🔄 Typedef type changed: LdSubmitButtonBuilder
- 🔄 Type parameters changed: `T` → `T, Arg`

**`typedef` LdSubmitCallback<T>** ([lib/src/submit/submit.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-90dec5a624a3cd55bf16ed8f4d39486f0ad3f7b8e1ff081a9177aedac7ea2802))
- 🔄 Typedef type changed: LdSubmitCallback
- 🔄 Type parameters changed: `T` → `T, Arg`

**`class` LdSubmitCenteredBuilder<T>** ([lib/src/submit/builders/centered_builder.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f53761f3b71a31e3217ff71fd135bbab141b97e6afd97a25cd7e3498bc638c12))
- 🔄 Type parameters changed: `T` → `T, Arg`
- 🔄 Param type changed in default constructor: `resultBuilder` (`Widget Function(BuildContext, T, LdSubmitController<T>)?` → `Widget Function(BuildContext, T, LdSubmitController<T, Arg>)?`), `submitButtonBuilder` (`Widget Function(BuildContext, LdSubmitController<T>)?` → `Widget Function(BuildContext, LdSubmitController<T, Arg>)?`), `loadingBuilder` (`Widget Function(BuildContext, LdSubmitController<T>)?` → `Widget Function(BuildContext, LdSubmitController<T, Arg>)?`), `errorBuilder` (`Widget Function(BuildContext, LdException, LdSubmitController<T>)?` → `Widget Function(BuildContext, LdException, LdSubmitController<T, Arg>)?`)
- 🔄 Properties type changed: `resultBuilder`, `submitButtonBuilder`, `loadingBuilder`, `errorBuilder`

**`class` LdSubmitConfig<T>** ([lib/src/submit/model/submit_config.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-b47d5b90994b395b32ba37a1724b89db6d61e0ac7b9a4f58a63b5c7e0f62630c))
- 🔄 Superclass changed: `Object` → `Equatable`
- 🔄 Type parameters changed: `T` → `T, Arg`
- 🔄 Param type changed in default constructor: `allowResubmit` (`bool?` → `bool`), `allowCancel` (`bool?` → `bool`), `action` (`Future<T> Function()` → `Future<T> Function(Arg?)`)
- 🔄 Properties type changed: `allowResubmit`, `allowCancel`, `action`

**`class` LdSubmitController<T>** ([lib/src/submit/model/submit_controller.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-d921dcc848cbe3ce44f849c2be50e41f4300cb5bddb83fe2c189bea7f63c8f34))
- 🔄 Type parameters changed: `T` → `T, Arg`
- 🔄 Param type changed in default constructor: `config` (`LdSubmitConfig<T>` → `LdSubmitConfig<T, Arg>`)
- ❌ Param removed in default constructor: `exceptionMapper` (named, required)
- 🔄 Property type changed: `config`
- ❌ Property removed: `exceptionMapper`

**`class` LdSubmitCustomBuilder<T>** ([lib/src/submit/builders/custom_builder.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-2b4f49eafad5ac815a7df3eeadcd97d2e1ac4612ab7e30b3b11f6b472bb252b7))
- 🔄 Type parameters changed: `T` → `T, Arg`
- 🔄 Param type changed in default constructor: `builder` (`Widget Function(BuildContext, LdSubmitController<T>, LdSubmitStateType)` → `Widget Function(BuildContext, LdSubmitController<T, Arg>, LdSubmitStateType)`)
- 🔄 Property type changed: `builder`

**`class` LdSubmitDialogBuilder<T>** ([lib/src/submit/builders/dialog_builder.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-667617a61b037cae73c86a02fac20c0c80283ad8dc680535c250ada7f9ae994a))
- 🔄 Type parameters changed: `T` → `T, Arg`
- 🔄 Param type changed in default constructor: `resultBuilder` (`Widget Function(BuildContext, T, LdSubmitController<T>)?` → `Widget Function(BuildContext, T, LdSubmitController<T, Arg>)?`), `errorBuilder` (`Widget Function(BuildContext, LdException, LdSubmitController<T>)?` → `Widget Function(BuildContext, LdException, LdSubmitController<T, Arg>)?`), `loadingBuilder` (`Widget Function(BuildContext, LdSubmitController<T>)?` → `Widget Function(BuildContext, LdSubmitController<T, Arg>)?`), `submitButtonBuilder` (`Widget Function(BuildContext, LdSubmitController<T>)?` → `Widget Function(BuildContext, LdSubmitController<T, Arg>)?`)
- 🔄 Properties type changed: `resultBuilder`, `submitButtonBuilder`, `loadingBuilder`, `errorBuilder`
- ❌ Property removed: `dialogKey`
- ❌ Methods removed: `buildLoadingDialog`, `buildErrorDialog`

**`typedef` LdSubmitErrorBuilder<T>** ([lib/src/submit/submit.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-90dec5a624a3cd55bf16ed8f4d39486f0ad3f7b8e1ff081a9177aedac7ea2802))
- 🔄 Typedef type changed: LdSubmitErrorBuilder
- 🔄 Type parameters changed: `T` → `T, Arg`

**`class` LdSubmitInlineBuilder<T>** ([lib/src/submit/builders/inline_builder.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-85a98a1597a4de71af9b3c5b9016210d32b5f12d14b7b4bd2bce41c3e15db53a))
- 🔄 Type parameters changed: `T` → `T, Arg`
- 🔄 Param type changed in default constructor: `resultBuilder` (`Widget Function(BuildContext, T, LdSubmitController<T>)?` → `Widget Function(BuildContext, T, LdSubmitController<T, Arg>)?`), `submitButtonBuilder` (`Widget Function(BuildContext, LdSubmitController<T>)?` → `Widget Function(BuildContext, LdSubmitController<T, Arg>)?`), `errorBuilder` (`Widget Function(BuildContext, LdException, LdSubmitController<T>)?` → `Widget Function(BuildContext, LdException, LdSubmitController<T, Arg>)?`)
- 🔄 Properties type changed: `resultBuilder`, `submitButtonBuilder`, `loadingBuilder`, `errorBuilder`
- ❌ Method removed: `buildSubmitButton`

**`typedef` LdSubmitLoadingBuilder<T>** ([lib/src/submit/submit.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-90dec5a624a3cd55bf16ed8f4d39486f0ad3f7b8e1ff081a9177aedac7ea2802))
- 🔄 Typedef type changed: LdSubmitLoadingBuilder
- 🔄 Type parameters changed: `T` → `T, Arg`

**`class` LdSubmitLoadingIndicator** ([lib/src/submit/submit_loading_indicator.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-09d1a7a8d50b754a8465b037876e60b85d895de2829c8ed8d7c59c119910207b))
- 🔄 Type parameters changed: `` → `T, Arg`
- ❌ Param removed in default constructor: `loading` (named, required)
- ❌ Properties removed: `loading`, `loadingText`

**`typedef` LdSubmitResultBuilder<T>** ([lib/src/submit/submit.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-90dec5a624a3cd55bf16ed8f4d39486f0ad3f7b8e1ff081a9177aedac7ea2802))
- 🔄 Typedef type changed: LdSubmitResultBuilder
- 🔄 Type parameters changed: `T` → `T, Arg`

**`class` LdTable<T>** ([lib/src/table.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-ef98608b9a8b08eb5208319f42f1b44644df8b7b941ef381fb63c43a6b0656e4))
- ❌ Property removed: `onSelectChange`

**`class` LdTabs** ([lib/src/tabs.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-79c9826669efbf745277c7afeac65e9b6781617860f0465b13337ec2ee63168a))
- ❌ Class removed: `LdTabs`

**`class` LdTagError** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdTagError`

**`class` LdTagSuccess** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdTagSuccess`

**`class` LdTagWarning** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdTagWarning`

**`class` LdTextCaption** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdTextCaption`

**`class` LdTextH** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdTextH`

**`class` LdTextHl** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdTextHl`

**`class` LdTextHs** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdTextHs`

**`class` LdTextHxs** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdTextHxs`

**`class` LdTextL** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdTextL`

**`class` LdTextLl** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdTextLl`

**`class` LdTextLs** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdTextLs`

**`class` LdTextLxs** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdTextLxs`

**`class` LdTextP** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdTextP`

**`class` LdTextPl** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdTextPl`

**`class` LdTextPs** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdTextPs`

**`class` LdTextPxs** ([lib/variants.g.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e27b11b167765ae364b87df5ff163b89a1ffcfe901d4163e5720ff5f245a8123))
- ❌ Class removed: `LdTextPxs`

**`class` LdThemeProvider** ([lib/src/theme/theme_provider.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-bb56e3df14103825a8edc59aa7689986b2bface5596870727b1ab28297f86e57))
- ❌ Property removed: `autoSize`

**`class` LdTimePicker** ([lib/src/time_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-fb045078ea903e4c0c3ae338b38f895d4245816be0481759aeb4cfc98122b476))
- 🔄 Param type changed in default constructor: `onChanged` (`void Function(TimeOfDay?)` → `void Function(TimeOfDay)`)
- 🔄 Property type changed: `onChanged`

**`class` LdTouchableSurface** ([lib/src/touchable/touchable.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-390c2ec1e7b0ebec409f605c4cdc4ea7ef337cf7876bdca7a87de6f2c647ea96))
- 🔄 Param type changed in default constructor: `builder` (`Widget Function(BuildContext, LdColorBundle, LdTouchableStatus)` → `Widget Function(BuildContext, LdTouchableStatus, Widget?)`)
- ❌ Param removed in default constructor: `onTap` (named, required)
- ❇️ Param added in default constructor: `onPressed` (named, required)
- ❌ Properties removed: `color`, `mode`, `onTap`
- 🔄 Property type changed: `builder`

**`class` LdWindowFrame** ([lib/src/window_frame.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-dbdb23098a936a2806f790c5756e86f1a21d8b93561b6e0a1e68bcc24bb3e3e9))
- 🔄 Property type changed: `title`
- ❌ Property removed: `showWindowFrame`

**`enum` MasterDetailLayoutMode** ([lib/src/master_detail.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-80147b9866d7287354dd14c965d448fb4533272c7164e2faa7b4a0f7ed280c60))
- ❌ Enum removed: `MasterDetailLayoutMode`

**`enum` MasterDetailPresentationMode** ([lib/src/master_detail.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-80147b9866d7287354dd14c965d448fb4533272c7164e2faa7b4a0f7ed280c60))
- ❌ Enum removed: `MasterDetailPresentationMode`

**`meta` Minimum Dart SDK version increased** ([pubspec.yaml](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-8b7e9df87668ffa6a04b32e1769a33434999e54ae081c52e5d943c541d4c0d25))
- 🎯 Minimum Dart SDK version increased: from `>=3.0.0 <4.0.0` to `>=3.5.0 <4.0.0`

**`typedef` OnSelectionChange** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- ❌ Typedef removed: `OnSelectionChange`

**`class` _ButtonShape** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- ❇️ Param added in default constructor: `disableSqueeze` (named, required)

**`class` _DatePickerSheet** ([lib/src/date_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-705cf9a7b3b5d494795266f0d9bd90767b033dd2dc19f3eee04d709951be9dd7))
- ⚠️ Params became required in default constructor: `minDate` (named, optional), `maxDate` (named, optional)
- ❌ Params removed in default constructor: `value` (named, required), `onChanged` (named, required), `dismiss` (named, required)
- ❇️ Param added in default constructor: `selectedDateNotifier` (named, required)

**`class` _DragRect** ([lib/src/list/selectable_list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f78a865a5b517b6892730363bb581f1e53588fb39b9bc88417dea463806327c7))
- 🔄 Param type changed in default constructor: `onUpdateRect` (`void Function(Rect)` → `void Function(Rect, bool)`)
- ❇️ Param added in default constructor: `onTapOutside` (named, required)

**`class` _LdAccordionChild** ([lib/src/accordion.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-d258daf61538439919df0bdb2434133a11f77b8b917079c64ecce8c56883d1d0))
- ❌ Params removed in default constructor: `flatCard` (named, required), `curveExpand` (named, required), `curveCollapse` (named, required)
- ❇️ Params added in default constructor: `disableElevation` (named, required), `size` (named, required)

**`class` _LdButtonState** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- 🔄 Param type changed in method `didUpdateWidget`: `oldWidget` (`LdButton` → `_LdButtonWidget`)

**`class` _LdCheckboxState** ([lib/src/checkbox.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-212494581d361b843cfc944c41577dc67246a6cfcd3adcc6c8732ec7791c2599))
- 🔄 Param type changed in method `didUpdateWidget`: `oldWidget` (`LdCheckbox` → `_LdCheckboxWidget`)

**`class` _LdChooseState<T>** ([lib/src/choose.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-7ac0dbb4a4066cbff0ac50927605c02a4480a89c02fff56480625ff3198d3337))
- 🔄 Param type changed in method `didUpdateWidget`: `oldWidget` (`LdChoose<T>` → `LdChoose<T, IdType>`)

**`class` _LdListState<T, GroupingCriterion>** ([lib/src/list/list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-888f80c71ddeacb424418138bd38d5900a4ffe694069cba2af68eb89e66a4a41))
- 🔄 Param type changed in method `didUpdateWidget`: `oldWidget` (`LdList<T, GroupingCriterion>` → `LdListWidget<T, IdType>`)

**`class` _LdSelectableListState<T, GroupingCriterion>** ([lib/src/list/selectable_list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f78a865a5b517b6892730363bb581f1e53588fb39b9bc88417dea463806327c7))
- 🔄 Param type changed in method `didUpdateWidget`: `oldWidget` (`LdSelectableList<T, GroupingCriterion>` → `LdSelectableList<T, IdType>`)

**`function` getScreenRadius** ([lib/src/theme/screen_radius.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-a5f16a3a2fa3b73fe3f0a3e88641e9f7f60d9081edb84c2f400576fa599ec89c))
- ❌ Function removed: `getScreenRadius`

**`function` neutralGhostColor** ([lib/src/touchable/touchable.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-390c2ec1e7b0ebec409f605c4cdc4ea7ef337cf7876bdca7a87de6f2c647ea96))
- ❌ Function removed: `neutralGhostColor`

**`function` touchableColor** ([lib/src/touchable/touchable.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-390c2ec1e7b0ebec409f605c4cdc4ea7ef337cf7876bdca7a87de6f2c647ea96))
- ❌ Function removed: `touchableColor`

#### ✨ Minor changes

**`extension` AtLeastEdgeInsets** ([lib/src/scaffold.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-35c580af7b94cd13fc78765d9afc1f836ec439643e1a61922b4b6c7a0614553d))
- ❇️ Extension added: `AtLeastEdgeInsets`

**`class` CloseDrawerAction** ([lib/src/monkey/actions/actions.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-250ba08dbbe05925449c761878d3265c71d99d63e119d34feda97f183532dd30))
- ❇️ Class added: `CloseDrawerAction`

**`class` CloseDrawerButton** ([lib/src/appbar/drawer_buttons.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-998051ffbe5c2156247ec3ddd0dae8857b52454fad9991da3821f6ba5e3cdc1b))
- ❇️ Class added: `CloseDrawerButton`

**`extension` ColumnSpacing** ([lib/src/padding.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f86451e3937e772cac008fcbbe050bb1deba8b3c2034db8e47879228fc363e18))
- ❇️ Extension added: `ColumnSpacing`

**`class` ContextConfigurable** ([lib/src/annotations.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-684d73ec610cb537a248e57776e1b0dab25e3c98b32ab824a578346e75e3e1fe))
- ❇️ Class added: `ContextConfigurable`

**`class` FetchOffsetParameters<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/data/fetch_page_parameters.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-d021e526a9882fd604228a370eefaceebc0fc93ea40bf51001d6632c0dda06be))
- ❇️ Class added: `FetchOffsetParameters`

**`class` FetchPageParameters<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/data/fetch_page_parameters.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-d021e526a9882fd604228a370eefaceebc0fc93ea40bf51001d6632c0dda06be))
- ❇️ Class added: `FetchPageParameters`

**`extension` FilterEquals<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_shell.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f58e8426a3074373d1a4d8d50d0d7467233933c3ceffe3098ffc530558a3aa9b))
- ❇️ Extension added: `FilterEquals`

**`mixin` Identifiable<I>** ([lib/src/monkey/data/identifiable.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-1ad47ab88bda68f42e7541dcdfed075bd482339738d29a796d6844d245329cef))
- ❇️ Mixin added: `Identifiable`

**`extension` InRange** ([lib/src/monkey/filter/ld_filter_range.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-bf38054883adc797e5840cf283d60d46e21ba512471c51e299aaada452eec6b9))
- ❇️ Extension added: `InRange`

**`class` LdAccordion** ([lib/src/accordion.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-d258daf61538439919df0bdb2434133a11f77b8b917079c64ecce8c56883d1d0))
- ❌ Params removed in default constructor: `curveCollapse` (named, optional, default: Curves.easeOut), `curveExpand` (named, optional, default: Curves.easeIn)
- ❇️ Param added in default constructor: `size` (named, optional)
- ❇️ Param added in constructor `fromList`: `size` (named, optional)
- ❇️ Constructor added: `single`
- ❇️ Property added: `size`

**`class` LdAppBar** ([lib/src/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-c052cf2a20bf84a3bb43daf0349ef5972bd9083a4a8c318d75c4f3b23c1793c6))
- ❌ Params removed in default constructor: `context` (named, optional), `elevation` (named, optional), `iconTheme` (named, optional), `primary` (named, optional), `centerTitle` (named, optional), `titleSpacing` (named, optional), `toolbarOpacity` (named, optional), `bottomOpacity` (named, optional), `toolbarHeight` (named, optional), `titleTextStyle` (named, optional), `actionsIconTheme` (named, optional), `flexibleSpace` (named, optional), `foregroundColor` (named, optional), `automaticallyImplyLeading` (named, optional), `clipBehavior` (named, optional), `shape` (named, optional), `toolbarTextStyle` (named, optional), `leadingWidth` (named, optional), `notificationPredicate` (named, optional), `forceMaterialTransparency` (named, optional), `scrolledUnderElevation` (named, optional), `surfaceTintColor` (named, optional), `excludeHeaderSemantics` (named, optional)
- ❇️ Params added in default constructor: `child` (named, optional), `addContainer` (named, optional, default: false), `attachedMode` (named, optional, default: LdAppBarAttachedMode.adaptive), `autoAttachToKeyboard` (named, optional, default: true), `backgroundMode` (named, optional, default: LdAppBarBackgroundMode.adaptive), `borderMode` (named, optional, default: LdAppBarBorderMode.adaptive), `bottom` (named, optional), `debugName` (named, optional), `implyCloseModalButton` (named, optional, default: true), `implyLeading` (named, optional), `avoidViewInsets` (named, optional, default: false), `order` (named, optional, default: 0), `overflowMenuProviders` (named, optional), `positionMode` (named, optional, default: LdAppBarPositionMode.top), `scrollBehavior` (named, optional, default: LdAppBarScrollBehavior.static), `searchConfig` (named, optional), `shadowMode` (named, optional, default: LdAppBarShadowMode.adaptive), `showWindowControls` (named, optional, default: true), `trailing` (named, optional)
- ❇️ Constructors added: `top`, `bottom`
- ❇️ Properties added: `trailing`, `implyLeading`, `addContainer`, `bottom`, `shadowMode`, `borderMode`, `backgroundMode`, `attachedMode`, `showWindowControls`, `implyCloseModalButton`, `avoidViewInsets`, `autoAttachToKeyboard`, `callbacks`, `overflowMenuProviders`, `searchConfig`, `debugName`, `positionMode`, `scrollBehavior`, `order`, `child`
- ❇️ Method added: `createState`

**`class` LdAppBarAction** ([lib/src/appbar/appbar_action.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-794db106d4f7693d7c1084b7103a07eaab28bb6e2ae95034930d7d423bc07135))
- ❇️ Class added: `LdAppBarAction`

**`enum` LdAppBarActionDisplayMode** ([lib/src/appbar/appbar_action.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-794db106d4f7693d7c1084b7103a07eaab28bb6e2ae95034930d7d423bc07135))
- ❇️ Enum added: `LdAppBarActionDisplayMode`

**`typedef` LdAppBarActionRequestedLeading** ([lib/src/appbar/appbar_action.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-794db106d4f7693d7c1084b7103a07eaab28bb6e2ae95034930d7d423bc07135))
- ❇️ Typedef added: `LdAppBarActionRequestedLeading`

**`enum` LdAppBarAttachedMode** ([lib/src/appbar/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-3fa4ae735c9f6ca4c26ac958e08eaa30e2da735b6e0f0ed00665eb6c2b2bb49f))
- ❇️ Enum added: `LdAppBarAttachedMode`

**`enum` LdAppBarBackgroundMode** ([lib/src/appbar/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-3fa4ae735c9f6ca4c26ac958e08eaa30e2da735b6e0f0ed00665eb6c2b2bb49f))
- ❇️ Enum added: `LdAppBarBackgroundMode`

**`enum` LdAppBarBorderMode** ([lib/src/appbar/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-3fa4ae735c9f6ca4c26ac958e08eaa30e2da735b6e0f0ed00665eb6c2b2bb49f))
- ❇️ Enum added: `LdAppBarBorderMode`

**`class` LdAppBarMetrics** ([lib/src/appbar/appbar_state.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-3e75260b022f83d5ee36c231362f6603999ada7073b656454d1545bcd74b197d))
- ❇️ Class added: `LdAppBarMetrics`

**`enum` LdAppBarPosition** ([lib/src/appbar/appbar_state.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-3e75260b022f83d5ee36c231362f6603999ada7073b656454d1545bcd74b197d))
- ❇️ Enum added: `LdAppBarPosition`

**`enum` LdAppBarPositionMode** ([lib/src/appbar/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-3fa4ae735c9f6ca4c26ac958e08eaa30e2da735b6e0f0ed00665eb6c2b2bb49f))
- ❇️ Enum added: `LdAppBarPositionMode`

**`enum` LdAppBarScrollBehavior** ([lib/src/scaffold.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-35c580af7b94cd13fc78765d9afc1f836ec439643e1a61922b4b6c7a0614553d))
- ❇️ Enum added: `LdAppBarScrollBehavior`

**`enum` LdAppBarShadowMode** ([lib/src/appbar/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-3fa4ae735c9f6ca4c26ac958e08eaa30e2da735b6e0f0ed00665eb6c2b2bb49f))
- ❇️ Enum added: `LdAppBarShadowMode`

**`class` LdAppbarActionOverflowMenu** ([lib/src/appbar/appbar_action_overflow_menu.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-1dfc9d78e0c3270012a678e8145e8c0c5d5ddf4b6b6fae409550c889040f0281))
- ❇️ Class added: `LdAppbarActionOverflowMenu`

**`extension` LdAutoSpaceExt** ([lib/src/autospace.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f17bdf0d5830aa5697a0e806f3c3035e3563b69cdf810372144eae69594248a3))
- ❇️ Extension added: `LdAutoSpaceExt`

**`class` LdAvatar** ([lib/src/avatar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e142afc5a4b71ea7f96a73a1f1b6ac035d2721395f0b2905b345fc22ff602458))
- ❇️ Param added in default constructor: `emoji` (named, optional, default: false)
- ❇️ Property added: `emoji`
- ❇️ Methods added: `success`, `warning`, `error`

**`class` LdAvatarConfig** ([lib/src/avatar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e142afc5a4b71ea7f96a73a1f1b6ac035d2721395f0b2905b345fc22ff602458))
- ❇️ Class added: `LdAvatarConfig`

**`class` LdAvatarConfigProvider** ([lib/src/avatar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e142afc5a4b71ea7f96a73a1f1b6ac035d2721395f0b2905b345fc22ff602458))
- ❇️ Class added: `LdAvatarConfigProvider`

**`class` LdBadge** ([lib/src/badge.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-99f2e9441527e24b1059221b3e99a1406fa2d269fc008cd72c67955619ca3a48))
- ❇️ Methods added: `success`, `warning`, `error`

**`class` LdBadgeWidget** ([lib/src/badge.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-99f2e9441527e24b1059221b3e99a1406fa2d269fc008cd72c67955619ca3a48))
- ❇️ Class added: `LdBadgeWidget`

**`class` LdBottomBar** ([lib/src/appbar/bottom_bar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-178e06f6e9bcb5b603d39a4524326f7e1f8ea90bd5bd2d3256b53845237111b2))
- ❇️ Class added: `LdBottomBar`

**`class` LdButton** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- ❇️ Param added in default constructor: `disableSqueeze` (named, optional)
- ❇️ Constructors added: `ghost`, `vague`, `outline`, `filled`
- ❇️ Property added: `disableSqueeze`
- ❇️ Methods added: `build`, `warning`, `error`, `success`

**`class` LdButtonConfig** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- ❇️ Class added: `LdButtonConfig`

**`class` LdButtonConfigProvider** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- ❇️ Class added: `LdButtonConfigProvider`

**`class` LdChainedSprings** ([lib/src/spring.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-5ac3b6f3d42047bf8fafd8bf82ad0f1c13e3a0b4d3f9b6e6cbb1c2788647f15a))
- ❇️ Params added in default constructor: `onAnimationEnd` (named, optional), `child` (named, optional)
- ❇️ Properties added: `onAnimationEnd`, `child`

**`class` LdCheckbox** ([lib/src/checkbox.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-212494581d361b843cfc944c41577dc67246a6cfcd3adcc6c8732ec7791c2599))
- ✅ Param became optional in default constructor: `checked` (named, required)
- ❇️ Param added in default constructor: `focusNode` (named, optional)
- ❇️ Property added: `focusNode`
- ❇️ Methods added: `build`, `success`, `warning`, `error`

**`class` LdCheckboxConfig** ([lib/src/checkbox.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-212494581d361b843cfc944c41577dc67246a6cfcd3adcc6c8732ec7791c2599))
- ❇️ Class added: `LdCheckboxConfig`

**`class` LdCheckboxConfigProvider** ([lib/src/checkbox.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-212494581d361b843cfc944c41577dc67246a6cfcd3adcc6c8732ec7791c2599))
- ❇️ Class added: `LdCheckboxConfigProvider`

**`class` LdChoose<T>** ([lib/src/choose.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-7ac0dbb4a4066cbff0ac50927605c02a4480a89c02fff56480625ff3198d3337))
- ✅ Param became optional in default constructor: `items` (named, required)
- ❌ Params removed in default constructor: `placeholder` (named, optional), `enableSearch` (named, optional)
- ❇️ Params added in default constructor: `repository` (named, optional), `groupHeaderBuilder` (named, optional), `groupingCriterion` (named, optional), `hint` (named, optional), `triggerBuilder` (named, optional)
- ❇️ Properties added: `repository`, `itemBuilder`, `selectedItemBuilder`, `onChanged`, `hint`, `triggerBuilder`, `groupingCriterion`, `groupHeaderBuilder`
- ❇️ Methods added: `fromList`, `fromSelectItems`

**`class` LdChooseInputTrigger<T extends Identifiable<IdType>, IdType>** ([lib/src/choose/choose_input_trigger.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-a4c64776859f48de2224df3ce1a2dcf5fadc39b3f8c64225643ab1cdcd3abbff))
- ❇️ Class added: `LdChooseInputTrigger`

**`class` LdChooseListItemTrigger<T extends Identifiable<IdType>, IdType>** ([lib/src/choose/choose_list_item_trigger.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f58c6e967209bc49c663f8d63699bc63e44729657444a1c6a577f40b8602693c))
- ❇️ Class added: `LdChooseListItemTrigger`

**`class` LdChoosePage<T extends Identifiable<IdType>, IdType>** ([lib/src/choose/choose.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-6ce965d70e5a38c7bb7d300718c981f5dd5c18807dcaf9b633cdc74c1d5c5c74))
- ❇️ Class added: `LdChoosePage`

**`class` LdChoosePageState<T extends Identifiable<IdType>, IdType>** ([lib/src/choose/choose.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-6ce965d70e5a38c7bb7d300718c981f5dd5c18807dcaf9b633cdc74c1d5c5c74))
- ❇️ Class added: `LdChoosePageState`

**`typedef` LdChooseTriggerBuilder<T extends Identifiable<IdType>, IdType>** ([lib/src/choose/choose.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-6ce965d70e5a38c7bb7d300718c981f5dd5c18807dcaf9b633cdc74c1d5c5c74))
- ❇️ Typedef added: `LdChooseTriggerBuilder`

**`class` LdChooseTriggerConfig<T extends Identifiable<IdType>, IdType>** ([lib/src/choose/choose.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-6ce965d70e5a38c7bb7d300718c981f5dd5c18807dcaf9b633cdc74c1d5c5c74))
- ❇️ Class added: `LdChooseTriggerConfig`

**`class` LdCollapseState** ([lib/src/collapse.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e4733e85d67e8f44f8cefc8d0aabc8c867c2a692a838d619e4d819632ae20496))
- ❇️ Class added: `LdCollapseState`

**`class` LdColor** ([lib/src/color/color.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-81bd681bff4366357f7038b9c9b8f503bbca597d1bffa013af59c292aa7875f1))
- ❇️ Params added in method `contrastingText`: `background` (named, optional), `isDark` (named, optional, default: false)

**`class` LdContextMenu** ([lib/src/context_menu.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-bd031ede2f184bbdb13c86e7300dc3ab6f62af650bf3cc1bd5c74ad2fe3e824e))
- ❌ Param removed in default constructor: `blurMode` (named, optional, default: LdContextMenuBlurMode.mobileOnly)
- ❇️ Params added in default constructor: `placeAboveTrigger` (named, optional, default: false), `inheritTriggerWidth` (named, optional, default: false), `scaleFromTrigger` (named, optional, default: true), `disabled` (named, optional, default: false), `child` (named, optional), `triggerColor` (named, optional), `menuProviders` (named, optional)
- ❇️ Properties added: `placeAboveTrigger`, `disabled`, `inheritTriggerWidth`, `triggerColor`, `scaleFromTrigger`, `menuProviders`, `child`

**`class` LdContextMenuDissmissNotification** ([lib/src/context_menu.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-bd031ede2f184bbdb13c86e7300dc3ab6f62af650bf3cc1bd5c74ad2fe3e824e))
- ❇️ Class added: `LdContextMenuDissmissNotification`

**`class` LdContextMenuRoute** ([lib/src/context_menu.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-bd031ede2f184bbdb13c86e7300dc3ab6f62af650bf3cc1bd5c74ad2fe3e824e))
- ❇️ Class added: `LdContextMenuRoute`

**`class` LdContextMenuState** ([lib/src/context_menu.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-bd031ede2f184bbdb13c86e7300dc3ab6f62af650bf3cc1bd5c74ad2fe3e824e))
- ❇️ Class added: `LdContextMenuState`

**`class` LdCounter** ([lib/src/counter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-56493e7e7233aac1f95d625ed446d310fe0305379c2e1b4429cd8bc3083c6a4d))
- ❇️ Class added: `LdCounter`

**`class` LdDatePicker** ([lib/src/date_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-705cf9a7b3b5d494795266f0d9bd90767b033dd2dc19f3eee04d709951be9dd7))
- ❇️ Method added: `createState`

**`class` LdDrawerItemSection** ([lib/src/drawer/section_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-28f28c80e2d46cf11a2f828c1c71e2ea1855ad735a2b4fa745622261f5d31cca))
- ❌ Param removed in default constructor: `onTap` (named, optional)
- ❇️ Param added in default constructor: `onPressed` (named, optional)
- ❇️ Property added: `onPressed`

**`enum` LdDrawerSlot** ([lib/src/scaffold.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-35c580af7b94cd13fc78765d9afc1f836ec439643e1a61922b4b6c7a0614553d))
- ❇️ Enum added: `LdDrawerSlot`

**`class` LdDrawerState** ([lib/src/drawer_state.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-8859c797a9078257b005903427308c3be052192a4c3b80263208f3058254f555))
- ❇️ Class added: `LdDrawerState`

**`class` LdException** ([lib/src/exception/model/exception.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-12c04f03aed1ea809f666cff20093761481831385aa468beea43c61cd27c3dcc))
- ❌ Param removed in default constructor: `moreInfo` (named, optional)
- ❇️ Methods added: `toString`, `localize`

**`class` LdExceptionDialog** ([lib/src/exception/exception_dialog.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-9dcfa48416d11e7566f7296f8e09751ea9d668e73261d40fdcbde7e3e981bfb7))
- ❇️ Param added in default constructor: `primaryButton` (named, optional)
- ❇️ Property added: `primaryButton`
- ❇️ Method added: `show`

**`typedef` LdExceptionLocalizeFunction** ([lib/src/exception/exception_mapper.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-28b0c331036e614fa95b8972965b2d236b84f21964859484974eb0decfc7d809))
- ❇️ Typedef added: `LdExceptionLocalizeFunction`

**`class` LdExceptionLocalizer** ([lib/src/exception/exception_mapper.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-28b0c331036e614fa95b8972965b2d236b84f21964859484974eb0decfc7d809))
- ❇️ Class added: `LdExceptionLocalizer`

**`class` LdExceptionLocalizerMapper** ([lib/src/exception/exception_mapper.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-28b0c331036e614fa95b8972965b2d236b84f21964859484974eb0decfc7d809))
- ❇️ Class added: `LdExceptionLocalizerMapper`

**`class` LdExceptionRetryIndicator** ([lib/src/exception/retry_indicator.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-6cc4acc54863d3ead021568a4d6f2ced99eaaaafeca277f4edd88bc4971ea408))
- ❇️ Property added: `cancelRetry`

**`class` LdFilterAnyOf<T extends Identifiable<IdType>, IdType, E>** ([lib/src/monkey/filter/ld_filter_any_of.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-06379cf11167b7e50d8fea6084957a34ae2ce3bf735cfe2edaff5b8f5f6a3a37))
- ❇️ Class added: `LdFilterAnyOf`

**`class` LdFilterAnyOfWidget<T extends Identifiable<IdType>, IdType, E>** ([lib/src/monkey/filter/ld_filter_any_of_widget.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-513bec06b6f72e9edc2a18ca7dd65637d1c5445222fdba2207a07b15727bbaa8))
- ❇️ Class added: `LdFilterAnyOfWidget`

**`class` LdFilterBool<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/filter/ld_filter_bool.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-b7e2eb346e2d45ea0555ea553cfbf179ee5c8371be7d02d82cb669dacc2825c5))
- ❇️ Class added: `LdFilterBool`

**`class` LdFilterContextMenu<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/filter/filter_modal.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f81eb630c2c49f587ee83d5b882e360f653478d4681dec0266d71e7777758747))
- ❇️ Class added: `LdFilterContextMenu`

**`class` LdFilterModal<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/filter/filter_modal.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f81eb630c2c49f587ee83d5b882e360f653478d4681dec0266d71e7777758747))
- ❇️ Class added: `LdFilterModal`

**`class` LdFilterOneOf<T extends Identifiable<IdType>, IdType, E>** ([lib/src/monkey/filter/ld_filter_one_of.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-8b4a7370965f8b84a2f66898dc4740594b5f188545f63c3b9a6b8fcdafdd876e))
- ❇️ Class added: `LdFilterOneOf`

**`class` LdFilterOneOfWidget<T extends Identifiable<IdType>, IdType, E>** ([lib/src/monkey/filter/ld_filter_one_of_widget.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-4625c1d07968584df7763d97cd06d9830c9c58915f3261a0d2a2b8733ed010ca))
- ❇️ Class added: `LdFilterOneOfWidget`

**`class` LdFilterOption<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/filter/ld_filter_option.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-03168a2273b93173ad00eaf26bfb2a8d185f19617a0c46505dd419b9f6072a5a))
- ❇️ Class added: `LdFilterOption`

**`class` LdFilterRange<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/filter/ld_filter_range.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-bf38054883adc797e5840cf283d60d46e21ba512471c51e299aaada452eec6b9))
- ❇️ Class added: `LdFilterRange`

**`class` LdFilterRangeWidget<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/filter/ld_filter_range.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-bf38054883adc797e5840cf283d60d46e21ba512471c51e299aaada452eec6b9))
- ❇️ Class added: `LdFilterRangeWidget`

**`class` LdFilterSearch<T extends Identifiable<IdType>, IdType, Suggestion>** ([lib/src/monkey/filter/ld_filter_search.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-4d71fc5bfdc4b0254470d2133519e55d28aa4013ef9ab8eeb02f139201fe0f73))
- ❇️ Class added: `LdFilterSearch`

**`class` LdFlexibleChild** ([lib/src/overflow/flexible_child.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-79324663b54116418cb7535ea97f90ab2d9b7e774421a5bbfde600d62401ebe9))
- ❇️ Class added: `LdFlexibleChild`

**`class` LdHint** ([lib/src/hint.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-dfc92525de9815f786b74d0fb4e4a920602109f9db1ffe185778ade2d4295570))
- ❇️ Constructors added: `info`, `warning`, `success`, `error`, `canceled`, `loading`, `pending`, `ongoing`

**`class` LdIndicator** ([lib/src/indicators.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-d795289d9c186887b0644807b9f5bf48ef75099f590cff62f4a832c3d6d85b3b))
- ❇️ Constructors added: `info`, `warning`, `canceled`, `error`, `success`, `loading`, `pending`, `ongoing`

**`class` LdInput** ([lib/src/input.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-2ffc2d5e6008b31f35c68f6ed0d27138168bf19c95df7c0aab8349787a9a5ef6))
- ❌ Param removed in default constructor: `onBlur` (named, optional)
- ❇️ Params added in default constructor: `trailing` (named, optional), `leading` (named, optional), `selectAllOnFocus` (named, optional, default: false), `allowTapOutside` (named, optional, default: true), `onBlurred` (named, optional), `onCleared` (named, optional)
- ❇️ Properties added: `onBlurred`, `onCleared`, `trailing`, `leading`, `allowTapOutside`, `selectAllOnFocus`

**`class` LdList<T, GroupingCriterion>** ([lib/src/list/list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-888f80c71ddeacb424418138bd38d5900a4ffe694069cba2af68eb89e66a4a41))
- ✅ Params became optional in default constructor: `itemBuilder` (named, required), `paginator` (named, required)
- ❇️ Param added in default constructor: `padding` (named, optional)
- ❇️ Property added: `padding`
- ❇️ Method added: `build`

**`class` LdListConfig<T extends Identifiable<IdType>, IdType>** ([lib/src/list/list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-888f80c71ddeacb424418138bd38d5900a4ffe694069cba2af68eb89e66a4a41))
- ❇️ Class added: `LdListConfig`

**`class` LdListConfigProvider<T extends Identifiable<IdType>, IdType>** ([lib/src/list/list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-888f80c71ddeacb424418138bd38d5900a4ffe694069cba2af68eb89e66a4a41))
- ❇️ Class added: `LdListConfigProvider`

**`class` LdListDefaultTrailingForward** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- ❇️ Class added: `LdListDefaultTrailingForward`

**`class` LdListItem** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- ❌ Params removed in default constructor: `radioSelection` (named, optional, default: false), `trailingForward` (named, optional, default: false), `showSelectionControls` (named, optional, default: false), `onSelectionChange` (named, optional), `onTap` (named, optional)
- ❇️ Params added in default constructor: `onSelectionChanged` (named, optional), `onPressed` (named, optional), `focusNode` (named, optional), `color` (named, optional), `selectionControl` (named, optional)
- ❇️ Constructor added: `trailingForward`
- ❇️ Properties added: `onPressed`, `onSelectionChanged`, `selectionControl`, `focusNode`, `color`

**`class` LdListItemAnimation** ([lib/src/list/ld_list_item_animation.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-761d55a256a89f0d592feb46f083fe873ecca89623c6113198e3af75db69e71d))
- ❇️ Class added: `LdListItemAnimation`

**`class` LdListItemConfig** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- ❇️ Class added: `LdListItemConfig`

**`class` LdListItemConfigProvider** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- ❇️ Class added: `LdListItemConfigProvider`

**`class` LdListItemWidget** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- ❇️ Class added: `LdListItemWidget`

**`class` LdListPage<T>** ([lib/src/list/list_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-1a8cac588961ab42d73539922e36de72efd066b5ff2545a8128fd36030a0da92))
- ❌ Param removed in default constructor: `error` (named, optional)
- ❇️ Constructor added: `fromList`
- ❇️ Method added: `copyWith`

**`class` LdListRenderItem<T extends Identifiable<dynamic>>** ([lib/src/list/list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-888f80c71ddeacb424418138bd38d5900a4ffe694069cba2af68eb89e66a4a41))
- ❇️ Class added: `LdListRenderItem`

**`enum` LdListRenderItemType** ([lib/src/list/list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-888f80c71ddeacb424418138bd38d5900a4ffe694069cba2af68eb89e66a4a41))
- ❇️ Enum added: `LdListRenderItemType`

**`class` LdListWidget<T extends Identifiable<IdType>, IdType>** ([lib/src/list/list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-888f80c71ddeacb424418138bd38d5900a4ffe694069cba2af68eb89e66a4a41))
- ❇️ Class added: `LdListWidget`

**`class` LdLocalizedException** ([lib/src/exception/model/exception.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-12c04f03aed1ea809f666cff20093761481831385aa468beea43c61cd27c3dcc))
- ❇️ Class added: `LdLocalizedException`

**`class` LdModalPage** ([lib/src/modal/modal_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-631ab921ead5b8110d200c0106bd500edcd6d089dc8efd32c150f33228e6341c))
- ❌ Param removed in default constructor: `name` (named, optional)

**`class` LdModalRoute<T>** ([lib/src/modal/modal.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-2d55c400b021d628a7e92bc6d07673f3775bac69b40c544c8332ae622d0f715d))
- ❇️ Class added: `LdModalRoute`

**`class` LdMonkeyAction<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/actions/actions.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-250ba08dbbe05925449c761878d3265c71d99d63e119d34feda97f183532dd30))
- ❇️ Class added: `LdMonkeyAction`

**`enum` LdMonkeyActionLocation** ([lib/src/monkey/actions/actions.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-250ba08dbbe05925449c761878d3265c71d99d63e119d34feda97f183532dd30))
- ❇️ Enum added: `LdMonkeyActionLocation`

**`class` LdMonkeyActionVisibility** ([lib/src/monkey/actions/action_visibility.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-838fefbc7b1b558a58ba0ae3fd5f830ebc9c1949e2e7747d95f60d6d558ba047))
- ❇️ Class added: `LdMonkeyActionVisibility`

**`typedef` LdMonkeyActions<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_shell.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f58e8426a3074373d1a4d8d50d0d7467233933c3ceffe3098ffc530558a3aa9b))
- ❇️ Typedef added: `LdMonkeyActions`

**`class` LdMonkeyAppBar<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_app_bar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-1ed77dea165bf61117ba5c39537c923f703bf59c28964a4507ccb301fab79a69))
- ❇️ Class added: `LdMonkeyAppBar`

**`class` LdMonkeyBareChildAction<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/actions/actions.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-250ba08dbbe05925449c761878d3265c71d99d63e119d34feda97f183532dd30))
- ❇️ Class added: `LdMonkeyBareChildAction`

**`class` LdMonkeyContextMenu<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/actions/context_menu.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-ddffdf63ace9a5a21d65e0775c22a505c9c90db2d81142a12a0972d01857fb3f))
- ❇️ Class added: `LdMonkeyContextMenu`

**`class` LdMonkeyDetailPage<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/detail_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-43d347b03da89e053d770a97150585d0955be32f82540fad5d2ceabd18d33035))
- ❇️ Class added: `LdMonkeyDetailPage`

**`class` LdMonkeyDetailState<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_detail_state.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-7a06a00001ff731934e0ba2c50ce88f2a6af34845580cf96625322a48d9531d3))
- ❇️ Class added: `LdMonkeyDetailState`

**`enum` LdMonkeyEffectiveLayoutMode** ([lib/src/monkey/monkey_effective_layout_mode.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-90fa9cb124a0714f971fd6fb7bcee0a69dfa81f6be9c9b1ffbd72ed202cf9c3c))
- ❇️ Enum added: `LdMonkeyEffectiveLayoutMode`

**`enum` LdMonkeyLayoutMode** ([lib/src/monkey/monkey_layout_mode.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-784ecdf563e9c1e85398ffc092298e8ee32a65fdf9c5b4fb7ee945fafbf7212a))
- ❇️ Enum added: `LdMonkeyLayoutMode`

**`class` LdMonkeyMasterPage<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_master_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f027b9824ac3c8ae9ddbe6ac353d6cb02c90fe60d3a5d83846b29dbd7ec3c437))
- ❇️ Class added: `LdMonkeyMasterPage`

**`class` LdMonkeyMultiShortcuts<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/actions/keyboard_shortcuts.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-65b51e5d2f55521a12a61c5bf3c93f00522ffe38cefe18f99263bd424f5b9282))
- ❇️ Class added: `LdMonkeyMultiShortcuts`

**`class` LdMonkeyRouteConfig<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_route_config.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e1d4248f5b3581ffaf1a1d2cb4d4b3d63b7e479e22aacc0bb35c483da737b1f2))
- ❇️ Class added: `LdMonkeyRouteConfig`

**`class` LdMonkeyRouteScope<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_route_scope.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-00b40f9e0517eb15a03249100eaf69b7c20db14e2b2ec72a032292e923048ac2))
- ❇️ Class added: `LdMonkeyRouteScope`

**`class` LdMonkeyRouterAdapter<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_router_adapter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-38733ea6a1cce5fbf22de0240816bf176f58d0e504bf36a2b06519fe5f9a108d))
- ❇️ Class added: `LdMonkeyRouterAdapter`

**`class` LdMonkeyRouterAdapterState<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_router_adapter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-38733ea6a1cce5fbf22de0240816bf176f58d0e504bf36a2b06519fe5f9a108d))
- ❇️ Class added: `LdMonkeyRouterAdapterState`

**`class` LdMonkeyRouterController<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_router_adapter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-38733ea6a1cce5fbf22de0240816bf176f58d0e504bf36a2b06519fe5f9a108d))
- ❇️ Class added: `LdMonkeyRouterController`

**`class` LdMonkeyScrollableDetailView<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_scrollable_detail_view.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-9400e0cdd55f75ba32cf7749184743cc74a59ce66cb9219b4dd01bcf26064b95))
- ❇️ Class added: `LdMonkeyScrollableDetailView`

**`class` LdMonkeySelection<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_selection.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-72f93ee9d49683aa9512af7176bb6780ce73d1f63dbc8674a08fd06e0297bacf))
- ❇️ Class added: `LdMonkeySelection`

**`class` LdMonkeyShell<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_shell.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f58e8426a3074373d1a4d8d50d0d7467233933c3ceffe3098ffc530558a3aa9b))
- ❇️ Class added: `LdMonkeyShell`

**`typedef` LdMonkeyShowingDetail<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_router_adapter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-38733ea6a1cce5fbf22de0240816bf176f58d0e504bf36a2b06519fe5f9a108d))
- ❇️ Typedef added: `LdMonkeyShowingDetail`

**`class` LdMonkeySingleShortcuts<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/actions/keyboard_shortcuts.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-65b51e5d2f55521a12a61c5bf3c93f00522ffe38cefe18f99263bd424f5b9282))
- ❇️ Class added: `LdMonkeySingleShortcuts`

**`class` LdMonkeySortAndFilterState<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_sort_and_filter_state.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f64f40e01e32a68dba992ea97a81b172ead7127ee0aafa928d3fec8632e6ad43))
- ❇️ Class added: `LdMonkeySortAndFilterState`

**`class` LdMonkeyStackDetailView<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_stack_detail_view.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-859c21b7002de70c6a448c5f9c3ce24edf467197f6ef2bca6c7362c436bf9679))
- ❇️ Class added: `LdMonkeyStackDetailView`

**`class` LdMonkeyStreamSelection<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/detail_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-43d347b03da89e053d770a97150585d0955be32f82540fad5d2ceabd18d33035))
- ❇️ Class added: `LdMonkeyStreamSelection`

**`class` LdMonkeySubmitAction<T extends Identifiable<IdType>, IdType, Result>** ([lib/src/monkey/actions/actions.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-250ba08dbbe05925449c761878d3265c71d99d63e119d34feda97f183532dd30))
- ❇️ Class added: `LdMonkeySubmitAction`
- 🔄 Required param added: `id`
- 🔄 Param replaced: `config` → `submitConfig` + `onSubmit(LdMonkeyActionContext)`
- 🔄 Submit host/trigger split: one offstage `LdSubmit` per action id per route

**`class` LdMonkeyBareChildAction<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/actions/actions.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-250ba08dbbe05925449c761878d3265c71d99d63e119d34feda97f183532dd30))
- 🔄 Param renamed: `onShortcutTrigger` → `onTrigger(LdMonkeyActionContext)`
- 🔄 `builder` signature: `(BuildContext)` → `(LdMonkeyActionContext, trigger)`

**`class` LdMonkeyActionContext<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/actions/action_context.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..HEAD#diff-action-context))
- ❇️ Class added: `LdMonkeyActionContext`

**`class` LdMultiPanelChildState** ([lib/src/multi_panel/multi_panel_layout.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-dcf83dd1348efc710dbc6957e505c08eb421234a466c65f2b9630f2f41b83750))
- ❇️ Class added: `LdMultiPanelChildState`

**`class` LdMultiPanelLayout** ([lib/src/multi_panel/multi_panel_layout.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-dcf83dd1348efc710dbc6957e505c08eb421234a466c65f2b9630f2f41b83750))
- ❇️ Class added: `LdMultiPanelLayout`

**`enum` LdMultiPanelLayoutMode** ([lib/src/multi_panel/multi_panel_layout_mode.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e0073e06a6f2b1edeaa4504353e535cfd751d1f53f0dbcc58e2ea5d1a9c806da))
- ❇️ Enum added: `LdMultiPanelLayoutMode`

**`class` LdNavigationTab** ([lib/src/appbar/tab_navigation.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-52bf35196752849d0d45f783bb5b24e4217e93ef2ae5ff75caafe39bc5b551fc))
- ❇️ Class added: `LdNavigationTab`

**`class` LdNotificationPortal** ([lib/src/notifications/notification_portal.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-5ecbf35c381d0c71f97cc9da48294271c95cf4655da1f141b5a297e4f94765d1))
- ❇️ Param added in default constructor: `debugLabel` (named, optional)
- ❇️ Property added: `debugLabel`

**`class` LdNotificationProvider** ([lib/src/notifications/notification_portal.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-5ecbf35c381d0c71f97cc9da48294271c95cf4655da1f141b5a297e4f94765d1))
- ❇️ Param added in default constructor: `debugLabel` (named, optional)
- ❇️ Property added: `debugLabel`

**`class` LdNotificationsController** ([lib/src/notifications/notifications_controller.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-7473196fa6b569fc3a6cdb5236987f2f7abd38e3216144e037039ad7a759e982))
- ❇️ Param added in default constructor: `debugLabel` (named, optional)
- ❇️ Property added: `debugLabel`
- ❇️ Methods added: `toString`, `maybeOf`

**`class` LdOverflowView** ([lib/src/overflow/overflow_view.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-3c4bab9daad078a31ff7546452536df0e86c05aae4e6e28655236688cd516a39))
- ❇️ Class added: `LdOverflowView`

**`class` LdOverflowViewElement** ([lib/src/overflow/overflow_view.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-3c4bab9daad078a31ff7546452536df0e86c05aae4e6e28655236688cd516a39))
- ❇️ Class added: `LdOverflowViewElement`

**`class` LdPaginator<T>** ([lib/src/list/list_paginator.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-c279977c526f2e1ad42c33e9e9f5451f323d228e7974b6ae305a16daa9ff8dc8))
- ✅ Param became optional in default constructor: `fetchListFunction` (named, required)
- ❌ Param removed in default constructor: `autoLoad` (named, optional, default: true)
- ❇️ Params added in default constructor: `initialItems` (named, optional), `fetchQueueSize` (named, optional, default: 3)
- ❌ Modifier `final` removed from properties: `fetchListFunction`, `initialOffset`
- ❇️ Properties added: `fetchQueueSize`, `mutex`, `itemsMap`, `itemsStream`, `updatedItems`
- ❇️ Param added in method `refreshList`: `hard` (named, optional, default: false)
- ❇️ Methods added: `confirmItemCreation`, `confirmItemDeletion`, `confirmItemUpdate`, `getItemById`, `getItemIndexById`, `replaceItems`, `rollbackItemCreation`, `rollbackItemDeletion`, `rollbackItemUpdate`, `scheduleItemCreation`, `scheduleItemDeletion`, `scheduleItemUpdate`, `setItems`, `watchItem`, `watchItems`, `watchListOfItems`, `toString`

**`class` LdPaginatorItem<T extends Identifiable<dynamic>>** ([lib/src/list/list_paginator.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-c279977c526f2e1ad42c33e9e9f5451f323d228e7974b6ae305a16daa9ff8dc8))
- ❇️ Class added: `LdPaginatorItem`

**`enum` LdPaginatorItemState** ([lib/src/list/list_paginator.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-c279977c526f2e1ad42c33e9e9f5451f323d228e7974b6ae305a16daa9ff8dc8))
- ❇️ Enum added: `LdPaginatorItemState`

**`class` LdPaginatorLoadedItem<T extends Identifiable<dynamic>>** ([lib/src/list/list_paginator.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-c279977c526f2e1ad42c33e9e9f5451f323d228e7974b6ae305a16daa9ff8dc8))
- ❇️ Class added: `LdPaginatorLoadedItem`

**`class` LdPalette** ([lib/src/color/palette.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-59442ab4f15c1556328d67962cd75a05c3a5c5d31f4a17a19c8a866960cc23d0))
- ❇️ Params added in default constructor: `background` (named, optional), `surface` (named, optional), `border` (named, optional), `stroke` (named, optional), `text` (named, optional), `textMuted` (named, optional), `floatingBorder` (named, optional)
- ❇️ Property added: `floatingBorder`

**`enum` LdPanelPosition** ([lib/src/multi_panel/ld_panel_position.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-8b73a988cb129cc072b306a35edef9cf930fa4e5d08c313ae3e06ecd1430e900))
- ❇️ Enum added: `LdPanelPosition`

**`enum` LdPanelRole** ([lib/src/multi_panel/ld_panel_role.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-b44b68e64059815c694cfb0368254a4261ecf0515dc27ef2fbbdd452ddeedc87))
- ❇️ Enum added: `LdPanelRole`

**`enum` LdPlatform** ([lib/src/theme/platform.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-07a6e8378db4cae8794d39c8044663b8fc8c98f7b4de183826d9d51cc9849208))
- ❇️ Enum added: `LdPlatform`

**`extension` LdPlatformExtension** ([lib/src/theme/platform.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-07a6e8378db4cae8794d39c8044663b8fc8c98f7b4de183826d9d51cc9849208))
- ❇️ Extension added: `LdPlatformExtension`

**`class` LdRadio** ([lib/src/radio.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-2c308573693eef4e4cf15c26891a5c684215e4725c9a28a038491f334e59b8d9))
- ❇️ Param added in default constructor: `focusNode` (named, optional)
- ❇️ Property added: `focusNode`
- ❇️ Methods added: `success`, `warning`, `error`

**`class` LdRepository<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/data/repository.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-0106e16f709edb1982d818cd2ca7b45a46cce2d5530db851270c61b4e1c950c3))
- ❇️ Class added: `LdRepository`

**`class` LdRepositoryProvider<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/data/repository_provider.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-d53f8e2e8c07954a7305ae5112dd68d3dd433f1bc35fd6369e32edfe3324dd8c))
- ❇️ Class added: `LdRepositoryProvider`

**`class` LdRetryConfig** ([lib/src/exception/model/retry_config.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f109fedccf68e4510b0180d75525074d12139fd40ae01fe8c3ca1d8f80c51056))
- ❇️ Properties added: `props`, `stringify`, `hashCode`
- ❇️ Methods added: `==`, `toString`

**`class` LdRetryController** ([lib/src/exception/retry_controller.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-b8c9671e8cc59ca621f69de1c8d942688baa43bd1a5b8e3ca23d4798f198a5bc))
- ❇️ Method added: `toMap`

**`class` LdReveal** ([lib/src/reveal.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f73624a6311b645560f7766d8f060577206e18ec8a187a0c9f713dfe194f2d17))
- ❇️ Params added in default constructor: `onAnimationEnd` (named, optional), `axes` (named, optional, default: const {Axis.horizontal, Axis.vertical})
- ❇️ Params added in constructor `quick`: `key` (named, optional), `axes` (named, optional, default: const {Axis.horizontal, Axis.vertical})
- ❇️ Param added in constructor `slow`: `axes` (named, optional, default: const {Axis.horizontal, Axis.vertical})
- ❇️ Properties added: `axes`, `onAnimationEnd`

**`class` LdRunnerLog** ([lib/src/runner.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-6b567e02a0af50b04f70212b6f0e9f870e0ed5de80b85853890572d0a7493947))
- ❇️ Params added in default constructor: `showCopyButton` (named, optional, default: false), `lineBuilder` (named, optional)
- ❇️ Properties added: `showCopyButton`, `lineBuilder`

**`class` LdRunnerStep** ([lib/src/runner.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-6b567e02a0af50b04f70212b6f0e9f870e0ed5de80b85853890572d0a7493947))
- ✅ Param became optional in default constructor: `children` (named, required)
- ❇️ Param added in default constructor: `customIndicator` (named, optional)
- ❇️ Property added: `customIndicator`

**`class` LdScaffold** ([lib/src/scaffold.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-35c580af7b94cd13fc78765d9afc1f836ec439643e1a61922b4b6c7a0614553d))
- ❇️ Class added: `LdScaffold`

**`class` LdScaffoldBody** ([lib/src/scaffold_body.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-25fd66a644218adca4f46a542b28e361a2aea16ff32c8a2def5a1819cf1c507b))
- ❇️ Class added: `LdScaffoldBody`

**`class` LdScaffoldBodyCentered** ([lib/src/scaffold_body.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-25fd66a644218adca4f46a542b28e361a2aea16ff32c8a2def5a1819cf1c507b))
- ❇️ Class added: `LdScaffoldBodyCentered`

**`class` LdScaffoldState** ([lib/src/scaffold.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-35c580af7b94cd13fc78765d9afc1f836ec439643e1a61922b4b6c7a0614553d))
- ❇️ Class added: `LdScaffoldState`

**`class` LdSearchAcceptSuggestion** ([lib/src/appbar/search_components.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-c7750a1ad0e6a79e8cd9a447bd3f31dd1c31866d30873339df5d2bea4b410ecd))
- ❇️ Class added: `LdSearchAcceptSuggestion`

**`class` LdSearchConfig** ([lib/src/appbar/search_config.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-368436926193fa74e40419890eb7131dcaf98ec1be8f7ecbe1493423a3d59d6d))
- ❇️ Class added: `LdSearchConfig`

**`class` LdSearchInput** ([lib/src/appbar/search_components.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-c7750a1ad0e6a79e8cd9a447bd3f31dd1c31866d30873339df5d2bea4b410ecd))
- ❇️ Class added: `LdSearchInput`

**`class` LdSearchSuggestionsOverlay** ([lib/src/appbar/search_components.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-c7750a1ad0e6a79e8cd9a447bd3f31dd1c31866d30873339df5d2bea4b410ecd))
- ❇️ Class added: `LdSearchSuggestionsOverlay`

**`class` LdSelect<T>** ([lib/src/select.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-bc5dd59ffff566f496d4463c5136fdcba05247739d6102d1b7578f12d41e30ac))
- ❌ Param removed in default constructor: `onChange` (named, optional)
- ❇️ Param added in default constructor: `onChanged` (named, optional)
- ❇️ Property added: `onChanged`

**`class` LdSelectItem<T>** ([lib/src/select.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-bc5dd59ffff566f496d4463c5136fdcba05247739d6102d1b7578f12d41e30ac))
- ➕ Mixin added: Identifiable
- ❇️ Properties added: `id`, `idString`

**`class` LdSelectableList<T, GroupingCriterion>** ([lib/src/list/selectable_list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f78a865a5b517b6892730363bb581f1e53588fb39b9bc88417dea463806327c7))
- ✅ Param became optional in default constructor: `listBuilder` (named, required)
- ❇️ Params added in default constructor: `showSelectionControls` (named, optional, default: false), `initialSelectedItems` (named, optional, default: const {})
- ❇️ Properties added: `initialSelectedItems`, `showSelectionControls`

**`enum` LdSelectionControl** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- ❇️ Enum added: `LdSelectionControl`

**`class` LdSizingConfig** ([lib/src/theme/theme.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e230b3066fca6361167b035927f3d5e83cda9a34212c86e2a307ed82bcf0d99e))
- ❇️ Param added in default constructor: `containerMaxWidth` (named, optional, default: 1200.0)
- ❇️ Property added: `containerMaxWidth`

**`class` LdSortOption<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/sort/sort_option.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-c6eadbc49568be771b736102517c1d37486b870934e27b2c3ebc0ea60a09db00))
- ❇️ Class added: `LdSortOption`

**`enum` LdSortOptionDirection** ([lib/src/monkey/sort/sort_option.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-c6eadbc49568be771b736102517c1d37486b870934e27b2c3ebc0ea60a09db00))
- ❇️ Enum added: `LdSortOptionDirection`

**`class` LdSpeedReader** ([lib/src/speed_reader.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-98a3cffa784a371ca850e8838ab43d691a0cda4d0e96f5129839c1b777cd73e9))
- ❇️ Class added: `LdSpeedReader`

**`class` LdSpeedReaderController** ([lib/src/speed_reader.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-98a3cffa784a371ca850e8838ab43d691a0cda4d0e96f5129839c1b777cd73e9))
- ❇️ Class added: `LdSpeedReaderController`

**`class` LdSpeedReaderState** ([lib/src/speed_reader.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-98a3cffa784a371ca850e8838ab43d691a0cda4d0e96f5129839c1b777cd73e9))
- ❇️ Class added: `LdSpeedReaderState`

**`class` LdSpring** ([lib/src/spring.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-5ac3b6f3d42047bf8fafd8bf82ad0f1c13e3a0b4d3f9b6e6cbb1c2788647f15a))
- ❇️ Param added in default constructor: `child` (named, optional)
- ❇️ Property added: `child`

**`class` LdSubmit<T>** ([lib/src/submit/submit.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-90dec5a624a3cd55bf16ed8f4d39486f0ad3f7b8e1ff081a9177aedac7ea2802))
- ❌ Param removed in default constructor: `builder` (named, optional)
- ❇️ Params added in default constructor: `arg` (named, optional), `child` (named, optional), `argEquals` (named, optional)
- ❇️ Properties added: `child`, `arg`, `argEquals`
- ❇️ Method added: `createState`

**`class` LdSubmitConfig<T>** ([lib/src/submit/model/submit_config.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-b47d5b90994b395b32ba37a1724b89db6d61e0ac7b9a4f58a63b5c7e0f62630c))
- ❇️ Params added in default constructor: `key` (named, optional), `debugLabel` (named, optional)
- ❇️ Properties added: `props`, `stringify`, `hashCode`, `key`, `debugLabel`
- ❇️ Methods added: `==`, `toString`

**`class` LdSubmitController<T>** ([lib/src/submit/model/submit_controller.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-d921dcc848cbe3ce44f849c2be50e41f4300cb5bddb83fe2c189bea7f63c8f34))
- ➕ Mixin added: ChangeNotifier
- ❇️ Param added in default constructor: `arg` (named, optional)
- ❇️ Properties added: `hasListeners`, `id`, `arg`
- ❇️ Methods added: `addListener`, `removeListener`, `notifyListeners`, `debugForceError`, `toMap`

**`class` LdSubmitDialog<T, Arg>** ([lib/src/submit/builders/dialog_builder.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-667617a61b037cae73c86a02fac20c0c80283ad8dc680535c250ada7f9ae994a))
- ❇️ Class added: `LdSubmitDialog`

**`class` LdSubmitDialogBuilder<T>** ([lib/src/submit/builders/dialog_builder.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-667617a61b037cae73c86a02fac20c0c80283ad8dc680535c250ada7f9ae994a))
- ❇️ Modifier `const` added to constructor: `new`
- ❇️ Param added in default constructor: `targetRoot` (named, optional, default: false)
- ❇️ Property added: `targetRoot`

**`class` LdSubmitLoadingIndicator** ([lib/src/submit/submit_loading_indicator.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-09d1a7a8d50b754a8465b037876e60b85d895de2829c8ed8d7c59c119910207b))
- ❌ Param removed in default constructor: `loadingText` (named, optional)

**`class` LdSubmitNotificationBuilder<T, Arg>** ([lib/src/submit/builders/notification_builder.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-9c6d145646b33b86392036585f3f6e79308af86c2cc191543dd1276b13cbe9c3))
- ❇️ Class added: `LdSubmitNotificationBuilder`

**`class` LdSwitch<T>** ([lib/src/switch.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-d8b30ecf078361f71ed29b6fb0755c25a0bb96217a1fbb7ba1593d825db75278))
- ❇️ Param added in default constructor: `expand` (named, optional, default: false)
- ❇️ Property added: `expand`

**`class` LdTabNavigation** ([lib/src/appbar/tab_navigation.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-52bf35196752849d0d45f783bb5b24e4217e93ef2ae5ff75caafe39bc5b551fc))
- ❇️ Class added: `LdTabNavigation`

**`class` LdTable<T>** ([lib/src/table.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-ef98608b9a8b08eb5208319f42f1b44644df8b7b941ef381fb63c43a6b0656e4))
- ❌ Param removed in default constructor: `onSelectChange` (named, optional)
- ❇️ Param added in default constructor: `onSelectionChanged` (named, optional)
- ❇️ Property added: `onSelectionChanged`

**`class` LdTableRow** ([lib/src/list/table_row.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-bf76546dc1543a913b217c1fb349fd7363e2b68722d8f44fce4a3358bc1eabbf))
- ❇️ Class added: `LdTableRow`

**`class` LdTag** ([lib/src/tag.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-7a2a1581011001cf2ceb5a616aac5032867a00eb9cc844c90a534fe6ae840f09))
- ❇️ Methods added: `success`, `warning`, `error`

**`class` LdText** ([lib/src/text.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-ce7342ea9aebd0be91a6fd6597751ce9b68c0040b4cd9db2386764d2efceb9a2))
- ❇️ Constructors added: `caption`, `h`, `hl`, `hs`, `hxs`, `l`, `ll`, `ls`, `lxs`, `p`, `pl`, `ps`, `pxs`

**`class` LdTextList** ([lib/src/text_list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-fba7580f681ec08f0ec1dc4c51008c71ff9762c0af1ccbbe10f742191c3e4fb6))
- ❇️ Class added: `LdTextList`

**`enum` LdTextListType** ([lib/src/text_list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-fba7580f681ec08f0ec1dc4c51008c71ff9762c0af1ccbbe10f742191c3e4fb6))
- ❇️ Enum added: `LdTextListType`

**`class` LdTheme** ([lib/src/theme/theme.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e230b3066fca6361167b035927f3d5e83cda9a34212c86e2a307ed82bcf0d99e))
- ❇️ Properties added: `platform`, `floatingBorder`
- ❇️ Method added: `radiusSize`

**`extension` LdThemeExtension** ([lib/src/theme/theme.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e230b3066fca6361167b035927f3d5e83cda9a34212c86e2a307ed82bcf0d99e))
- ❇️ Extension added: `LdThemeExtension`

**`class` LdThemeProvider** ([lib/src/theme/theme_provider.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-bb56e3df14103825a8edc59aa7689986b2bface5596870727b1ab28297f86e57))
- ❌ Param removed in default constructor: `autoSize` (named, optional, default: true)
- ❇️ Params added in default constructor: `screenRadiusStream` (named, optional), `size` (named, optional), `platform` (named, optional)
- ❇️ Properties added: `size`, `platform`, `screenRadiusStream`

**`class` LdTimePicker** ([lib/src/time_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-fb045078ea903e4c0c3ae338b38f895d4245816be0481759aeb4cfc98122b476))
- ❇️ Param added in default constructor: `focusNode` (named, optional)
- ❇️ Property added: `focusNode`

**`class` LdTimePickerModal** ([lib/src/time_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-fb045078ea903e4c0c3ae338b38f895d4245816be0481759aeb4cfc98122b476))
- ❇️ Class added: `LdTimePickerModal`

**`class` LdTouchableSurface** ([lib/src/touchable/touchable.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-390c2ec1e7b0ebec409f605c4cdc4ea7ef337cf7876bdca7a87de6f2c647ea96))
- ❌ Params removed in default constructor: `color` (named, optional), `mode` (named, optional, default: LdTouchableSurfaceMode.neutralGhost)
- ❇️ Params added in default constructor: `hitTestBehavior` (named, optional, default: HitTestBehavior.opaque), `allowTapOutside` (named, optional, default: false), `onPressedKeys` (named, optional), `isOdd` (named, optional, default: false), `child` (named, optional)
- ❇️ Properties added: `hitTestBehavior`, `isOdd`, `onPressed`, `allowTapOutside`, `child`, `onPressedKeys`

**`enum` LdTouchableSurfaceMode** ([lib/src/touchable/touchable.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-390c2ec1e7b0ebec409f605c4cdc4ea7ef337cf7876bdca7a87de6f2c647ea96))
- ❇️ Property added: `input`

**`class` LdTouchableTouchFeedback** ([lib/src/touchable/touchable.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-390c2ec1e7b0ebec409f605c4cdc4ea7ef337cf7876bdca7a87de6f2c647ea96))
- ❇️ Class added: `LdTouchableTouchFeedback`

**`class` LdWindowCallbacks** ([lib/src/appbar/window_callbacks.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-480f64a0955d604c25c21621155bcf6fbe2f957d32894b2e803e788494c43f09))
- ❇️ Class added: `LdWindowCallbacks`

**`class` LdWindowFrame** ([lib/src/window_frame.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-dbdb23098a936a2806f790c5756e86f1a21d8b93561b6e0a1e68bcc24bb3e3e9))
- 🔄 Param type changed in default constructor: `title` (`Text` → `Widget`, widened)
- ❇️ Method added: `showWindowFrame`

**`class` LdWrapConditional** ([lib/src/conditional_parent.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-0c2f88e1b8a773abd704b4c32c032e744ff4b949fa2aa00cd8a54ef2522eda09))
- ❇️ Class added: `LdWrapConditional`

**`class` LiquidLocalizations** ([lib/src/l10n/generated/liquid_localizations.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-355d12226806e42fbe28958594669ec350c927c0fc7c9226bf2b78c89f288995))
- ❇️ Properties added: `errorDetails`, `clearError`, `createNew`, `delete`, `deleteSelected`, `edit`, `select`, `filter`, `apply`, `activeFilters`, `sort`, `minimize`, `maximize`, `showDrawer`, `hideDrawer`, `clearSelection`, `openDrawer`, `closeDrawer`, `ctrlListExplanation`, `listHidden`, `shiftListExplanation`, `copy`, `copiedToClipboard`
- ❇️ Methods added: `deleteNItems`, `clearSelectionBody`

**`extension` LsPaddings** ([lib/src/padding.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f86451e3937e772cac008fcbbe050bb1deba8b3c2034db8e47879228fc363e18))
- ❇️ Methods added: `padVertical`, `padHorizontal`, `insetLeft`, `insetRight`, `insetTop`, `insetBottom`

**`class` MonkeyRouteNode<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_route_tree.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-5ee5971433b226f5666f1c6e2da4cdd4b73a3416065519e97a778a01e3fae04d))
- ❇️ Class added: `MonkeyRouteNode`

**`typedef` OnSelectionChanged** ([lib/src/list/list_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-78298edd98f67013b7aac32bb2d42bcfc7aac8ca48eadd30199b423dbceca120))
- ❇️ Typedef added: `OnSelectionChanged`

**`class` OpenDrawerAction** ([lib/src/monkey/actions/actions.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-250ba08dbbe05925449c761878d3265c71d99d63e119d34feda97f183532dd30))
- ❇️ Class added: `OpenDrawerAction`

**`class` OpenDrawerButton** ([lib/src/appbar/drawer_buttons.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-998051ffbe5c2156247ec3ddd0dae8857b52454fad9991da3821f6ba5e3cdc1b))
- ❇️ Class added: `OpenDrawerButton`

**`class` PanelWidth** ([lib/src/multi_panel/panel_width.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-2e87ba2994621966672b899a390d206ed6cfda24f90a7f61013986ad59ea89e1))
- ❇️ Class added: `PanelWidth`

**`class` Paragraph** ([lib/src/speed_reader.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-98a3cffa784a371ca850e8838ab43d691a0cda4d0e96f5129839c1b777cd73e9))
- ❇️ Class added: `Paragraph`

**`class` PreventAutoFocus** ([lib/src/monkey/monkey_shell.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f58e8426a3074373d1a4d8d50d0d7467233933c3ceffe3098ffc530558a3aa9b))
- ❇️ Class added: `PreventAutoFocus`

**`extension` RowSpacing** ([lib/src/padding.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f86451e3937e772cac008fcbbe050bb1deba8b3c2034db8e47879228fc363e18))
- ❇️ Extension added: `RowSpacing`

**`class` ScrollIntoView** ([lib/src/select.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-bc5dd59ffff566f496d4463c5136fdcba05247739d6102d1b7578f12d41e30ac))
- ❇️ Class added: `ScrollIntoView`

**`class` ScrollObserver** ([lib/src/scaffold.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-35c580af7b94cd13fc78765d9afc1f836ec439643e1a61922b4b6c7a0614553d))
- ❇️ Class added: `ScrollObserver`

**`class` ScrolledUnderBuilder** ([lib/src/appbar/appbar_scroll_behavior.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-606c1460e1579fd6b64ba2e68aa3d1ff412c768394b432167c38d7537aa75dc5))
- ❇️ Class added: `ScrolledUnderBuilder`

**`class` Sentence** ([lib/src/speed_reader.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-98a3cffa784a371ca850e8838ab43d691a0cda4d0e96f5129839c1b777cd73e9))
- ❇️ Class added: `Sentence`

**`extension` SortEqals<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_shell.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f58e8426a3074373d1a4d8d50d0d7467233933c3ceffe3098ffc530558a3aa9b))
- ❇️ Extension added: `SortEqals`

**`class` ToggleDrawerAction** ([lib/src/monkey/actions/actions.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-250ba08dbbe05925449c761878d3265c71d99d63e119d34feda97f183532dd30))
- ❇️ Class added: `ToggleDrawerAction`

**`class` Variant** ([lib/src/annotations.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-684d73ec610cb537a248e57776e1b0dab25e3c98b32ab824a578346e75e3e1fe))
- ❇️ Class added: `Variant`

**`class` Variants** ([lib/src/annotations.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-684d73ec610cb537a248e57776e1b0dab25e3c98b32ab824a578346e75e3e1fe))
- ❇️ Class added: `Variants`

**`extension` WrapSpacing** ([lib/src/padding.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f86451e3937e772cac008fcbbe050bb1deba8b3c2034db8e47879228fc363e18))
- ❇️ Extension added: `WrapSpacing`

**`class` _ButtonShape** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- ❇️ Param added in default constructor: `panOffset` (named, optional)

**`class` _DragRect** ([lib/src/list/selectable_list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f78a865a5b517b6892730363bb581f1e53588fb39b9bc88417dea463806327c7))
- ❇️ Params added in default constructor: `mobile` (named, optional, default: false), `isAdditive` (named, optional, default: true)

**`class` _LdAccordionChild** ([lib/src/accordion.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-d258daf61538439919df0bdb2434133a11f77b8b917079c64ecce8c56883d1d0))
- ❌ Param removed in default constructor: `key` (named, optional)

**`class` _LdChainedSpringsState** ([lib/src/spring.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-5ac3b6f3d42047bf8fafd8bf82ad0f1c13e3a0b4d3f9b6e6cbb1c2788647f15a))
- ❇️ Param added in method `update`: `elapsedMs` (positional, optional)

**`class` _LdPadding** ([lib/src/padding.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f86451e3937e772cac008fcbbe050bb1deba8b3c2034db8e47879228fc363e18))
- ❌ Param removed in default constructor: `key` (named, optional)
- ❇️ Param added in default constructor: `sides` (named, optional)

**`class` _LdSpringState** ([lib/src/spring.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-5ac3b6f3d42047bf8fafd8bf82ad0f1c13e3a0b4d3f9b6e6cbb1c2788647f15a))
- ❇️ Param added in method `update`: `elapsedTime` (positional, optional)

**`class` _Spring** ([lib/src/spring.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-5ac3b6f3d42047bf8fafd8bf82ad0f1c13e3a0b4d3f9b6e6cbb1c2788647f15a))
- ❇️ Param added in method `update`: `elapsedMs` (positional, optional)

**`function` appBarSystemUiOverlayStyle** ([lib/src/appbar/appbar_system_ui.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-2e2afdb32db8587902e3a7772bfed984caed29e27a8cb461243c3ac77387b8cc))
- ❇️ Function added: `appBarSystemUiOverlayStyle`

**`function` buildMonkeyRouteTree<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_route_tree.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-5ee5971433b226f5666f1c6e2da4cdd4b73a3416065519e97a778a01e3fae04d))
- ❇️ Function added: `buildMonkeyRouteTree`

**`function` buildMonkeyRoutes<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_routes.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-5dd41942d7588e4b4e14333a7153952c923f9bc1226bae8302adcf3f9c97ce29))
- ❇️ Function added: `buildMonkeyRoutes`

**`function` defaultMonkeyScopeStorageKey** ([lib/src/monkey/monkey_route_tree.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-5ee5971433b226f5666f1c6e2da4cdd4b73a3416065519e97a778a01e3fae04d))
- ❇️ Function added: `defaultMonkeyScopeStorageKey`

**`meta` dependency `flutter_portal`** ([pubspec.yaml](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-8b7e9df87668ffa6a04b32e1769a33434999e54ae081c52e5d943c541d4c0d25))
- 📦 Dependency removed: removed

**`meta` dependency `flutter_sticky_header`** ([pubspec.yaml](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-8b7e9df87668ffa6a04b32e1769a33434999e54ae081c52e5d943c541d4c0d25))
- 📦 Dependency removed: removed

**`meta` dependency `fuzzy`** ([pubspec.yaml](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-8b7e9df87668ffa6a04b32e1769a33434999e54ae081c52e5d943c541d4c0d25))
- 📦 Dependency removed: removed

**`meta` dependency `multi_split_view`** ([pubspec.yaml](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-8b7e9df87668ffa6a04b32e1769a33434999e54ae081c52e5d943c541d4c0d25))
- 📦 Dependency removed: removed

**`meta` dependency `wolt_modal_sheet`** ([pubspec.yaml](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-8b7e9df87668ffa6a04b32e1769a33434999e54ae081c52e5d943c541d4c0d25))
- 📦 Dependency removed: removed

**`function` generateAutoSpacings** ([lib/src/autospace.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f17bdf0d5830aa5697a0e806f3c3035e3563b69cdf810372144eae69594248a3))
- ❇️ Function added: `generateAutoSpacings`

**`function` ldCheckboxPreview** ([lib/src/checkbox.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-212494581d361b843cfc944c41577dc67246a6cfcd3adcc6c8732ec7791c2599))
- ❇️ Function added: `ldCheckboxPreview`

**`function` ldCheckboxPreviewUnchecked** ([lib/src/checkbox.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-212494581d361b843cfc944c41577dc67246a6cfcd3adcc6c8732ec7791c2599))
- ❇️ Function added: `ldCheckboxPreviewUnchecked`

**`function` ldEnterTextModal** ([lib/src/modal/utils.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f01b6f5832f5bdf2f5a51ef00d415aedca5a29c465181b1e02d5a123527e80e6))
- ❇️ Function added: `ldEnterTextModal`

**`function` ldFilterModal<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/filter/filter_modal.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f81eb630c2c49f587ee83d5b882e360f653478d4681dec0266d71e7777758747))
- ❇️ Function added: `ldFilterModal`

**`function` ldMonkeyAppBarActionsForLocation<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/actions/app_bar_actions.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-7e2580b61094599c12a19178307a1c7658a88a5fa9242b062552d217710e3c5d))
- ❇️ Function added: `ldMonkeyAppBarActionsForLocation`

**`function` ldMonkeyDetailModal<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_detail_modal.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f8b5b6e7c6e0e6f4f77a3c137c4fd875aad21949ca410142b8b0d458c7da8d65))
- ❇️ Function added: `ldMonkeyDetailModal`

**`function` maybePopContextMenu** ([lib/src/context_menu.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-bd031ede2f184bbdb13c86e7300dc3ab6f62af650bf3cc1bd5c74ad2fe3e824e))
- ❇️ Function added: `maybePopContextMenu`

**`function` outlineColor** ([lib/src/touchable/outline_color.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-1bbff78515c080600c6fb85f6b0be1c34b55c21b0247994ef355b45e6bfa0576))
- ❇️ Function added: `outlineColor`

**`function` refreshAction<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/actions/refresh_action.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-5bd8d2d1017389a5482896c30ebfe14238f54a589974c6c68230d1ff19ad1d94))
- ❇️ Function added: `refreshAction`

**`function` showFilterContextMenu<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/actions/toggle_filter_action.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-d19de782179dd620487392f95c110cb9fdac399599f4177ab87295cda4a449e2))
- ❇️ Function added: `showFilterContextMenu`

**`function` showFilterModal<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/actions/toggle_filter_action.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-d19de782179dd620487392f95c110cb9fdac399599f4177ab87295cda4a449e2))
- ❇️ Function added: `showFilterModal`

**`function` showSelection<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/actions/show_selection_action.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-91de8cd4c131434a431168435fd68e61dde5cc32922dbbb1d38706e7b44c3296))
- ❇️ Function added: `showSelection`

**`function` toggleSelectionControls<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/actions/toggle_selection_controls_action.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-6cfa515a9ef5008be024ece91b236bda9956532e3703ad438178c3cda1266cde))
- ❇️ Function added: `toggleSelectionControls`

#### 👀 Patch changes

**`class` LdAppBar** ([lib/src/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-c052cf2a20bf84a3bb43daf0349ef5972bd9083a4a8c318d75c4f3b23c1793c6))
- ➖ Methods annotation removed: `debugFillProperties` (@protected), `debugFillProperties` (@mustCallSuper)
- ➕ Method annotation added: `debugFillProperties` (@override)

**`class` LdColor** ([lib/src/color/color.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-81bd681bff4366357f7038b9c9b8f503bbca597d1bffa013af59c292aa7875f1))
- ❇️ Method added: `_calcContrast`

**`class` LdDatePicker** ([lib/src/date_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-705cf9a7b3b5d494795266f0d9bd90767b033dd2dc19f3eee04d709951be9dd7))
- ❌ Property removed: `_initialDate`

**`class` LdExceptionView** ([lib/src/exception/exception_view.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-3b9caa32d813b4accee332539fa3d1e44ecc015a406dd715143f70a5e7c96088))
- 🔄 Method type changed: `_buildRetryButton` (`dynamic` → `Widget`, narrowed), `_buildRetryIndicator` (`dynamic` → `Widget`, narrowed), `_buildDialogButton` (`dynamic` → `LdButton`, narrowed), `_buildHorizontal` (`dynamic` → `LdAutoSpace`, narrowed), `_buildVertical` (`dynamic` → `LdAutoSpace`, narrowed)

**`class` LdNotificationWidget** ([lib/src/notifications/notification_portal.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-5ecbf35c381d0c71f97cc9da48294271c95cf4655da1f141b5a297e4f94765d1))
- ❌ Method removed: `_buildConfirmationButtons`

**`class` LdNotificationsController** ([lib/src/notifications/notifications_controller.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-7473196fa6b569fc3a6cdb5236987f2f7abd38e3216144e037039ad7a759e982))
- ❇️ Property added: `_disposed`
- ➖ Method annotation removed: `dispose` (@mustCallSuper)
- ➕ Method annotation added: `dispose` (@override)
- ❇️ Method added: `_safeNotifyListeners`

**`class` LdPaginator<T>** ([lib/src/list/list_paginator.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-c279977c526f2e1ad42c33e9e9f5451f323d228e7974b6ae305a16daa9ff8dc8))
- 🔄 Properties type changed: `_items`, `_error`
- ❌ Property removed: `_totalItems`
- ❇️ Properties added: `_itemsStreamController`, `_itemStreamController`, `_mutex`, `_offsetQueue`
- ➖ Method annotation removed: `dispose` (@mustCallSuper)
- ➕ Method annotation added: `dispose` (@override)
- 🔄 Param type changed in method `_setError`: `error` (`Object?` → `LdException?`, narrowed)
- ❌ Methods removed: `_fetchItemsAtOffset`, `_debounce`, `_debounceAndSafeExecute`
- ❇️ Methods added: `_triggerFetch`, `_addToOffsetQueue`, `_fetchItems`, `_updated`

**`class` LdRadio** ([lib/src/radio.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-2c308573693eef4e4cf15c26891a5c684215e4725c9a28a038491f334e59b8d9))
- ❌ Method removed: `_onTap`

**`class` LdSubmit<T>** ([lib/src/submit/submit.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-90dec5a624a3cd55bf16ed8f4d39486f0ad3f7b8e1ff081a9177aedac7ea2802))
- ❌ Method removed: `_buildProvider`

**`class` LdSubmitController<T>** ([lib/src/submit/model/submit_controller.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-d921dcc848cbe3ce44f849c2be50e41f4300cb5bddb83fe2c189bea7f63c8f34))
- ❇️ Properties added: `_count`, `_listeners`, `_notificationCallStackDepth`, `_reentrantlyRemovedListeners`, `_debugDisposed`, `_debugCreationDispatched`
- ➕ Method annotation added: `dispose` (@override)
- ❇️ Methods added: `_removeAt`, `_onArgChanged`

**`class` LdSubmitCustomBuilder<T>** ([lib/src/submit/builders/custom_builder.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-2b4f49eafad5ac815a7df3eeadcd97d2e1ac4612ab7e30b3b11f6b472bb252b7))
- ➕ Class annotation added: `LdSubmitCustomBuilder` (@Deprecated("You can use a simple builder with context.watch<LdSubmitController<T, Arg>>() to build your own submit widget."))

**`class` LdTag** ([lib/src/tag.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-7a2a1581011001cf2ceb5a616aac5032867a00eb9cc844c90a534fe6ae840f09))
- ❌ Methods removed: `_padding`, `_fontSize`

**`class` LdTheme** ([lib/src/theme/theme.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e230b3066fca6361167b035927f3d5e83cda9a34212c86e2a307ed82bcf0d99e))
- ❇️ Property added: `_platform`

**`class` _ButtonShape** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- ❇️ Properties added: `disableSqueeze`, `panOffset`, `_circularSizeBump`
- ➖ Methods annotation removed: `debugFillProperties` (@protected), `debugFillProperties` (@mustCallSuper)
- ➕ Method annotation added: `debugFillProperties` (@override)
- 🔄 Param type changed in method `_border`: `context` (`dynamic` → `BuildContext`, narrowed)

**`class` _DatePickerSheet** ([lib/src/date_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-705cf9a7b3b5d494795266f0d9bd90767b033dd2dc19f3eee04d709951be9dd7))
- ❌ Properties removed: `value`, `onChanged`, `dismiss`
- ❇️ Property added: `selectedDateNotifier`

**`class` _DatePickerSheetState** ([lib/src/date_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-705cf9a7b3b5d494795266f0d9bd90767b033dd2dc19f3eee04d709951be9dd7))
- ❌ Property removed: `_selectedDate`
- ❇️ Method added: `_selectDate`

**`class` _Default** ([lib/src/autospace.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f17bdf0d5830aa5697a0e806f3c3035e3563b69cdf810372144eae69594248a3))
- ❌ Class removed: `_Default`

**`class` _DetailPage<T>** ([lib/src/master_detail.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-80147b9866d7287354dd14c965d448fb4533272c7164e2faa7b4a0f7ed280c60))
- ❌ Class removed: `_DetailPage`

**`class` _DragRect** ([lib/src/list/selectable_list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f78a865a5b517b6892730363bb581f1e53588fb39b9bc88417dea463806327c7))
- 🔄 Property type changed: `onUpdateRect`
- ❇️ Properties added: `onTapOutside`, `isAdditive`, `mobile`

**`class` _DragRectState** ([lib/src/list/selectable_list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f78a865a5b517b6892730363bb581f1e53588fb39b9bc88417dea463806327c7))
- ❇️ Methods added: `_buildMobileGestureDetector`, `_buildDesktopGestureDetector`, `_buildDesktopDragRect`, `_buildDragRect`

**`class` _LdAccordionChild** ([lib/src/accordion.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-d258daf61538439919df0bdb2434133a11f77b8b917079c64ecce8c56883d1d0))
- ❌ Properties removed: `curveExpand`, `curveCollapse`, `flatCard`
- ❇️ Properties added: `size`, `disableElevation`

**`class` _LdActionBarGradient** ([lib/src/modal/modal.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-2d55c400b021d628a7e92bc6d07673f3775bac69b40c544c8332ae622d0f715d))
- ❌ Class removed: `_LdActionBarGradient`

**`class` _LdAppBarState** ([lib/src/appbar/appbar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-3fa4ae735c9f6ca4c26ac958e08eaa30e2da735b6e0f0ed00665eb6c2b2bb49f))
- ❇️ Class added: `_LdAppBarState`

**`class` _LdAvatarWidget** ([lib/src/avatar.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e142afc5a4b71ea7f96a73a1f1b6ac035d2721395f0b2905b345fc22ff602458))
- ❇️ Class added: `_LdAvatarWidget`

**`class` _LdButtonState** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- 🔄 Properties type changed: `_trailing`, `_leading`
- ➖ Methods annotation removed: `debugFillProperties` (@protected), `debugFillProperties` (@mustCallSuper)
- ➕ Method annotation added: `debugFillProperties` (@override)

**`class` _LdButtonWidget** ([lib/src/button.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-ff5af0a48673590388fb412e3ae360f4d302beeea64e1280f57ea1b097e23697))
- ❇️ Class added: `_LdButtonWidget`

**`class` _LdCheckboxWidget** ([lib/src/checkbox.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-212494581d361b843cfc944c41577dc67246a6cfcd3adcc6c8732ec7791c2599))
- ❇️ Class added: `_LdCheckboxWidget`

**`class` _LdChooseList<T>** ([lib/src/choose.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-7ac0dbb4a4066cbff0ac50927605c02a4480a89c02fff56480625ff3198d3337))
- ❌ Class removed: `_LdChooseList`

**`class` _LdChooseListState<T>** ([lib/src/choose.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-7ac0dbb4a4066cbff0ac50927605c02a4480a89c02fff56480625ff3198d3337))
- ❌ Class removed: `_LdChooseListState`

**`class` _LdChoosePage<T>** ([lib/src/choose.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-7ac0dbb4a4066cbff0ac50927605c02a4480a89c02fff56480625ff3198d3337))
- ❌ Class removed: `_LdChoosePage`

**`class` _LdChooseState<T>** ([lib/src/choose.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-7ac0dbb4a4066cbff0ac50927605c02a4480a89c02fff56480625ff3198d3337))
- 🔄 Type parameters changed: `T` → `T extends Identifiable<IdType>, IdType`
- ❌ Properties removed: `_sheetKey`, `_enableSearch`
- ❇️ Properties added: `_repository`, `_ownsRepository`
- ➖ Method annotation removed: `didUpdateWidget` (@override)
- ➕ Methods annotation added: `didUpdateWidget` (@mustCallSuper), `didUpdateWidget` (@protected)
- 🔄 Method type changed: `_onTap` (`void` → `Future<void>`)
- ❌ Param removed in method `_onTap`: `openDialog` (positional, required)
- ❇️ Methods added: `_fetchSelectedItems`, `_getDisplayItems`

**`class` _LdCollapseState** ([lib/src/collapse.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-e4733e85d67e8f44f8cefc8d0aabc8c867c2a692a838d619e4d819632ae20496))
- ❌ Class removed: `_LdCollapseState`

**`class` _LdContextMenuState** ([lib/src/context_menu.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-bd031ede2f184bbdb13c86e7300dc3ab6f62af650bf3cc1bd5c74ad2fe3e824e))
- ❌ Class removed: `_LdContextMenuState`

**`class` _LdCounterDigit** ([lib/src/counter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-56493e7e7233aac1f95d625ed446d310fe0305379c2e1b4429cd8bc3083c6a4d))
- ❇️ Class added: `_LdCounterDigit`

**`class` _LdCounterDigitState** ([lib/src/counter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-56493e7e7233aac1f95d625ed446d310fe0305379c2e1b4429cd8bc3083c6a4d))
- ❇️ Class added: `_LdCounterDigitState`

**`class` _LdCounterState** ([lib/src/counter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-56493e7e7233aac1f95d625ed446d310fe0305379c2e1b4429cd8bc3083c6a4d))
- ❇️ Class added: `_LdCounterState`

**`class` _LdCounterWidget** ([lib/src/counter.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-56493e7e7233aac1f95d625ed446d310fe0305379c2e1b4429cd8bc3083c6a4d))
- ❇️ Class added: `_LdCounterWidget`

**`class` _LdDatePickerState** ([lib/src/date_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-705cf9a7b3b5d494795266f0d9bd90767b033dd2dc19f3eee04d709951be9dd7))
- ❇️ Class added: `_LdDatePickerState`

**`class` _LdEnterTextModal** ([lib/src/modal/utils.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f01b6f5832f5bdf2f5a51ef00d415aedca5a29c465181b1e02d5a123527e80e6))
- ❇️ Class added: `_LdEnterTextModal`

**`class` _LdEnterTextModalState** ([lib/src/modal/utils.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f01b6f5832f5bdf2f5a51ef00d415aedca5a29c465181b1e02d5a123527e80e6))
- ❇️ Class added: `_LdEnterTextModalState`

**`class` _LdHintWidget** ([lib/src/hint.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-dfc92525de9815f786b74d0fb4e4a920602109f9db1ffe185778ade2d4295570))
- ❇️ Class added: `_LdHintWidget`

**`class` _LdIndicatorWidget** ([lib/src/indicators.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-d795289d9c186887b0644807b9f5bf48ef75099f590cff62f4a832c3d6d85b3b))
- ❇️ Class added: `_LdIndicatorWidget`

**`class` _LdInputState** ([lib/src/input.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-2ffc2d5e6008b31f35c68f6ed0d27138168bf19c95df7c0aab8349787a9a5ef6))
- ❌ Property removed: `_hovering`
- ❇️ Property added: `_focusScopeNode`

**`class` _LdListState<T, GroupingCriterion>** ([lib/src/list/list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-888f80c71ddeacb424418138bd38d5900a4ffe694069cba2af68eb89e66a4a41))
- 🔄 Type parameters changed: `T, GroupingCriterion` → `T extends Identifiable<IdType>, IdType`
- 🔄 Property type changed: `_groupedItems`
- ❌ Properties removed: `_assumeItemKey`, `_effectiveAssumedHeight`, `calculatedItemHeight`
- ❇️ Properties added: `_itemKeys`, `_performedInitialScroll`
- ➖ Methods annotation removed: `didChangeDependencies` (@protected), `didChangeDependencies` (@mustCallSuper)
- ➕ Method annotation added: `didChangeDependencies` (@override)
- 🔄 Param type changed in method `_shouldRegroupItems`: `oldWidget` (`LdList<T, GroupingCriterion>` → `LdListWidget<T, IdType>`)
- 🔄 Param type changed in method `_shouldUpdateDataListener`: `oldWidget` (`LdList<T, GroupingCriterion>` → `LdListWidget<T, IdType>`)
- 🔄 Method type changed: `_groupItems` (`List<_ListItem<T, GroupingCriterion>>` → `List<LdListRenderItem<T>>`), `_createInterspersedList` (`List<_ListItem<T, GroupingCriterion>>` → `List<LdListRenderItem<T>>`), `_maybePerformInitialScroll` (`void` → `Future<void>`)
- ❇️ Param added in method `_onRefresh`: `context` (positional, required)
- ❌ Param removed in method `_buildActualItem`: `item` (positional, required)
- ❇️ Param added in method `_buildActualItem`: `listEntry` (positional, required)
- ❌ Method removed: `_buildLoadMore`
- 🔄 Param type changed in method `_buildError`: `error` (`Object` → `LdException`, narrowed)
- ❇️ Method added: `_getAverageItemHeight`

**`class` _LdMasterDetailState<T>** ([lib/src/master_detail.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-80147b9866d7287354dd14c965d448fb4533272c7164e2faa7b4a0f7ed280c60))
- ❌ Class removed: `_LdMasterDetailState`

**`class` _LdMonkeyMasterPageState<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_master_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f027b9824ac3c8ae9ddbe6ac353d6cb02c90fe60d3a5d83846b29dbd7ec3c437))
- ❇️ Class added: `_LdMonkeyMasterPageState`

**`class` _LdMonkeyShellState<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_shell.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f58e8426a3074373d1a4d8d50d0d7467233933c3ceffe3098ffc530558a3aa9b))
- ❇️ Class added: `_LdMonkeyShellState`

**`class` _LdMultiPanelLayoutState** ([lib/src/multi_panel/multi_panel_layout.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-dcf83dd1348efc710dbc6957e505c08eb421234a466c65f2b9630f2f41b83750))
- ❇️ Class added: `_LdMultiPanelLayoutState`

**`class` _LdOrbState** ([lib/src/liquid_orb.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-77302ae24f129be07973b7dedb81c73569eef9d7e22d7c51c0d8c4b7d6813f72))
- 🔄 Properties type changed: `_animationController`, `_animation`
- ❇️ Modifier `late` added to properties: `_animationController`, `_animation`
- ❌ Properties removed: `_angle`, `_streamSubscription`

**`class` _LdPadding** ([lib/src/padding.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f86451e3937e772cac008fcbbe050bb1deba8b3c2034db8e47879228fc363e18))
- ❇️ Property added: `sides`

**`class` _LdRadioWidget** ([lib/src/radio.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-2c308573693eef4e4cf15c26891a5c684215e4725c9a28a038491f334e59b8d9))
- ❇️ Class added: `_LdRadioWidget`

**`class` _LdRepositoryProviderState<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/data/repository_provider.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-d53f8e2e8c07954a7305ae5112dd68d3dd433f1bc35fd6369e32edfe3324dd8c))
- ❇️ Class added: `_LdRepositoryProviderState`

**`class` _LdRunnerLogState** ([lib/src/runner.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-6b567e02a0af50b04f70212b6f0e9f870e0ed5de80b85853890572d0a7493947))
- ❇️ Property added: `_isHovering`

**`class` _LdSearchInputState** ([lib/src/appbar/search_components.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-c7750a1ad0e6a79e8cd9a447bd3f31dd1c31866d30873339df5d2bea4b410ecd))
- ❇️ Class added: `_LdSearchInputState`

**`class` _LdSearchSuggestionsOverlayState** ([lib/src/appbar/search_components.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-c7750a1ad0e6a79e8cd9a447bd3f31dd1c31866d30873339df5d2bea4b410ecd))
- ❇️ Class added: `_LdSearchSuggestionsOverlayState`

**`class` _LdSelectState<T>** ([lib/src/select.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-bc5dd59ffff566f496d4463c5136fdcba05247739d6102d1b7578f12d41e30ac))
- ❌ Properties removed: `isOpen`, `_overlayController`, `_menuKey`
- ❇️ Property added: `_focusNodeChildren`
- ❌ Method removed: `_insetDropdownSafely`
- ❇️ Methods added: `_buildDropdownItem`, `_buildDropdownMenu`, `_buildDropdownButton`

**`class` _LdSelectableListState<T, GroupingCriterion>** ([lib/src/list/selectable_list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f78a865a5b517b6892730363bb581f1e53588fb39b9bc88417dea463806327c7))
- ➕ Mixin added: WidgetsBindingObserver
- 🔄 Type parameters changed: `T, GroupingCriterion` → `T extends Identifiable<IdType>, IdType`
- ❌ Properties removed: `_selectedItems`, `_dragRectItems`, `_changeNotifier`, `_focusNode`, `_itemKeys`, `_shiftPressed`, `_ctrlPressed`, `isMultiSelect`
- ❇️ Properties added: `_selectionController`, `_isMobile`
- ❌ Methods removed: `isSelected`, `onTap`, `_selectRange`, `onSelectionChange`
- ❇️ Param added in method `_onUpdateDragRect`: `directionIsDownRight` (positional, required)
- 🔄 Method type changed: `_onEndDrag` (`void` → `Future<void>`), `_onKeyEvent` (`void` → `KeyEventResult`)
- 🔢 Param reordered in method `_onKeyEvent`: `event` (positional, required)
- ❇️ Param added in method `_onKeyEvent`: `node` (positional, required)
- ❇️ Methods added: `didPopRoute`, `handleStartBackGesture`, `handleUpdateBackGestureProgress`, `handleCommitBackGesture`, `handleCancelBackGesture`, `handleStatusBarTap`, `didPushRoute`, `didPushRouteInformation`, `didChangeMetrics`, `didChangeTextScaleFactor`, `didChangePlatformBrightness`, `didChangeLocales`, `didChangeAppLifecycleState`, `didChangeViewFocus`, `didRequestAppExit`, `didHaveMemoryPressure`, `didChangeAccessibilityFeatures`, `_onSelectionControllerChanged`, `_defaultListBuilder`, `_wrapListItem`

**`class` _LdSheetDragController<T>** ([lib/src/modal/modal.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-2d55c400b021d628a7e92bc6d07673f3775bac69b40c544c8332ae622d0f715d))
- ❇️ Class added: `_LdSheetDragController`

**`class` _LdSheetDragGestureDetector<T>** ([lib/src/modal/modal.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-2d55c400b021d628a7e92bc6d07673f3775bac69b40c544c8332ae622d0f715d))
- ❇️ Class added: `_LdSheetDragGestureDetector`

**`class` _LdSheetDragGestureDetectorState<T>** ([lib/src/modal/modal.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-2d55c400b021d628a7e92bc6d07673f3775bac69b40c544c8332ae622d0f715d))
- ❇️ Class added: `_LdSheetDragGestureDetectorState`

**`class` _LdSliderState** ([lib/src/slider.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-82fc935898b26344b6fdbde471300e33419c889583414e3e13bec600f0a8fc96))
- 🔄 Method type changed: `_onDragStart` (`dynamic` → `void`, narrowed), `_onDragUpdate` (`dynamic` → `void`, narrowed), `_onDragEnd` (`dynamic` → `Future<void>`, narrowed)

**`class` _LdSpeedReaderState** ([lib/src/speed_reader.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-98a3cffa784a371ca850e8838ab43d691a0cda4d0e96f5129839c1b777cd73e9))
- ❇️ Class added: `_LdSpeedReaderState`

**`class` _LdSubmitDialogState<T, Arg>** ([lib/src/submit/builders/dialog_builder.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-667617a61b037cae73c86a02fac20c0c80283ad8dc680535c250ada7f9ae994a))
- ❇️ Class added: `_LdSubmitDialogState`

**`class` _LdSubmitNotification<T, Arg>** ([lib/src/submit/builders/notification_builder.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-9c6d145646b33b86392036585f3f6e79308af86c2cc191543dd1276b13cbe9c3))
- ❇️ Class added: `_LdSubmitNotification`

**`class` _LdSubmitNotificationState<T, Arg>** ([lib/src/submit/builders/notification_builder.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-9c6d145646b33b86392036585f3f6e79308af86c2cc191543dd1276b13cbe9c3))
- ❇️ Class added: `_LdSubmitNotificationState`

**`class` _LdSubmitState<T, Arg>** ([lib/src/submit/submit.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-90dec5a624a3cd55bf16ed8f4d39486f0ad3f7b8e1ff081a9177aedac7ea2802))
- ❇️ Class added: `_LdSubmitState`

**`class` _LdTabNavigationState** ([lib/src/appbar/tab_navigation.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-52bf35196752849d0d45f783bb5b24e4217e93ef2ae5ff75caafe39bc5b551fc))
- ❇️ Class added: `_LdTabNavigationState`

**`class` _LdTagWidget** ([lib/src/tag.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-7a2a1581011001cf2ceb5a616aac5032867a00eb9cc844c90a534fe6ae840f09))
- ❇️ Class added: `_LdTagWidget`

**`class` _LdTextWidget** ([lib/src/text.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-ce7342ea9aebd0be91a6fd6597751ce9b68c0040b4cd9db2386764d2efceb9a2))
- ❇️ Class added: `_LdTextWidget`

**`class` _LdThemeProviderState** ([lib/src/theme/theme_provider.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-bb56e3df14103825a8edc59aa7689986b2bface5596870727b1ab28297f86e57))
- ❇️ Properties added: `_screenRadiusSubscription`, `_windowDecoration`
- ❌ Method removed: `_getScreenRadius`
- ❇️ Methods added: `_runAfterFrame`, `_applyInitialTheme`, `_listenToScreenRadiusStream`, `_applyThemeSize`, `_applyPlatformOverride`

**`class` _LdTimePickerModalState** ([lib/src/time_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-fb045078ea903e4c0c3ae338b38f895d4245816be0481759aeb4cfc98122b476))
- ❇️ Class added: `_LdTimePickerModalState`

**`class` _LdTimePickerWidgetState** ([lib/src/time_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-fb045078ea903e4c0c3ae338b38f895d4245816be0481759aeb4cfc98122b476))
- ❇️ Property added: `_minuteFocusNode`

**`class` _LdTouchableSurfaceState** ([lib/src/touchable/touchable.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-390c2ec1e7b0ebec409f605c4cdc4ea7ef337cf7876bdca7a87de6f2c647ea96))
- ❌ Property removed: `_colorBundle`
- ❇️ Properties added: `_listenerKey`, `_pointerDownOffset`, `_panOffset`, `_onPressedKeys`

**`class` _ListItem<T, SeparationCriterion>** ([lib/src/list/list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-888f80c71ddeacb424418138bd38d5900a4ffe694069cba2af68eb89e66a4a41))
- ❌ Class removed: `_ListItem`

**`enum` _ListItemType** ([lib/src/list/list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-888f80c71ddeacb424418138bd38d5900a4ffe694069cba2af68eb89e66a4a41))
- ❌ Enum removed: `_ListItemType`

**`class` _MonkeyShellLayoutBuilder<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_shell.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f58e8426a3074373d1a4d8d50d0d7467233933c3ceffe3098ffc530558a3aa9b))
- ❇️ Class added: `_MonkeyShellLayoutBuilder`

**`class` _PostFrameCallback** ([lib/src/context_menu.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-bd031ede2f184bbdb13c86e7300dc3ab6f62af650bf3cc1bd5c74ad2fe3e824e))
- ❌ Class removed: `_PostFrameCallback`

**`class` _PostFrameCallbackState** ([lib/src/context_menu.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-bd031ede2f184bbdb13c86e7300dc3ab6f62af650bf3cc1bd5c74ad2fe3e824e))
- ❌ Class removed: `_PostFrameCallbackState`

**`class` _PreventAutoFocusState** ([lib/src/monkey/monkey_shell.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f58e8426a3074373d1a4d8d50d0d7467233933c3ceffe3098ffc530558a3aa9b))
- ❇️ Class added: `_PreventAutoFocusState`

**`class` _RepostoryWatchItems<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/detail_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-43d347b03da89e053d770a97150585d0955be32f82540fad5d2ceabd18d33035))
- ❇️ Class added: `_RepostoryWatchItems`

**`class` _RepostoryWatchItemsState<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/detail_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-43d347b03da89e053d770a97150585d0955be32f82540fad5d2ceabd18d33035))
- ❇️ Class added: `_RepostoryWatchItemsState`

**`class` _SetNotifier<T>** ([lib/src/list/selectable_list.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f78a865a5b517b6892730363bb581f1e53588fb39b9bc88417dea463806327c7))
- ❌ Class removed: `_SetNotifier`

**`enum` _Side** ([lib/src/padding.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f86451e3937e772cac008fcbbe050bb1deba8b3c2034db8e47879228fc363e18))
- ❇️ Enum added: `_Side`

**`class` _Spring** ([lib/src/spring.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-5ac3b6f3d42047bf8fafd8bf82ad0f1c13e3a0b4d3f9b6e6cbb1c2788647f15a))
- ❇️ Properties added: `oneFrameElapsed`, `state`

**`function` _buildDetailRoutes** ([lib/src/monkey/monkey_route_tree.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-5ee5971433b226f5666f1c6e2da4cdd4b73a3416065519e97a778a01e3fae04d))
- ❇️ Function added: `_buildDetailRoutes`

**`function` _collectPathTo** ([lib/src/monkey/monkey_route_tree.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-5ee5971433b226f5666f1c6e2da4cdd4b73a3416065519e97a778a01e3fae04d))
- ❇️ Function added: `_collectPathTo`

**`function` _detailPageBuilder** ([lib/src/monkey/monkey_route_tree.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-5ee5971433b226f5666f1c6e2da4cdd4b73a3416065519e97a778a01e3fae04d))
- ❇️ Function added: `_detailPageBuilder`

**`function` _detailPathSegment** ([lib/src/monkey/monkey_route_tree.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-5ee5971433b226f5666f1c6e2da4cdd4b73a3416065519e97a778a01e3fae04d))
- ❇️ Function added: `_detailPathSegment`

**`function` _wrapBodyWithBar<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey/monkey_master_page.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-f027b9824ac3c8ae9ddbe6ac353d6cb02c90fe60d3a5d83846b29dbd7ec3c437))
- ❇️ Functions added: `_wrapBodyWithBar`, `_wrapBodyWithBar`

**`meta` dependency `equatable`** ([pubspec.yaml](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-8b7e9df87668ffa6a04b32e1769a33434999e54ae081c52e5d943c541d4c0d25))
- 📦 Dependency added: with version `^2.0.7`

**`meta` dependency `go_router`** ([pubspec.yaml](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-8b7e9df87668ffa6a04b32e1769a33434999e54ae081c52e5d943c541d4c0d25))
- 📦 Dependency version changed: from `^14.6.2` to `^17.0.1`

**`meta` dependency `haptic_feedback`** ([pubspec.yaml](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-8b7e9df87668ffa6a04b32e1769a33434999e54ae081c52e5d943c541d4c0d25))
- 📦 Dependency version changed: from `>=0.4.2 <0.6.0` to `^0.6.4+3`

**`meta` dependency `lucide_icons_flutter`** ([pubspec.yaml](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-8b7e9df87668ffa6a04b32e1769a33434999e54ae081c52e5d943c541d4c0d25))
- 📦 Dependency version changed: from `^3.0.3` to `^3.1.9`

**`meta` dependency `mutex`** ([pubspec.yaml](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-8b7e9df87668ffa6a04b32e1769a33434999e54ae081c52e5d943c541d4c0d25))
- 📦 Dependency added: with version `^3.1.0`

**`meta` dependency `sensors_plus`** ([pubspec.yaml](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-8b7e9df87668ffa6a04b32e1769a33434999e54ae081c52e5d943c541d4c0d25))
- 📦 Dependency version changed: from `>=5.0.1 <7.0.0` to `^7.0.0`

**`meta` dependency `value_layout_builder`** ([pubspec.yaml](https://github.com/emdgroup-liquid/liquid-flutter/compare/v22.0.4..9285455ad3c034825185634381dbe83eaba70ac2#diff-8b7e9df87668ffa6a04b32e1769a33434999e54ae081c52e5d943c541d4c0d25))
- 📦 Dependency added: with version `^0.5.0`



Since version 23.0.0-2
Please refer to the changelog at the root of the repository or at 

https://github.com/emdgroup-liquid/liquid-flutter/blob/main/CHANGELOG.md

