import 'package:flutter_bloc_app/features/staff_app_demo/staff_app_demo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('staff_app_demo barrel exposes public API types', () {
    expect(StaffDemoSessionCubit, isA<Type>());
    expect(StaffAppDemoShellPage, isA<Type>());
    expect(StaffAppDemoDashboardPage, isA<Type>());
    expect(StaffDemoTimeclockRepository, isA<Type>());
  });
}
