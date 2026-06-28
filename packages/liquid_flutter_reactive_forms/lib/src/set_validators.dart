import 'package:collection/collection.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// Validators for [Set]-valued form controls (e.g. [LdChoose] / `chooseFromItems`).
///
/// [LdFormValidators.equals] uses `==`, which does not compare set contents for
/// all set implementations. Use [equals] here instead.
abstract final class LdFormSetValidators {
  static Validator<dynamic> equals<T>(Set<T> expected) {
    final equality = SetEquality<T>();
    return Validators.delegate((control) {
      final actual = control.value as Set<T>?;
      if (actual != null && equality.equals(actual, expected)) {
        return null;
      }
      return {
        ValidationMessage.equals: <String, dynamic>{
          'required': expected,
          'actual': actual,
        },
      };
    });
  }
}
