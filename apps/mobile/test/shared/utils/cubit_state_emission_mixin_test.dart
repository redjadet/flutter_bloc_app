import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_state_emission_mixin.dart';

void main() {
  group('StateHelpers', () {
    test('isLoading returns true for loading status', () {
      expect(StateHelpers.isLoading(ViewStatus.loading), isTrue);
      expect(StateHelpers.isLoading(ViewStatus.initial), isFalse);
      expect(StateHelpers.isLoading(ViewStatus.success), isFalse);
      expect(StateHelpers.isLoading(ViewStatus.error), isFalse);
    });

    test('hasError returns true for error status', () {
      expect(StateHelpers.hasError(ViewStatus.error), isTrue);
      expect(StateHelpers.hasError(ViewStatus.loading), isFalse);
      expect(StateHelpers.hasError(ViewStatus.success), isFalse);
      expect(StateHelpers.hasError(ViewStatus.initial), isFalse);
    });

    test('isSuccess returns true for success status', () {
      expect(StateHelpers.isSuccess(ViewStatus.success), isTrue);
      expect(StateHelpers.isSuccess(ViewStatus.loading), isFalse);
      expect(StateHelpers.isSuccess(ViewStatus.error), isFalse);
      expect(StateHelpers.isSuccess(ViewStatus.initial), isFalse);
    });

    test('isInitial returns true for initial status', () {
      expect(StateHelpers.isInitial(ViewStatus.initial), isTrue);
      expect(StateHelpers.isInitial(ViewStatus.loading), isFalse);
      expect(StateHelpers.isInitial(ViewStatus.success), isFalse);
      expect(StateHelpers.isInitial(ViewStatus.error), isFalse);
    });
  });
}
