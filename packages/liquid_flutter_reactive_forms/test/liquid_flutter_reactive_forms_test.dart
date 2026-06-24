import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart';

Widget _wrapWithMaterialApp(Widget widget) {
  return MaterialApp(
    localizationsDelegates: const [
      LiquidLocalizations.delegate,
    ],
    home: Scaffold(
      body: LdThemeProvider(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Container(child: widget),
        ),
      ),
    ),
  );
}

void main() {
  group('LdFormSubmitConfig', () {
    test('creates a copy with action', () {
      final config = LdFormSubmitConfig(
        loadingText: 'Loading...',
        submitText: 'Submit',
        allowResubmit: true,
        withHaptics: false,
        autoTrigger: true,
        timeout: const Duration(seconds: 5),
        allowCancel: true,
      );

      var actionResult = '';
      final configWithAction = config.copyWithAction((_) async {
        actionResult = 'Action executed';
      });

      expect(configWithAction.loadingText, equals('Loading...'));
      expect(configWithAction.submitText, equals('Submit'));
      expect(configWithAction.allowResubmit, isTrue);
      expect(configWithAction.withHaptics, isFalse);
      expect(configWithAction.autoTrigger, isTrue);
      expect(configWithAction.timeout, equals(const Duration(seconds: 5)));
      expect(configWithAction.allowCancel, isTrue);

      configWithAction.action(null);
      expect(actionResult, equals('Action executed'));
    });
  });

  group('LdReactiveForm', () {
    testWidgets('renders form items correctly', (WidgetTester tester) async {
      final formItems = [
        LdReactiveFormItem.input<String>(
          key: 'name',
          inputFieldHint: 'Enter your name',
          label: 'Name',
        ),
        LdReactiveFormItem.checkbox(
          key: 'terms',
          label: 'Accept Terms',
        ),
      ];

      await tester.pumpWidget(
        _wrapWithMaterialApp(
          LdReactiveForm(
            items: formItems,
            onSubmit: (form) async {},
          ),
        ),
      );

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Enter your name'), findsOneWidget);
      expect(find.text('Accept Terms'), findsOneWidget);
      expect(find.byType(LdInput), findsOneWidget);
      expect(find.byType(LdCheckbox), findsOneWidget);
      expect(find.byType(LdSubmit<void, void>), findsOneWidget);
    });

    testWidgets('form validation works', (WidgetTester tester) async {
      final formItems = [
        LdReactiveFormItem.input<String>(
          key: 'email',
          inputFieldHint: 'Enter your email',
          label: 'Email',
          validators: [LdFormValidators.required, LdFormValidators.email],
          validationMessages: {
            'required': (error) => 'Email is required',
            'email': (error) => 'Invalid email format',
          },
        ),
      ];

      await tester.pumpWidget(
        _wrapWithMaterialApp(
          LdReactiveForm(
            items: formItems,
            onSubmit: (form) async {},
          ),
        ),
      );

      final submitButton = find.byType(LdButton);
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);

      await tester.enterText(find.byType(LdInput), 'not-an-email');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Invalid email format'), findsOneWidget);

      await tester.enterText(find.byType(LdInput), 'test@example.com');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Invalid email format'), findsNothing);
      expect(find.text('Email is required'), findsNothing);
    });

    testWidgets('onSubmit is called with valid form', (WidgetTester tester) async {
      var onSubmitCalled = false;
      final formItems = [
        LdReactiveFormItem.input<String>(
          key: 'name',
          inputFieldHint: 'Enter your name',
          initialValue: 'John Doe',
        ),
      ];

      await tester.pumpWidget(
        _wrapWithMaterialApp(
          LdReactiveForm(
            items: formItems,
            onSubmit: (form) async {
              onSubmitCalled = true;
            },
          ),
        ),
      );

      final submitButton = find.byType(LdButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(onSubmitCalled, isTrue);
    });

    testWidgets('form is disabled during submission', (WidgetTester tester) async {
      final formItems = [
        LdReactiveFormItem.input<String>(
          key: 'name',
          inputFieldHint: 'Enter your name',
          initialValue: 'John Doe',
        ),
      ];

      await tester.pumpWidget(
        _wrapWithMaterialApp(
          LdReactiveForm(
            items: formItems,
            onSubmit: (form) async {
              await Future<void>.delayed(const Duration(milliseconds: 500));
            },
            submitConfig: LdFormSubmitConfig(
              loadingText: 'Submitting...',
            ),
          ),
        ),
      );

      final submitButton = find.byType(LdButton);
      await tester.tap(submitButton);
      await tester.pump();

      expect(find.text('Submitting...'), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('custom submit button appears correctly', (WidgetTester tester) async {
      final formItems = [
        LdReactiveFormItem.input<String>(
          key: 'name',
          inputFieldHint: 'Enter your name',
        ),
      ];

      await tester.pumpWidget(
        _wrapWithMaterialApp(
          LdReactiveForm(
            items: formItems,
            onSubmit: (form) async {},
            submitBuilder: (context, form, child) {
              return LdButton(
                onPressed: () async {},
                disabled: form.disabled,
                child: const Text('Custom Submit'),
              );
            },
          ),
        ),
      );

      expect(find.text('Custom Submit'), findsOneWidget);
    });

    testWidgets('form validators are applied', (WidgetTester tester) async {
      final formItems = [
        LdReactiveFormItem.input<String>(
          key: 'username',
          inputFieldHint: 'Username',
          initialValue: 'user1',
        ),
        LdReactiveFormItem.input<String>(
          key: 'password',
          inputFieldHint: 'Password',
          initialValue: 'pass',
        ),
      ];

      final formValidator = LdFormValidators.mustMatch(
        'username',
        'password',
      );

      var onSubmitCalled = false;

      await tester.pumpWidget(
        _wrapWithMaterialApp(
          LdReactiveForm(
            items: formItems,
            validators: [formValidator],
            validationMessages: {
              'mustMatch': (error) => 'Username and password must not match',
            },
            onSubmit: (form) async {
              onSubmitCalled = true;
            },
          ),
        ),
      );

      final submitButton = find.byType(LdButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Username and password must not match'), findsOneWidget);
      expect(onSubmitCalled, isFalse);

      await tester.enterText(find.byType(LdInput).first, 'same');
      await tester.enterText(find.byType(LdInput).last, 'same');

      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(onSubmitCalled, isTrue);
    });
  });
}
