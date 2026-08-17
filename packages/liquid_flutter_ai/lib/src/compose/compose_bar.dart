import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/compose/waveform_recorder.dart';
import 'package:liquid_flutter_ai/src/models/compose_attachment.dart';
import 'package:liquid_flutter_ai/src/send/send_fly_scope.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:waveform_recorder/waveform_recorder.dart';

/// Result of a completed voice recording from [LdComposeBar].
class LdVoiceRecording {
  final XFile file;
  final Duration length;

  const LdVoiceRecording({required this.file, required this.length});
}

/// Floating bottom compose bar (wraps [child] via LdAppBar.bottom).
class LdComposeBar extends StatefulWidget {
  final Widget child;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final List<LdComposeAttachment> attachments;
  final ValueChanged<String>? onSend;
  final VoidCallback? onStop;
  final bool isBusy;
  final ValueChanged<LdVoiceRecording>? onVoiceRecorded;
  final VoidCallback? onPickImage;
  final VoidCallback? onPickCamera;
  final VoidCallback? onPickFile;
  final ValueChanged<LdComposeAttachment>? onRemoveAttachment;
  final Widget? leading;
  final String? hintText;

  /// Optional slot painted above the input (e.g. custom chrome).
  /// Send-fly uses [LdSendFlyScope] + input origin, not this slot.
  final Widget? overlay;

  final Widget? attachmentsExtra;

  /// When set, paste (keyboard and context menu) tries this first. Return true
  /// when paste was handled (e.g. image attachment). Otherwise plain text is
  /// pasted as usual.
  final Future<bool> Function()? onCustomPaste;

  const LdComposeBar({
    super.key,
    required this.child,
    this.controller,
    this.focusNode,
    this.attachments = const [],
    this.onSend,
    this.onStop,
    this.isBusy = false,
    this.onVoiceRecorded,
    this.onPickImage,
    this.onPickCamera,
    this.onPickFile,
    this.onRemoveAttachment,
    this.leading,
    this.hintText,
    this.overlay,
    this.attachmentsExtra,
    this.onCustomPaste,
  });

  @override
  State<LdComposeBar> createState() => _LdComposeBarState();
}

class _LdComposeBarState extends State<LdComposeBar> {
  static const _controlSize = LdSize.l;

  TextEditingController? _ownedController;
  FocusNode? _ownedFocusNode;
  late final WaveformRecorderController _waveController;
  var _startingRecording = false;

  TextEditingController get _controller =>
      widget.controller ?? _ownedController!;
  FocusNode get _focusNode => widget.focusNode ?? _ownedFocusNode!;

  bool get _isRecording => _waveController.isRecording;
  bool get _voiceEnabled => widget.onVoiceRecorded != null;

