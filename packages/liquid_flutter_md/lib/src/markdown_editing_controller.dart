import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// A [TextEditingController] that renders its content as WYSIWYG markdown.
///
/// Unlike the old approach, there is no `isEditing` flag — [WidgetSpan]s
/// (tables, HR, blockquote bars, images, checkboxes) are always rendered
/// because the consuming widget is a [RichText] (backed by [RenderParagraph]),
/// not an [EditableText].  [RenderParagraph] has no strut-height clamping, so
/// [WidgetSpan]s size correctly at all times.
///
/// ## Flat-text invariant
/// The total character count of the emitted [TextSpan] tree always equals
/// [text].length.  Hidden characters (delimiter markers, heading `#` prefix,
/// blockquote `>` marker) are emitted with `fontSize: 0.001 / height: 0.001`.
/// [WidgetSpan]s (hr divider, blockquote bar) each replace exactly one source
/// character via the same hidden-N-1 + WidgetSpan pattern.
///
/// ## GestureRecognizer lifecycle
/// All [GestureRecognizer]s are tracked in [_activeRecognizers] and disposed
/// at the start of every [buildTextSpan] call and in [dispose].
class LdMarkdownEditingController extends TextEditingController {
  LdMarkdownEditingController({super.text});

  /// Called when the user taps a link.
  void Function(String url, String title)? onLinkTap;

  /// Called when the user taps a hashtag (e.g. `#flutter`).
  /// `tag` is the text without the `#` prefix.
  void Function(String tag)? onHashtagTap;

  /// Called to resolve an image widget for the given src / alt pair.
  Widget? Function(String src, String alt)? imageBuilder;

  /// Whether the editor is currently focused/editing.
  /// When true, the line containing the cursor shows raw markdown delimiters
  /// dimmed so the user can edit them; other lines render as WYSIWYG.
  /// When false, all lines render as WYSIWYG.
  bool isEditing = true;

  final List<GestureRecognizer> _activeRecognizers = [];
  bool _transforming = false;
  bool _gesturesEnabled = false;
  bool _initialBuildDone = false;

  /// Intercepts newline insertions from the engine/IME (Flutter 3.44+)
  /// to implement smart list/blockquote continuation.
  @override
  set value(TextEditingValue newValue) {
    if (_transforming) {
      super.value = newValue;
      return;
    }

    final oldValue = value;
    super.value = newValue;

    _handleNewlineInserted(oldValue, newValue);
  }

  void _handleNewlineInserted(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length != oldValue.text.length + 1) return;
    if (oldValue.selection.baseOffset < 0) return;

    final cursorPos = oldValue.selection.baseOffset;
    if (cursorPos >= newValue.text.length) return;
    if (newValue.text[cursorPos] != '\n') return;

    final lineStart = oldValue.text.lastIndexOf('\n', cursorPos - 1) + 1;
    final line = oldValue.text.substring(lineStart, cursorPos);

    if (RegExp(r'^(\*{3,}|-{3,}|_{3,})\s*$').hasMatch(line)) return;

    _transforming = true;

    final orderedMatch = RegExp(r'^(\s*)(\d+)\.\s').firstMatch(line);
    if (orderedMatch != null) {
      final indent = orderedMatch.group(1)!;
      final num = int.parse(orderedMatch.group(2)!);
      if (line.trim() == '${orderedMatch.group(2)}.') {
        value = TextEditingValue(
          text:
              oldValue.text.substring(0, lineStart) +
              oldValue.text.substring(cursorPos),
          selection: TextSelection.collapsed(offset: lineStart),
        );
      } else {
        final continuation = '$indent${num + 1}. ';
        value = TextEditingValue(
          text:
              newValue.text.substring(0, cursorPos + 1) +
              continuation +
              newValue.text.substring(cursorPos + 1),
          selection: TextSelection.collapsed(
            offset: cursorPos + 1 + continuation.length,
          ),
        );
      }
      _transforming = false;
      return;
    }

