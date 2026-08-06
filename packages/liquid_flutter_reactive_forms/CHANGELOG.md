## 0.1.1-4
Released on: 8/6/2026, changelog automatically generated.

### API Changes

#### 💣 Breaking changes

**`class` LdForm<T extends Identifiable<IdType>, IdType, TDetail extends Object, TCreate, TUpdate>** ([lib/src/monkey_detail/detail_form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-3..liquid_flutter_reactive_forms/v0.1.1-4#diff-89b4bb66eebde2fa45d4db603df7a31fd895700872ef73e55f84ea3817c3a2b9))
- ❌ Param removed in default constructor: `formItems` (named, required)
- ❇️ Param added in default constructor: `formGroup` (named, required)
- ❌ Property removed: `formItems`

**`class` LdFormSlider** ([lib/src/form_widgets/ld_form_slider.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-3..liquid_flutter_reactive_forms/v0.1.1-4#diff-011cfbace12dcdece6e8cd2815c4101180c89e2bdf4fb054fe2d9283b70704ae))
- 🔄 Param type changed in default constructor: `hintBuilder` (`LdHint? Function(ReactiveFormFieldState<double, double>)?` → `LdHint? Function(ReactiveFormFieldState<num, num>)?`)
- 🔄 Property type changed: `hintBuilder`

**`class` LdReactiveFormItem<TModel>** ([lib/src/reactive_form_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-3..liquid_flutter_reactive_forms/v0.1.1-4#diff-fecce365ac099bcac9c05fa0ebfcf73fb2f5c141032f4ca8bbda22ed6fcc9f1f))
- ❌ Class removed: `LdReactiveFormItem`

#### ✨ Minor changes

**`class` LdForm<T extends Identifiable<IdType>, IdType, TDetail extends Object, TCreate, TUpdate>** ([lib/src/monkey_detail/detail_form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-3..liquid_flutter_reactive_forms/v0.1.1-4#diff-89b4bb66eebde2fa45d4db603df7a31fd895700872ef73e55f84ea3817c3a2b9))
- ❇️ Param added in default constructor: `onFormInit` (named, optional)
- ❇️ Properties added: `formGroup`, `onFormInit`

**`class` LdFormChooseRepository<T extends Identifiable<IdType>, IdType>** ([lib/src/form_widgets/ld_form_choose.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-3..liquid_flutter_reactive_forms/v0.1.1-4#diff-b17ff8842b55b034c0d81ca073196e99a6e00163948e3cfdaa488889073e2d22))
- ❇️ Params added in default constructor: `hint` (named, optional), `triggerBuilder` (named, optional), `truncateDisplay` (named, optional)
- ❇️ Properties added: `triggerBuilder`, `hint`, `truncateDisplay`

**`class` LdFormMarkdownEditor** ([lib/src/form_widgets/ld_form_markdown_editor.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-3..liquid_flutter_reactive_forms/v0.1.1-4#diff-7ea40be9f8fa0147df5a8492494d793d5634fd227b1d65f24607849fca9b5f8d))
- ❇️ Class added: `LdFormMarkdownEditor`

**`class` LdFormRangeSlider** ([lib/src/form_widgets/ld_form_range_slider.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-3..liquid_flutter_reactive_forms/v0.1.1-4#diff-893403c54781dd46821754dcf7d56bb775c020d271b70bf46242e62490133a92))
- ❇️ Params added in default constructor: `showValueInput` (named, optional, default: true), `valueFormatter` (named, optional)
- ❇️ Properties added: `showValueInput`, `valueFormatter`

**`class` LdFormSlider** ([lib/src/form_widgets/ld_form_slider.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-3..liquid_flutter_reactive_forms/v0.1.1-4#diff-011cfbace12dcdece6e8cd2815c4101180c89e2bdf4fb054fe2d9283b70704ae))
- ❇️ Params added in default constructor: `isInteger` (named, optional, default: false), `showValueInput` (named, optional, default: true), `size` (named, optional, default: LdSize.m), `valueFormatter` (named, optional)
- ❇️ Properties added: `isInteger`, `showValueInput`, `size`, `valueFormatter`

#### 👀 Patch changes

**`class` LdFormRangeSlider** ([lib/src/form_widgets/ld_form_range_slider.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-3..liquid_flutter_reactive_forms/v0.1.1-4#diff-893403c54781dd46821754dcf7d56bb775c020d271b70bf46242e62490133a92))
- ❇️ Property added: `_minSeparation`

**`class` _LdFormMarkdownEditorField** ([lib/src/form_widgets/ld_form_markdown_editor.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-3..liquid_flutter_reactive_forms/v0.1.1-4#diff-7ea40be9f8fa0147df5a8492494d793d5634fd227b1d65f24607849fca9b5f8d))
- ❇️ Class added: `_LdFormMarkdownEditorField`

**`class` _LdFormMarkdownEditorFieldState** ([lib/src/form_widgets/ld_form_markdown_editor.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-3..liquid_flutter_reactive_forms/v0.1.1-4#diff-7ea40be9f8fa0147df5a8492494d793d5634fd227b1d65f24607849fca9b5f8d))
- ❇️ Class added: `_LdFormMarkdownEditorFieldState`

**`class` _LdFormState<T extends Identifiable<IdType>, IdType, TDetail extends Object, TCreate, TUpdate>** ([lib/src/monkey_detail/detail_form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-3..liquid_flutter_reactive_forms/v0.1.1-4#diff-89b4bb66eebde2fa45d4db603df7a31fd895700872ef73e55f84ea3817c3a2b9))
- ❌ Modifier `final` removed from property: `_form`
- ❌ Property removed: `_loadingDetail`

**`meta` pubspec.yaml** ([pubspec.yaml](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-3..liquid_flutter_reactive_forms/v0.1.1-4#diff-8b7e9df87668ffa6a04b32e1769a33434999e54ae081c52e5d943c541d4c0d25))
- 📦 Added `liquid_flutter_md`: with version `^0.0.1`


## 0.1.1-3
Released on: 7/7/2026, changelog automatically generated.

### API Changes

#### 💣 Breaking changes

**`typedef` LdFormFieldBuilder<TModel, TView>** ([lib/src/typedefs.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-d41df30ce75b2909ffb263279ef0ccb723dfb91bf29ec247918d56debe10a746))
- ❌ Typedef removed: `LdFormFieldBuilder`

**`typedef` LdFormGroup** ([lib/src/typedefs.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-d41df30ce75b2909ffb263279ef0ccb723dfb91bf29ec247918d56debe10a746))
- ❌ Typedef removed: `LdFormGroup`

**`typedef` LdFormSubmitBuilder** ([lib/src/typedefs.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-d41df30ce75b2909ffb263279ef0ccb723dfb91bf29ec247918d56debe10a746))
- ❌ Typedef removed: `LdFormSubmitBuilder`

**`class` LdFormSubmitConfig** ([lib/src/reactive_form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-0b73714a12c90a56b0a0b2e5fc4ee1f2ad895bcebba3d56ae1125c4b4f213ccf))
- ❌ Class removed: `LdFormSubmitConfig`

**`typedef` LdFormValidator<T>** ([lib/src/typedefs.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-d41df30ce75b2909ffb263279ef0ccb723dfb91bf29ec247918d56debe10a746))
- ❌ Typedef removed: `LdFormValidator`

**`typedef` LdFormValidators** ([lib/src/typedefs.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-d41df30ce75b2909ffb263279ef0ccb723dfb91bf29ec247918d56debe10a746))
- ❌ Typedef removed: `LdFormValidators`

**`class` LdMonkeyDetailFormFieldHooks** ([lib/src/monkey_detail/ld_monkey_detail_form_field_hooks.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-65260ad979976070039f792b19476e34888bf9c03eff36d630453b8ee290a567))
- ❌ Class removed: `LdMonkeyDetailFormFieldHooks`

**`typedef` LdMonkeyDetailFormItemsBuilder** ([lib/src/monkey_detail/ld_monkey_detail_form_field_hooks.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-65260ad979976070039f792b19476e34888bf9c03eff36d630453b8ee290a567))
- ❌ Typedef removed: `LdMonkeyDetailFormItemsBuilder`

**`class` LdMonkeyDetailFormScope<TDetail>** ([lib/src/monkey_detail/ld_monkey_detail_form_scope.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-62bf549cbf336a34d2fb01070e140bbf74f9f113a920f0096adebb1844d2dbaa))
- ❌ Class removed: `LdMonkeyDetailFormScope`

**`typedef` LdMonkeyDetailFormToCreatePayload<TCreate, TDetail>** ([lib/src/monkey_detail/ld_monkey_reactive_detail_form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-6703bfe01b8395270d0a6fb1fad74d57e4772adab447674396cdc09bf90f5239))
- ❌ Typedef removed: `LdMonkeyDetailFormToCreatePayload`

**`typedef` LdMonkeyDetailFormToUpdatePayload<TUpdate, TDetail>** ([lib/src/monkey_detail/ld_monkey_reactive_detail_form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-6703bfe01b8395270d0a6fb1fad74d57e4772adab447674396cdc09bf90f5239))
- ❌ Typedef removed: `LdMonkeyDetailFormToUpdatePayload`

**`typedef` LdMonkeyDetailFormValues<TDetail>** ([lib/src/monkey_detail/ld_monkey_reactive_detail_form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-6703bfe01b8395270d0a6fb1fad74d57e4772adab447674396cdc09bf90f5239))
- ❌ Typedef removed: `LdMonkeyDetailFormValues`

**`typedef` LdMonkeyDetailFromEntity<T, TDetail>** ([lib/src/monkey_detail/ld_monkey_reactive_detail_form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-6703bfe01b8395270d0a6fb1fad74d57e4772adab447674396cdc09bf90f5239))
- ❌ Typedef removed: `LdMonkeyDetailFromEntity`

**`typedef` LdMonkeyDetailLoadDetail<TDetail, IdType>** ([lib/src/monkey_detail/ld_monkey_reactive_detail_form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-6703bfe01b8395270d0a6fb1fad74d57e4772adab447674396cdc09bf90f5239))
- ❌ Typedef removed: `LdMonkeyDetailLoadDetail`

**`typedef` LdMonkeyDetailOnCreated<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey_detail/ld_monkey_reactive_detail_form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-6703bfe01b8395270d0a6fb1fad74d57e4772adab447674396cdc09bf90f5239))
- ❌ Typedef removed: `LdMonkeyDetailOnCreated`

**`enum` LdMonkeyDetailPreSaveCheck** ([lib/src/monkey_detail/ld_monkey_detail_pre_save_check.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-efd27655fa6de3278d96ff1706dce6a6683bcdbad81c617b329c886c4024cb46))
- ❌ Enum removed: `LdMonkeyDetailPreSaveCheck`

**`enum` LdMonkeyDetailSaveMode** ([lib/src/monkey_detail/ld_monkey_detail_save_mode.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-98fded717653717c89e0a53c499d7b2dd45ff3fb86767499a3620dc3203b997b))
- ❌ Enum removed: `LdMonkeyDetailSaveMode`

**`class` LdMonkeyFieldConflict** ([lib/src/monkey_detail/ld_monkey_field_conflict.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-286a624f52ebcc6e61ddbfb0b8069d577b15d9a0d7ee1526244a1c7d21040857))
- ❌ Property removed: `label`

**`class` LdMonkeyFieldConflictHint** ([lib/src/monkey_detail/ld_monkey_field_conflict_hint.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-4afb921824255b664fe37123f731cfabf9bff7a7531870304fe1fe6bacd9525f))
- 🔄 Superclass changed: `StatelessWidget` → `StatefulWidget`
- ❌ Param removed in default constructor: `control` (named, required)
- ❇️ Params added in default constructor: `conflict` (named, required), `onPreviewResolution` (named, required)
- ❌ Properties removed: `control`, `label`
- ❌ Method removed: `build`

**`class` LdMonkeyReactiveDetailForm<T extends Identifiable<IdType>, IdType, TDetail extends Object, TCreate, TUpdate>** ([lib/src/monkey_detail/ld_monkey_reactive_detail_form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-6703bfe01b8395270d0a6fb1fad74d57e4772adab447674396cdc09bf90f5239))
- ❌ Class removed: `LdMonkeyReactiveDetailForm`

**`enum` LdMonkeyReactiveDetailFormMode** ([lib/src/monkey_detail/ld_monkey_reactive_detail_form_mode.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-84953b1bb480d70e7645b8cbee931e055cae3c45d76d5116331b50ba729d8bf1))
- ❌ Enum removed: `LdMonkeyReactiveDetailFormMode`

**`class` LdMonkeyVersionConflictException<TDetail>** ([lib/src/monkey_detail/ld_monkey_version_conflict_exception.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-663c842bea3dc82f2cb69a3503fc4b3ef1a666bbe935afacb64917ef329e3525))
- ❌ Class removed: `LdMonkeyVersionConflictException`

**`class` LdReactiveForm** ([lib/src/reactive_form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-0b73714a12c90a56b0a0b2e5fc4ee1f2ad895bcebba3d56ae1125c4b4f213ccf))
- ❌ Class removed: `LdReactiveForm`

**`typedef` LdReactiveFormFieldState<TModel, TView>** ([lib/src/typedefs.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-d41df30ce75b2909ffb263279ef0ccb723dfb91bf29ec247918d56debe10a746))
- ❌ Typedef removed: `LdReactiveFormFieldState`

**`class` LdReactiveFormItem<TModel, TView>** ([lib/src/reactive_form_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-fecce365ac099bcac9c05fa0ebfcf73fb2f5c141032f4ca8bbda22ed6fcc9f1f))
- 🔄 Type parameters changed: `TModel, TView` → `TModel`
- 🔄 Param type changed in default constructor: `valueAccessor` (`ControlValueAccessor<TModel, TView>?` → `ControlValueAccessor<TModel, dynamic>?`)
- ❌ Param removed in default constructor: `formFieldBuilder` (named, required)
- ❌ Properties removed: `label`, `formFieldBuilder`, `hintBuilder`, `validationMessages`
- 🔄 Property type changed: `valueAccessor`
- ❇️ Modifier `final` added to property: `valueAccessor`
- ❌ Methods removed: `input`, `select`, `chooseFromItems`, `multiSelect`, `chooseFromList`, `chooseRepository`, `checkbox`, `datePicker`, `slider`, `createFormField`, `buildMonkeyDetailField`

**`class` LdReactiveFormScope** ([lib/src/reactive_form_scope.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-9c9b0b197150819ce58640aeffaa9194d13acd549ac52f03d98b357a2fb31b9d))
- ❌ Class removed: `LdReactiveFormScope`

**`function` ldMonkeyMergeFormFromServer** ([lib/src/monkey_detail/ld_monkey_detail_form_merge.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-366954feef300bfd505e2a25134bf01c66daca42b8fd83911d2b380cf2fde80f))
- ❌ Function removed: `ldMonkeyMergeFormFromServer`

**`function` ldMonkeyResolveFieldConflict** ([lib/src/monkey_detail/ld_monkey_detail_form_merge.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-366954feef300bfd505e2a25134bf01c66daca42b8fd83911d2b380cf2fde80f))
- ❌ Function removed: `ldMonkeyResolveFieldConflict`

#### ✨ Minor changes

**`typedef` LdDetailToForm<TDetail>** ([lib/src/monkey_detail/detail_form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-89b4bb66eebde2fa45d4db603df7a31fd895700872ef73e55f84ea3817c3a2b9))
- ❇️ Typedef added: `LdDetailToForm`

**`class` LdForm<T extends Identifiable<IdType>, IdType, TDetail extends Object, TCreate, TUpdate>** ([lib/src/monkey_detail/detail_form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-89b4bb66eebde2fa45d4db603df7a31fd895700872ef73e55f84ea3817c3a2b9))
- ❇️ Class added: `LdForm`

**`class` LdFormCheckbox** ([lib/src/form_widgets/ld_form_checkbox.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-4f4297f8f4c5c541b5c21412531a77401ab044259f10896985e24c5b4887d02c))
- ❇️ Class added: `LdFormCheckbox`

**`class` LdFormChoose<T>** ([lib/src/form_widgets/ld_form_choose.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-b17ff8842b55b034c0d81ca073196e99a6e00163948e3cfdaa488889073e2d22))
- ❇️ Class added: `LdFormChoose`

**`class` LdFormChooseFromList<T extends Identifiable<IdType>, IdType>** ([lib/src/form_widgets/ld_form_choose.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-b17ff8842b55b034c0d81ca073196e99a6e00163948e3cfdaa488889073e2d22))
- ❇️ Class added: `LdFormChooseFromList`

**`class` LdFormChooseRepository<T extends Identifiable<IdType>, IdType>** ([lib/src/form_widgets/ld_form_choose.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-b17ff8842b55b034c0d81ca073196e99a6e00163948e3cfdaa488889073e2d22))
- ❇️ Class added: `LdFormChooseRepository`

**`class` LdFormConflictException<TDetail>** ([lib/src/monkey_detail/conflict_exception.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-bfea564dff37cc12b1093a524bc9d8422996ef23efc0ceb9b9cdd8b78f98ae9c))
- ❇️ Class added: `LdFormConflictException`

**`class` LdFormConflicts** ([lib/src/monkey_detail/form_state.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-f2049125fab094ae683281cc7fe06d10f04a1fb2728766bb29bcfaa75dcd420b))
- ❇️ Class added: `LdFormConflicts`

**`class` LdFormDatePicker** ([lib/src/form_widgets/ld_form_date_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-93a1f4effadc11b78fe11164afcc1588e128fba8c1dba693cb50229846dfecd8))
- ❇️ Class added: `LdFormDatePicker`

**`class` LdFormEmojiPicker** ([lib/src/form_widgets/ld_form_emoji_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-7694a239f1e11a6b9844d60182518c6368722364e9a4549507bc20d3c0907c63))
- ❇️ Class added: `LdFormEmojiPicker`

**`class` LdFormInput<T>** ([lib/src/form_widgets/ld_form_input.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-587f880d765bd6800e74114b32a7acbd75a7b8c3271e47f07bba62829032ae45))
- ❇️ Class added: `LdFormInput`

**`typedef` LdFormLoadDetail<TDetail, T>** ([lib/src/monkey_detail/detail_form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-89b4bb66eebde2fa45d4db603df7a31fd895700872ef73e55f84ea3817c3a2b9))
- ❇️ Typedef added: `LdFormLoadDetail`

**`enum` LdFormMode** ([lib/src/monkey_detail/form_mode.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-2eccfb75b7f8c3edc12fccbf363448444acdf8d0ee0a99a43b5458c8b855a1e0))
- ❇️ Enum added: `LdFormMode`

**`typedef` LdFormOnSubmitted<T extends Identifiable<IdType>, IdType>** ([lib/src/monkey_detail/detail_form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-89b4bb66eebde2fa45d4db603df7a31fd895700872ef73e55f84ea3817c3a2b9))
- ❇️ Typedef added: `LdFormOnSubmitted`

**`enum` LdFormPreSaveCheck** ([lib/src/monkey_detail/pre_save.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-8b3edb361e7901dfca3adb513fee8635fb9afdaa66ac1abeb93f27b3e2626152))
- ❇️ Enum added: `LdFormPreSaveCheck`

**`class` LdFormRadio<T>** ([lib/src/form_widgets/ld_form_radio.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-d95db92a5feb026f1972ba23af5b5ed389920510884ea52d4c9f7996f8eef7f3))
- ❇️ Class added: `LdFormRadio`

**`class` LdFormRangeSlider** ([lib/src/form_widgets/ld_form_range_slider.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-893403c54781dd46821754dcf7d56bb775c020d271b70bf46242e62490133a92))
- ❇️ Class added: `LdFormRangeSlider`

**`class` LdFormResetButton** ([lib/src/monkey_detail/buttons.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-0434a5673df65cdbc36541f53e7b0423d0b677a82a2819f4102320ddcce47c09))
- ❇️ Class added: `LdFormResetButton`

**`class` LdFormSelect<T>** ([lib/src/form_widgets/ld_form_select.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-4bf650aec6818bb190e3a4381833eed3d40c1eeb30c752a82a1b7ea7f4d92933))
- ❇️ Class added: `LdFormSelect`

**`class` LdFormSlider** ([lib/src/form_widgets/ld_form_slider.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-011cfbace12dcdece6e8cd2815c4101180c89e2bdf4fb054fe2d9283b70704ae))
- ❇️ Class added: `LdFormSlider`

**`class` LdFormState** ([lib/src/monkey_detail/form_state.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-f2049125fab094ae683281cc7fe06d10f04a1fb2728766bb29bcfaa75dcd420b))
- ❇️ Class added: `LdFormState`

**`class` LdFormSubmitButton** ([lib/src/monkey_detail/buttons.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-0434a5673df65cdbc36541f53e7b0423d0b677a82a2819f4102320ddcce47c09))
- ❇️ Class added: `LdFormSubmitButton`

**`class` LdFormSwitch<T>** ([lib/src/form_widgets/ld_form_switch.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-97082a214871d8533000a297ebb3fd822056ebd45017e3b910db5b31a5e0fa4e))
- ❇️ Class added: `LdFormSwitch`

**`class` LdFormTimePicker** ([lib/src/form_widgets/ld_form_time_picker.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-e57b7a06055742465e82d0d337afbada998dcfe8e9e8e218391b915fe43e3a2a))
- ❇️ Class added: `LdFormTimePicker`

**`typedef` LdFormToCreatePayload<TCreate, TDetail>** ([lib/src/monkey_detail/detail_form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-89b4bb66eebde2fa45d4db603df7a31fd895700872ef73e55f84ea3817c3a2b9))
- ❇️ Typedef added: `LdFormToCreatePayload`

**`typedef` LdFormToUpdatePayload<TUpdate, TDetail>** ([lib/src/monkey_detail/detail_form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-89b4bb66eebde2fa45d4db603df7a31fd895700872ef73e55f84ea3817c3a2b9))
- ❇️ Typedef added: `LdFormToUpdatePayload`

**`class` LdFormToggle** ([lib/src/form_widgets/ld_form_toggle.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-c20c7ad8568b7117b170f31ca642d10f1a58fd2445d23d4c62ab0c5330d2dbdd))
- ❇️ Class added: `LdFormToggle`

**`class` LdMonkeyFieldConflict** ([lib/src/monkey_detail/ld_monkey_field_conflict.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-286a624f52ebcc6e61ddbfb0b8069d577b15d9a0d7ee1526244a1c7d21040857))
- ❌ Param removed in default constructor: `label` (named, optional)

**`class` LdMonkeyFieldConflictHint** ([lib/src/monkey_detail/ld_monkey_field_conflict_hint.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-4afb921824255b664fe37123f731cfabf9bff7a7531870304fe1fe6bacd9525f))
- ❌ Param removed in default constructor: `label` (named, optional)
- ❇️ Properties added: `conflict`, `onPreviewResolution`
- ❇️ Method added: `createState`

**`class` LdReactiveFormItem<TModel, TView>** ([lib/src/reactive_form_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-fecce365ac099bcac9c05fa0ebfcf73fb2f5c141032f4ca8bbda22ed6fcc9f1f))
- ❌ Params removed in default constructor: `label` (named, optional), `hintBuilder` (named, optional), `validationMessages` (named, optional)
- ❇️ Methods added: `forInt`, `forDouble`, `forDateTime`

**`enum` LdReactiveFormSaveMode** ([lib/src/monkey_detail/save_mode.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-bb3a3edcda7157d4c7857b6eacc8fc4e5450ae60584e84b383901f3c0ab051e5))
- ❇️ Enum added: `LdReactiveFormSaveMode`

**`function` ldBuildFormFieldChrome<TModel, TView>** ([lib/src/form_widgets/ld_form_field_base.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-a632ab91a350b9e09e9b1f88f95ec7c79f7e233f40e270befd55b7ebe0e960a7))
- ❇️ Function added: `ldBuildFormFieldChrome`

#### 👀 Patch changes

**`class` LdReactiveFormItem<TModel, TView>** ([lib/src/reactive_form_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-fecce365ac099bcac9c05fa0ebfcf73fb2f5c141032f4ca8bbda22ed6fcc9f1f))
- ❌ Property removed: `_valueAccessor`

**`class` _LdFormInputField<T>** ([lib/src/form_widgets/ld_form_input.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-587f880d765bd6800e74114b32a7acbd75a7b8c3271e47f07bba62829032ae45))
- ❇️ Class added: `_LdFormInputField`

**`class` _LdFormInputFieldState<T>** ([lib/src/form_widgets/ld_form_input.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-587f880d765bd6800e74114b32a7acbd75a7b8c3271e47f07bba62829032ae45))
- ❇️ Class added: `_LdFormInputFieldState`

**`class` _LdFormInputState<T>** ([lib/src/form_widgets/ld_form_input.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-587f880d765bd6800e74114b32a7acbd75a7b8c3271e47f07bba62829032ae45))
- ❇️ Class added: `_LdFormInputState`

**`class` _LdFormState<T extends Identifiable<IdType>, IdType, TDetail extends Object, TCreate, TUpdate>** ([lib/src/monkey_detail/detail_form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-89b4bb66eebde2fa45d4db603df7a31fd895700872ef73e55f84ea3817c3a2b9))
- ❇️ Class added: `_LdFormState`

**`class` _LdMonkeyFieldConflictHintState** ([lib/src/monkey_detail/ld_monkey_field_conflict_hint.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-4afb921824255b664fe37123f731cfabf9bff7a7531870304fe1fe6bacd9525f))
- ❇️ Class added: `_LdMonkeyFieldConflictHintState`

**`class` _LdMonkeyReactiveDetailFormState<T extends Identifiable<IdType>, IdType, TDetail extends Object, TCreate, TUpdate>** ([lib/src/monkey_detail/ld_monkey_reactive_detail_form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-6703bfe01b8395270d0a6fb1fad74d57e4772adab447674396cdc09bf90f5239))
- ❌ Class removed: `_LdMonkeyReactiveDetailFormState`

**`class` _LdReactiveFormState** ([lib/src/reactive_form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-0b73714a12c90a56b0a0b2e5fc4ee1f2ad895bcebba3d56ae1125c4b4f213ccf))
- ❌ Class removed: `_LdReactiveFormState`

**`class` _ReactiveLdInput<T>** ([lib/src/reactive_form_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-fecce365ac099bcac9c05fa0ebfcf73fb2f5c141032f4ca8bbda22ed6fcc9f1f))
- ❌ Class removed: `_ReactiveLdInput`

**`class` _ReactiveLdInputState<T>** ([lib/src/reactive_form_item.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-fecce365ac099bcac9c05fa0ebfcf73fb2f5c141032f4ca8bbda22ed6fcc9f1f))
- ❌ Class removed: `_ReactiveLdInputState`

**`function` _applyConflictResolutions** ([lib/src/monkey_detail/ld_monkey_detail_form_merge.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-366954feef300bfd505e2a25134bf01c66daca42b8fd83911d2b380cf2fde80f))
- ❌ Function removed: `_applyConflictResolutions`

**`function` _resolveConflict** ([lib/src/monkey_detail/ld_monkey_detail_form_merge.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-2..liquid_flutter_reactive_forms/v0.1.1-3#diff-366954feef300bfd505e2a25134bf01c66daca42b8fd83911d2b380cf2fde80f))
- ❌ Function removed: `_resolveConflict`


## 0.1.1-2
Released on: 7/2/2026, changelog automatically generated.

### API Changes

#### 💣 Breaking changes

**`class` LdMonkeyReactiveDetailForm<T extends Identifiable<IdType>, IdType, TDetail extends Object, TCreate, TUpdate>** ([lib/src/monkey_detail/ld_monkey_reactive_detail_form.dart](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-1..liquid_flutter_reactive_forms/v0.1.1-2#diff-6703bfe01b8395270d0a6fb1fad74d57e4772adab447674396cdc09bf90f5239))
- 🔄 Param type changed in constructor `edit`: `formToUpdatePayload` (`TUpdate Function(FormGroup, TDetail)` → `TUpdate Function(FormGroup, TDetail)?`)
- 🔄 Param type changed in constructor `create`: `formToCreatePayload` (`TCreate Function(FormGroup, TDetail)` → `TCreate Function(FormGroup, TDetail)?`)

#### 👀 Patch changes

**`meta` pubspec.yaml** ([pubspec.yaml](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.1.1-1..liquid_flutter_reactive_forms/v0.1.1-2#diff-8b7e9df87668ffa6a04b32e1769a33434999e54ae081c52e5d943c541d4c0d25))
- 📦 Added `collection`: with version `^1.19.0`
- 📦 Added `provider`: with version `^6.1.0`


## 0.1.1-1
Released on: 6/28/2026, changelog automatically generated.

### API Changes

#### 👀 Patch changes

**`meta` pubspec.yaml** ([pubspec.yaml](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_reactive_forms/v0.0.1..liquid_flutter_reactive_forms/v0.1.1-1#diff-8b7e9df87668ffa6a04b32e1769a33434999e54ae081c52e5d943c541d4c0d25))
- 📦 `liquid_flutter` version changed: from `^23.0.0-4` to `^23.0.0-5`


## 0.1.0

* Initial release.
* Adds `reactive_forms` extensions for `liquid_flutter`, including monkey detail form helpers.
