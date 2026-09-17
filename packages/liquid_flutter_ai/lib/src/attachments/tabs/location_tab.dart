import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../attachment_models.dart';
import '../attachment_picker_controller.dart';
import '../attachment_result.dart';
import '../widgets/action_tile.dart';
import '../widgets/section_header.dart';

/// Location tab: map preview, "send current location", and "choose a place".
class LdLocationTab extends StatefulWidget {
  const LdLocationTab({super.key, required this.controller});

  final LdAttachmentPickerController controller;

  @override
  State<LdLocationTab> createState() => _LdLocationTabState();
}

class _LdLocationTabState extends State<LdLocationTab>
    with WidgetsBindingObserver {
  LdGeoPosition? _position;
  bool _locating = false;

  final List<LdPlace> _places = [];
  bool _searching = false;
  bool _loadedNearby = false;
  Timer? _debounce;

  LdAttachmentPickerController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _init();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _position == null) {
      _loadPosition();
    }
  }

  /// Requesting permission is the trigger for opening this tab; then the
  /// position (and nearby places) is resolved.
  Future<void> _init() async {
    try {
      await _controller.services.location.requestPermission();
    } catch (error, stackTrace) {
      debugPrint(
        'LdLocationTab: failed to request permission: $error\n$stackTrace',
      );
    }
    if (mounted) {
      await _loadPosition();
    }
  }

  Future<void> _loadPosition() async {
    try {
      final position = await _controller.services.location.currentPosition();
      if (!mounted) {
        return;
      }
      setState(() => _position = position);
      if (position != null) {
        await _loadNearby(position);
      }
    } catch (error, stackTrace) {
      debugPrint('LdLocationTab: failed to load position: $error\n$stackTrace');
    }
  }

  Future<void> _loadNearby(LdGeoPosition origin) async {
    if (_loadedNearby || _searching) {
      return;
    }
    _loadedNearby = true;
    setState(() => _searching = true);
    try {
      final places = await _controller.services.places.nearby(origin);
      if (!mounted) {
        return;
      }
      setState(() {
        _places
          ..clear()
          ..addAll(places);
        _searching = false;
      });
    } catch (error, stackTrace) {
      debugPrint('LdLocationTab: nearby search failed: $error\n$stackTrace');
      if (mounted) {
        setState(() => _searching = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _places.clear();
        _searching = false;
      });
      if (_position != null) {
        _loadedNearby = false;
        _loadNearby(_position!);
      }
      return;
    }
    setState(() => _searching = true);
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        final places = await _controller.services.places.search(trimmed);
        if (!mounted) {
          return;
        }
        setState(() {
          _places
            ..clear()
            ..addAll(places);
          _searching = false;
        });
      } catch (error, stackTrace) {
        debugPrint('LdLocationTab: place search failed: $error\n$stackTrace');
        if (mounted) {
          setState(() => _searching = false);
        }
      }
    });
  }

  Future<void> _sendCurrentLocation() async {
    if (_locating) {
      return;
    }
    setState(() => _locating = true);
    try {
      await _controller.services.location.requestPermission();
      final position = await _controller.services.location.currentPosition();
      if (!mounted || position == null) {
        return;
      }
      _controller.completeWith(
        LdPickedAttachment(
          id: 'location:${DateTime.now().microsecondsSinceEpoch}',
          kind: LdAttachmentKind.location,
          name: 'Location',
          location: position,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint(
        'LdLocationTab: failed to send current location: $error\n$stackTrace',
      );
    } finally {
      if (mounted) {
        setState(() => _locating = false);
      }
    }
  }

  void _sendPlace(LdPlace place) {
    _controller.completeWith(
      LdPickedAttachment(
        id: 'place:${place.latitude},${place.longitude}',
        kind: LdAttachmentKind.location,
        name: place.name,
        place: place,
        location: place.position,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final labels = _controller.labels;
    final position = _position;

    return Column(
      children: [
        if (position != null) ldSpacerM,
        Expanded(
          child: LdScaffoldBody(
            shrinkWrap: true,
            children: [
              if (position != null)
                ClipRRect(
                  borderRadius: theme.radius(LdSize.m),
                  child: SizedBox(
                    height: 300,
                    child: _controller.services.map.buildMap(
                      context,
                      LdMapRequest(center: position, markers: _places),
                    ),
                  ),
                ),
              LdAttachmentActionTile(
                icon: LucideIcons.locateFixed,
                title: labels.sendCurrentLocation,
                subtitle: position == null ? labels.locationUnavailable : null,
                trailing: _locating ? const LdLoader(size: 18) : null,
                onTap: _locating ? null : _sendCurrentLocation,
              ),
              ldSpacerL,
              LdAttachmentSectionHeader(label: labels.chooseAPlace),
              LdInput(
                hint: labels.searchPlaces,
                leading: const Icon(LucideIcons.search),
                showClear: true,
                onChanged: _onSearchChanged,
                onCleared: () => _onSearchChanged(''),
              ),
              ldSpacerS,
              if (_searching)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: LdLoader()),
                )
              else if (_places.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: theme.paddingSize(size: LdSize.s),
                  ),
                  child: LdText.ps(labels.noPlaces),
                )
              else
                LdCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final place in _places)
                        LdListItem(
                          leading: const LdAvatar(
                            child: Icon(LucideIcons.mapPin),
                          ),
                          title: LdText.l(
                            place.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: place.subtitle == null
                              ? null
                              : LdText.ps(
                                  place.subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          onPressed: () => _sendPlace(place),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
