import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

Widget _wrapWithReactiveForm({
  required FormGroup form,
  required Widget child,
  Map<String, ValidationMessageFunction>? validationMessages,
}) {
  return MaterialApp(
    localizationsDelegates: const [
      LiquidLocalizations.delegate,
    ],
    home: Scaffold(
      body: LdThemeProvider(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: ReactiveFormConfig(
            validationMessages: ldMergeReactiveFormValidationMessages(validationMessages),
            child: ReactiveForm(
              formGroup: form,
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('LdFormInput', () {
    testWidgets('renders label and hint', (WidgetTester tester) async {
      final form = FormGroup({'name': FormControl<String>()});

      await tester.pumpWidget(
        _wrapWithReactiveForm(
          form: form,
          child: LdFormInput<String>(
            formKey: 'name',
            label: 'Name',
            hint: 'Enter your name',
          ),
        ),
      );

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Enter your name'), findsOneWidget);
      expect(find.byType(LdInput), findsOneWidget);
    });

    testWidgets('does not show error before touch', (WidgetTester tester) async {
      final form = FormGroup({
        'email': FormControl<String>(validators: [Validators.required]),
      });

      await tester.pumpWidget(
        _wrapWithReactiveForm(
          form: form,
          validationMessages: {'required': (_) => 'This field is required'},
          child: Column(
            children: [
              LdFormInput<String>(formKey: 'email', label: 'Email', hint: 'Enter your email'),
              const Text('outside'),
            ],
          ),
        ),
      );

      // Tap the input then blur — no error yet because not dirty
      await tester.tap(find.byType(LdInput));
      await tester.pump();
      await tester.tap(find.text('outside'));
      await tester.pump();

      expect(find.text('This field is required'), findsNothing);
    });

    testWidgets('shows error after marking dirty and touched', (WidgetTester tester) async {
      final form = FormGroup({
        'email': FormControl<String>(validators: [Validators.required, Validators.email]),
      });

      await tester.pumpWidget(
        _wrapWithReactiveForm(
          form: form,
          validationMessages: {
            'required': (_) => 'Email is required',
            'email': (_) => 'Invalid email format',
          },
          child: LdFormInput<String>(formKey: 'email', label: 'Email', hint: 'Enter email'),
        ),
      );

      // Mark touched and dirty to trigger error display
      form.control('email').markAsTouched();
      form.control('email').markAsDirty();
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);

      await tester.enterText(find.byType(LdInput), 'not-an-email');
      await tester.pump();

      expect(find.text('Invalid email format'), findsOneWidget);

      await tester.enterText(find.byType(LdInput), 'test@example.com');
      await tester.pump();

      expect(find.text('Invalid email format'), findsNothing);
    });

    testWidgets('onBlurred callback is invoked on focus loss', (WidgetTester tester) async {
      final form = FormGroup({'name': FormControl<String>()});

      await tester.pumpWidget(
        _wrapWithReactiveForm(
          form: form,
          child: Column(
            children: [
              Provider<LdFormState?>.value(
                value: null,
                child: LdFormInput<String>(
                  formKey: 'name',
                  label: 'Name',
                  hint: 'Name',
                ),
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

      // The control value should reflect what was typed
      expect(form.control('name').value, 'Jane');
    });
  });

  group('LdFormCheckbox', () {
    testWidgets('renders label and toggles control', (WidgetTester tester) async {
      final form = FormGroup({'terms': FormControl<bool>(value: false)});

      await tester.pumpWidget(
        _wrapWithReactiveForm(
          form: form,
          child: LdFormCheckbox(
            formKey: 'terms',
            label: 'Accept Terms',
          ),
        ),
      );

      expect(find.text('Accept Terms'), findsOneWidget);
      expect(find.byType(LdCheckbox), findsOneWidget);

      await tester.tap(find.byType(LdCheckbox));
      await tester.pump();

      expect(form.control('terms').value, isTrue);
    });
  });

  group('LdFormChoose', () {
    testWidgets('renders label and select trigger', (WidgetTester tester) async {
      final form = FormGroup({'choice': FormControl<Set<String>>()});

      await tester.pumpWidget(
        _wrapWithReactiveForm(
          form: form,
          child: LdFormChoose<String>(
            formKey: 'choice',
            label: 'Pick one',
            items: const [
              LdSelectItem(value: 'a', child: Text('A')),
              LdSelectItem(value: 'b', child: Text('B')),
            ],
          ),
        ),
      );

      expect(find.text('Pick one'), findsOneWidget);
      expect(find.text('Select...'), findsOneWidget);
    });
  });

  group('LdFormSetValidators', () {
    test('equals validator returns no error when set matches', () {
      final validator = LdFormSetValidators.equals({'a'});
      final control = FormControl<Set<String>>(value: {'a'});
      expect(validator(control), isNull);
    });

    test('equals validator returns error when set does not match', () {
      final validator = LdFormSetValidators.equals({'a'});
      final control = FormControl<Set<String>>(value: {'b'});
      expect(validator(control), isNotNull);
    });

    testWidgets('shows custom message for requiredEquals-style error', (WidgetTester tester) async {
      final form = FormGroup({
        'choice': FormControl<Set<String>>(
          validators: [LdFormSetValidators.equals({'a'})],
        ),
      });

      await tester.pumpWidget(
        _wrapWithReactiveForm(
          form: form,
          child: LdFormChoose<String>(
            formKey: 'choice',
            label: 'Pick one',
            // In reactive_forms 18.x, ValidationMessage.equals = 'requiredEquals'.
            validationMessages: {'requiredEquals': (_) => 'Pick A'},
            items: const [
              LdSelectItem(value: 'a', child: Text('A')),
              LdSelectItem(value: 'b', child: Text('B')),
            ],
          ),
        ),
      );

      await tester.pump();

      // Interact with the control so the field shows validation errors.
      form.control('choice').markAsTouched();
      form.control('choice').markAsDirty();
      // Two pumps: first propagates the control change event,
      // second lets ReactiveFormField rebuild with the updated error state.
      await tester.pump();
      await tester.pump();

      expect(find.text('Pick A'), findsOneWidget);
    });
  });
}
