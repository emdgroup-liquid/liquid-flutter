/// The type of change that was detected in the API.
/// A [patch] change is a change that does not break the API.
/// A [minor] change is a change that adds new features to the API or introduces
/// backwards-compatible changes.
/// A [major] change is a change that breaks the API or removes features.
enum ApiChangeType {
  patch,
  minor,
  major;

  ApiChangeType atLeast(ApiChangeType other) {
    return index >= other.index ? this : other;
  }

  ApiChangeType atMost(ApiChangeType other) {
    return index <= other.index ? this : other;
  }
}

/// A change description in the API that belongs to a specific component.
class ApiChange {
  final String component;
  final String description;
  final ApiChangeType type;

  ApiChange({
    required this.component,
    required this.description,
    required this.type,
  });

  ApiChange atMost(ApiChangeType other) {
    return ApiChange(
      component: component,
      description: description,
      type: type.atMost(other),
    );
  }
}
