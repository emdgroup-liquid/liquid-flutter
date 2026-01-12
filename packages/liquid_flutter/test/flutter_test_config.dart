import 'dart:async';

import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';

const _kGoldenTestsThreshold = 7 / 100;

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await setupGoldenTest(
    fileComparatorThreshold: _kGoldenTestsThreshold,
  );

  await testMain();
}
