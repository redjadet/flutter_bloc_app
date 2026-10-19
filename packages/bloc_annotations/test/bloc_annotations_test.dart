import 'package:bloc_annotations/bloc_annotations.dart';
import 'package:test/test.dart';

void main() {
  test('GenerateSwitchHelper is a const annotation', () {
    const annotation = GenerateSwitchHelper();
    expect(annotation, isA<GenerateSwitchHelper>());
  });

  test('GenerateStateValidator carries transitions', () {
    const annotation = GenerateStateValidator(
      transitions: [StateTransition(from: 'Loading', to: 'Ready')],
    );
    expect(annotation.transitions, hasLength(1));
    expect(annotation.transitions.single.from, 'Loading');
    expect(annotation.transitions.single.to, 'Ready');
  });

  test('GenerateCubitFactory is a const annotation', () {
    const annotation = GenerateCubitFactory();
    expect(annotation, isA<GenerateCubitFactory>());
  });
}
