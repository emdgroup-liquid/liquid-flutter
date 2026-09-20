import 'attachment_models.dart';

/// User-facing strings for [LdAttachmentPicker].
///
/// Kept as a plain object (rather than a localization delegate) so the package
/// stays self-contained and host apps can override any string, or localize it
/// themselves.
class LdAttachmentPickerLabels {
  final String title;
  final String recents;
  final String gallery;
  final String file;
  final String location;
  final String contacts;
  final String camera;
  final String selectFromGallery;
  final String selectFromFiles;
  final String scanDocument;
  final String recentlySentFiles;
  final String sendCurrentLocation;
  final String chooseAPlace;
  final String manage;
  final String limitedAccessMessage;
  final String allowAccess;
  final String selectMorePhotos;
  final String changeSettings;
  final String openSettings;
  final String searchContacts;
  final String searchPlaces;
  final String send;
  final String cancel;
  final String noRecentFiles;
  final String noContacts;
  final String noPlaces;
  final String noPhotos;
  final String photosDenied;
  final String cameraUnavailable;
  final String locationUnavailable;
  final String contactsDenied;
  final String accuracy;
  final String noSources;

  const LdAttachmentPickerLabels({
    this.title = 'Attach',
    this.recents = 'Recents',
    this.gallery = 'Gallery',
    this.file = 'File',
    this.location = 'Location',
    this.contacts = 'Contacts',
    this.camera = 'Camera',
    this.selectFromGallery = 'Select from Gallery',
    this.selectFromFiles = 'Select from Files',
    this.scanDocument = 'Scan Document',
    this.recentlySentFiles = 'RECENTLY SENT FILES',
    this.sendCurrentLocation = 'Send My Current Location',
    this.chooseAPlace = 'OR CHOOSE A PLACE',
    this.manage = 'MANAGE',
    this.limitedAccessMessage = 'You have limited access to your photos.',
    this.allowAccess = 'Allow access',
    this.selectMorePhotos = 'Select more photos',
    this.changeSettings = 'Change settings',
    this.openSettings = 'Open settings',
    this.searchContacts = 'Search contacts',
    this.searchPlaces = 'Search places',
    this.send = 'Send',
    this.cancel = 'Cancel',
    this.noRecentFiles = 'No recently sent files',
    this.noContacts = 'No contacts found',
    this.noPlaces = 'No places found',
    this.noPhotos = 'No photos or videos',
    this.photosDenied = 'Allow access to your photos to attach them.',
    this.cameraUnavailable = 'Camera is not available on this device.',
    this.locationUnavailable = 'Location is not available.',
    this.contactsDenied = 'Allow access to your contacts to attach them.',
    this.accuracy = 'Accuracy',
    this.noSources = 'No attachment sources are available on this device.',
  });

  /// A human readable label for a tab.
  String tabLabel(LdAttachmentTab tab) => switch (tab) {
    LdAttachmentTab.gallery => gallery,
    LdAttachmentTab.file => file,
    LdAttachmentTab.location => location,
    LdAttachmentTab.contacts => contacts,
  };

  LdAttachmentPickerLabels copyWith({
    String? title,
    String? recents,
    String? gallery,
    String? file,
    String? location,
    String? contacts,
    String? camera,
    String? selectFromGallery,
    String? selectFromFiles,
    String? scanDocument,
    String? recentlySentFiles,
    String? sendCurrentLocation,
    String? chooseAPlace,
    String? manage,
    String? limitedAccessMessage,
    String? allowAccess,
    String? selectMorePhotos,
    String? changeSettings,
    String? openSettings,
    String? searchContacts,
    String? searchPlaces,
    String? send,
    String? cancel,
    String? noRecentFiles,
    String? noContacts,
    String? noPlaces,
    String? noPhotos,
    String? photosDenied,
    String? cameraUnavailable,
    String? locationUnavailable,
    String? contactsDenied,
    String? accuracy,
    String? noSources,
  }) {
    return LdAttachmentPickerLabels(
      title: title ?? this.title,
      recents: recents ?? this.recents,
      gallery: gallery ?? this.gallery,
      file: file ?? this.file,
      location: location ?? this.location,
      contacts: contacts ?? this.contacts,
      camera: camera ?? this.camera,
      selectFromGallery: selectFromGallery ?? this.selectFromGallery,
      selectFromFiles: selectFromFiles ?? this.selectFromFiles,
      scanDocument: scanDocument ?? this.scanDocument,
      recentlySentFiles: recentlySentFiles ?? this.recentlySentFiles,
      sendCurrentLocation: sendCurrentLocation ?? this.sendCurrentLocation,
      chooseAPlace: chooseAPlace ?? this.chooseAPlace,
      manage: manage ?? this.manage,
      limitedAccessMessage: limitedAccessMessage ?? this.limitedAccessMessage,
      allowAccess: allowAccess ?? this.allowAccess,
      selectMorePhotos: selectMorePhotos ?? this.selectMorePhotos,
      changeSettings: changeSettings ?? this.changeSettings,
      openSettings: openSettings ?? this.openSettings,
      searchContacts: searchContacts ?? this.searchContacts,
      searchPlaces: searchPlaces ?? this.searchPlaces,
      send: send ?? this.send,
      cancel: cancel ?? this.cancel,
      noRecentFiles: noRecentFiles ?? this.noRecentFiles,
      noContacts: noContacts ?? this.noContacts,
      noPlaces: noPlaces ?? this.noPlaces,
      noPhotos: noPhotos ?? this.noPhotos,
      photosDenied: photosDenied ?? this.photosDenied,
      cameraUnavailable: cameraUnavailable ?? this.cameraUnavailable,
      locationUnavailable: locationUnavailable ?? this.locationUnavailable,
      contactsDenied: contactsDenied ?? this.contactsDenied,
      accuracy: accuracy ?? this.accuracy,
      noSources: noSources ?? this.noSources,
    );
  }
}
