/// Shared info/warning/success/error tone used by callouts and timeline items.
enum LdGenuiTone {
  info,
  warning,
  success,
  error;

  static LdGenuiTone parse(Object? raw, {LdGenuiTone or = LdGenuiTone.info}) {
    return switch (raw) {
      'warning' => LdGenuiTone.warning,
      'success' => LdGenuiTone.success,
      'error' => LdGenuiTone.error,
      'info' => LdGenuiTone.info,
      _ => or,
    };
  }

  static const schemaValues = ['info', 'warning', 'success', 'error'];
}
