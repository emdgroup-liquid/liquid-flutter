// In this file, we define the typedefs for the library. Basically we specify
// which parts of Flutter's ReactiveForms package we want to expose to Liquid
// Flutter and how we want to call them, as our typedefs are just aliases to the
// original types.

import 'package:reactive_forms/reactive_forms.dart';

typedef LdReactiveFormFieldState<TModel, TView> = ReactiveFormFieldState<TModel, TView>;
typedef LdFormFieldBuilder<TModel, TView> = ReactiveFormFieldBuilder<TModel, TView>;
typedef LdFormSubmitBuilder = ReactiveFormConsumerBuilder;
typedef LdFormValidator<T> = Validator<T>;
typedef LdFormValidators = Validators;
typedef LdFormGroup = FormGroup;
