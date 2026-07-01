import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

enum LdAppBarImpliedFeature { back, close, windowControls, drawerToggle }

extension LdAppBarImpliedFeaturesExtension on LdAppBarImpliedFeature {
  bool shownByParent(
    BuildContext context,
  ) {
    return context.watch<LdAppBarImpliedFeatures?>()?.features.contains(this) ?? false;
  }
}

class LdAppBarImpliedFeatures {
  Set<LdAppBarImpliedFeature> features;
  LdAppBarImpliedFeatures({
    this.features = const {},
  });

  LdAppBarImpliedFeatures copyWith({
    Set<LdAppBarImpliedFeature>? features,
  }) {
    return LdAppBarImpliedFeatures(
      features: features ?? this.features,
    );
  }
}
