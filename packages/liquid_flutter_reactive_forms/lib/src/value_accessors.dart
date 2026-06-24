import 'package:reactive_forms/reactive_forms.dart';

class MapValueAccessor<T> extends ControlValueAccessor<T, String> {
  final Map<T, String> map;

  MapValueAccessor(this.map);

  @override
  String? modelToViewValue(T? modelValue) {
    return modelValue == null ? null : map[modelValue];
  }

  @override
  T? viewToModelValue(String? viewValue) {
    return map.entries.firstWhere((entry) => entry.value == viewValue).key;
  }
}
