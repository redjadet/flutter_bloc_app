# Performance documentation

Runtime performance, memory safety, and profiling guidance. Start with
[`../reliability_error_handling_performance.md`](../reliability_error_handling_performance.md)
for repository-wide reliability rules.

| Need | Read |
| --- | --- |
| Memory ownership | [memory_management.md](memory_management.md) |
| Leak testing and CI | [memory_testing.md](memory_testing.md), [memory_ci.md](memory_ci.md) |
| Performance checklist | [`../review/performance_checklist.md`](../review/performance_checklist.md) |
| Startup measurement | [startup_time_profiling.md](startup_time_profiling.md) |
| Bundle sizing | [bundle_size_monitoring.md](bundle_size_monitoring.md) |
| Large JSON parsing | [compute_isolate_review.md](compute_isolate_review.md) |
| Lazy loading and scrolling | [lazy_loading_review.md](lazy_loading_review.md), [performance_bottlenecks.md](performance_bottlenecks.md) |

Keep focused profiling and memory procedures here. Move a root performance doc
only with its inbound-link updates and tool-message references.
