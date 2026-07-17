# CustomPainter & RenderObject — contract

Use custom painting when widgets cannot express the visual. Prefer
`CustomPainter` for data-driven paint; use a custom `RenderObject` only when
you need layout + paint control.

## When

| Approach | Use when |
| --- | --- |
| `CustomPainter` | Rings, charts, badges, whiteboard strokes — parent owns layout |
| `RenderObject` | Custom layout + paint (e.g. markdown preview layout) |

## Architecture

- Keep painters **presentation-only**. Cubit/BLoC own domain state; painter
  receives immutable view data.
- Do not put networking, Hive, or DI inside `paint` / `performLayout`.
- Prefer `shouldRepaint` / `shouldRebuild` that compare meaningful fields.

## Repo examples

| Example | Path |
| --- | --- |
| Whiteboard painter | `apps/mobile/lib/features/example/presentation/widgets/whiteboard/` |
| Markdown render object | `apps/mobile/lib/features/example/presentation/widgets/markdown_editor/` |

## Related

- [`design_system.md`](../design_system.md) — tokens / Mix for surrounding chrome
- [`bloc_standards.md`](../bloc_standards.md) — state ownership
