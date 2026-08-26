---
name: liquid_flutter_reactive_forms-forms
description: Use when building forms with Liquid Flutter — covers LdForm, reactive form field widgets (LdFormInput, LdFormCheckbox, LdFormChoose, LdFormDatePicker, etc.), field validation, conflict resolution, and save-mode patterns.
---

# Liquid Flutter Reactive Forms

`liquid_flutter_reactive_forms` bridges the `reactive_forms` package with Liquid Flutter's design system. It provides ready-made field widgets, the `LdForm` master-detail orchestrator, field-conflict resolution, and save-mode logic.

## Import

```dart
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart';
```

---

## Form field widgets

All field widgets must live inside a `ReactiveForm` or `LdForm`. They bind to their `FormControl` by `formKey`.

### `LdFormInput<T>`

Text input. Auto-selects the right `ControlValueAccessor` for `int`, `double`, `DateTime`, `TimeOfDay`.

```dart
LdFormInput<String>(
  formKey: 'name',
  hint: 'Enter your name',
  label: 'Name',              // optional
  maxLines: 1,                // default 1; null = unbounded
  size: LdSize.m,
  disabled: false,
)
```

### `LdFormCheckbox`

```dart
LdFormCheckbox(
  formKey: 'agreed',
  label: 'I agree to the terms',
)
```

### `LdFormChoose<T>`

Static-list choose (single or multi-select).

```dart
LdFormChoose<String>(
  formKey: 'role',
  items: [
    LdSelectItem(value: 'admin', label: Text('Admin')),
    LdSelectItem(value: 'viewer', label: Text('Viewer')),
  ],
  label: 'Role',
  multiple: false,       // true = multi-select (binds FormControl<Set<T>>)
  allowEmpty: false,
  mode: LdChooseMode.auto,
)
```

### `LdFormChooseFromList<T extends Identifiable<IdType>, IdType>`

Choose backed by an in-memory list of `Identifiable` entities. Binds `FormControl<Set<IdType>>`.

```dart
LdFormChooseFromList<User, String>(
  formKey: 'assignees',
  items: users,
  selectedItemBuilder: (context, user) => Text(user.name),
  multiple: true,
  searchText: (user) => user.name,
)
```

### `LdFormChooseRepository<T extends Identifiable<IdType>, IdType>`

Like `LdFormChooseFromList` but backed by a `LdListController` (paginated server data). Adds `filtersBuilder`, `sortOptionsBuilder`, `filterChipConfigs`.

### `LdFormDatePicker`

```dart
LdFormDatePicker(
  formKey: 'dueDate',
  label: 'Due Date',
)
```

### `LdFormDurationPicker`

Binds `FormControl<LdDuration>`.

```dart
LdFormDurationPicker(
  formKey: 'timeout',
  label: 'Timeout',
  config: const LdDurationConfig.timer(),
)
```

### `LdFormSlider`

```dart
LdFormSlider(
  formKey: 'priority',
  label: 'Priority',
  min: 0,
  max: 10,
  step: 1,
)
```

### `LdFormEmojiPicker`

```dart
LdFormEmojiPicker(
  formKey: 'icon',
  label: 'Icon',
)
```

---

## Defining form items

`LdReactiveFormItem<TModel>` is a pure model descriptor for a `FormControl` — no widget concerns.

```dart
final formItems = [
  LdReactiveFormItem<String>(
    key: 'name',
    validators: [Validators.required, Validators.maxLength(100)],
  ),
  LdReactiveFormItem<bool>(
    key: 'active',
    initialValue: true,
  ),
  LdReactiveFormItem.forInt(key: 'count'),
  LdReactiveFormItem.forDouble(key: 'price'),
  LdReactiveFormItem.forDateTime(key: 'dueDate'),
];
```

---

## Validation

```dart
// Default messages are provided for: required, email, minLength, maxLength,
// mustMatch, requiredTrue, equals.
// Merge custom messages on top:
ldMergeReactiveFormValidationMessages({
  'myCustomRule': (error) => 'Custom error: ${error['value']}',
})

// Set validators
LdFormSetValidators.equals<String>({'a', 'b'})  // validator for Set<T> controls

// Error visibility predicate (used internally; shows errors when dirty+touched+invalid):
ldReactiveFormShowErrors
```

---

## LdForm — Master-detail edit/create orchestrator

`LdForm` is the primary widget for master-detail edit and create flows. It handles:
- Loading the current entity detail
- Populating a `FormGroup` from the detail
- Saving via `formToUpdatePayload` / `formToCreatePayload`
- Detecting and resolving field conflicts (optimistic concurrency)
- Navigation guards (blocks routing away with dirty, unsaved changes)
- Multiple save modes: blur, manual, adaptive, custom

