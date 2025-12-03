import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Represents a sentence containing words
class Sentence {
  /// Words in this sentence
  final List<String> words;

  const Sentence(this.words);

  /// Total number of words in this sentence
  int get wordCount => words.length;
}

/// Represents a paragraph containing sentences
class Paragraph {
  /// Sentences in this paragraph
  final List<Sentence> sentences;

  const Paragraph(this.sentences);

  /// Total number of words across all sentences in this paragraph
  int get wordCount => sentences.fold(0, (sum, sentence) => sum + sentence.wordCount);

  /// Total number of sentences in this paragraph
  int get sentenceCount => sentences.length;
}

/// State object for the speed reader
class LdSpeedReaderState {
  /// Whether reading is active
  final bool isPlaying;

  /// Current reading speed in WPM
  final int speed;

  /// Current paragraph index (0-based)
  final int currentParagraphIndex;

  /// Current sentence index within paragraph (0-based)
  final int currentSentenceIndex;

  /// Current word index within sentence (0-based)
  final int currentWordIndex;

  final List<Paragraph> paragraphs;

  String? get currentWord {
    final safeParagraphIndex = currentParagraphIndex.clamp(0, paragraphs.length - 1);
    final safeSentenceIndex = currentSentenceIndex.clamp(0, paragraphs[safeParagraphIndex].sentences.length - 1);
    final safeWordIndex =
        currentWordIndex.clamp(0, paragraphs[safeParagraphIndex].sentences[safeSentenceIndex].words.length - 1);
    return paragraphs[safeParagraphIndex].sentences[safeSentenceIndex].words[safeWordIndex];
  }

  const LdSpeedReaderState({
    this.isPlaying = false,
    this.paragraphs = const [],
    this.speed = 400,
    this.currentParagraphIndex = 0,
    this.currentSentenceIndex = 0,
    this.currentWordIndex = 0,
  });

  List<double> get paragraphProgress {
    final progressList = <double>[];
    for (final paragraph in paragraphs) {
      final paragraphIndex = paragraphs.indexOf(paragraph);
      if (currentParagraphIndex == paragraphIndex) {
        int currentParagraphWord = 0;
        for (int i = 0; i < currentSentenceIndex; i++) {
          currentParagraphWord += paragraphs[paragraphIndex].sentences[i].words.length;
        }
        currentParagraphWord += currentWordIndex;
        final progress = currentParagraphWord / paragraph.wordCount;
        progressList.add(progress);
      } else if (currentParagraphIndex > paragraphs.indexOf(paragraph)) {
        progressList.add(1.0);
      } else {
        progressList.add(0.0);
      }
    }

    return progressList;
  }

  /// Creates a copy of this state with the given fields replaced
  LdSpeedReaderState copyWith({
    List<Paragraph>? paragraphs,
    bool? isPlaying,
    int? currentIndex,
    int? totalWords,
    int? speed,
    int? currentParagraphIndex,
    int? currentSentenceIndex,
    int? currentWordIndex,
  }) {
    return LdSpeedReaderState(
      paragraphs: paragraphs ?? this.paragraphs,
      isPlaying: isPlaying ?? this.isPlaying,
      speed: speed ?? this.speed,
      currentParagraphIndex: currentParagraphIndex ?? this.currentParagraphIndex,
      currentSentenceIndex: currentSentenceIndex ?? this.currentSentenceIndex,
      currentWordIndex: currentWordIndex ?? this.currentWordIndex,
    );
  }

  @override
  String toString() {
    return 'LdSpeedReaderState(isPlaying: $isPlaying, speed: $speed, currentParagraphIndex: $currentParagraphIndex, currentSentenceIndex: $currentSentenceIndex, currentWordIndex: $currentWordIndex, paragraphs: $paragraphs)';
  }
}

/// Controller for managing speed reader state and logic
class LdSpeedReaderController {
  final String text;
  final _stateController = StreamController<LdSpeedReaderState>.broadcast();
  LdSpeedReaderState _state = const LdSpeedReaderState();
  Timer? _timer;

  bool _disposed = false;

  /// Stream of speed reader states
  Stream<LdSpeedReaderState> get stateStream => _stateController.stream;

  /// Current state
  LdSpeedReaderState get state => _state;

  LdSpeedReaderController({
    required this.text,
  }) {
    _parseText();
    _setState(_state.copyWith(
      speed: 400,
    ));
  }

