import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../attachment_models.dart';
import '../attachment_picker_controller.dart';
import '../attachment_result.dart';
import '../widgets/empty_state.dart';
import '../widgets/permission_prompt.dart';

/// Contacts tab: searchable contact list.
class LdContactsTab extends StatefulWidget {
  const LdContactsTab({super.key, required this.controller});

  final LdAttachmentPickerController controller;

  @override
  State<LdContactsTab> createState() => _LdContactsTabState();
}

class _LdContactsTabState extends State<LdContactsTab>
    with WidgetsBindingObserver {
  final List<LdContactEntry> _contacts = [];
  final Map<String, Uint8List> _avatars = {};
  final Set<String> _requestedAvatars = {};

  LdPermissionState _permission = LdPermissionState.notDetermined;
  bool _loading = true;
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
    if (state == AppLifecycleState.resumed) {
      _refresh(request: false);
    }
  }

  Future<void> _init() async {
    if (!_controller.services.contacts.isSupported) {
      if (mounted) {
        setState(() => _loading = false);
      }
      return;
    }
    await _refresh(request: true);
  }

  /// Resolves the permission and (when granted) loads contacts.
  ///
  /// [request] prompts when the user has not been asked yet; passing false
  /// re-checks silently, e.g. after returning from the system settings.
  Future<void> _refresh({required bool request}) async {
    setState(() => _loading = _contacts.isEmpty);
    try {
      final permission = request
          ? await _controller.services.contacts.requestPermission()
          : await _controller.services.contacts.permissionState();
      if (!mounted) {
        return;
      }
      _permission = permission;
      if (permission == LdPermissionState.authorized ||
          permission == LdPermissionState.limited) {
        final contacts = await _controller.services.contacts.loadContacts();
        if (!mounted) {
          return;
        }
        _contacts
          ..clear()
          ..addAll(contacts);
      }
    } catch (error, stackTrace) {
      debugPrint('LdContactsTab: failed to load contacts: $error\n$stackTrace');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final contacts = await _controller.services.contacts.loadContacts(
          query: query.trim().isEmpty ? null : query.trim(),
        );
        if (!mounted) {
          return;
        }
        setState(() {
          _contacts
            ..clear()
            ..addAll(contacts);
        });
      } catch (error, stackTrace) {
        debugPrint('LdContactsTab: search failed: $error\n$stackTrace');
      }
    });
  }

  Future<void> _loadAvatar(LdContactEntry contact) async {
    if (_requestedAvatars.contains(contact.id)) {
      return;
    }
    _requestedAvatars.add(contact.id);
    try {
      final bytes = await _controller.services.contacts.avatar(contact);
      if (!mounted) {
        return;
      }
      if (bytes != null && bytes.isNotEmpty) {
        setState(() => _avatars[contact.id] = Uint8List.fromList(bytes));
      }
    } catch (error, stackTrace) {
      debugPrint('LdContactsTab: failed to load avatar: $error\n$stackTrace');
    }
  }

  void _sendContact(LdContactEntry contact) {
    _controller.handleTap(
      LdPickedAttachment(
        id: 'contact:${contact.id}',
        kind: LdAttachmentKind.contact,
        name: contact.displayName,
        contact: contact,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labels = _controller.labels;

    if (!_controller.services.contacts.isSupported) {
      return LdAttachmentEmptyState(
        icon: LucideIcons.users,
        message: labels.noContacts,
      );
    }

    if (_loading) {
      return const Center(child: LdLoader());
    }

    if (_permission != LdPermissionState.authorized &&
        _permission != LdPermissionState.limited) {
      return LdAttachmentPermissionPrompt(
        icon: LucideIcons.users,
        message: labels.contactsDenied,
        actionLabel: labels.allowAccess,
        onAction: () => _refresh(request: true),
      );
    }

    return LdAppBar(
      title: Text(labels.contacts),
      searchConfig: LdSearchConfig(
        hint: labels.searchContacts,
        onSearch: _onSearchChanged,
      ),
      child: switch (_contacts.isEmpty) {
        true => LdScaffoldBodyCentered(
          child: LdAttachmentEmptyState(
            icon: LucideIcons.users,
            message: labels.noContacts,
          ),
        ),
        false => LdScaffoldBody(
          itemBuilder: (context, index) => _buildContactItem(_contacts[index]),
          itemCount: _contacts.length,
        ),
      },
    );
  }

  Widget _buildContactItem(LdContactEntry contact) {
    final selected = _controller.isSelected('contact:${contact.id}');
    _loadAvatar(contact);
    final avatar = _avatars[contact.id];

    return LdListItem(
      active: selected,
      leading: avatar == null
          ? LdAvatar(
              circular: true,
              child: LdText.ls(ldInitialsFromName(contact.displayName)),
            )
          : ClipOval(
              child: SizedBox(
                width: 38,
                height: 38,
                child: Image.memory(avatar, fit: BoxFit.cover),
              ),
            ),
      title: LdText.l(
        contact.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: _contactSubtitle(contact),
      trailing: selected ? const Icon(LucideIcons.circleCheck) : null,
      onPressed: () => _sendContact(contact),
    );
  }

  Widget? _contactSubtitle(LdContactEntry contact) {
    final value = contact.phoneNumbers.isNotEmpty
        ? contact.phoneNumbers.first
        : contact.email;
    if (value == null) {
      return null;
    }
    return LdText.ps(value, maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}
