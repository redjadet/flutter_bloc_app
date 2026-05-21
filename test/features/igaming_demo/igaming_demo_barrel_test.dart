import 'package:flutter_bloc_app/features/igaming_demo/igaming_demo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('igaming_demo barrel exposes public API types', () {
    expect(LobbyCubit, isA<Type>());
    expect(GameCubit, isA<Type>());
    expect(LobbyPage, isA<Type>());
    expect(GamePage, isA<Type>());
    expect(DemoBalanceRepository, isA<Type>());
    expect(DemoGameRepository, isA<Type>());
  });
}
