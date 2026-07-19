import 'dart:convert';
import 'dart:io';

class IdentifiableProtoConfig {
  final Map<String, String> fieldOverrides;

  const IdentifiableProtoConfig(this.fieldOverrides);

  factory IdentifiableProtoConfig.fromJson(Map<String, dynamic> json) {
    final overrides = <String, String>{};
    for (final entry in json.entries) {
      final key = entry.key.trim();
      final value = entry.value;
      if (key.isEmpty) {
        throw FormatException('Empty class name in config');
      }
      if (value is! String || value.trim().isEmpty) {
        throw FormatException(
          'Field override for "$key" must be a non-empty string',
        );
      }
      overrides[key] = value.trim();
    }
    return IdentifiableProtoConfig(overrides);
  }

  factory IdentifiableProtoConfig.load(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      return IdentifiableProtoConfig(const {});
    }
    final json = jsonDecode(file.readAsStringSync());
    if (json is! Map<String, dynamic>) {
      throw FormatException('Config file must be a JSON object');
    }
    return IdentifiableProtoConfig.fromJson(json);
  }
}