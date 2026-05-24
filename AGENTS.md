---
git_provider: github
---

# Agent instructions

Cursor loads detailed rules from [`.cursor/rules/`](.cursor/rules/). This file is a short baseline for any tool that reads repository-root `AGENTS.md` only.

## Essentials

- **Stack**: Flutter with the Liquid Flutter design system.
- **Widgets & state**: Prefer `StatelessWidget`, `StatefulWidget`, and `Provider` for shared state; avoid heavier state libraries unless necessary.
- **Layout**: Organize `lib/` by feature / widget tree (screen folders, colocated components), not by technical layers only.
- **Services**: Stateless helpers may be global singletons; anything with mutable state belongs in the tree via `Provider` / `ChangeNotifier`. Do not store references to other services—resolve dependencies with `BuildContext` when you need them (e.g. `context.read<T>()` / `context.watch<T>()` in widgets and callbacks).
- **Testing**: Favor widget tests for UI-coupled behavior; unit-test pure logic that does not depend on Flutter.
- **Scaffold**: Use `LdScaffold` with `LdAppBar.top(child: LdScaffoldBody(...))` (use `addContainer: true` when you want standard page padding).
- **Text**: Use `LdText` for standalone labels and body copy; plain `Text` is fine inside components that own the label (e.g. buttons).
- **Spacing & layout**: Use `LdAutoSpace` in `Column`s unless you intentionally need tight stacking; use `LdTheme.of(context).pad(...)` or `.padS()` / `.padM()` / `.padL()` (and `ldSpacerS` / `ldSpacerM` / `ldSpacerL` when you need explicit gaps).
- **Shape**: Use `LdTheme.of(context).radius(LdSize.*)` for corners.
- **Modals**: Use `LdModalRoute` for dialogs, modals, and sheets.
- **Icons**: Prefer Lucide icons over `Icons` / `CupertinoIcons` where applicable.
- **Lists in cards**: `LdCard` with `padding: EdgeInsets.zero` and a `Column` of `LdListItem`s when building grouped settings-style lists.

## Before pushing

- Run **static analysis** and **tests** from the repository root using **Melos** scripts declared in [pubspec.yaml](pubspec.yaml) under `melos.scripts`—do not substitute ad-hoc per-package commands unless a script does not cover your change.
- Typical checks before push: `melos run analyze` (runs `dart analyze` across packages) and `melos run test` (runs `flutter test` for packages in the `testable` category).
- For API or versioning workflows that touch public packages, see also `melos run api_guard` (see `packageFilters` and `exec` in the same `melos.scripts` block).

## Topic guides

Open the matching file when work touches that area (YAML frontmatter at the top of each `.mdc` is for Cursor only; the rest is Markdown).

- **[Architecture](.cursor/rules/architecture.mdc)** — App structure, Provider, services, testing, and build-method conventions.
- **[Design system](.cursor/rules/design.mdc)** — Components, spacing, colors, typography, and common UI patterns.
- **[App root setup](.cursor/rules/app_root_setup.mdc)** — `main()`, root widget tree, and initialization.
- **[LdSubmit usage](.cursor/rules/ldsubmit_usage.mdc)** — Async actions, loading, and submit flows with `LdSubmit`.
- **[LdSubmit errors](.cursor/rules/ldsubmit_errors.mdc)** — Error handling patterns for `LdSubmit` and async UX.
- **[LdSubmit best practices](.cursor/rules/ldsubmit_best_practices.mdc)** — Conventions and maintainability for `LdSubmit`.
