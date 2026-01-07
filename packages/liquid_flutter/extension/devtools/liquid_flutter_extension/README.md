# Liquid Flutter DevTools Extension

This DevTools extension allows you to inspect and search for specific widgets in your Flutter app's widget tree, with special focus on Liquid Design components like `LdSubmit`, `LdButton`, `LdForm`, and more.

## Features

- **Widget Search**: Search for widgets by type, key, or partial matches
- **Property Inspection**: View widget properties and configuration
- **Hierarchy Visualization**: See the widget tree structure and relationships
- **Liquid Design Focus**: Optimized for finding and inspecting Liquid Design components

## Current Implementation

The extension currently provides a **mock implementation** that demonstrates the structure and capabilities. It shows how you would integrate with the actual DevTools API to traverse the widget tree.

### What's Implemented

- ✅ UI for searching and displaying widgets
- ✅ Mock data structure for `LdSubmit`, `LdButton`, and `LdForm` widgets
- ✅ Widget property display and hierarchy visualization
- ✅ Conceptual integration points with DevTools API

### What's Missing (Real Implementation)

- ❌ Actual connection to running Flutter app
- ❌ Real widget tree traversal
- ❌ Live widget property extraction
- ❌ Source location detection

## How to Use

1. **Install the Extension**: Build and install this extension in DevTools
2. **Search for Widgets**: Use the search bar to find specific widget types
3. **Inspect Properties**: Click on widgets to expand and see their properties
4. **View Hierarchy**: See the parent-child relationships between widgets

### Search Examples

- `LdSubmit` - Find all submit widgets
- `LdButton` - Find all button widgets
- `LdForm` - Find all form widgets
- `submit` - Find widgets containing "submit" in their type or key

## Implementing Real Widget Tree Traversal

To implement actual widget tree traversal, you'll need to integrate with the DevTools extension API. Here's the conceptual approach:

### 1. Connect to the Running App

```dart
// Get the current app connection
final app = await DevToolsExtension.instance.getConnectedApp();
```

### 2. Access the Widget Inspector

```dart
// Access the widget inspector
final inspector = await app.getWidgetInspector();
```

### 3. Get the Widget Tree

```dart
// Get the current widget tree
final tree = await inspector.getWidgetTree();
```

### 4. Traverse and Search

```dart
// Recursively traverse the tree
List<WidgetInfo> _traverseWidgetTree(dynamic widgetNode, String query) {
  final results = <WidgetInfo>[];

  // Check if current widget matches query
  if (_widgetMatchesQuery(widgetNode, query)) {
    results.add(WidgetInfo(
      type: widgetNode.runtimeType.toString(),
      key: widgetNode.key?.toString(),
      location: _getWidgetLocation(widgetNode),
      properties: _extractWidgetProperties(widgetNode),
      children: _traverseWidgetTree(widgetNode.children, query),
    ));
  }

  // Recursively check children
  for (final child in widgetNode.children) {
    results.addAll(_traverseWidgetTree(child, query));
  }

  return results;
}
```

### 5. Extract Widget Properties

```dart
Map<String, dynamic> _extractWidgetProperties(dynamic widget) {
  final properties = <String, dynamic>{};

  // For LdSubmit widgets
  if (widget.runtimeType.toString().startsWith('LdSubmit')) {
    properties['arg'] = widget.arg;
    properties['autoTrigger'] = widget.config?.autoTrigger;
    properties['withHaptics'] = widget.config?.withHaptics;
    properties['allowCancel'] = widget.config?.allowCancel;
    properties['timeout'] = widget.config?.timeout;
  }

  return properties;
}
```

## Widget Types Supported

### LdSubmit Widgets

- `LdSubmit<T, Arg>` - Generic submit widget
- `LdSubmitInlineBuilder<T, Arg>` - Inline result display
- `LdSubmitDialogBuilder<T, Arg>` - Dialog-based display
- `LdSubmitCustomBuilder<T, Arg>` - Custom display logic

### LdButton Widgets

- `LdButton` - Standard button component
- Various sizes and colors supported

### LdForm Widgets

- `LdForm` - Form container
- `LdInput` - Form input fields
- Nested submit widgets

## Development

### Prerequisites

- Flutter SDK
- DevTools extension development environment

### Building

```bash
cd extension/devtools/liquid_flutter_extension
flutter pub get
flutter build
```

### Testing

```bash
flutter test
```

## Architecture

```
lib/
├── main.dart                    # Main extension UI
├── devtools_integration.dart    # DevTools API integration
└── README.md                   # This file
```

## Future Enhancements

- [ ] Real-time widget tree monitoring
- [ ] Widget state inspection
- [ ] Performance profiling for Liquid Design components
- [ ] Custom widget property extractors
- [ ] Export widget tree data
- [ ] Integration with Liquid Design documentation

## Contributing

1. Fork the repository
2. Create a feature branch
3. Implement your changes
4. Add tests
5. Submit a pull request

## Resources

- [Flutter DevTools Extensions](https://docs.flutter.dev/tools/devtools/extensions)
- [Liquid Design Documentation](https://liquid.emdgroup.com)
- [Flutter Widget Inspector](https://docs.flutter.dev/tools/devtools/inspector)

## License

This extension is part of the Liquid Flutter project and follows the same license terms.
