library liquid_flutter;

import 'package:flutter/foundation.dart';

export 'src/accordion.dart';
export 'src/appbar.dart';
export 'src/autospace.dart';
export 'src/avatar.dart';
export 'src/badge.dart';
export 'src/blurring_header.dart';
export 'src/breadcrumb.dart';
export 'src/button.dart';
export 'src/card.dart';
export 'src/checkbox.dart';
export 'src/choose.dart';
export 'src/collapse.dart';
export 'src/color/color.dart';
export 'src/color/palette.dart';
export 'src/color/tokens/amber.dart';
export 'src/color/tokens/green.dart';
export 'src/color/tokens/red.dart';
export 'src/color/tokens/sky.dart';
export 'src/color/tokens/zinc.dart';
export 'src/container.dart';
export 'src/context_menu.dart';
export 'src/date_picker.dart';
export 'src/divider.dart';
export 'src/drawer/header.dart';
export 'src/drawer/section_header.dart';
export 'src/drawer/section_item.dart';
export 'src/exception/exception_dialog.dart';
export 'src/exception/exception_mapper.dart';
export 'src/exception/exception_more_info_button.dart';
export 'src/exception/exception_view.dart';
export 'src/exception/model/exception.dart';
export 'src/exception/model/retry_config.dart';
export 'src/exception/retry_controller.dart';
export 'src/exception/retry_indicator.dart';
export 'src/form.dart';
export 'src/hint.dart';
export 'src/indicators.dart';
export 'src/input.dart';
export 'src/l10n/generated/liquid_localizations.dart';
export 'src/liquid_orb.dart';
export 'src/list/list.dart';
export 'src/list/list_empty.dart';
export 'src/list/list_item.dart';
export 'src/list/list_item_toggle.dart';
export 'src/list/list_loading.dart';
export 'src/list/list_page.dart';
export 'src/list/list_paginator.dart';
export 'src/list/list_seperator.dart';
export 'src/list/selectable_list.dart';
export 'src/loading.dart';
export 'src/master_detail/crud_actions.dart';
export 'src/master_detail/crud_master_list.dart';
export 'src/master_detail/master_detail.dart';
export 'src/master_detail/master_detail_controller.dart';
export 'src/master_detail/master_detail_route.dart';
export 'src/modal/modal.dart';
export 'src/modal/modal_builder.dart';
export 'src/modal/modal_page.dart';
export 'src/modal/modal_type_mode.dart';
export 'src/modal/modal_types.dart';
export 'src/modal/sheet.dart';
export 'src/modal/utils.dart';
export 'src/notifications/notification.dart';
export 'src/notifications/notification_portal.dart';
export 'src/notifications/notification_type.dart';
export 'src/notifications/notifications_controller.dart';
export 'src/padding.dart';
export 'src/portal.dart';
export 'src/radio.dart';
export 'src/reveal.dart';
export 'src/runner.dart';
export 'src/select.dart';
export 'src/slider.dart';
export 'src/spacer.dart';
export 'src/spring.dart';
export 'src/submit/builders/centered_builder.dart';
export 'src/submit/builders/custom_builder.dart';
export 'src/submit/builders/dialog_builder.dart';
export 'src/submit/builders/inline_builder.dart';
export 'src/submit/model/submit_config.dart';
export 'src/submit/model/submit_controller.dart';
export 'src/submit/model/submit_state.dart';
export 'src/submit/submit.dart';
export 'src/submit/submit_loading_indicator.dart';
export 'src/surface.dart';
export 'src/switch.dart';
export 'src/table.dart';
export 'src/tabs.dart';
export 'src/tag.dart';
export 'src/text.dart';
export 'src/theme/liquid_material_theme.dart';
export 'src/theme/screen_radius.dart';
export 'src/theme/theme.dart';
export 'src/theme/theme_provider.dart';
export 'src/theme/themed_material_app_builder.dart';
export 'src/time_picker.dart';
export 'src/toggle.dart';
export 'src/tokens.dart';
export 'src/touchable/touchable.dart';
export 'src/typography.dart';
export 'src/version.dart';
export 'src/window_frame.dart';
export 'variants.g.dart';

/// This variable defines whether TextStyle should use the `liquid_flutter`
/// package prefix when defining the font family.
///
/// If a font is defined in a package, this will be prefixed with
/// 'packages/package_name/' (e.g. 'packages/cool_fonts/Roboto'). The
/// prefixing is done by the constructor when the `package` argument is
/// provided.
///
/// This is particularly useful when:
/// - You're using a package that provides custom fonts
/// - You're creating a package that includes custom fonts
/// - You want to keep your fonts organized in separate packages
///
/// Defaults to true
var ldIncludeFontPackage = true;

/// This flag is used to disable animations in the library.
/// This is useful for golden tests, as animations can cause flakiness
/// and take time until they complete and the screen or widget is stable.
///
/// Defaults to false
var ldDisableAnimations = false;

/// Whether LiquidFlutter should print debug messages.
///
/// Defaults to [kDebugMode]
var ldPrintDebugMessages = kDebugMode;
