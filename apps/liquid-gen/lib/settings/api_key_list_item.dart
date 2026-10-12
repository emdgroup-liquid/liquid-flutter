import 'package:flutter/material.dart';

import 'package:liquid_flutter/liquid_flutter.dart';

import '../services/api_key_service.dart';
import '../ai/genui_service.dart';

class ApiKeyListItem extends StatelessWidget {
  final String provider;
  final String label;

  const ApiKeyListItem({
    super.key,
    required this.provider,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return LdSubmit<bool, void>(
      config: LdSubmitConfig<bool, void>(
        autoTrigger: true,
        action: (_) async {
          return await ApiKeyService.instance.hasApiKey(provider);
        },
      ),
      builder: LdSubmitCustomBuilder<bool, void>(
        builder: (context, controller, stateType) {
          return switch (stateType) {
            LdSubmitStateType.loading => LdListItem.trailingForward(
              title: Text(label),
              subtitle: const LdLoader(),
              onPressed: null,
            ),
            LdSubmitStateType.error => LdListItem.trailingForward(
              title: Text(label),
              subtitle: Text('Error loading API key status'),
              onPressed: () async {
                final currentKey = await ApiKeyService.instance.getApiKey(
                  provider,
                );

                if (!context.mounted) {
                  return;
                }
                final newKey = await ldEnterTextModal(
                  context: context,
                  title: Text(label),
                  description: 'Enter your API key for $label',
                  initialValue: currentKey,
                  inputHint: 'Enter API key',
                  inputLabel: 'API Key',
                );
                if (!context.mounted) {
                  return;
                }

                if (newKey != null) {
                  await _saveApiKey(context, newKey);
                  controller.trigger();
                }
              },
            ),
            LdSubmitStateType.result => LdListItem.trailingForward(
              title: Text(label),
              subtitle: Text(
                controller.state.result == true
                    ? 'API key is configured'
                    : 'No API key configured',
              ),
              onPressed: () async {
                final currentKey = await ApiKeyService.instance.getApiKey(
                  provider,
                );
                if (!context.mounted) {
                  return;
                }
                final newKey = await ldEnterTextModal(
                  context: context,
                  title: Text(label),
                  description: 'Enter your API key for $label',
                  initialValue: currentKey,
                  inputHint: 'Enter API key',
                  inputLabel: 'API Key',
                );
                if (!context.mounted) {
                  return;
                }

                if (newKey != null) {
                  await _saveApiKey(context, newKey);
                  controller.trigger();
                }
              },
            ),
            LdSubmitStateType.idle => LdListItem.trailingForward(
              title: Text(label),
              subtitle: Text('Loading...'),
              onPressed: null,
            ),
          };
        },
      ),
    );
  }

  Future<void> _saveApiKey(BuildContext context, String apiKey) async {
    if (apiKey.trim().isNotEmpty) {
      await ApiKeyService.instance.setApiKey(provider, apiKey.trim());
    } else {
      await ApiKeyService.instance.deleteApiKey(provider);
    }

    // Reinitialize GenUI service with new API key if it's Gemini
    if (provider == 'gemini') {
      await GenUIService.instance.reinitialize();
    }

    if (context.mounted) {
      LdNotificationsController.of(
        context,
      ).success('API key saved successfully');
    }
  }
}