  /// Parses text into paragraphs, sentences, and words
  void _parseText() {
    if (text.isEmpty) {
      return;
    }

    // Split by double newlines for paragraphs
    final paragraphTexts = text.split(RegExp(r'\n\s*\n'));

    final paragraphs = <Paragraph>[];

    for (final paragraphText in paragraphTexts) {
      final trimmed = paragraphText.trim();
      if (trimmed.isEmpty) continue;

      final sentences = _parseSentences(trimmed);
      if (sentences.isNotEmpty) {
        paragraphs.add(Paragraph(sentences));
      }
    }

    _setState(_state.copyWith(
      paragraphs: paragraphs,
    ));
  }

  /// Parses a paragraph text into sentences
  List<Sentence> _parseSentences(String paragraphText) {
    // Split by sentence delimiters, keeping punctuation with the sentence
    // This regex matches: end of sentence (., !, ?) followed by whitespace or end of string
    final sentencePattern = RegExp(r'([.!?]+)(?=\s+|$)');
    final sentenceParts = paragraphText.split(sentencePattern);
    final List<String> processedParts = [];

    for (var i = 0; i < sentenceParts.length; i++) {
      var part = sentenceParts[i].trim();
      if (part.isEmpty) continue;

      // If this part is only punctuation, attach it to the previous part
      if (RegExp(r'^[.!?]+$').hasMatch(part)) {
        if (processedParts.isNotEmpty) {
          processedParts[processedParts.length - 1] += part;
        } else {
          processedParts.add(part);
        }
      } else {
        // Check if next part is punctuation and attach it
        if (i + 1 < sentenceParts.length) {
          final nextPart = sentenceParts[i + 1].trim();
          if (RegExp(r'^[.!?]+$').hasMatch(nextPart)) {
            part += nextPart;
            i++; // Skip the punctuation part
          }
        }
        processedParts.add(part);
      }
    }

    // Convert each sentence part into a Sentence object
    final List<Sentence> sentences = [];
    for (final sentenceText in processedParts) {
      final trimmed = sentenceText.trim();
      if (trimmed.isEmpty) continue;

      // Split sentence into words (preserve punctuation with words)
      final words = trimmed.split(RegExp(r'\s+')).map((word) => word.trim()).where((word) => word.isNotEmpty).toList();

      if (words.isNotEmpty) {
        sentences.add(Sentence(words));
      }
    }

    return sentences;
  }

