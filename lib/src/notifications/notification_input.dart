import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/autospace.dart';
import 'package:liquid_flutter/src/button.dart';
import 'package:liquid_flutter/src/input.dart';
import 'package:liquid_flutter/src/l10n/generated/liquid_localizations.dart';
import 'package:liquid_flutter/src/notifications/notification.dart';

class NotificationInput extends StatefulWidget {
  final LdInputNotification notification;

  final Function(String) onSubmitted;

  const NotificationInput({super.key, required this.notification, required this.onSubmitted});

  @override
  State<NotificationInput> createState() => _NotificationInputState();
}

class _NotificationInputState extends State<NotificationInput> {
  final TextEditingController _controller = TextEditingController();
  late final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: LdAutoSpace(
        children: [
          LdInput(
            controller: _controller,
            autofocus: true,
            focusNode: _focusNode,
            keyboardType: widget.notification.inputType,
            label: widget.notification.inputLabel,
            onSubmitted: (result) => widget.onSubmitted(result),
            hint: widget.notification.inputHint ?? LiquidLocalizations.of(context).enterText,
          ),
          LdButton(
            width: double.infinity,
            size: LdSize.l,
            mode: LdButtonMode.vague,
            child: Text(widget.notification.submitText ?? LiquidLocalizations.of(context).submit),
            onPressed: () {
              widget.onSubmitted(_controller.text);
            },
          )
        ],
      ),
    );
  }
}
