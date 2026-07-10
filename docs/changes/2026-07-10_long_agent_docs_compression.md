# Long agent documentation compression

## Scope

Audited tracked agent-facing docs over 200 lines. Product guides, migration
history, setup manuals, and README files remained outside compression scope.

## Change

- Replaced 506-line state-management essay with 121-line decision contract.
- Replaced 521-line responsive-review snapshot with 131-line executable review
  and proof contract.
- Preserved existing section anchors used by shared host skills.
- Kept [`design_system.md`](../design_system.md) and validation catalog unchanged after automated
  compression produced negligible savings and worse prose.
- Added bootstrap regression guard and negative fixture so context reduction
  cannot silently remove owner routes.

## Quality controls retained

Architecture placement, lifecycle, failure, performance, accessibility,
cross-platform, widget-test, and validation-routing rules remain linked to
their canonical owners. Harness, engineering scorecards, boundary checks,
fixture suite, docs gardening, and checklist-fast remain required proof.
