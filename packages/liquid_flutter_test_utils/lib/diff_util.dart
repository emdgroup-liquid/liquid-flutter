import 'package:diff_match_patch/diff_match_patch.dart' as dmp;
import 'package:flutter_test/flutter_test.dart';

/// ANSI escape codes for color highlighting
const String red = '\u001b[31m'; // Red color
const String reset = '\u001b[0m'; // Reset color

/// Finds the first difference between two strings and highlights it in red.
void expectEqualStrings(String actual, String expected, {String? reason}) {
  final expectedLines = expected.split('\n');
  final actualLines = actual.split('\n');

  for (var i = 0; i < expectedLines.length && i < actualLines.length; i++) {
    if (expectedLines[i] != actualLines[i]) {
      final highlightedExpected =
          _highlightDifference(expectedLines[i], actualLines[i]);
      final highlightedActual =
          _highlightDifference(actualLines[i], expectedLines[i]);

      throw TestFailure('''
${reason ?? 'Strings do not match'}:
Difference at line ${i + 1}:

Expected: $highlightedExpected

Actual  : $highlightedActual
''');
    }
  }

  if (expectedLines.length != actualLines.length) {
    throw TestFailure('''
${reason ?? 'Strings do not match'}:
Difference in number of lines:
Expected ${expectedLines.length} lines, but got ${actualLines.length}
''');
  }
}

/// Highlights the first character difference in red.
String _highlightDifference(String line1, String line2) {
  final diffIndex = _findFirstDifference(line1, line2);
  if (diffIndex == -1) return line1; // No difference found

  return line1.substring(0, diffIndex) +
      red +
      line1.substring(diffIndex, diffIndex + 1) +
      reset +
      line1.substring(diffIndex + 1);
}

/// Finds the first index where two strings differ.
int _findFirstDifference(String a, String b) {
  for (var i = 0; i < a.length && i < b.length; i++) {
    if (a[i] != b[i]) return i;
  }
  return (a.length != b.length) ? a.length : -1;
}

/// Generates an HTML diff between two XML strings using the DiffMatchPatch package
/// with color-coded formatting (additions in green, deletions in red)
String generateHtmlFormattedDiff(
  String actual,
  String expected, {
  String title = 'String Comparison',
  String subtitle = 'Diff report between two strings',
}) {
  // Create a new DiffMatchPatch instance
  final diffMatchPatch = dmp.DiffMatchPatch();

  // Generate diffs between the two XML strings
  final diffs = diffMatchPatch.diff(actual, expected);
  diffMatchPatch.diffCleanupEfficiency(diffs);
  diffMatchPatch.diffCleanupSemantic(diffs);

  // Convert the diffs to HTML with proper styling
  return diffsToHtml(diffs, title: title, subtitle: subtitle);
}

