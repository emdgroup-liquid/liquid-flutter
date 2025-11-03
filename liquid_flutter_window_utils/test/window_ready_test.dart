import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter_window_utils/liquid_flutter_window_utils.dart';

void main() {
  group('Window Ready API Tests', () {
    test('windowReadyStream should be available', () {
      final windowUtils = LiquidFlutterWindowUtils.instance;
      expect(windowUtils.windowReadyStream, isNotNull);
    });

    test('windowReadyStream should emit events', () async {
      final windowUtils = LiquidFlutterWindowUtils.instance;
      bool receivedEvent = false;

      // Listen to the stream
      final subscription = windowUtils.windowReadyStream.listen((isReady) {
        if (isReady) {
          receivedEvent = true;
        }
      });

      // Wait a bit to see if any events are emitted
      await Future.delayed(Duration(milliseconds: 100));

      // Note: This test might not receive events in a test environment
      // but it verifies the API is properly set up
      subscription.cancel();

      // The test passes if no exceptions are thrown
      expect(receivedEvent, isTrue);
    });
  });
}