    final unorderedMatch = RegExp(r'^(\s*)([-*+]) ').firstMatch(line);
    if (unorderedMatch != null) {
      final indent = unorderedMatch.group(1)!;
      final marker = unorderedMatch.group(2)!;
      if (line.trim() == marker) {
        value = TextEditingValue(
          text:
              oldValue.text.substring(0, lineStart) +
              oldValue.text.substring(cursorPos),
          selection: TextSelection.collapsed(offset: lineStart),
        );
      } else {
        final continuation = '$indent$marker ';
        value = TextEditingValue(
          text:
              newValue.text.substring(0, cursorPos + 1) +
              continuation +
              newValue.text.substring(cursorPos + 1),
          selection: TextSelection.collapsed(
            offset: cursorPos + 1 + continuation.length,
          ),
        );
      }
      _transforming = false;
      return;
    }

    if (line.startsWith('> ')) {
      if (line.trim() == '>') {
        value = TextEditingValue(
          text:
              oldValue.text.substring(0, lineStart) +
              oldValue.text.substring(cursorPos),
          selection: TextSelection.collapsed(offset: lineStart),
        );
      } else {
        final continuation = '> ';
        value = TextEditingValue(
          text:
              '${newValue.text.substring(0, cursorPos + 1)}$continuation${newValue.text.substring(cursorPos + 1)}',
          selection: TextSelection.collapsed(
            offset: cursorPos + 1 + continuation.length,
          ),
        );
      }
      _transforming = false;
      return;
    }

