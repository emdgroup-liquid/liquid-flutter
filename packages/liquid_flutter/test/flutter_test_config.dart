import 'dart:async';

import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await setupGoldenTest();

  await testMain();
}
