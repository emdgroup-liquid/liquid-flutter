// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../ast.dart';
import '../block_parser.dart';
import '../patterns.dart';
import 'block_syntax.dart';
import 'paragraph_syntax.dart';

/// Parses setext-style headers.
class SetextHeaderSyntax extends BlockSyntax {
  @override
  RegExp get pattern => setextPattern;

  const SetextHeaderSyntax();

  @override
  bool canParse(BlockParser parser) {
    final lastSyntax = parser.currentSyntax;
    if (parser.setextHeadingDisabled || lastSyntax is! ParagraphSyntax) {
      return false;
    }
    return pattern.hasMatch(parser.current.content);
  }

  @override
  Node? parse(BlockParser parser) {
    final lines = parser.linesToConsume;
    if (lines.length < 2) {
      return null;
    }

    // The marker line is the last entry and is also parser.current at this
    // point; capture its offset before mutating the list.
    final markerLine = lines.last;
    final firstLine = lines.first;

    final elementOffset = firstLine.charOffset ?? 0;
    final elementLength =
        (markerLine.charOffset ?? 0) +
        markerLine.content.length -
        elementOffset;

    // Remove the last line which is a marker.
    lines.removeLast();

    final marker = parser.current.content.trim();
    final level = (marker[0] == '=') ? '1' : '2';
    final content = lines.map((e) => e.content).join('\n').trimRight();

    final unparsed = UnparsedContent(content)
      ..sourceOffset = elementOffset
      ..sourceLength = content.length;

    parser.advance();

    final element = Element('h$level', [unparsed]);
    element.sourceOffset = elementOffset;
    element.sourceLength = elementLength;
    return element;
  }
}
