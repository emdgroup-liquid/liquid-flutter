import 'dart:convert';
import 'package:flutter/services.dart';

import '../widget_tree/widget_whitelist.dart';

class ApiSchema {
  static final ApiSchema instance = ApiSchema._();
  ApiSchema._();

  List<dynamic>? _schema;

  Future<void> load() async {
    if (_schema != null) return;

    try {
      final String jsonString = await rootBundle.loadString(
        '../../packages/liquid_flutter/api_guard/api.json',
      );
      _schema = jsonDecode(jsonString) as List<dynamic>;
    } catch (e) {
      // If loading from packages path fails, try direct path
      try {
        final String jsonString = await rootBundle.loadString('api.json');
        _schema = jsonDecode(jsonString) as List<dynamic>;
      } catch (e2) {
        throw Exception('Failed to load API schema: $e2');
      }
    }
  }

  List<dynamic>? get schema => _schema;

  String? getSchemaSummary() {
    if (_schema == null) return null;

    final buffer = StringBuffer();
    buffer.writeln('Available Liquid Flutter Components:');
    buffer.writeln('');

    for (final item in _schema!) {
      if (item is Map<String, dynamic>) {
        final name = item['name'] as String?;
        final description = item['description'] as String?;
        if (name != null) {
          buffer.writeln('- $name');
          if (description != null && description.isNotEmpty) {
            buffer.writeln('  $description');
          }
          final constructors = item['constructors'] as List?;
          if (constructors != null && constructors.isNotEmpty) {
            for (final constructor in constructors) {
              if (constructor is Map<String, dynamic>) {
                final constructorName = constructor['name'] as String?;
                final signature = constructor['signature'] as List?;
                if (signature != null && signature.isNotEmpty) {
                  buffer.write('  Constructor: $constructorName(');
                  final params = <String>[];
                  for (final param in signature) {
                    if (param is Map<String, dynamic>) {
                      final paramName = param['name'] as String?;
                      final paramType = param['type'] as String?;
                      final required = param['required'] as bool? ?? false;
                      if (paramName != null && paramType != null) {
                        params.add(
                          '$paramType $paramName${required ? '' : '?'}',
                        );
                      }
                    }
                  }
                  buffer.write(params.join(', '));
                  buffer.writeln(')');
                }
              }
            }
          }
          buffer.writeln('');
        }
      }
    }

    return buffer.toString();
  }

  String? getComponentInfo(String componentName) {
    if (_schema == null) return null;

    for (final item in _schema!) {
      if (item is Map<String, dynamic>) {
        final name = item['name'] as String?;
        if (name == componentName) {
          return jsonEncode(item);
        }
      }
    }
    return null;
  }

  /// Get a compact schema summary showing only widget types and their property signatures
  /// Format: WidgetName(prop1: Type, prop2?: Type)
  String? getCompactSchemaSummary() {
    if (_schema == null) return null;

    // Group widgets by category
    final categories = <String, List<String>>{
      'Layout': [
        'LdScaffold',
        'LdAppBar',
        'LdScaffoldBody',
        'LdAutoSpace',
        'LdBundle',
        'LdCard',
        'LdContainer',
      ],
      'Text': [
        'LdText',
        'LdText.h',
        'LdText.hl',
        'LdText.hs',
        'LdText.hxs',
        'LdText.p',
        'LdText.pl',
        'LdText.ps',
        'LdText.pxs',
        'LdText.l',
        'LdText.ll',
        'LdText.ls',
        'LdText.lxs',
        'LdText.caption',
      ],
      'Form': [
        'LdInput',
        'LdButton',
        'LdCheckbox',
        'LdRadio',
        'LdSwitch',
        'LdSelect',
        'LdSlider',
        'LdDatePicker',
        'LdTimePicker',
      ],
      'List': [
        'LdList',
        'LdListItem',
        'LdListEmpty',
        'LdListLoading',
      ],
      'Feedback': [
        'LdNotification',
        'LdHint',
        'LdLoading',
        'LdExceptionView',
      ],
      'Modal': [
        'LdSheet',
      ],
      'Other': [
        'LdBadge',
        'LdTag',
        'LdAvatar',
        'LdDivider',
        'LdAccordion',
        'LdBreadcrumb',
        'LdTable',
      ],
    };

    final buffer = StringBuffer();
    buffer.writeln('Available Widget Types:');
    buffer.writeln('');

    for (final categoryEntry in categories.entries) {
      buffer.writeln('${categoryEntry.key}:');
      
      for (final widgetType in categoryEntry.value) {
        if (!WidgetWhitelist.isWhitelisted(widgetType)) continue;

        // Extract base class name for factory constructors
        final baseClassName = widgetType.contains('.')
            ? widgetType.split('.').first
            : widgetType;

        final widgetInfo = _findWidgetInSchema(baseClassName);
        if (widgetInfo != null) {
          final signature = _extractCompactSignature(widgetInfo, widgetType);
          buffer.writeln('  $widgetType$signature');
        } else {
          // Widget not found in schema, just list the name
          buffer.writeln('  $widgetType');
        }
      }
      
      buffer.writeln('');
    }

    return buffer.toString();
  }