    _transforming = false;
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final r in _activeRecognizers) {
      r.dispose();
    }
    _activeRecognizers.clear();
  }

  // ---------------------------------------------------------------------------
  // buildTextSpan
  // ---------------------------------------------------------------------------

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    // Short-circuit during IME composition.
    if (withComposing && value.isComposingRangeValid) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }

    // Defer gesture recognizers until after the first buildTextSpan call to
    // avoid Flutter issue #97433 (assertion in RenderEditable.describeSemanticsConfiguration
    // on iOS when inline tap targets exist in a non-read-only EditableText).
    if (_initialBuildDone) {
      _gesturesEnabled = true;
    } else {
      _initialBuildDone = true;
    }

    _disposeRecognizers();

    final source = text;
    if (source.isEmpty) return TextSpan(text: '', style: style);

    final theme = LdTheme.of(context);
    final baseStyle = style ?? const TextStyle();

    // Determine focused line (the line the cursor is on).
    final cursorPos = value.selection.isValid ? value.selection.baseOffset : -1;

    // Split source into lines, tracking each line's start offset.
    final lines = source.split('\n');
    final lineStarts = <int>[];
    {
      var pos = 0;
      for (final line in lines) {
        lineStarts.add(pos);
        pos += line.length + 1;
      }
    }

    int focusedLineIdx = -1;
    if (cursorPos >= 0) {
      for (var li = 0; li < lines.length; li++) {
        final lineEnd = lineStarts[li] + lines[li].length;
        if (cursorPos >= lineStarts[li] && cursorPos <= lineEnd) {
          focusedLineIdx = li;
          break;
        }
      }
    }

    final spans = <InlineSpan>[];

    var i = 0;
    while (i < lines.length) {
      final line = lines[i];
      final isLast = i == lines.length - 1;

      // ── Detect a table block (run of consecutive table lines) ──────────────
      if (_tableRow.hasMatch(line)) {
        var tableEnd = i;
        while (tableEnd + 1 < lines.length &&
            _tableRow.hasMatch(lines[tableEnd + 1])) {
          tableEnd++;
        }

        final tableLines = lines.sublist(i, tableEnd + 1);

        // When editing and cursor is inside this table block, show raw source.
        if (isEditing && focusedLineIdx >= i && focusedLineIdx <= tableEnd) {
          for (var ti = 0; ti < tableLines.length; ti++) {
            spans.add(TextSpan(text: tableLines[ti], style: baseStyle));
            if (ti < tableLines.length - 1) {
              spans.add(TextSpan(text: '\n', style: baseStyle));
            }
          }
          i = tableEnd + 1;
          if (i < lines.length) {
            spans.add(TextSpan(text: '\n', style: baseStyle));
          }
          continue;
        }

        // Render the entire table as a single WidgetSpan.
        // With forceStrutHeight: false, the hidden \n characters inside _hide
        // create near-zero-height lines — no visible gaps between rows.
        final allParsed = tableLines.map(_splitTableRow).toList();
        final dataRows = allParsed
            .where((r) => !r.every((c) => _tableSepCell.hasMatch(c)))
            .toList();
        final colCount = dataRows.fold(
          0,
          (m, r) => r.length > m ? r.length : m,
        );
        final headerStyle = baseStyle
            .merge(ldBuildTextStyle(theme, LdTextType.paragraph, LdSize.m))
            .copyWith(fontWeight: FontWeight.bold);
        final bodyStyle = baseStyle.merge(
          ldBuildTextStyle(theme, LdTextType.paragraph, LdSize.m),
        );

        final allSource = tableLines.join('\n');
        final toHide = allSource.substring(1);
        // Replace \n with spaces so _hide doesn't create visible line breaks.
        // The hidden text (fontSize: 0.001) sits invisibly next to the
        // WidgetSpan on the same line — no empty lines between table rows.
        final hiddenNoBreaks = toHide.replaceAll('\n', ' ');
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.top,
            child: _TableWidget(
              dataRows: dataRows,
              colCount: colCount,
              headerStyle: headerStyle,
              bodyStyle: bodyStyle,
              theme: theme,
            ),
          ),
        );
        if (hiddenNoBreaks.isNotEmpty) _hide(hiddenNoBreaks, spans);

        i = tableEnd + 1;
        if (i < lines.length) {
          spans.add(TextSpan(text: '\n', style: baseStyle));
        }
        continue;
      }

      // ── Normal single-line rendering ───────────────────────────────────────
      final lineIsFocused = isEditing && i == focusedLineIdx;
      _emitLine(line, baseStyle, theme, spans, context, focused: lineIsFocused);

      if (!isLast) {
        spans.add(TextSpan(text: '\n', style: baseStyle));
      }

      i++;
    }

    return TextSpan(style: style, children: spans);
  }

  // ---------------------------------------------------------------------------
  // Line-level rendering
  // ---------------------------------------------------------------------------

  static final _h6 = RegExp(r'^(#{6} ?)(.*)$');
  static final _h5 = RegExp(r'^(#{5} ?)(.*)$');
  static final _h4 = RegExp(r'^(#{4} ?)(.*)$');
  static final _h3 = RegExp(r'^(#{3} ?)(.*)$');
  static final _h2 = RegExp(r'^(#{2} ?)(.*)$');
  static final _h1 = RegExp(r'^(#{1} ?)(.*)$');
  static final _headings = [
    (6, _h6),
    (5, _h5),
    (4, _h4),
    (3, _h3),
    (2, _h2),
    (1, _h1),
  ];

  static final _hr = RegExp(r'^(\*{3,}|-{3,}|_{3,})\s*$');
  static final _blockquote = RegExp(r'^(> ?)(.*)$');
  static final _ul = RegExp(r'^(\s*)([-*+] )(.*)$');
  static final _ol = RegExp(r'^(\s*\d+\. )(.*)$');
  static final _fencedFence = RegExp(r'^(```|~~~)');
  static final _checkbox = RegExp(r'^(\s*[-*+] \[)([ xX])(\] )(.*)$');
  static final _indentedCode = RegExp(r'^( {4}|\t)(.*)$');

  static final _tableRow = RegExp(r'^\|(.+)\|$');
  static final _tableSepCell = RegExp(r'^\s*:?-+:?\s*$');

  void _emitLine(
    String line,
    TextStyle baseStyle,
    LdTheme theme,
    List<InlineSpan> out,
    BuildContext context, {
    bool focused = false,
  }) {
    if (line.isEmpty) return;

    // ── Horizontal rule ────────────────────────────────────────────────────
    if (_hr.hasMatch(line)) {
      if (focused) {
        out.add(TextSpan(text: line, style: baseStyle));
        return;
      }
      _hide(line.substring(0, line.length - 1), out);
      out.add(
        WidgetSpan(alignment: PlaceholderAlignment.middle, child: _HrWidget()),
      );
      return;
    }

    // ── Fenced code fence line ─────────────────────────────────────────────
    if (_fencedFence.hasMatch(line)) {
      out.add(
        TextSpan(
          text: line,
          style: baseStyle.copyWith(
            fontFamily: 'monospace',
            color: theme.textMuted,
            fontSize: theme.paragraphSize(LdSize.s),
          ),
        ),
      );
      return;
    }

    // ── Indented code block line ───────────────────────────────────────────
    if (_indentedCode.hasMatch(line)) {
      out.add(
        TextSpan(
          text: line,
          style: baseStyle.copyWith(fontFamily: 'monospace'),
        ),
      );
      return;
    }

    // ── Blockquote ─────────────────────────────────────────────────────────
    final bqMatch = _blockquote.firstMatch(line);
    if (bqMatch != null) {
      if (focused) {
        out.add(TextSpan(text: line, style: baseStyle));
        return;
      }
      final marker = bqMatch.group(1)!;
      final content = bqMatch.group(2)!;
      if (marker.length > 1) {
        _hide(marker.substring(0, marker.length - 1), out);
      }
      out.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: const _BlockquoteBar(),
        ),
      );
      final contentStyle = _paragraphStyle(
        theme,
        baseStyle,
      ).copyWith(fontStyle: FontStyle.italic, color: theme.textMuted);
      _emitInline(content, baseStyle, contentStyle, theme, out, context);
      return;
    }

    // ── Headings ───────────────────────────────────────────────────────────
    for (final (level, pattern) in _headings) {
      final m = pattern.firstMatch(line);
      if (m != null) {
        final prefix = m.group(1)!;
        final content = m.group(2)!;
        final hStyle = _headingStyle(level, theme, baseStyle);
        _emitMarker(prefix, hStyle, theme, out, focused: focused);
        _emitInline(
          content,
          baseStyle,
          hStyle,
          theme,
          out,
          context,
          focused: focused,
        );
        return;
      }
    }

    // ── Checkbox list item ─────────────────────────────────────────────────
    final cbMatch = _checkbox.firstMatch(line);
    if (cbMatch != null) {
      if (focused) {
        out.add(TextSpan(text: line, style: baseStyle));
        return;
      }
      final beforeBracket = cbMatch.group(1)!;
      final checkChar = cbMatch.group(2)!;
      final afterBracket = cbMatch.group(3)!;
      final content = cbMatch.group(4)!;
      final checked = checkChar.toLowerCase() == 'x';
      final markerLen =
          beforeBracket.length + checkChar.length + afterBracket.length;
      _hide(line.substring(0, markerLen - 1), out);
      out.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: LdCheckbox(checked: checked),
          ),
        ),
      );
      _emitInline(
        content,
        baseStyle,
        _paragraphStyle(theme, baseStyle),
        theme,
        out,
        context,
      );
      return;
    }

    // ── Unordered list item ────────────────────────────────────────────────
    final ulMatch = _ul.firstMatch(line);
    if (ulMatch != null) {
      final indent = ulMatch.group(1)!;
      final marker = ulMatch.group(2)!;
      final content = ulMatch.group(3)!;
      final paraStyle = _paragraphStyle(theme, baseStyle);
      if (indent.isNotEmpty) {
        out.add(TextSpan(text: indent, style: baseStyle));
      }
      out.add(
        TextSpan(
          text: marker,
          style: baseStyle.copyWith(color: theme.textMuted),
        ),
      );
      _emitInline(
        content,
        baseStyle,
        paraStyle,
        theme,
        out,
        context,
        focused: focused,
      );
      return;
    }

    // ── Ordered list item ──────────────────────────────────────────────────
    final olMatch = _ol.firstMatch(line);
    if (olMatch != null) {
      final marker = olMatch.group(1)!;
      final content = olMatch.group(2)!;
      final paraStyle = _paragraphStyle(theme, baseStyle);
      out.add(
        TextSpan(
          text: marker,
          style: baseStyle.copyWith(color: theme.textMuted),
        ),
      );
      _emitInline(
        content,
        baseStyle,
        paraStyle,
        theme,
        out,
        context,
        focused: focused,
      );
      return;
    }

    // ── Default: paragraph ─────────────────────────────────────────────────
    _emitInline(
      line,
      baseStyle,
      _paragraphStyle(theme, baseStyle),
      theme,
      out,
      context,
      focused: focused,
    );
  }

  // ---------------------------------------------------------------------------
  // Inline rendering (within a single line)
  // ---------------------------------------------------------------------------

  static final _boldItalic = RegExp(r'(\*{3}|_{3})(.*?)\1');
  static final _bold = RegExp(r'(\*{2}|_{2})(.*?)\1');
  static final _italic = RegExp(r'(\*|_)(.*?)\1');
  static final _inlineCode = RegExp(r'(`+)(.*?)\1');
  static final _link = RegExp(r'\[([^\]]+)\]\(([^)]+)(?:\s+"[^"]*")?\)');
  static final _image = RegExp(r'!\[([^\]]*)\]\(([^)]+)(?:\s+"[^"]*")?\)');
  static final _strikethrough = RegExp(r'(~~)(.*?)\1');
  static final _hashtag = RegExp(r'(?<!\w)#(\w[\w-]*)');

  void _emitInline(
    String text,
    TextStyle baseStyle,
    TextStyle lineStyle,
    LdTheme theme,
    List<InlineSpan> out,
    BuildContext context, {
    bool focused = false,
  }) {
    int cursor = 0;

    while (cursor < text.length) {
      Match? earliest;
      _InlineKind? earliestKind;
      int earliestStart = text.length;

      void tryPattern(RegExp pat, _InlineKind kind) {
        final m = pat.firstMatch(text.substring(cursor));
        if (m == null) return;
        final mStart = cursor + m.start;
        if (mStart < earliestStart) {
          earliestStart = mStart;
          earliest = m;
          earliestKind = kind;
        }
      }

      tryPattern(_image, _InlineKind.image);
      tryPattern(_link, _InlineKind.link);
      tryPattern(_boldItalic, _InlineKind.boldItalic);
      tryPattern(_bold, _InlineKind.bold);
      tryPattern(_italic, _InlineKind.italic);
      tryPattern(_inlineCode, _InlineKind.code);
      tryPattern(_strikethrough, _InlineKind.strikethrough);
      tryPattern(_hashtag, _InlineKind.hashtag);

      if (earliest == null) {
        out.add(TextSpan(text: text.substring(cursor), style: lineStyle));
        return;
      }

      if (earliestStart > cursor) {
        out.add(
          TextSpan(
            text: text.substring(cursor, earliestStart),
            style: lineStyle,
          ),
        );
      }

      final matchLen = earliest!.group(0)!.length;
      final matchStr = text.substring(earliestStart, earliestStart + matchLen);

      switch (earliestKind!) {
        case _InlineKind.boldItalic:
          final delim = earliest!.group(1)!;
          final inner = earliest!.group(2)!;
          final innerStyle = lineStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          );
          _conceal(delim, lineStyle, theme, out, focused: focused);
          _emitInline(
            inner,
            baseStyle,
            innerStyle,
            theme,
            out,
            context,
            focused: focused,
          );
          _conceal(delim, lineStyle, theme, out, focused: focused);

        case _InlineKind.bold:
          final delim = earliest!.group(1)!;
          final inner = earliest!.group(2)!;
          final innerStyle = lineStyle.copyWith(fontWeight: FontWeight.bold);
          _conceal(delim, lineStyle, theme, out, focused: focused);
          _emitInline(
            inner,
            baseStyle,
            innerStyle,
            theme,
            out,
            context,
            focused: focused,
          );
          _conceal(delim, lineStyle, theme, out, focused: focused);

        case _InlineKind.italic:
          final delim = earliest!.group(1)!;
          final inner = earliest!.group(2)!;
          final innerStyle = lineStyle.copyWith(fontStyle: FontStyle.italic);
          _conceal(delim, lineStyle, theme, out, focused: focused);
          _emitInline(
            inner,
            baseStyle,
            innerStyle,
            theme,
            out,
            context,
            focused: focused,
          );
          _conceal(delim, lineStyle, theme, out, focused: focused);

        case _InlineKind.code:
          final delim = earliest!.group(1)!;
          final inner = earliest!.group(2)!;
          final codeStyle = lineStyle.copyWith(
            fontFamily: 'monospace',
            background: Paint()..color = theme.surface,
          );
          _conceal(delim, lineStyle, theme, out, focused: focused);
          out.add(TextSpan(text: inner, style: codeStyle));
          _conceal(delim, lineStyle, theme, out, focused: focused);

        case _InlineKind.link:
          final linkText = earliest!.group(1)!;
          final href = earliest!.group(2)!;
          _conceal('[', lineStyle, theme, out, focused: focused);
          if (_gesturesEnabled && !isEditing && onLinkTap != null) {
            final recognizer = TapGestureRecognizer()
              ..onSecondaryTap = () => onLinkTap?.call(href, '');
            _activeRecognizers.add(recognizer);
            out.add(
              TextSpan(
                text: linkText,
                style: lineStyle.copyWith(
                  color: theme.primaryColor,
                  decoration: TextDecoration.underline,
                  decorationColor: theme.primaryColor,
                ),
                recognizer: recognizer,
              ),
            );
          } else {
            out.add(
              TextSpan(
                text: linkText,
                style: lineStyle.copyWith(
                  color: theme.primaryColor,
                  decoration: TextDecoration.underline,
                  decorationColor: theme.primaryColor,
                ),
              ),
            );
          }
          final hiddenSuffix = matchStr.substring(1 + linkText.length);
          _conceal(hiddenSuffix, lineStyle, theme, out, focused: focused);

        case _InlineKind.image:
          if (focused) {
            out.add(
              TextSpan(
                text: matchStr,
                style: lineStyle.copyWith(color: theme.textMuted),
              ),
            );
          } else {
            final src = earliest!.group(2)!;
            final alt = earliest!.group(1)!;
            final imgWidget =
                imageBuilder?.call(src, alt) ??
                Image.network(
                  src,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                );
            if (matchLen > 1) _hide(matchStr.substring(0, matchLen - 1), out);
            out.add(
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: imgWidget,
              ),
            );
          }

        case _InlineKind.strikethrough:
          final delim = earliest!.group(1)!;
          final inner = earliest!.group(2)!;
          final innerStyle = lineStyle.copyWith(
            decoration: TextDecoration.lineThrough,
          );
          _conceal(delim, lineStyle, theme, out, focused: focused);
          _emitInline(
            inner,
            baseStyle,
            innerStyle,
            theme,
            out,
            context,
            focused: focused,
          );
          _conceal(delim, lineStyle, theme, out, focused: focused);

        case _InlineKind.hashtag:
          final tag = earliest!.group(1)!;
          final fullMatch = earliest!.group(0)!;
          if (_gesturesEnabled && !isEditing && onHashtagTap != null) {
            final recognizer = TapGestureRecognizer()
              ..onTap = () => onHashtagTap?.call(tag);
            _activeRecognizers.add(recognizer);
            out.add(
              TextSpan(
                text: fullMatch,
                style: lineStyle.copyWith(color: theme.primaryColor),
                recognizer: recognizer,
              ),
            );
          } else {
            out.add(
              TextSpan(
                text: fullMatch,
                style: lineStyle.copyWith(color: theme.primaryColor),
              ),
            );
          }
      }

      cursor = earliestStart + matchLen;
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Emits [text] invisible so it occupies buffer positions (preserves the
  /// char-count invariant) but contributes zero visual advance.
  static void _hide(String text, List<InlineSpan> out) {
    if (text.isEmpty) return;
    out.add(
      TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 0.001,
          height: 0.001,
          letterSpacing: 0,
          wordSpacing: 0,
          color: Color(0x00000000),
        ),
      ),
    );
  }

  /// Emits a block-level marker (e.g. `## `) either hidden (non-focused) or
  /// dimmed to [hStyle]'s size but muted color (focused).
  static void _emitMarker(
    String marker,
    TextStyle hStyle,
    LdTheme theme,
    List<InlineSpan> out, {
    required bool focused,
  }) {
    if (marker.isEmpty) return;
    if (focused) {
      out.add(
        TextSpan(
          text: marker,
          style: hStyle.copyWith(
            color: theme.textMuted,
            fontWeight: FontWeight.normal,
          ),
        ),
      );
    } else {
      _hide(marker, out);
    }
  }

  /// On unfocused lines: fully hides [text] (fontSize 0).
  /// On focused lines: shows [text] at the same size as [lineStyle] but muted.
  static void _conceal(
    String text,
    TextStyle lineStyle,
    LdTheme theme,
    List<InlineSpan> out, {
    required bool focused,
  }) {
    if (text.isEmpty) return;
    if (focused) {
      out.add(
        TextSpan(
          text: text,
          style: lineStyle.copyWith(
            color: theme.textMuted,
            fontWeight: FontWeight.normal,
            fontStyle: FontStyle.normal,
          ),
        ),
      );
    } else {
      _hide(text, out);
    }
  }

  static TextStyle _paragraphStyle(LdTheme theme, TextStyle base) =>
      base.merge(ldBuildTextStyle(theme, LdTextType.paragraph, LdSize.m));

  static TextStyle _headingStyle(int level, LdTheme theme, TextStyle base) {
    const sizes = [
      LdSize.l,
      LdSize.m,
      LdSize.s,
      LdSize.xs,
      LdSize.xs,
      LdSize.xs,
    ];
    final size = sizes[(level - 1).clamp(0, 5)];
    return base.merge(ldBuildTextStyle(theme, LdTextType.headline, size));
  }

  /// Returns the link URL at [offset] in the current text, or null.
  String? linkAtOffset(int offset) {
    for (final m in _link.allMatches(text)) {
      if (offset >= m.start && offset <= m.end) {
        return m.group(2);
      }
    }
    return null;
  }

  /// Returns the hashtag (without `#`) at [offset], or null.
  String? hashtagAtOffset(int offset) {
    for (final m in _hashtag.allMatches(text)) {
      if (offset >= m.start && offset <= m.end) {
        return m.group(1);
      }
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Internal types
// ---------------------------------------------------------------------------

enum _InlineKind {
  boldItalic,
  bold,
  italic,
  code,
  link,
  image,
  strikethrough,
  hashtag,
}

// ---------------------------------------------------------------------------
// Horizontal rule widget
// ---------------------------------------------------------------------------

class _HrWidget extends StatelessWidget {
  const _HrWidget();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            (constraints.maxWidth.isFinite ? constraints.maxWidth : 0.0) - 5;
        return SizedBox(
          width: width,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: LdDivider(),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Blockquote bar widget
// ---------------------------------------------------------------------------

class _BlockquoteBar extends StatelessWidget {
  const _BlockquoteBar();

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: SizedBox(
        width: theme.borderWidth,
        height: 18,
        child: DecoratedBox(decoration: BoxDecoration(color: theme.border)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Table helpers
// ---------------------------------------------------------------------------

List<String> _splitTableRow(String line) {
  final inner = line.substring(1, line.length - 1);
  return inner.split('|').map((c) => c.trim()).toList();
}

/// Renders an entire GFM table block as a single widget inside a [WidgetSpan].
/// Uses [LayoutBuilder] to fill the available width from the paragraph.
class _TableWidget extends StatelessWidget {
  const _TableWidget({
    required this.dataRows,
    required this.colCount,
    required this.headerStyle,
    required this.bodyStyle,
    required this.theme,
  });

  final List<List<String>> dataRows;
  final int colCount;
  final TextStyle headerStyle;
  final TextStyle bodyStyle;
  final LdTheme theme;

  @override
  Widget build(BuildContext context) {
    final bw = theme.borderWidth;
    final bc = theme.border;
    final cellPad = theme.pad(size: LdSize.s);
    final radius = theme.radius(LdSize.s);

    final tableRows = <TableRow>[];
    for (var ri = 0; ri < dataRows.length; ri++) {
      final cells = dataRows[ri];
      final isHeader = ri == 0;
      final style = isHeader ? headerStyle : bodyStyle;
      final isLast = ri == dataRows.length - 1;

      final topBorder = ri == 0
          ? BorderSide(color: bc, width: bw)
          : ri == 1
          ? BorderSide(color: bc, width: bw * 2)
          : BorderSide.none;
      final bottomBorder = isLast
          ? BorderSide(color: bc, width: bw)
          : BorderSide.none;

      tableRows.add(
        TableRow(
          decoration: BoxDecoration(color: isHeader ? theme.surface : null),
          children: List.generate(colCount, (ci) {
            final text = ci < cells.length ? cells[ci] : '';
            final isLastCol = ci == colCount - 1;
            return DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: topBorder,
                  bottom: bottomBorder,
                  left: BorderSide(color: bc, width: bw),
                  right: isLastCol
                      ? BorderSide(color: bc, width: bw)
                      : BorderSide.none,
                ),
              ),
              child: Padding(
                padding: cellPad,
                child: Text(text, style: style),
              ),
            );
          }),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availW =
            (constraints.maxWidth.isFinite ? constraints.maxWidth : 300.0) - 5;
        return ClipRRect(
          borderRadius: radius,
          child: SizedBox(
            width: availW,
            child: Table(
              border: TableBorder.symmetric(
                inside: BorderSide(color: bc, width: bw),
              ),
              defaultColumnWidth: const FlexColumnWidth(),
              children: tableRows,
            ),
          ),
        );
      },
    );
  }
}
