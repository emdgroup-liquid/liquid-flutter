import 'package:liquid/components/component_well/component_well.dart';

class ShowSourceCodeOptions {
  /// The tag to look for in the source code.
  /// The source code must contain a comment like this:
  /// ```dart
  /// /*begin demo:tag*/
  /// // your code here
  /// /*end demo:tag*/
  /// ```
  /// where `tag` is the value of this property.
  /// The code between the `begin` and `end` comments will be displayed.
  ///
  /// If no tag is provided, the source code will be extracted in an elaborated
  /// way counting the braces to ensure the entire child widget is captured.
  ///
  /// If multiple [ComponentWell] widgets are present in the same file, the
  /// [componentWellIndex] property can be used to specify which one to extract.
  ///
  /// This method is less reliable and may not work in all cases.
  final String? tag;

  /// The index of the [ComponentWell] widget in the source code file. It will
  /// only be used if the [tag] property is not provided.
  final int? componentWellIndex;

  /// The path to the source code file, e.g. "lib/components/reactive_form.dart".
  /// If no path is provided, it will be tried to be inferred from the current
  /// route.
  final String? path;

  /// Set to false to hide the source code button.
  final bool showButton;

  ShowSourceCodeOptions(
      {this.tag, this.path, this.showButton = true, this.componentWellIndex});
}