  /// Sets the internal state and notifies listeners
  void _setState(LdSpeedReaderState newState) {
    _state = newState;
    if (!_disposed && !_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  /// Calculates word delay in milliseconds based on WPM
  int _getWordDelay(int wpm) {
    if (wpm <= 0) return 1000;
    return (60000 / wpm).round();
  }

  /// Starts reading
  void start() async {
    if (_disposed || _state.isPlaying) return;

    _setState(_state.copyWith(
      isPlaying: true,
    ));
    await Future.delayed(const Duration(seconds: 1));
    _displayNextWord();
  }

  /// Pauses reading
  void pause() {
    if (!_state.isPlaying) return;

    _timer?.cancel();
    _timer = null;
    _setState(_state.copyWith(
      isPlaying: false,
    ));
  }

  /// Restarts reading from the beginning
  void restart() {
    _timer?.cancel();
    _timer = null;
    _setState(_state.copyWith(
      isPlaying: false,
      currentIndex: 0,
      currentParagraphIndex: 0,
      currentSentenceIndex: 0,
      currentWordIndex: 0,
    ));
  }

  /// Sets the reading speed
  void setSpeed(int wpm) {
    if (wpm <= 0) return;

    final wasPlaying = _state.isPlaying;
    if (wasPlaying) {
      _timer?.cancel();
      _timer = null;
    }

    _setState(_state.copyWith(speed: wpm));

    if (wasPlaying) {
      _displayNextWord();
    }
  }

  /// Jumps back to the start of the current sentence, or to the previous sentence if already at the start
  void jumpBackSentence() {
    if (_disposed) return;

    _timer?.cancel();
    _timer = null;

    int newParagraphIndex = _state.currentParagraphIndex;
    int newSentenceIndex = _state.currentSentenceIndex;
    int newWordIndex = _state.currentWordIndex;

    // If we're at the start of a sentence, go to the previous sentence
    if (_state.currentWordIndex == 0) {
      if (_state.currentSentenceIndex > 0) {
        newSentenceIndex = _state.currentSentenceIndex - 1;
        newWordIndex = 0;
      } else if (_state.currentParagraphIndex > 0) {
        // Move to the last sentence of the previous paragraph
        newParagraphIndex = _state.currentParagraphIndex - 1;
        final paragraph = _state.paragraphs[newParagraphIndex];
        if (paragraph.sentences.isNotEmpty) {
          newSentenceIndex = paragraph.sentences.length - 1;
          newWordIndex = 0;
        }
      }
    } else {
      // Jump to the start of the current sentence
      newWordIndex = 0;
    }

    _setState(_state.copyWith(
      currentParagraphIndex: newParagraphIndex,
      currentSentenceIndex: newSentenceIndex,
      currentWordIndex: newWordIndex,
    ));

    // If reading is active, continue from the new position
    if (_state.isPlaying) {
      _displayNextWord();
    }
  }

  /// Jumps back to the start of the current paragraph, or to the previous paragraph if already at the start
  void jumpBackParagraph() {
    if (_disposed) return;

    _timer?.cancel();
    _timer = null;

    int newParagraphIndex = _state.currentParagraphIndex;
    int newSentenceIndex = _state.currentSentenceIndex;
    int newWordIndex = _state.currentWordIndex;

    // If we're at the start of a paragraph, go to the previous paragraph
    if (_state.currentSentenceIndex == 0 && _state.currentWordIndex == 0) {
      if (_state.currentParagraphIndex > 0) {
        newParagraphIndex = _state.currentParagraphIndex - 1;
        final paragraph = _state.paragraphs[newParagraphIndex];
        if (paragraph.sentences.isNotEmpty) {
          newSentenceIndex = 0;
          newWordIndex = 0;
        }
      }
    } else {
      // Jump to the start of the current paragraph
      newSentenceIndex = 0;
      newWordIndex = 0;
    }

    _setState(_state.copyWith(
      currentParagraphIndex: newParagraphIndex,
      currentSentenceIndex: newSentenceIndex,
      currentWordIndex: newWordIndex,
    ));

    // If reading is active, continue from the new position
    if (_state.isPlaying) {
      _displayNextWord();
    }
  }

  /// Displays the next word
  void _displayNextWord() {
    if (_disposed) {
      _setState(_state.copyWith(
        isPlaying: false,
      ));
      return;
    }

    LdSpeedReaderState newState = _state;

    final currentParagraph = _state.paragraphs[_state.currentParagraphIndex];
    final currentSentence = currentParagraph.sentences[_state.currentSentenceIndex];
    Duration delay = Duration.zero;

    if (_state.currentWordIndex == currentSentence.words.length - 1) {
      // Move to next sentence
      if (_state.currentSentenceIndex < _state.paragraphs[_state.currentParagraphIndex].sentences.length - 1) {
        newState = newState.copyWith(
          currentSentenceIndex: _state.currentSentenceIndex + 1,
          currentWordIndex: 0,
        );
        delay = Duration(milliseconds: _getWordDelay(_state.speed) * 2);
      } else {
        if (_state.currentParagraphIndex < _state.paragraphs.length - 1) {
          newState = newState.copyWith(
            currentParagraphIndex: _state.currentParagraphIndex + 1,
            currentSentenceIndex: 0,
            currentWordIndex: 0,
          );
          delay = Duration(milliseconds: _getWordDelay(_state.speed) * 4);
        } else {
          // Finished reading all paragraphs
          newState = newState.copyWith(
            isPlaying: false,
          );
        }
      }
    } else {
      // Move to next word
      newState = newState.copyWith(
        currentWordIndex: _state.currentWordIndex + 1,
      );
      delay = Duration(milliseconds: _getWordDelay(_state.speed));
    }

    _setState(newState);

    // Schedule next word
    _timer = Timer(delay, () {
      if (_state.isPlaying) {
        _displayNextWord();
      }
    });
  }

  /// Disposes of the controller
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    _stateController.close();
  }
}

/// A speed reader widget that displays text one word at a time
class LdSpeedReader extends StatefulWidget {
  /// The controller managing the speed reader state
  final LdSpeedReaderController? controller;

  /// Default speed options in WPM
  final List<int> speedOptions;

  /// Whether to expand the text, to full height.
  final bool expandText;

  /// The text to display
  final String? text;

