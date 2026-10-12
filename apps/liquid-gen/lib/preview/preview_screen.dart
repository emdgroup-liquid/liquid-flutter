import 'package:flutter/material.dart';

import 'package:genui/genui.dart' as genui;
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/ld_frame.dart';
import 'package:provider/provider.dart';

import '../ai/genui_service.dart';
import 'preview_provider.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PreviewProvider>();

    return Padding(
      padding: MediaQuery.paddingOf(
        context,
      ).atLeast(LdTheme.of(context).pad(size: LdSize.l)),
      child: Column(
        children: [
          // Device frame selector
          Container(
            padding: LdTheme.of(context).pad(size: LdSize.s),
            child: Row(
              children: DeviceFrameType.values.map((frame) {
                final isSelected = frame == provider.selectedFrame;
                final label = _getFrameLabel(frame);
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: frame != DeviceFrameType.values.last ? 8 : 0,
                    ),
                    child: LdButton(
                      mode: isSelected
                          ? LdButtonMode.filled
                          : LdButtonMode.outline,
                      onPressed: () => provider.setSelectedFrame(frame),
                      child: LdText.l(label),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          // Preview area
          Expanded(
            child: provider.surfaceIds.isEmpty
                ? Center(
                    child: LdText.p(
                      'No UI generated yet. Start a conversation to generate UI.',
                    ),
                  )
                : _buildPreview(context, provider),
          ),
        ],
      ),
    );
  }

  String _getFrameLabel(DeviceFrameType frame) {
    switch (frame) {
      case DeviceFrameType.iphone16Pro:
        return 'iPhone 16 Pro';
      case DeviceFrameType.ipadPro11:
        return 'iPad Pro 11';
      case DeviceFrameType.fairphone6:
        return 'Fairphone 6';
    }
  }

  Widget _buildPreview(BuildContext context, PreviewProvider provider) {
    final frameOptions = provider.getFrameOptions();
    final host = GenUIService.instance.host;
    final surfaceIds = provider.surfaceIds.toList();

    if (host == null) {
      return Center(
        child: LdText.p('GenUI not initialized'),
      );
    }

    return Center(
      child: SizedBox(
        width: frameOptions.width,
        height: frameOptions.height,
        child: Padding(
          padding: LdTheme.of(context).pad(size: LdSize.l),
          child: ldFrame(
            child: surfaceIds.isEmpty
                ? const SizedBox()
                : ListView.builder(
                    itemCount: surfaceIds.length,
                    itemBuilder: (context, index) {
                      final surfaceId = surfaceIds[index];
                      return genui.GenUiSurface(
                        host: host,
                        surfaceId: surfaceId,
                      );
                    },
                  ),
            ldFrameOptions: frameOptions,
          ),
        ),
      ),
    );
  }
}
