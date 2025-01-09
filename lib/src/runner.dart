import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdRunnerLog extends StatefulWidget {
  final List<String> messages;
  const LdRunnerLog({Key? key, required this.messages}) : super(key: key);

  @override
  State<LdRunnerLog> createState() => _LdRunnerLogState();
}

class _LdRunnerLogState extends State<LdRunnerLog> {
  final FocusNode _node = FocusNode();

  @override
  dispose() {
    _node.dispose();
    super.dispose();
  }

  Widget buildLine(int index, LdTheme theme) {
    return LdTouchableSurface(
        onTap: () {},
        color: LdTheme.of(context).palette.neutral,
        builder: (context, colors, status) {
          return Container(
            decoration: BoxDecoration(
              color: colors.surface,
            ),
            padding: theme.balPad(LdSize.s) / 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectionContainer.disabled(
                  child: SizedBox(
                    width: 32,
                    child: Text(
                      "${index + 1}",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: "NotoSansMono",
                        fontSize: theme.paragraphSize(LdSize.s),
                        color: theme.textMuted,
                      ),
                    ),
                  ),
                ),
                ldSpacerS,
                Expanded(
                  child: Text(
                    widget.messages[index],
                    style: TextStyle(
                      fontFamily: "NotoSansMono",
                      fontSize: theme.paragraphSize(LdSize.s),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    return LdCard(
      padding: EdgeInsets.zero,
      child: SelectableRegion(
        focusNode: _node,
        selectionControls: MaterialTextSelectionControls(),
        child: SizedBox(
          height: widget.messages.length < 50 ? null : 300,
          child: ListView.builder(
            shrinkWrap: widget.messages.length < 50,
            itemCount: widget.messages.length,
            physics: widget.messages.length < 50
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return buildLine(index, theme);
            },
          ),
        ),
      ),
    );
  }
}

class LdRunnerStep extends StatelessWidget {
  final Widget title;
  final LdIndicatorType status;
  final bool disabled;
  final Widget? trailing;
  final bool isExpanded;
  final VoidCallback? onPress;

  final List<Widget> children;

  const LdRunnerStep(
      {Key? key,
      required this.title,
      required this.status,
      this.disabled = false,
      this.trailing,
      this.isExpanded = false,
      this.onPress,
      required this.children})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    return Column(children: [
      LdTouchableSurface(
          active: isExpanded,
          disabled: disabled,
          onTap: () {
            if (onPress != null) {
              onPress!();
            }
          },
          color: theme.primary,
          builder: (context, colors, status) {
            return Container(
              padding: theme.balPad(LdSize.s),
              decoration: BoxDecoration(
                borderRadius: theme.radius(LdSize.s),
                color: children.isNotEmpty ? colors.surface : null,
              ),
              child: Row(
                children: [
                  if (children.isNotEmpty)
                    SizedBox(
                      width: 32,
                      child: AnimatedRotation(
                        turns: isExpanded ? 0.25 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: colors.icon,
                        ),
                      ),
                    )
                  else
                    const SizedBox(
                      width: 32,
                    ),
                  ldSpacerS,
                  LdIndicator(type: this.status),
                  ldSpacerM,
                  Expanded(
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: colors.text,
                        height: 1,
                      ),
                      child: title,
                    ),
                  ),
                  if (trailing != null)
                    DefaultTextStyle(
                      child: trailing!,
                      style: TextStyle(
                          fontFamily: "NotoSansMono",
                          color: colors.text,
                          fontSize: LdTheme.of(context).labelSize(LdSize.m)),
                    ),
                ],
              ),
            );
          }),
      LdReveal.quick(
        transformYOffset: 20,
        child: Padding(
          padding: theme.pad().copyWith(left: 32),
          child: LdAutoSpace(
            children: children,
          ),
        ),
        revealed: isExpanded,
      )
    ]);
  }
}
