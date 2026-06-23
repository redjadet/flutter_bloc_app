class BadState {
  const BadState(this.items);

  final List<int> items;

  List<int> get evenItems =>
      items.where((final item) => item.isEven).toList(growable: false);
}

class BadContext {
  T selectState<C, S, T>({required final T Function(S state) selector}) =>
      throw UnimplementedError();
}

void build(final BadContext context) {
  context.selectState<Object, BadState, List<int>>(
    selector: (final state) => state.evenItems,
  );
}
