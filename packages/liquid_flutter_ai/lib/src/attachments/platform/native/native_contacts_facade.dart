import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;

import '../../attachment_models.dart';
import '../contacts_facade.dart';

/// Bundled [LdContactsFacade] backed by `package:flutter_contacts`.
class LdNativeContactsFacade implements LdContactsFacade {
  @override
  bool get isSupported => !kIsWeb;

  @override
  Future<LdPermissionState> permissionState() async {
    final status = await fc.FlutterContacts.permissions.check(
      fc.PermissionType.read,
    );
    return _mapPermission(status);
  }

  @override
  Future<LdPermissionState> requestPermission() async {
    final status = await fc.FlutterContacts.permissions.request(
      fc.PermissionType.read,
    );
    return _mapPermission(status);
  }

  @override
  Future<List<LdContactEntry>> loadContacts({String? query}) async {
    try {
      final contacts = await fc.FlutterContacts.getAll(
        properties: {
          fc.ContactProperty.name,
          fc.ContactProperty.phone,
          fc.ContactProperty.email,
          fc.ContactProperty.photoThumbnail,
        },
        filter: query == null || query.isEmpty
            ? null
            : fc.ContactFilter.name(query),
      );
      return contacts.map(_toEntry).toList(growable: false);
    } catch (error, stackTrace) {
      debugPrint(
        'LdNativeContactsFacade: failed to load contacts: $error\n$stackTrace',
      );
      return const [];
    }
  }

  @override
  Future<List<int>?> avatar(LdContactEntry contact) async {
    try {
      final entry = await fc.FlutterContacts.get(
        contact.id,
        properties: {fc.ContactProperty.photoThumbnail},
      );
      return entry?.photo?.thumbnail;
    } catch (error, stackTrace) {
      debugPrint(
        'LdNativeContactsFacade: failed to load avatar: $error\n$stackTrace',
      );
      return null;
    }
  }

  LdContactEntry _toEntry(fc.Contact contact) {
    return LdContactEntry(
      id: contact.id ?? contact.displayName ?? '',
      displayName: contact.displayName ?? '',
      phoneNumbers: contact.phones
          .map((phone) => phone.number)
          .where((number) => number.isNotEmpty)
          .toList(growable: false),
      email: contact.emails.isEmpty ? null : contact.emails.first.address,
    );
  }

  LdPermissionState _mapPermission(fc.PermissionStatus status) =>
      switch (status) {
        fc.PermissionStatus.granted => LdPermissionState.authorized,
        fc.PermissionStatus.limited => LdPermissionState.limited,
        fc.PermissionStatus.denied => LdPermissionState.denied,
        fc.PermissionStatus.permanentlyDenied => LdPermissionState.restricted,
        fc.PermissionStatus.restricted => LdPermissionState.restricted,
        fc.PermissionStatus.notDetermined => LdPermissionState.notDetermined,
      };
}
