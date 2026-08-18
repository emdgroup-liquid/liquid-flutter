import 'package:flutter/material.dart';
import 'package:liquid/color_selector.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ---------------------------------------------------------------------------
// Interactive playground (stateful — no @Preview)
// ---------------------------------------------------------------------------

class LdButtonPlaygroundDemo extends StatefulWidget {
  const LdButtonPlaygroundDemo({super.key});

  @override
  State<LdButtonPlaygroundDemo> createState() => _LdButtonPlaygroundDemoState();
}

class _LdButtonPlaygroundDemoState extends State<LdButtonPlaygroundDemo> {
  LdSize _size = LdSize.m;
  bool _disabled = false;
  bool _active = false;
  bool _showIcon = true;
  LdButtonMode _mode = LdButtonMode.filled;
  late LdColor _color;

  @override
  void initState() {
    _color = LdTheme.of(context).palette.primary;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LdBundle(
      children: [
        ComponentWell(
          onSurface: true,
          child: Center(
            child: Column(
              children: [
                /*begin demo:LdButtonPlayground*/
                LdButton(
                  color: _color,
                  mode: _mode,
                  active: _active,
                  disabled: _disabled,
                  leading: _showIcon ? const Icon(LucideIcons.donut) : null,
                  size: _size,
                  onPressed: () async {
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  child: const Text('Button'),
                ),
                /*end demo:LdButtonPlayground*/
              ],
            ),
          ),
        ),
        LdBundle(
          children: [
            LdSelect<LdButtonMode>(
              value: _mode,
              label: 'Mode',
              items: const [
                LdSelectItem(child: Text('Filled'), value: LdButtonMode.filled),
                LdSelectItem(child: Text('Outline'), value: LdButtonMode.outline),
                LdSelectItem(child: Text('Ghost'), value: LdButtonMode.ghost),
                LdSelectItem(child: Text('Vague'), value: LdButtonMode.vague),
              ],
              onChanged: (LdButtonMode v) => setState(() => _mode = v),
            ),
          ],
        ),
        LdBundle(
          children: [
            LdText.l('Color'),
            ColorSelctor(
              active: _color,
              colors: {
                'primary': LdTheme.of(context).palette.primary,
                'secondary': LdTheme.of(context).palette.secondary,
                'success': LdTheme.of(context).palette.success,
                'warning': LdTheme.of(context).palette.warning,
                'error': LdTheme.of(context).palette.error,
              },
              onChanged: (c) => setState(() => _color = c),
            ),
          ],
        ),
        LdBundle(
          children: [
            LdSelect<LdSize>(
              value: _size,
              label: 'Size',
              items: const [
                LdSelectItem(child: Text('Extra Small (XS)'), value: LdSize.xs),
                LdSelectItem(child: Text('Small (S)'), value: LdSize.s),
                LdSelectItem(child: Text('Medium (M)'), value: LdSize.m),
                LdSelectItem(child: Text('Large (L)'), value: LdSize.l),
              ],
              onChanged: (LdSize v) => setState(() => _size = v),
            ),
          ],
        ),
        LdToggle(checked: _disabled, onChanged: (bool v) => setState(() => _disabled = v), label: 'Disabled'),
        LdToggle(checked: _active, onChanged: (bool v) => setState(() => _active = v), label: 'Active'),
        LdToggle(checked: _showIcon, onChanged: (bool v) => setState(() => _showIcon = v), label: 'Show Icon'),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Static demos
// ---------------------------------------------------------------------------

class LdButtonErrorDemo extends StatelessWidget {
  const LdButtonErrorDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentWell(
      child: Center(
        child: Column(
          children: [
            /*begin demo:LdButtonError*/
            LdButton(
              mode: LdButtonMode.filled,
              color: LdTheme.of(context).warning,
              onPressed: () async {
                await Future.delayed(const Duration(seconds: 1));
                throw LdLocalizedException(message: "Told you!", moreInfo: "Nothing actually happened");
              },
              child: const Text("I won't work"),
            ),
            /*end demo:LdButtonError*/
          ],
        ),
      ),
    );
  }
}

class LdButtonLeadingTrailingDemo extends StatelessWidget {
  const LdButtonLeadingTrailingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentWell(
      child: Column(
        children: [
          ldSpacerL,
          Wrap(
            spacing: 8,
            children: [
              /*begin demo:LdButtonLeadingTrailing*/
              LdButton(
                leading: const Icon(LucideIcons.square),
                onPressed: () => LdNotificationsController.of(context).addNotification(
                  LdNotification(
                    type: LdNotificationType.success,
                    message: 'You pressed a button with a leading widget!',
                  ),
                ),
                child: const Text('Leading'),
              ),
              LdButton(
                trailing: const Icon(LucideIcons.square),
                onPressed: () => LdNotificationsController.of(context).addNotification(
                  LdNotification(
                    type: LdNotificationType.success,
                    message: 'You pressed a button with a trailing widget!',
                  ),
                ),
                child: const Text('Trailing'),
              ),
              /*end demo:LdButtonLeadingTrailing*/
            ],
          ),
        ],
      ),
    );
  }
}

class LdButtonDisabledDemo extends StatelessWidget {
  const LdButtonDisabledDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentWell(
      child: Column(
        children: [
          /*begin demo:LdButtonDisabled*/
          LdButton(onPressed: () {}, disabled: true, child: const Text('Disabled')),
          /*end demo:LdButtonDisabled*/
        ],
      ),
    );
  }
}

class LdButtonCircularDemo extends StatelessWidget {
  const LdButtonCircularDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentWell(
      child: Column(
        children: [
          /*begin demo:LdButtonCircular*/
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LdButton(
                size: LdSize.xs,
                onPressed: () async => Future.delayed(const Duration(seconds: 1)),
                child: const Icon(LucideIcons.x),
              ),
              LdButton(
                size: LdSize.s,
                onPressed: () async => Future.delayed(const Duration(seconds: 1)),
                child: const Icon(LucideIcons.x),
              ),
              LdButton(
                onPressed: () async => Future.delayed(const Duration(seconds: 1)),
                child: const Icon(LucideIcons.x),
              ),

              LdButton(
                size: LdSize.l,
                onPressed: () async => Future.delayed(const Duration(seconds: 1)),
                child: const Icon(LucideIcons.x),
              ),
            ],
          ).spaceM(),
          /*end demo:LdButtonCircular*/
        ],
      ),
    );
  }
}

