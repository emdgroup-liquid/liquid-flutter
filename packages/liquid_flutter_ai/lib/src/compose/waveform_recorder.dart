import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:waveform_flutter/waveform_flutter.dart';
import 'package:waveform_recorder/waveform_recorder.dart';

/// Waveform visualization styled like [LdInput], for use in [LdComposeBar].
///
/// Uses [LdTheme.controlContentPadding] for inset and [LdCounter] for elapsed
/// recording time.
class LdWaveformRecorder extends StatefulWidget {
  const LdWaveformRecorder({
    required this.controller,
    this.size = LdSize.m,
    this.waveColor,
    this.onRecordingStarted,
    this.onRecordingStopped,
    super.key,
  });

  final WaveformRecorderController controller;
  final LdSize size;
  final Color? waveColor;
  final VoidCallback? onRecordingStarted;
  final VoidCallback? onRecordingStopped;

  @override
  State<LdWaveformRecorder> createState() => _LdWaveformRecorderState();
}

class _LdWaveformRecorderState extends State<LdWaveformRecorder> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    widget.onRecordingStarted?.call();
    if (widget.onRecordingStopped != null) {
      widget.controller.addListener(_onRecordingChange);
    }
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  void _onRecordingChange() {
    if (!widget.controller.isRecording) {
      _timer?.cancel();
      _timer = null;
      widget.onRecordingStopped?.call();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (widget.onRecordingStopped != null) {
      widget.controller.removeListener(_onRecordingChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final size = widget.size;
    final labelStyle = ldBuildTextStyle(theme, LdTextType.label, size);
    final lineBoxHeight = labelStyle.fontSize! * labelStyle.height!;
    final fieldPadding =
        theme.controlContentPadding(size) - EdgeInsets.all(theme.borderWidth);
    final durationStyle = labelStyle.copyWith(color: theme.textMuted);
    final waveColor = widget.waveColor ?? theme.primaryColor;
    final elapsed = widget.controller.timeElapsed;
    final minutes = elapsed.inMinutes.toDouble();
    final seconds = (elapsed.inSeconds % 60).toDouble();

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: theme.radius(LdSize.s),
        border: Border.all(
          color: theme.border,
          width: theme.borderWidth,
        ),
      ),
      child: Padding(
        padding: fieldPadding,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: lineBoxHeight),
          child: Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  LdCounter(
                    value: minutes,
                    minDigits: 2,
                    style: durationStyle,
                    inline: true,
                  ),
                  Text(':', style: durationStyle),
                  LdCounter(
                    value: seconds,
                    minDigits: 2,
                    style: durationStyle,
                    inline: true,
                  ),
                ],
              ),
              ldHSpacerS,
              Expanded(
                child: SizedBox(
                  height: lineBoxHeight,
                  child: ClipRect(
                    child: AnimatedWaveList(
                      stream: widget.controller.isRecording
                          ? widget.controller.amplitudeStream
                          : const Stream<Amplitude>.empty(),
                      barBuilder: (animation, amplitude) => WaveFormBar(
                        animation: animation,
                        amplitude: amplitude,
                        color: waveColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
