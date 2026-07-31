import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/approval/tool_allow_rule.dart';

/// Shared exact/wildcard field cards for [LdToolAllowRulePickerSheet] and
/// [LdToolAllowRuleEditor].
class LdToolAllowFieldTree extends StatelessWidget {
  const LdToolAllowFieldTree({
    super.key,
    required this.args,
    required this.pins,
    required this.onPinChanged,
    this.emptyLabel = 'No arguments to pin.',
  });

  final Map<String, dynamic> args;
  final Map<String, LdToolAllowPinMode> pins;
  final void Function(String path, LdToolAllowPinMode mode) onPinChanged;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final paths = pins.keys.toList()..sort();

    if (paths.isEmpty) {
      return LdText.l(emptyLabel);
    }

    return _FieldCard(
      path: '',
      args: args,
      pins: pins,
      onPinChanged: onPinChanged,
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.path,
    required this.args,
    required this.pins,

    required this.onPinChanged,
  });

  final String path;
  final Map<String, dynamic> args;
  final Map<String, LdToolAllowPinMode> pins;

  final void Function(String path, LdToolAllowPinMode mode) onPinChanged;

  Widget _buildChild(BuildContext context, String childKey) {
    final childArg = args[childKey];
    final childPath = path.isEmpty ? childKey : '$path.$childKey';

    final pin = pins[childPath] ?? LdToolAllowPinMode.exact;

    final isMap = childArg is Map<String, dynamic>;

    if (isMap) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 1,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: LdTheme.of(context).border),
                  ),
                ),
              ),

              SizedBox(width: 3),
              LdText.ls("$childKey:"),
              SizedBox(width: 3),
              Expanded(
                child: LdSwitch(
                  size: LdSize.s,
                  children: {
                    LdToolAllowPinMode.exact: Text('Fixed'),
                    LdToolAllowPinMode.wildcard: Text('Any'),
                  },
                  value: pin,
                  onChanged: (value) => onPinChanged(childPath, value),
                ),
              ),
            ],
          ),

          LdReveal(
            revealed: pin == LdToolAllowPinMode.exact,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: _FieldCard(
                    path: childPath,
                    args: childArg,
                    pins: pins,
                    onPinChanged: onPinChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ).spaceS();
    } else {
      return Row(
        children: [
          Container(
            width: 6,
            height: 1,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: LdTheme.of(context).border),
              ),
            ),
          ),
          LdText.ls("$childKey:"),
          LdSwitch(
            size: LdSize.s,
            children: {
              LdToolAllowPinMode.exact: Text('$childArg'),
              LdToolAllowPinMode.wildcard: Text('Any'),
            },
            value: pin,
            onChanged: (value) => onPinChanged(childPath, value),
          ),
        ],
      ).spaceS();
    }
  }

  @override
  Widget build(BuildContext context) {
    final children = args.keys;

    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: LdTheme.of(context).border),
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final child in children) ...[_buildChild(context, child)],
          ],
        ).spaceS(),
      ],
    );
  }
}
