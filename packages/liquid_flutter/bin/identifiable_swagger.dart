// ignore_for_file: avoid_print

import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;

import 'package:liquid_flutter/src/proto/identifiable_proto_config.dart';
import 'package:liquid_flutter/src/swagger/identifiable_swagger_builder.dart';

void main(List<String> args) {
  final parser = ArgParser()
    ..addOption(
      'swagger-dir',
      defaultsTo: 'lib/api',
      help: 'Directory containing .swagger.dart files',
    )
    ..addOption(
      'config',
      defaultsTo: 'lib/api/identifiable_swagger.json',
      help: 'Path to JSON config file with field overrides',
    )
    ..addFlag(
      'dry-run',
      negatable: false,
      help: 'Print changes without modifying files',
    )
    ..addFlag(
      'verbose',
      negatable: false,
      help: 'Log detailed information about each file',
    )
    ..addFlag('help', negatable: false, help: 'Show usage information');

  final parsed = parser.parse(args);

  if (parsed['help'] as bool) {
    print('''
Post-processes .swagger.dart files to add Identifiable mixin to model classes.

Usage: dart run liquid_flutter:identifiable_swagger [options]

Options:
  --swagger-dir DIR  Directory containing .swagger.dart files (default: lib/api)
  --config PATH      Path to JSON config file (default: lib/api/identifiable_swagger.json)
  --dry-run          Print changes without modifying files
  --verbose          Log detailed information
  --help             Show this message

Config file format (JSON):
  { "ClassName": "fieldName" }

Only needed for classes that use a field other than "id" for identity.
''');
    return;
  }

  final swaggerDir = parsed['swagger-dir'] as String;
  final configPath = parsed['config'] as String;
  final dryRun = parsed['dry-run'] as bool;
  final verbose = parsed['verbose'] as bool;

  final dir = Directory(swaggerDir);
  if (!dir.existsSync()) {
    print('Directory not found: $swaggerDir');
    exit(1);
  }

  final config = IdentifiableProtoConfig.load(configPath);

  if (verbose && config.fieldOverrides.isNotEmpty) {
    print(
      'Loaded ${config.fieldOverrides.length} field override(s) from $configPath',
    );
  }

  final files = dir.listSync().whereType<File>().where((f) {
    final name = p.basename(f.path);
    return name.endsWith('.swagger.dart') &&
        !name.endsWith('.swagger.g.dart') &&
        !name.endsWith('.swagger.chopper.dart') &&
        !name.endsWith('.enums.swagger.dart');
  }).toList();

  if (files.isEmpty) {
    print('No .swagger.dart files found in $swaggerDir');
    exit(0);
  }

  var modified = 0;

  for (final file in files) {
    final content = file.readAsStringSync();
    final transformed =
        transformIdentifiableSwagger(content, config.fieldOverrides);

    if (transformed != content) {
      if (dryRun) {
        final name = p.basename(file.path);
        print('$name would be updated');
        if (verbose) {
          _printDiff(content, transformed, name);
        }
      } else {
        file.writeAsStringSync(transformed);
        modified++;
        final name = p.basename(file.path);
        print('Updated $name');
      }
    } else if (verbose) {
      final name = p.basename(file.path);
      final classCount = _countSwaggerClasses(content);
      if (classCount == 0) {
        print('$name: skipped (no @JsonSerializable model classes)');
      } else {
        print('$name: up to date ($classCount class(es))');
      }
    }
  }

  if (dryRun) {
    print('\nDry run complete. No files were modified.');
  } else if (modified > 0) {
    print('Identifiable mixin applied to $modified file(s).');
  } else {
    print('No changes (${files.length} file(s) already up to date).');
  }
}

int _countSwaggerClasses(String content) {
  final re = RegExp(r'@JsonSerializable\(');
  return re.allMatches(content).length;
}

void _printDiff(String old, String new_, String name) {
  final oldLines = old.split('\n');
  final newLines = new_.split('\n');
  for (var i = 0; i < oldLines.length && i < newLines.length; i++) {
    if (oldLines[i] != newLines[i]) {
      print('  -$i: ${oldLines[i].trim()}');
      print('  +$i: ${newLines[i].trim()}');
    }
  }
}