  const LdSpeedReader({
    this.speedOptions = const [300, 400, 500, 600, 700],
    this.expandText = false,
    this.controller,
    this.text,
    super.key,
  }) : assert(
          text != null || controller != null,
          'Either text or controller must be provided',
        );

  @override
  State<LdSpeedReader> createState() => _LdSpeedReaderState();
}

class _LdSpeedReaderState extends State<LdSpeedReader> {
  late LdSpeedReaderController _controller = widget.controller ?? LdSpeedReaderController(text: widget.text!);

  @override
  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null) {
      if (oldWidget.text != widget.text) {
        _controller.dispose();
        _controller = LdSpeedReaderController(text: widget.text!);
      }
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LdSpeedReaderState>(
      stream: _controller.stateStream,
      initialData: _controller.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;

        return LdAutoSpace(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ldSpacerL,
            // Centered word display
            LdWrapConditional(
                condition: widget.expandText,
                child: state.currentWord != null
                    ? LdText.hl(
                        state.currentWord!,
                        textAlign: TextAlign.center,
                        color: state.isPlaying ? null : LdTheme.of(context).textMuted,
                      )
                    : LdText.p(
                        'Ready to start',
                        textAlign: TextAlign.center,
                      ),
                builder: (context, child) => Expanded(child: Center(child: child))),
            ldSpacerL,

            // Progress
            LdReveal.quick(
              revealed: !state.isPlaying,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final progress in state.paragraphProgress.asMap().entries)
                    Container(
                      width: progress.key == state.currentParagraphIndex ? 50 : 20,
                      decoration: BoxDecoration(
                        borderRadius: LdTheme.of(context).radius(LdSize.xs),
                        color: LdTheme.of(context).surface,
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 3,
                            width: (progress.key == state.currentParagraphIndex ? 50 : 20) * progress.value,
                            decoration: BoxDecoration(
                              color: progress.key >= state.currentParagraphIndex
                                  ? LdTheme.of(context).primaryColor
                                  : LdTheme.of(context).textMuted,
                              borderRadius: LdTheme.of(context).radius(LdSize.xs),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ).spaceS(),
            ),

            // Control bar

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LdReveal.quick(
                  revealed: !state.isPlaying && state.currentParagraphIndex > 0,
                  child: Tooltip(
                    message: 'Jump Back Paragraph',
                    child: LdButton.outline(
                      child: const Icon(LucideIcons.arrowBigLeftDash),
                      onPressed: () {
                        _controller.jumpBackParagraph();
                      },
                    ),
                  ),
                ),
                LdReveal.quick(
                  revealed: !state.isPlaying && (state.currentSentenceIndex > 0 || state.currentParagraphIndex > 0),
                  child: Tooltip(
                    message: 'Jump Back Sentence',
                    child: LdButton.outline(
                      child: const Icon(LucideIcons.arrowBigLeft),
                      onPressed: () {
                        _controller.jumpBackSentence();
                      },
                    ),
                  ),
                ),
                // Restart button
                LdReveal.quick(
                  revealed: !state.isPlaying,
                  child: Tooltip(
                    message: 'Restart',
                    child: LdButton.outline(
                      onPressed: () {
                        _controller.restart();
                      },
                      disabled: state.isPlaying,
                      child: const Icon(LucideIcons.rotateCcw),
                    ),
                  ),
                ),
                LdReveal.quick(
                  revealed: state.isPlaying,
                  child: Tooltip(
                    message: 'Pause',
                    child: LdButton(
                      child: const Icon(
                        LucideIcons.pause,
                      ),
                      active: state.isPlaying,
                      onPressed: () {
                        _controller.pause();
                      },
                    ),
                  ),
                ),
                LdReveal.quick(
                  revealed: !state.isPlaying,
                  child: Tooltip(
                    message: 'Start',
                    child: LdButton(
                      child: const Icon(
                        LucideIcons.play,
                      ),
                      onPressed: () {
                        _controller.start();
                      },
                      active: state.isPlaying,
                    ),
                  ),
                ),
              ],
            ),
            // Speed selector
            SizedBox(
              width: 150,
              child: LdSelect<int>(
                items: widget.speedOptions
                    .map(
                      (wpm) => LdSelectItem<int>(
                        value: wpm,
                        child: Text('$wpm WPM'),
                      ),
                    )
                    .toList(),
                value: state.speed,
                onChanged: (wpm) {
                  _controller.setSpeed(wpm);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
