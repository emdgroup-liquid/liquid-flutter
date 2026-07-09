import 'package:flutter/widgets.dart';
import 'package:liquid/components/data_display/markdown_demos.dart';
import 'package:liquid/components/feedback/hint_demos.dart';
import 'package:liquid/components/interaction/button_demos.dart';

/// Maps demo tag names (as used in `<!-- demo:TAG -->` markers inside
/// dartdoc comments) to the widget that should be embedded at that point
/// in the generated documentation page.
///
/// Keys must match exactly the TAG strings written in the `///` comments of
/// the corresponding `liquid_flutter` widget source files.
///
/// To add a new demo:
/// 1. Create a standalone widget class in the appropriate `*_demos.dart` file.
/// 2. Add an entry here.
/// 3. Add a `<!-- demo:TAG -->` marker in the `///` comment of the widget.
/// 4. Run `melos run api_guard && melos run generate_docs`.
const Map<String, Widget Function()> demoRegistry = {
  // LdHint
  'LdHintVariants': LdHintVariantsDemo.new,
  'LdHintWithBackground': LdHintWithBackgroundDemo.new,

  // LdButton
  'LdButtonPlayground': LdButtonPlaygroundDemo.new,
  'LdButtonError': LdButtonErrorDemo.new,
  'LdButtonLeadingTrailing': LdButtonLeadingTrailingDemo.new,
  'LdButtonDisabled': LdButtonDisabledDemo.new,
  'LdButtonCircular': LdButtonCircularDemo.new,
  'LdButtonFullWidth': LdButtonFullWidthDemo.new,
  'LdButtonConfig': LdButtonConfigDemo.new,

  // LdMarkdown
  'LdMarkdownLive': LdMarkdownLiveDemo.new,
};
