# IDE support — current contract

This repo ships **snippets**, not a custom IDE extension.

## VS Code / Cursor snippets

- File: [`.vscode/flutter_bloc_snippets.code-snippets`](../.vscode/flutter_bloc_snippets.code-snippets)
- Covers type-safe Cubit access, Freezed/sealed state templates, type-safe
  BLoC widgets.

Open the workspace so Cursor/VS Code loads project snippets automatically.

## Analysis / custom lint

- Repo `analysis_options.yaml` + custom lints under `custom_lints/`
- Mix lint runner: `./tool/run_mix_lint.sh` (see [`design_system.md`](design_system.md))

## Related

- [`compile_time_safety.md`](compile_time_safety.md)
- [`code_generation_guide.md`](code_generation_guide.md)
- [`bloc_standards.md`](bloc_standards.md)
