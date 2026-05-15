import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/touchable/neutral_ghost_color.dart';

class LdRunnerLog extends StatefulWidget {
  /// The list of messages to display.
  final List<String> messages;

  /// Whether to show a copy button.
  ///
  /// Defaults to false. The button is only shown on desktop platforms.
  final bool showCopyButton;

  /// An optional builder that can be used to override the default Text widget for each line.
  final Widget Function(BuildContext context, int index, String content)? lineBuilder;

  const LdRunnerLog({
    super.key,
    required this.messages,
    this.showCopyButton = false,
    this.lineBuilder,
  });

  @override
  State<LdRunnerLog> createState() => _LdRunnerLogState();
}

class _LdRunnerLogState extends State<LdRunnerLog> {
  final FocusNode _node = FocusNode();
  bool _isHovering = false;

  @override
  dispose() {
    _node.dispose();
    super.dispose();
  }

  Widget buildLine(int index, LdTheme theme) {
    return LdTouchableSurface(
      onPressed: () {},
      builder: (context, status, _) => Builder(
        builder: (context) {
          final colorBundle = neutralGhostColor(theme, status);
          return Container(
            decoration: BoxDecoration(
              color: colorBundle.surface,
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
                  child: widget.lineBuilder?.call(context, index, widget.messages[index]) ??
                      Text(
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
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    bool isDesktop = LdTheme.of(context).platform.isDesktop;
    final tr = LiquidLocalizations.of(context);

    return LdCard(
      padding: EdgeInsets.zero,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: Stack(
          children: [
            SelectableRegion(
              focusNode: _node,
              selectionControls: MaterialTextSelectionControls(),
              child: SizedBox(
                height: widget.messages.length < 50 ? null : 300,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
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
            if (widget.showCopyButton && isDesktop && _isHovering)
              Positioned(
                top: theme.balPad(LdSize.s).top,
                right: theme.balPad(LdSize.s).right,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.palette.surface,
                    borderRadius: theme.radius(LdSize.s),
                  ),
                  child: LdButton(
                    color: shadSky,
                    size: LdSize.s,
                    mode: LdButtonMode.outline,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.messages.join("\n")));
                      LdNotificationsController.of(context).addNotification(
                        LdNotification(
                          message: tr.copiedToClipboard,
                          type: LdNotificationType.success,
                        ),
                      );
                    },
                    child: Text(tr.copy),
                  ),
                ),
              ),
          ],
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

  /// An optional custom indicator to use instead of the default [LdIndicator].
  final Widget? customIndicator;

  final List<Widget>? children;

  const LdRunnerStep(
      {super.key,
      required this.title,
      required this.status,
      this.disabled = false,
      this.trailing,
      this.isExpanded = false,
      this.onPress,
      this.customIndicator,
      this.children});

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    return Column(children: [
      LdTouchableSurface(
        active: isExpanded,
        disabled: disabled,
        onPressed: () {
          if (onPress != null) {
            onPress!();
          }
        },
        builder: (context, status, _) => Builder(
          builder: (context) {
            final colorBundle = neutralGhostColor(theme, status);
            return Container(
              padding: theme.balPad(LdSize.s),
              decoration: BoxDecoration(
                borderRadius: theme.radius(LdSize.s),
                color: (children?.isNotEmpty ?? false) ? colorBundle.surface : null,
              ),
              child: Row(
                children: [
                  if (children?.isNotEmpty ?? false)
                    SizedBox(
                      width: 32,
                      child: AnimatedRotation(
                        turns: isExpanded ? 0.25 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: colorBundle.icon,
                        ),
                      ),
                    )
                  else
                    const SizedBox(
                      width: 32,
                    ),
                  ldSpacerS,
                  customIndicator ?? LdIndicator(type: this.status),
                  ldSpacerM,
                  Expanded(
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: colorBundle.text,
                        height: 1,
                      ),
                      child: title,
                    ),
                  ),
                  if (trailing != null)
                    DefaultTextStyle(
                      style: TextStyle(
                          fontFamily: "NotoSansMono",
                          color: colorBundle.text,
                          fontSize: LdTheme.of(context).labelSize(LdSize.m)),
                      child: trailing!,
                    ),
                ],
              ),
            );
          },
        ),
      ),
      if (children != null && children!.isNotEmpty)
        LdReveal.quick(
          transformYOffset: 20,
          revealed: isExpanded,
          child: Padding(
            padding: theme.pad().copyWith(left: 32),
            child: LdAutoSpace(
              children: children!,
            ),
          ),
        )
    ]);
  }
}
