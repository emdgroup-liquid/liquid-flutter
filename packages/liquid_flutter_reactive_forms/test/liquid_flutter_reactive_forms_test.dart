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

    testWidgets('does not show errors on focus without edits', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          Column(
            children: [
              LdReactiveForm(
                items: [
                  LdReactiveFormItem.input<String>(
                    key: 'email',
                    inputFieldHint: 'Enter your email',
                    label: 'Email',
                    validators: [LdFormValidators.required],
                  ),
                ],
                onSubmit: (form) async {},
              ),
              const Text('outside'),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(LdInput));
      await tester.pump();
      await tester.tap(find.text('outside'));
      await tester.pump();

      expect(find.text('This field is required'), findsNothing);
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

    testWidgets('hides submit button when showSubmitButton is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          LdReactiveForm(
            showSubmitButton: false,
            items: [
              LdReactiveFormItem.input<String>(
                key: 'name',
                inputFieldHint: 'Name',
              ),
            ],
            onSubmit: (form) async {},
          ),
        ),
      );

      expect(find.byType(LdSubmit<void, void>), findsNothing);
    });

    testWidgets('exposes form group via LdReactiveFormScope', (WidgetTester tester) async {
      LdFormGroup? scopedForm;

      await tester.pumpWidget(
        _wrapWithMaterialApp(
          Builder(
            builder: (context) {
              return LdReactiveForm(
                items: [
                  LdReactiveFormItem.input<String>(
                    key: 'name',
                    inputFieldHint: 'Name',
                  ),
                ],
                onSubmit: (form) async {},
                submitBuilder: (context, form, child) {
                  scopedForm = LdReactiveFormScope.of(context);
                  return LdButton(
                    onPressed: () async {},
                    child: const Text('Submit'),
                  );
                },
              );
            },
          ),
        ),
      );

      expect(scopedForm, isNotNull);
      expect(scopedForm!.contains('name'), isTrue);
    });

    testWidgets('input onBlurred is called and marks control touched', (WidgetTester tester) async {
      var blurredValue = '';
      final formItems = [
        LdReactiveFormItem.input<String>(
          key: 'name',
          inputFieldHint: 'Name',
          onBlurred: (value) => blurredValue = value,
        ),
      ];

      await tester.pumpWidget(
        _wrapWithMaterialApp(
          Column(
            children: [
              LdReactiveForm(
                items: formItems,
                onSubmit: (form) async {},
              ),
              const Text('outside'),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(LdInput));
      await tester.pump();
      await tester.enterText(find.byType(LdInput), 'Jane');
      await tester.tap(find.text('outside'));
      await tester.pump();

      expect(blurredValue, 'Jane');
    });

    testWidgets('shows requiredEquals message for equals validator', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          LdReactiveForm(
            items: [
              LdReactiveFormItem.chooseFromItems<String>(
                key: 'choice',
                label: 'Pick one',
                items: const [
                  LdSelectItem(value: 'a', child: Text('A')),
                  LdSelectItem(value: 'b', child: Text('B')),
                ],
                validators: [LdFormSetValidators.equals({'a'})],
                validationMessages: {
                  'requiredEquals': (error) => 'Pick A',
                },
              ),
            ],
            onSubmit: (form) async {},
          ),
        ),
      );

      await tester.tap(find.byType(LdButton));
      await tester.pumpAndSettle();

      expect(find.text('Pick A'), findsOneWidget);
      expect(find.text('requiredEquals'), findsNothing);
    });

    testWidgets('chooseFromItems renders LdChoose trigger', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          LdReactiveForm(
            items: [
              LdReactiveFormItem.chooseFromItems<String>(
                key: 'choice',
                label: 'Pick one',
                items: const [
                  LdSelectItem(value: 'a', child: Text('A')),
                  LdSelectItem(value: 'b', child: Text('B')),
                ],
              ),
            ],
            onSubmit: (form) async {},
          ),
        ),
      );

      expect(find.text('Pick one'), findsOneWidget);
      expect(find.text('Select...'), findsOneWidget);
    });
  });
}
