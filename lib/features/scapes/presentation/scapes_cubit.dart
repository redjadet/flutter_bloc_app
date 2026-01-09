import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/scapes/domain/scape.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/scapes_state.dart';

class ScapesCubit extends Cubit<ScapesState> {
  ScapesCubit() : super(const ScapesState()) {
    _loadScapes();
  }

  void _loadScapes() {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    // Simulate loading delay
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (isClosed) return;

      final scapes = _generateMockScapes();
      emit(
        state.copyWith(
          scapes: scapes,
          isLoading: false,
        ),
      );
    });
  }

  List<Scape> _generateMockScapes() {
    final random = Random(42);
    final colors = [
      'pink',
      'orange',
      'green',
      'yellow',
      'purple',
      'blue',
    ];

    return List.generate(6, (final index) {
      final color = colors[index % colors.length];
      return Scape(
        id: 'scape_$index',
        name: 'Scape Name ${index + 1}',
        imageUrl: 'https://picsum.photos/seed/$color$index/400/400',
        duration: Duration(seconds: random.nextInt(3600)),
        assetCount: random.nextInt(100),
      );
    });
  }

  void toggleViewMode() {
    final newMode = state.viewMode == ScapesViewMode.grid
        ? ScapesViewMode.list
        : ScapesViewMode.grid;
    emit(state.copyWith(viewMode: newMode));
  }

  void toggleFavorite(final String scapeId) {
    final updatedScapes = state.scapes.map((final scape) {
      if (scape.id == scapeId) {
        return scape.copyWith(isFavorite: !scape.isFavorite);
      }
      return scape;
    }).toList();

    emit(state.copyWith(scapes: updatedScapes));
  }

  void reload() {
    _loadScapes();
  }
}
