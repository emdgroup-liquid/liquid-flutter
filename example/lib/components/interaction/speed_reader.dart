import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class SpeedReaderDemo extends StatefulWidget {
  const SpeedReaderDemo({super.key});

  @override
  State<SpeedReaderDemo> createState() => _SpeedReaderDemoState();
}

class _SpeedReaderDemoState extends State<SpeedReaderDemo> {
  late final LdSpeedReaderController _controller;

  final String _sampleText = '''
The speed reader is a powerful tool for improving reading comprehension and speed. 

It displays text one word at a time, centered on the screen. This technique helps reduce subvocalization and eye movement, allowing you to read faster while maintaining comprehension.

The component supports adjustable reading speeds, measured in words per minute (WPM). You can pause, resume, and restart the reading session at any time. The speed reader automatically adds appropriate delays after sentences and paragraphs to maintain natural reading flow.

Try adjusting the speed to find your optimal reading pace. Start with a slower speed and gradually increase it as you become more comfortable with the technique.
''';

  @override
  void initState() {
    super.initState();
    _controller = LdSpeedReaderController(text: _sampleText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/src/speed_reader.dart",
      title: "LdSpeedReader",
      apiComponents: const [
        "LdSpeedReader",
        "LdSpeedReaderController",
        "LdSpeedReaderState",
      ],
      demo: LdAutoSpace(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LdBundle(
            children: [
              LdText.hs("Basic Usage"),
              LdText.p(
                "The speed reader displays text one word at a time, centered on the screen. "
                "Use the controls to start, pause, resume, and restart the reading session.",
              ),
              ComponentWell(
                child: SizedBox(
                  height: 400,
                  child: Center(
                    child: LdSpeedReader(
                      controller: _controller,
                    ),
                  ),
                ),
              ),
            ],
          ),
          LdBundle(
            children: [
              LdText.hs("Features"),
              LdText.p(
                "• Adjustable reading speed (WPM)\n"
                "• Automatic pauses after sentences and paragraphs\n"
                "• Pause and resume functionality\n"
                "• Restart from beginning\n"
                "• State management via stream",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
