// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:liquid_generators/doc_comparator/api_change.dart';
import 'package:liquid_generators/doc_comparator/doc_ext.dart';
import 'package:liquid_generators/doc_comparator/doc_parser.dart';

void main(List<String> args) async {
  if (args.contains('--help') || args.contains('-h')) {
    print(
        '\nCompare the API documentation of documentation.dart files that were generated by the documentation_generator.\n');
    print('Usage: dart doc_comparator.dart <newFile> <baseFile> [options]');
    print(
        '  where <newFile> and <baseFile> can be paths within the GIT repository that you prefix with a branch, tag or commit hash, or URLs to the raw file on GitHub.\n');
    print(
        'Example: dart doc_comparator.dart HEAD:./lib/documentation.dart origin/main:./lib/documentation.dart\n');
    print('Options:');
    print('  --help, -h: Show this help message');
    print('  --verbose, -v: Print detailed information about the changes');
    return;
  }

  final verbose = args.contains('--verbose') || args.contains('-v');

  final positionalArgs =
      args.where((element) => !element.startsWith('-')).toList();
  final newFile =
      positionalArgs.elementAtOrNull(0) ?? 'HEAD:./lib/documentation.dart';
  final baseFile = positionalArgs.elementAtOrNull(1) ??
      'origin/main:./lib/documentation.dart';
  final newContent = newFile.startsWith('https')
      ? await _getRemoteContent(Uri.parse(newFile))
      : await _getGitFileContent(newFile);
  final baseContent = baseFile.startsWith('https')
      ? await _getRemoteContent(Uri.parse(baseFile))
      : await _getGitFileContent(baseFile);

  final apiChanges = parseLdDocComponentsFile(baseContent).compareTo(
    parseLdDocComponentsFile(newContent),
  );

  // print api changes
  var result = ApiChangeType.patch;
  for (var change in apiChanges) {
    result = result.atLeast(change.type);
    if (verbose) {
      print(
        "[${change.type.name}] change in '${change.component}': ${change.description}",
      );
    }
  }
  print(verbose ? '\nFinal result: ${result.name}' : result.name);
}

Future<String> _getRemoteContent(Uri uri) async {
  final response = HttpClient().getUrl(uri);
  return await response.then((value) => value.close()).then((value) {
    return value.transform(const Utf8Decoder()).join();
  });
}

Future<String> _getGitFileContent(String fileIdentifier) async {
  final parts = fileIdentifier.split(':');
  if (parts.length < 2) {
    throw ArgumentError(
        'Invalid fileIdentifier format. Expected "<tree-ish>:<file-path>".');
  }

  final treeIsh = parts.first;
  final path = parts.sublist(1).join(':'); // Handle file paths with colons

  final process = await Process.start(
    'git',
    ['show', '$treeIsh:$path'],
    mode: ProcessStartMode.normal, // Capture output instead of inheriting it
  );

  final stdoutFuture = process.stdout.transform(utf8.decoder).join();
  final stderrFuture = process.stderr.transform(utf8.decoder).join();

  final exitCode = await process.exitCode;
  final stdoutResult = await stdoutFuture;
  final stderrResult = await stderrFuture;

  if (exitCode != 0) {
    throw Exception('git show failed: $stderrResult');
  }

  return stdoutResult;
}
