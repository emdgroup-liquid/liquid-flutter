/// Whitelist of allowed UI-only widgets for widget tree generation.
/// Only presentation widgets from Liquid Flutter are allowed.
/// Logic widgets like Column, Row, Container are excluded.
class WidgetWhitelist {
  /// Set of allowed widget type names
  static const Set<String> allowedWidgets = {
    // Layout components
    'LdScaffold',
    'LdAppBar',
    'LdScaffoldBody',
    'LdAutoSpace',
    'LdBundle',
    'LdCard',
    'LdContainer',
    // Text components
    'LdText',
    'LdText.h',
    'LdText.hl',
    'LdText.hs',
    'LdText.hxs',
    'LdText.p',
    'LdText.pl',
    'LdText.ps',
    'LdText.pxs',
    'LdText.l',
    'LdText.ll',
    'LdText.ls',
    'LdText.lxs',
    'LdText.caption',
    // Form components
    'LdInput',
    'LdButton',
    'LdCheckbox',
    'LdRadio',
    'LdSwitch',
    'LdSelect',
    'LdSlider',
    'LdDatePicker',
    'LdTimePicker',
    // List components
    'LdList',
    'LdListItem',
    'LdListEmpty',
    'LdListLoading',
    // Feedback components
    'LdNotification',
    'LdHint',
    'LdLoading',
    'LdExceptionView',
    // Modal components
    'LdSheet',
    // Other components
    'LdBadge',
    'LdTag',
    'LdAvatar',
    'LdDivider',
    'LdAccordion',
    'LdBreadcrumb',
    'LdTable',
  };

  /// Check if a widget type is whitelisted
  static bool isWhitelisted(String widgetType) {
    return allowedWidgets.contains(widgetType);
  }

  /// Get a formatted list of allowed widgets for prompts
  static String getFormattedList() {
    final buffer = StringBuffer();
    buffer.writeln('Allowed Widget Types:');
    buffer.writeln('');
    
    // Group by category
    final categories = <String, List<String>>{
      'Layout': [
        'LdScaffold',
        'LdAppBar',
        'LdScaffoldBody',
        'LdAutoSpace',
        'LdBundle',
        'LdCard',
        'LdContainer',
      ],
      'Text': [
        'LdText',
        'LdText.h',
        'LdText.hl',
        'LdText.hs',
        'LdText.hxs',
        'LdText.p',
        'LdText.pl',
        'LdText.ps',
        'LdText.pxs',
        'LdText.l',
        'LdText.ll',
        'LdText.ls',
        'LdText.lxs',
        'LdText.caption',
      ],
      'Form': [
        'LdInput',
        'LdButton',
        'LdCheckbox',
        'LdRadio',
        'LdSwitch',
        'LdSelect',
        'LdSlider',
        'LdDatePicker',
        'LdTimePicker',
      ],
      'List': [
        'LdList',
        'LdListItem',
        'LdListEmpty',
        'LdListLoading',
      ],
      'Feedback': [
        'LdNotification',
        'LdHint',
        'LdLoading',
        'LdExceptionView',
      ],
      'Modal': [
        'LdSheet',
      ],
      'Other': [
        'LdBadge',
        'LdTag',
        'LdAvatar',
        'LdDivider',
        'LdAccordion',
        'LdBreadcrumb',
        'LdTable',
      ],
    };

    for (final entry in categories.entries) {
      buffer.writeln('${entry.key}:');
      for (final widget in entry.value) {
        buffer.writeln('  - $widget');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }
}
