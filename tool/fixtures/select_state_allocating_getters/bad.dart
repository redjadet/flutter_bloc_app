class BadState {
  const BadState(this.items);

  final List<int> items;

  List<int> get evenItems =>
      items.where((item) => item.isEven).toList(growable: false);
}

class BadContext {
  T selectState<C, S, T>({required T Function(S state) selector}) =>
      throw UnimplementedError();
}

void build(BadContext context) {
  context.selectState<Object, BadState, List<int>>(
    selector: (state) => state.evenItems,
  );
}
