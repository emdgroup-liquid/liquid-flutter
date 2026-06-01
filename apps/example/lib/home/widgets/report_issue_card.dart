import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class HomeReportIssueCard extends StatelessWidget {
  const HomeReportIssueCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LdCard(
      child: LdAutoSpace(
        children: [
          LdText.h('Report an issue'),
          LdText.p('What area are you having problems with?'),
          Row(
            children: [
              Expanded(
                child: LdSelect(
                  label: 'Area',
                  value: 'ui',
                  items: [
                    LdSelectItem(child: Text('UI'), value: 'ui'),
                    LdSelectItem(child: Text('Functionality'), value: 'functionality'),
                    LdSelectItem(child: Text('Performance'), value: 'performance'),
                    LdSelectItem(child: Text('Other'), value: 'other'),
                  ],
                ),
              ),
              Expanded(
                child: LdSelect(
                  label: 'Severity',
                  value: 'medium',
                  items: [
                    LdSelectItem(child: Text('Low'), value: 'low'),
                    LdSelectItem(child: Text('Medium'), value: 'medium'),
                    LdSelectItem(child: Text('High'), value: 'high'),
                  ],
                ),
              ),
            ],
          ).spaceM(),
          LdInput(hint: 'I need help with...', label: 'Subject'),
          LdInput(
            hint: 'Describe your issue in detail...',
            label: 'Description',
            minLines: 3,
            maxLines: 5,
            textInputAction: TextInputAction.done,
          ),
          Row(
            children: [
              LdButton.ghost(child: Text('Cancel'), onPressed: () {}),
              LdButton(child: Text('Submit'), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }
}
