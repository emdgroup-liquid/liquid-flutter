import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart';
import 'package:reactive_forms/reactive_forms.dart';

enum Pet { cats, dogs }

void main() {
  test('native set == can fail for identical-looking enum sets', () {
    final a = {Pet.cats};
    final b = {Pet.cats};
    expect(const SetEquality<Pet>().equals(a, b), isTrue);
  });

  test('LdFormSetValidators.equals matches choose field values', () {
    final control = FormControl<Set<Pet>>(
      value: {Pet.dogs},
      validators: [LdFormSetValidators.equals({Pet.dogs})],
    );

    expect(control.valid, isTrue);

    control.value = {Pet.cats};
    expect(control.valid, isFalse);
    expect(control.errors.containsKey('requiredEquals'), isTrue);
  });
}
