import 'package:reactive_forms/reactive_forms.dart';

/// When to show field-level validation errors.
///
/// Errors appear after the user has edited and left a field, or after a failed
/// submit (which marks all controls touched and dirty).
bool ldReactiveFormShowErrors(AbstractControl<dynamic> control) {
  return control.invalid && control.dirty && control.touched;
}

/// Default validation messages for [LdReactiveForm].
///
/// Merged with form-specific [validationMessages]; form entries override these.
final Map<String, ValidationMessageFunction> ldDefaultReactiveFormValidationMessages = {
  'required': (error) => 'This field is required',
  'email': (error) => 'Enter a valid email address',
  'minLength': (error) {
    final map = error as Map<String, dynamic>?;
    final requiredLength = map?['requiredLength'];
    return 'Enter at least $requiredLength characters';
  },
  'maxLength': (error) {
    final map = error as Map<String, dynamic>?;
    final requiredLength = map?['requiredLength'];
    return 'Enter at most $requiredLength characters';
  },
  'mustMatch': (error) => 'Values must match',
  'requiredTrue': (error) => 'This field must be checked',
  'requiredEquals': (error) => 'Invalid selection',
  // reactive_forms <=17 used `equals`; keep alias for older call sites.
  'equals': (error) => 'Invalid selection',
};

Map<String, ValidationMessageFunction> ldMergeReactiveFormValidationMessages(
  Map<String, ValidationMessageFunction>? overrides,
) {
  if (overrides == null || overrides.isEmpty) {
    return ldDefaultReactiveFormValidationMessages;
  }
  return {
    ...ldDefaultReactiveFormValidationMessages,
    ...overrides,
  };
}
