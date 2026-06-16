part of 'ld_filter_chips_bar.dart';

/// Muted group label aligned to [LdButton] size `s` chip content lane.
class _FilterChipGroupLabel extends StatelessWidget {
  const _FilterChipGroupLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return LdMute(
      child: LdText.ls(
        text,
        lineHeight: 1.2,
      ),
    );
  }
}

class _FilterChipGroupDivider extends StatelessWidget {
  const _FilterChipGroupDivider();

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);

    return SizedBox(
      height: theme.labelSize(LdSize.s) * 2,
      child: VerticalDivider(
        width: theme.borderWidth,
        color: theme.border,
        indent: 0,
        endIndent: 0,
      ),
    );
  }
}
