## Unreleased

* **Breaking:** GenUI surfaces are rendered with the A2UI Dart SDKs
  (`a2ui_core` and `a2ui_flutter`) instead of `genui`. The `genui` fenced
  blocks in message text and the A2UI v0.9 messages in them are unchanged.
  * `buildLdCatalog()` returns an `a2ui_flutter` `CatalogImplementation`
    instead of a genui `Catalog`, and the `catalog` parameter of
    `LdGenuiSurfaceManager` takes one.
  * `LdGenuiSurfaceManager.controller`, a genui `SurfaceController`, is
    replaced by `processor`, an `a2ui_core` `MessageProcessor`. Instead of
    `controller.onSubmit`, listen to `processor.model.onAction` for user
    actions and to `processor.model.onError` for errors to report to the
    agent. `ActionMessage(version: 'v0.9', action: action).toJson()` and
    `ErrorMessage(version: 'v0.9', error: error).toJson()` give the JSON that
    genui sent in its `UiInteractionPart`.
  * `LdGenuiSurfaceManager.contextFor(surfaceId)` is replaced by
    `surfaceFor(surfaceId)`, which returns the surface's `SurfaceModel`, or
    null until the agent creates it.
* GenUI behavior changes that come with the new SDKs:
  * A message that fails validation, such as one with an unknown `catalogId`
    or an invalid enum value, is rejected and reported on
    `processor.model.onError`. genui applied invalid components and reported
    them. Updates for a surface that does not exist yet are rejected instead
    of buffered until `createSurface` arrives.
  * Component data that cannot be read, such as an `LdCardGallery` without
    cards, is shown as an error `LdHint` instead of genui's
    `FallbackWidget`, and is still reported with code `RUNTIME_ERROR`.
  * When `selected` of `LdMultipleChoice` or `LdCardGallery` is a literal,
    the user's choice is kept in widget state. genui wrote it to the data
    model under `<componentId>.selected`. A `selected` bound to a data path
    is written to that path as before.

## 0.0.1-2
Released on: 8/22/2026, changelog automatically generated.

### API Changes

#### 👀 Patch changes

**`meta` pubspec.yaml** ([pubspec.yaml](https://github.com/emdgroup-liquid/liquid-flutter/compare/liquid_flutter_ai/v0.0.1-1..liquid_flutter_ai/v0.0.1-2#diff-8b7e9df87668ffa6a04b32e1769a33434999e54ae081c52e5d943c541d4c0d25))
- 📦 `liquid_flutter_md` version changed: from `^0.0.1-1` to `^0.0.1-2`

## 0.0.1-2

* Allow-rule picker: nested Any pins match calls that omit those objects.

## 0.0.1-1

* Initial release: conversation list, compose bar, bubbles (user / agent /
  tool / approval / reasoning), activity grouping, send-fly, tool allow-rule
  UI, GenUI surfaces, and usage/cost helpers.
