# liquid_flutter_lint

Custom analyzer rules for Liquid Flutter design-system compliance.

> **Status: experimental / not part of the workspace.**
>
> This package is intentionally **not** listed in the root `pubspec.yaml`
> `workspace:` list and is not covered by `melos run analyze` or CI.
>
> It targets the legacy analyzer plugin API and pins `analyzer: ^8.1.1`
> because `analysis_server_plugin` 0.2.x requires exactly that generation.
> The workspace moved to analyzer 13+ with the `material_ui` / Flutter 3.50
> migration, so enabling this plugin inside the workspace does not resolve.
>
> To revive it, migrate to `analysis_server_plugin ^0.3.x` (analyzer 13+),
> add `String get name`, replace the removed `NamedExpression` AST node with
> `NamedArgument` (`name.lexeme`, `argumentExpression`), and switch the
> `analysis_options.yaml` registration to the top-level `plugins:` format.
> Then add the package to the workspace so CI keeps it working.