```dart
LdForm<User, String, UserDetail, CreateUserDto, UpdateUserDto>(
  item: paginatorItem,          // null in create mode
  mode: LdFormMode.edit,        // or LdFormMode.create
  formItems: formItems,         // list of LdReactiveFormItem
  detailToFormValues: (detail) => {
    'name': detail.name,
    'active': detail.active,
  },
  itemToDetail: (context, user) async {
    return await context.read<UserService>().getDetail(user!.id);
  },
  formToUpdatePayload: (form, detail) {
    return UpdateUserDto(
      name: form.control('name').value as String,
      active: form.control('active').value as bool,
    );
  },
  saveMode: LdReactiveFormSaveMode.adaptive,
  child: LdAutoSpace(
    children: [
      LdFormInput<String>(formKey: 'name', hint: 'Name', label: 'Name'),
      LdFormCheckbox(formKey: 'active', label: 'Active'),
      LdFormSubmitButton(),    // reads LdFormState automatically
    ],
  ),
)
```

### Create mode

```dart
LdForm<User, String, UserDetail, CreateUserDto, UpdateUserDto>(
  item: null,
  mode: LdFormMode.create,
  formToCreatePayload: (form, detail) {
    return CreateUserDto(name: form.control('name').value as String);
  },
  itemToDetail: (context, _) async => UserDetail.empty(),
  onSubmitted: (context, created) {
    // navigate away or show success
  },
  // ...other required params
)
```

### Reading form state

`LdFormState` is provided via `Provider` inside `LdForm`. Read it in descendant widgets:

```dart
final state = context.watch<LdFormState>();
final isSaving = state.isSaving;
final hasConflicts = state.hasConflicts;

// Trigger save/reset programmatically:
await state.onSubmit();
state.onReset();
```

### Pre-built buttons

```dart
LdFormSubmitButton()   // automatically disabled while saving or when invalid
LdFormResetButton()    // resets the form to its last loaded state
```

### Field conflicts (optimistic concurrency)

When a server returns a newer version of the record while the user has unsaved edits, throw `LdFormConflictException` from your payload builder to trigger automatic merge:

```dart
formToUpdatePayload: (form, detail) {
  if (serverVersionIsNewer) {
    throw LdFormConflictException.detail(serverDetail);
    // or: throw LdFormConflictException.fields({'name': serverValue});
  }
  return UpdateUserDto(...);
}
```

Configure how conflicts are resolved:

```dart
LdForm(
  conflictPolicy: LdMonkeyFieldConflictPolicy.prompt,  // prompt user
  onFieldConflict: (context, conflict) async {
    // Show custom UI; return LdMonkeyFieldConflictResolution.keepLocal or .preferServer
    return LdMonkeyFieldConflictResolution.keepLocal;
  },
)
```

### Save modes

| Mode | Behaviour |
|---|---|
| `LdReactiveFormSaveMode.onBlur` | Auto-saves when a field loses focus |
| `LdReactiveFormSaveMode.manualSubmit` | Only saves on explicit submit |
| `LdReactiveFormSaveMode.adaptive` | `onBlur` on desktop, `manualSubmit` on mobile (default) |
| `LdReactiveFormSaveMode.custom` | You call `state.onSubmit()` / `state.onFieldBlurred(key)` yourself |

---

## Simple reactive form (without LdForm)

For lightweight forms that don't need master-detail loading or conflict resolution, use `ReactiveForm` from `reactive_forms` directly:

```dart
final form = fb.group({
  'email': ['', Validators.required, Validators.email],
  'password': ['', Validators.required, Validators.minLength(8)],
});

ReactiveForm(
  formGroup: form,
  child: LdAutoSpace(
    children: [
      LdFormInput<String>(formKey: 'email', hint: 'Email', label: 'Email'),
      LdFormInput<String>(
        formKey: 'password',
        hint: 'Password',
        label: 'Password',
        validationMessages: ldMergeReactiveFormValidationMessages({
          'minLength': (_) => 'At least 8 characters',
        }),
      ),
      LdButton(
        child: const Text('Submit'),
        onPressed: () {
          if (form.valid) submit(form.value);
        },
      ),
    ],
  ),
)
```

---

## Best practices

1. **Prefer `LdForm`** for master-detail edit/create pages — it handles loading, saving, conflicts, and navigation guards automatically.
2. **Use `LdReactiveFormItem`** to centralize validators and initial values, separate from widget code.
3. **Throw `LdFormConflictException`** from payload builders to trigger automatic merge — do not resolve conflicts manually in the action.
4. **Use `LdFormMode.adaptive`** save mode unless you have a specific reason to force manual or blur-only saves.
5. **Always provide `ldLocationLockRedirect`** (or `ldComposeGoRouterRedirects`) in your router so `LdForm`'s dirty-form guard blocks accidental navigation.