  @override
  void initState() {
    super.initState();
    _waveController = WaveformRecorderController(
      // openai_dart / OpenAI chat only type wav|mp3 for input_audio; wav is
      // universally supported for voice notes across platforms.
      config: const RecordConfig(encoder: AudioEncoder.wav),
    );
    _waveController.addListener(_handleWaveChanged);
    if (widget.controller == null) {
      _ownedController = TextEditingController();
    }
    if (widget.focusNode == null) {
      _ownedFocusNode = FocusNode();
    }
    _controller.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(LdComposeBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownedController)?.removeListener(
        _handleTextChanged,
      );
      if (widget.controller == null) {
        _ownedController ??= TextEditingController();
      }
      _controller.addListener(_handleTextChanged);
    }
    if (oldWidget.focusNode != widget.focusNode && widget.focusNode == null) {
      _ownedFocusNode ??= FocusNode();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
    _waveController.removeListener(_handleWaveChanged);
    unawaited(_disposeWaveController());
    _ownedController?.dispose();
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  Future<void> _disposeWaveController() async {
    if (_waveController.isRecording) {
      try {
        await _waveController.cancelRecording();
      } catch (_) {
        // Best-effort cleanup on dispose.
      }
    }
    _waveController.dispose();
  }

  void _handleTextChanged() => setState(() {});

  void _handleWaveChanged() => setState(() {});

  bool get _hasContent =>
      _controller.text.trim().isNotEmpty || widget.attachments.isNotEmpty;

  void _handleSend() {
    if (widget.onSend == null || !_hasContent) {
      return;
    }
    widget.onSend!(_controller.text);
  }

  Future<void> _handleStartRecording() async {
    if (!_voiceEnabled || _isRecording || _startingRecording) {
      return;
    }

    setState(() => _startingRecording = true);
    _focusNode.unfocus();
    try {
      await _waveController.startRecording();
    } catch (error, stackTrace) {
      debugPrint(
        'LdComposeBar: failed to start recording: $error\n$stackTrace',
      );
    } finally {
      if (mounted) {
        setState(() => _startingRecording = false);
      }
    }
  }

  Future<void> _handleCancelRecording() async {
    if (!_isRecording) {
      return;
    }
    try {
      await _waveController.cancelRecording();
    } catch (error, stackTrace) {
      debugPrint(
        'LdComposeBar: failed to cancel recording: $error\n$stackTrace',
      );
    }
  }

  Future<void> _handleConfirmRecording() async {
    if (!_isRecording || widget.onVoiceRecorded == null) {
      return;
    }
    try {
      await _waveController.stopRecording();
      final file = _waveController.file;
      if (file == null) {
        return;
      }
      widget.onVoiceRecorded!(
        LdVoiceRecording(file: file, length: _waveController.length),
      );
      _waveController.clear();
    } catch (error, stackTrace) {
      debugPrint('LdComposeBar: failed to stop recording: $error\n$stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAttachments = widget.attachments.isNotEmpty && !_isRecording;
    return AppBarFrame(
      position: LdAppBarPosition.bottom,
      insidePadding: LdTheme.of(context).pad(),
      attached: false,
      scrollBehavior: LdAppBarScrollBehavior.static,
      wrappedChild: widget.child,

      child: Builder(
        builder: (context) {
          return Padding(
            padding: MediaQuery.of(context).padding,
            child: Column(
              children: [
                _buildChrome(context),
                if (hasAttachments) _buildAttachmentStrip(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChrome(BuildContext context) {
    return _buildInputRow(context);
  }

  Widget _buildAttachmentStrip(BuildContext context) {
    final chips = widget.attachments
        .map((attachment) => _buildAttachmentChip(context, attachment))
        .toList(growable: false);

    return LdHorizontalScroll(
      layout: LdHorizontalScrollLayout.scroll,
      children: chips,
    );
  }

  Widget _buildAttachmentChip(
    BuildContext context,
    LdComposeAttachment attachment,
  ) {
    final theme = LdTheme.of(context);
    final onRemove = widget.onRemoveAttachment;

    return LdTag(
      key: ValueKey(attachment.id),
      onDismiss: onRemove != null ? () => onRemove(attachment) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (attachment.preview != null)
            ClipRRect(
              borderRadius: theme.radius(LdSize.xs),
              child: SizedBox(width: 18, height: 18, child: attachment.preview),
            )
          else ...[
            Icon(
              attachment.isImage
                  ? LucideIcons.image
                  : attachment.isAudio
                  ? LucideIcons.mic
                  : LucideIcons.paperclip,
            ),
            ldHSpacerXS,
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                attachment.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputRow(BuildContext context) {
    final showAttachRow =
        widget.onPickImage != null ||
        widget.onPickCamera != null ||
        widget.onPickFile != null;
    final showMic = _voiceEnabled && _controller.text.isEmpty && !_isRecording;

    final theme = LdTheme.of(context);
    final controlHeight = theme.controlHeight(_controlSize);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LdReveal.quick(
          revealed: _isRecording,
          axes: {Axis.horizontal},
          child: Row(
            children: [
              LdButton.outline(
                onPressed: _handleCancelRecording,
                size: _controlSize,
                child: const Icon(LucideIcons.x),
              ),
              ldSpacerXS,
            ],
          ),
        ),
        LdReveal.quick(
          revealed: !_isRecording && !_focusNode.hasFocus,
          child: Row(
            children: [if (widget.leading != null) widget.leading!, ldSpacerXS],
          ),
        ),
        LdReveal.quick(
          revealed: !_isRecording,
          axes: {Axis.horizontal},
          child: Row(
            children: [
              if (showAttachRow) _buildAttachButtons(context),
              ldSpacerXS,
            ],
          ),
        ),

        Expanded(
          child: Stack(
            children: [
              SizedBox(width: double.infinity),
              Center(
                child: LdReveal(
                  revealed: !_isRecording,
                  child: LdSendFlyOrigin(
                    child: Stack(
                      children: [
                        _buildInput(context),
                        if (widget.overlay != null) widget.overlay!,
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: LdReveal(
                  revealed: _isRecording,
                  child: (_isRecording && !_startingRecording)
                      ? LdWaveformRecorder(
                          controller: _waveController,
                          size: _controlSize,
                        )
                      : SizedBox(height: controlHeight, width: double.infinity),
                ),
              ),
            ],
          ),
        ),
        LdReveal.quick(
          revealed: widget.isBusy && widget.onStop != null,
          child: Row(
            children: [
              ldSpacerXS,
              LdButton(
                color: theme.error,
                size: _controlSize,
                onPressed: widget.onStop ?? () {},

                child: const Icon(LucideIcons.square),
              ),
            ],
          ),
        ),
        LdReveal.quick(
          revealed: !widget.isBusy && (_hasContent && widget.onSend != null),
          child: Row(
            children: [
              ldSpacerXS,
              LdButton.filled(
                onPressed: _handleSend,
                size: _controlSize,
                child: const Icon(LucideIcons.arrowUp),
              ),
            ],
          ),
        ),
        LdReveal.quick(
          revealed: showMic,
          axes: {Axis.horizontal},
          child: Row(children: [ldSpacerXS, _buildMicButton(context)]),
        ),
        LdReveal.quick(
          revealed: _isRecording,
          axes: {Axis.horizontal},
          child: Row(
            children: [
              ldSpacerXS,
              LdButton.filled(
                size: _controlSize,
                onPressed: _handleConfirmRecording,
                child: const Icon(LucideIcons.arrowUp),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttachButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LdContextMenu(
          menuBuilder: (context) => ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                LdHorizontalScroll(
                  children: [
                    if (widget.onPickImage != null)
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: LdButton.vague(
                          width: double.infinity,
                          onPressed: widget.onPickImage!,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.image),
                              ldSpacerM,
                              Text('Photos'),
                            ],
                          ),
                        ),
                      ),
                    if (widget.onPickCamera != null)
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: LdButton.vague(
                          width: double.infinity,
                          onPressed: widget.onPickCamera!,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.camera),
                              ldSpacerM,
                              Text('Camera'),
                            ],
                          ),
                        ),
                      ),
                    if (widget.onPickFile != null)
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: LdButton.vague(
                          onPressed: widget.onPickFile!,
                          width: double.infinity,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.file),
                              ldSpacerM,
                              Text('Files'),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                ldSpacerM,
                if (widget.attachmentsExtra != null) widget.attachmentsExtra!,
              ],
            ),
          ).padM(),
          builder: (context, isShuttle, trigger, isOpen, child) {
            return LdButton.outline(
              onPressed: trigger,
              size: LdSize.l,
              child: const Icon(LucideIcons.plus),
            );
          },
        ),
      ],
    ).spaceXS();
  }

  Widget _buildInput(BuildContext context) {
    return LdInput(
      hint: widget.hintText ?? 'Message',
      controller: _controller,
      focusNode: _focusNode,
      size: _controlSize,
      minLines: 1,
      borderRadius: LdTheme.of(context).radius(LdSize.l),
      maxLines: 6,

      allowTapOutside: true,
      onSubmitted: (_) => _handleSend(),
      onCustomPaste: widget.onCustomPaste,
    );
  }

  Widget _buildMicButton(BuildContext context) {
    return LdButton.outline(
      disabled: _startingRecording,
      size: _controlSize,
      onPressed: _handleStartRecording,
      child: const Icon(LucideIcons.mic),
    );
  }
}
