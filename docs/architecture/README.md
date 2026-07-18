# Architecture documentation

Architecture contracts and reference implementations. Start with the root
[architecture entry hub](../architecture.md), then load only the owner needed.

| Need | Read |
| --- | --- |
| Layer direction and core model | [`../clean_architecture.md`](../clean_architecture.md) |
| SOLID guidance | [solid_principles.md](solid_principles.md) |
| Feature folders and placement | [feature_structure_contract.md](feature_structure_contract.md) |
| Reliable reference features | [reference_features.md](reference_features.md) |
| DTO, mapper, and error boundaries | [use_case_dto_policy.md](use_case_dto_policy.md) |
| Semantic patterns | [reduce_surprise_patterns.md](reduce_surprise_patterns.md) |
| Lazy loading flow | [architecture_lazy_loading_and_flow.md](architecture_lazy_loading_and_flow.md) |
| App init and feature control | [app_initialization_and_feature_control.md](app_initialization_and_feature_control.md) |
| Compile-time safety / Freezed | [compile_time_safety.md](compile_time_safety.md), [freezed_usage_analysis.md](freezed_usage_analysis.md) |
| Advanced rendering | [custom_painter_and_render_object.md](custom_painter_and_render_object.md) |

Keep cross-cutting architectural canon at `docs/` root only when it is a
high-traffic entry document. Put focused contracts in this folder.
