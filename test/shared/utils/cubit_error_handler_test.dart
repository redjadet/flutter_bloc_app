import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_error_handler.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestState {
  const _TestState({this.errorMessage});

  final String? errorMessage;
}

class _TestCubit extends Cubit<_TestState> with CubitErrorHandler<_TestState> {
  _TestCubit({String? initialError})
    : super(_TestState(errorMessage: initialError));

  void triggerError(Object error) {
    handleError(
      error,
      StackTrace.current,
      (err) => _TestState(errorMessage: err.toString()),
      '_TestCubit.triggerError',
    );
  }

  void triggerErrorWithFactory(Object error) {
    handleErrorWithFactory<String>(
      error,
      StackTrace.current,
      (err) => 'converted:${err.toString()}',
      (converted) => _TestState(errorMessage: converted),
      '_TestCubit.triggerErrorWithFactory',
    );
  }
}

void main() {
  group('CubitErrorHandler', () {
    test('handleError emits error state', () {
      final cubit = _TestCubit();

      cubit.triggerError(Exception('boom'));

      expect(cubit.state.errorMessage, equals('Exception: boom'));
      cubit.close();
    });

    test('handleErrorWithFactory uses converted error', () {
      final cubit = _TestCubit();

      final error = ArgumentError('bad');

      cubit.triggerErrorWithFactory(error);

      expect(cubit.state.errorMessage, equals('converted:${error.toString()}'));
      cubit.close();
    });

    test('handleErrorWithFactory accepts already-converted error', () {
      final cubit = _TestCubit();

      cubit.triggerErrorWithFactory('direct');

      expect(cubit.state.errorMessage, equals('direct'));
      cubit.close();
    });

    test('handleError skips emit when cubit is closed', () async {
      final cubit = _TestCubit(initialError: 'initial');

      await cubit.close();
      cubit.triggerError(Exception('ignored'));

      expect(cubit.state.errorMessage, equals('initial'));
    });
  });
}