  /// Find widget information in schema
  Map<String, dynamic>? _findWidgetInSchema(String widgetName) {
    if (_schema == null) return null;

    for (final item in _schema!) {
      if (item is Map<String, dynamic>) {
        final name = item['name'] as String?;
        if (name == widgetName) {
          return item;
        }
      }
    }
    return null;
  }

  /// Extract compact signature for a widget
  String _extractCompactSignature(
    Map<String, dynamic> widgetInfo,
    String widgetType,
  ) {
    final constructors = widgetInfo['constructors'] as List?;
    if (constructors == null || constructors.isEmpty) {
      return '()';
    }

    Map<String, dynamic>? targetConstructor;

    // Handle factory constructors (e.g., LdText.h)
    if (widgetType.contains('.')) {
      final factoryName = widgetType.split('.').last;
      for (final constructor in constructors) {
        if (constructor is Map<String, dynamic>) {
          final constructorName = constructor['name'] as String?;
          if (constructorName == factoryName) {
            targetConstructor = constructor;
            break;
          }
        }
      }
    }

    // If no factory constructor found, use the first constructor
    targetConstructor ??= constructors.first as Map<String, dynamic>?;

    if (targetConstructor == null) {
      return '()';
    }

    final signature = targetConstructor['signature'] as List?;
    if (signature == null || signature.isEmpty) {
      return '()';
    }

    final params = <String>[];
    for (final param in signature) {
      if (param is Map<String, dynamic>) {
        final paramName = param['name'] as String?;
        final paramType = param['type'] as String?;
        final isRequired = param['required'] as bool? ?? false;
        final isNamed = param['named'] as bool? ?? false;

        // Skip non-named parameters (positional) and key parameter
        if (paramName == null ||
            paramName == 'key' ||
            (!isNamed && paramName != 'text')) {
          continue;
        }

        // Skip function types (callbacks)
        if (paramType?.contains('Function') == true ||
            paramType?.contains('VoidCallback') == true ||
            paramType?.contains('ValueChanged') == true ||
            paramType?.contains('ValueSetter') == true ||
            paramType?.contains('ValueGetter') == true) {
          continue;
        }

        // Simplify type name
        final simplifiedType = _simplifyType(paramType ?? 'dynamic');
        final optionalMarker = isRequired ? '' : '?';
        params.add('$paramName: $simplifiedType$optionalMarker');
      }
    }

    if (params.isEmpty) {
      return '()';
    }

    return '(${params.join(', ')})';
  }

  /// Simplify Dart type names for compact display
  String _simplifyType(String dartType) {
    // Handle nullable types
    final isNullable = dartType.endsWith('?');
    final baseType = isNullable
        ? dartType.substring(0, dartType.length - 1)
        : dartType;

    // Handle List types
    if (baseType.startsWith('List<')) {
      final innerType = baseType.substring(5, baseType.length - 1);
      final innerTypeNullable = innerType.endsWith('?');
      final innerBaseType = innerTypeNullable
          ? innerType.substring(0, innerType.length - 1)
          : innerType;

      if (innerBaseType == 'Widget' ||
          innerBaseType.startsWith('List<Widget') ||
          innerBaseType.contains('Widget')) {
        return 'Widget[]';
      }

      return '${_simplifyType(innerBaseType)}[]';
    }

    // Handle Widget type
    if (baseType == 'Widget') {
      return 'Widget';
    }

    // Handle primitive types
    switch (baseType) {
      case 'String':
        return 'String';
      case 'int':
      case 'double':
      case 'num':
        return 'Number';
      case 'bool':
        return 'Boolean';
      case 'EdgeInsets':
        return 'EdgeInsets';
      case 'BorderRadius':
        return 'BorderRadius';
      case 'Alignment':
      case 'AlignmentGeometry':
        return 'Alignment';
      case 'TextAlign':
        return 'TextAlign';
      case 'TextStyle':
        return 'TextStyle';
      case 'Color':
        return 'Color';
      case 'Size':
        return 'Size';
      case 'Offset':
        return 'Offset';
      case 'LdSize':
        return 'LdSize';
      default:
        // Check if it's a whitelisted widget type
        if (WidgetWhitelist.isWhitelisted(baseType)) {
          return baseType;
        }
        return 'Any';
    }
  }
}
