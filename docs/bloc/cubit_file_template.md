# Cubit File Template

Copy-paste starting point for new feature Cubits. Canon:
[`bloc_standards.md`](../bloc_standards.md), [`review/bloc_checklist.md`](../review/bloc_checklist.md),
[`architecture/reduce_surprise_patterns.md`](../architecture/reduce_surprise_patterns.md) § P4.

Place files under `apps/mobile/lib/features/<feature>/presentation/cubit/` only (singular
`cubit/`, not `cubits/`).

## State (`<feature>_state.dart`)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '<feature>_state.freezed.dart';

@freezed
class <Feature>State with _$<Feature>State {
  const factory <Feature>State.initial() = _Initial;
  const factory <Feature>State.loading() = _Loading;
  const factory <Feature>State.success({required <DomainModel> data}) = _Success;
  const factory <Feature>State.failure({required String message}) = _Failure;
}
```

Use domain models in state — never DTOs. Prefer sealed unions over many
booleans.

## Cubit (`<feature>_cubit.dart`)

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

class <Feature>Cubit extends Cubit<<Feature>State> {
  <Feature>Cubit({required <Feature>Repository repository})
      : _repository = repository,
        super(const <Feature>State.initial());

  final <Feature>Repository _repository;

  Future<void> load() async {
    if (isClosed) return;
    emit(const <Feature>State.loading());
    try {
      final data = await _repository.fetch();
      if (isClosed) return;
      emit(<Feature>State.success(data: data));
    } catch (error, stackTrace) {
      if (isClosed) return;
      emit(<Feature>State.failure(message: error.toString()));
    }
  }

  @override
  Future<void> close() {
    // Cancel subscriptions/timers here.
    return super.close();
  }
}
```

Wire async through existing `CubitExceptionHandler` patterns when the feature
already uses them.

## Test (`test/features/<feature>/presentation/<feature>_cubit_test.dart`)

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late <Feature>Repository repository;

  setUp(() {
    repository = _Fake<Feature>Repository();
  });

  blocTest<<Feature>Cubit, <Feature>State>(
    'emits success when load succeeds',
    build: () => <Feature>Cubit(repository: repository),
    act: (cubit) => cubit.load(),
    expect: () => [
      const <Feature>State.loading(),
      isA<<Feature>StateSuccess>(),
    ],
  );
}
```

## Proof

`flutter test test/features/<feature>/presentation/` and `./tool/analyze.sh`.