class LdButtonFullWidthDemo extends StatelessWidget {
  const LdButtonFullWidthDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentWell(
      child: Column(
        children: [
          LdButton(
            leading: const Icon(LucideIcons.airVent),
            trailing: const Icon(LucideIcons.arrowRight),
            mode: LdButtonMode.outline,
            width: double.infinity,
            onPressed: () => LdNotificationsController.of(context).addNotification(
              LdNotification(message: 'You pressed the full width button', type: LdNotificationType.success),
            ),
            child: const Text('Full width'),
          ),
        ],
      ),
    );
  }
}

class LdButtonConfigDemo extends StatelessWidget {
  const LdButtonConfigDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentWell(
      child: Column(
        children: [
          /*begin demo:LdButtonConfig*/
          LdButtonConfigProvider(
            config: const LdButtonConfig(mode: LdButtonMode.outline, size: LdSize.s, disabled: false),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                LdButton(
                  onPressed: () => LdNotificationsController.of(
                    context,
                  ).addNotification(LdNotification(message: 'Button 1', type: LdNotificationType.success)),
                  child: const Text('Button 1'),
                ),
                LdButton(
                  onPressed: () => LdNotificationsController.of(
                    context,
                  ).addNotification(LdNotification(message: 'Button 2', type: LdNotificationType.success)),
                  child: const Text('Button 2'),
                ),
                LdButton(
                  mode: LdButtonMode.filled,
                  size: LdSize.m,
                  onPressed: () => LdNotificationsController.of(context).addNotification(
                    LdNotification(message: 'Button 3 (overrides config)', type: LdNotificationType.success),
                  ),
                  child: const Text('Button 3'),
                ),
              ],
            ),
          ),
          /*end demo:LdButtonConfig*/
        ],
      ),
    );
  }
}