String diffsToHtml(
  List<dmp.Diff> diffs, {
  required String title,
  required String subtitle,
}) {
  final buffer = StringBuffer();

  // Add HTML header with enhanced styling
  buffer.write('''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$title</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      margin: 0;
      padding: 20px;
      background-color: #f5f5f5;
      color: #333;
    }
    
    .diff-container { 
      font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, Courier, monospace;
      white-space: pre-wrap;
      line-height: 1.6;
      padding: 16px;
      background-color: #ffffff;
      border-radius: 6px;
      box-shadow: 0 1px 3px rgba(0,0,0,0.1);
      overflow-x: auto;
      font-size: 14px;
      margin-bottom: 20px;
    }
    
    .diff-header {
      margin-bottom: 15px;
      font-size: 16px;
      font-weight: 600;
      border-bottom: 1px solid #e1e4e8;
      padding-bottom: 10px;
    }
    
    .diff-stats {
      display: flex;
      margin-bottom: 15px;
      font-size: 13px;
    }
    
    .diff-stats div {
      margin-right: 20px;
      display: flex;
      align-items: center;
    }
    
    .diff-stats-icon {
      display: inline-block;
      width: 8px;
      height: 8px;
      border-radius: 50%;
      margin-right: 6px;
    }
    
    .diff-addition { 
      background-color: #dafbe1; 
      color: #22863a;
      padding: 1px 2px;
      border-radius: 2px;
    }
    
    .diff-deletion { 
      background-color: #ffeef0; 
      color: #cb2431;
      padding: 1px 2px;
      border-radius: 2px;
    }
    
    .line-number {
      user-select: none;
      text-align: right;
      color: #999;
      padding-right: 10px;
      min-width: 40px;
      display: inline-block;
      border-right: 1px solid #e1e4e8;
      margin-right: 10px;
    }
    
    .diff-line {
      display: block;
      margin: 0;
      padding: 0 0 0 10px;
      border-left: 2px solid transparent;
    }
    
    .diff-line.addition {
      background-color: #f0fff4;
      border-left: 2px solid #34d058;
    }
    
    .diff-line.deletion {
      background-color: #ffeef0;
      border-left: 2px solid #d73a49;
    }
    
    .diff-line.change {
      background-color: #fff5b1;
      border-left: 2px solid #f6a623;
    }
    
    @media (prefers-color-scheme: dark) {
      body {
        background-color: #1e1e1e;
        color: #d4d4d4;
      }
      .diff-container {
        background-color: #252526;
        box-shadow: 0 1px 3px rgba(0,0,0,0.3);
      }
      .diff-addition {
        background-color: #133929;
        color: #56d364;
      }
      .diff-deletion {
        background-color: #331c1e;
        color: #f85149;
      }
      .diff-line.addition {
        background-color: #0d1a12;
        border-left-color: #238636;
      }
      .diff-line.deletion {
        background-color: #291a1d;
        border-left-color: #da3633;
      }
      .diff-line.change {
        background-color: #3c3f00;
        border-left-color: #f6a623;
      }
      .line-number {
        color: #666;
        border-right-color: #333;
      }
      .diff-header {
        border-bottom-color: #333;
      }
    }
  </style>
</head>
<body>
  <div class="diff-container">
    <div class="diff-header"><p>$title</p><small>$subtitle</small></div>
''');

  // Count number of lines and operations
  int lineNumber = 1;
  int additions = 0;
  int deletions = 0;

  // Group diffs by lines
  final lineGroups = <List<dmp.Diff>>[];
  List<dmp.Diff> currentLine = [];

  for (final diff in diffs) {
    final lines = diff.text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      // If not the first line in split result, we need to start a new line group
      if (i > 0) {
        lineGroups.add([...currentLine]);
        currentLine = [];
      }

      // Add the current line segment with appropriate operation
      if (lines[i].isNotEmpty || i < lines.length - 1) {
        final textContent = i == lines.length - 1 ? lines[i] : '${lines[i]}\n';
        currentLine.add(dmp.Diff(diff.operation, textContent));

        // Count operations
        if (diff.operation == dmp.DIFF_INSERT) additions++;
        if (diff.operation == dmp.DIFF_DELETE) deletions++;
      }
    }
  }

  // Add the last line if it exists
  if (currentLine.isNotEmpty) {
    lineGroups.add(currentLine);
  }

  // Update stats display with real numbers
  buffer.write('''
    <div class="diff-stats">
      <div><span class="diff-stats-icon" style="background-color: #34d058;"></span>$additions Additions</div>
      <div><span class="diff-stats-icon" style="background-color: #d73a49;"></span>$deletions Deletions</div>
    </div>
  ''');

  // Process each line group with line numbers
  for (final lineGroup in lineGroups) {
    bool isAddition =
        lineGroup.any((diff) => diff.operation == dmp.DIFF_INSERT);
    bool isDeletion =
        lineGroup.any((diff) => diff.operation == dmp.DIFF_DELETE);

    String lineClass = "";
    if (isAddition && !isDeletion) lineClass = "addition";
    if (isDeletion && !isAddition) lineClass = "deletion";
    if (isDeletion && isAddition) lineClass = "change";

    buffer.write('<div class="diff-line $lineClass">');
    buffer.write('<span class="line-number">${lineNumber++}</span>');

    // Process each diff segment in the line
    for (final diff in lineGroup) {
      final htmlEscapedText = htmlEscape(diff.text);

      switch (diff.operation) {
        case dmp.DIFF_INSERT:
          buffer.write('<span class="diff-addition">$htmlEscapedText</span>');
          break;
        case dmp.DIFF_DELETE:
          buffer.write('<span class="diff-deletion">$htmlEscapedText</span>');
          break;
        case dmp.DIFF_EQUAL:
          buffer.write(htmlEscapedText);
          break;
      }
    }

    buffer.write('</div>');
  }

  // Add HTML footer
  buffer.write('''
  </div>
</body>
</html>
''');

  return buffer.toString();
}

/// Simple HTML escaping function
String htmlEscape(String text) {
  return text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}
