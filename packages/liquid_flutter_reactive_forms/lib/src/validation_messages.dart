import 'package:reactive_forms/reactive_forms.dart';

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
