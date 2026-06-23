class GoodState {
  const GoodState(this.items);

  final List<int> items;
}

class GoodContext {
  T selectState<C, S, T>({required final T Function(S state) selector}) =>
      throw UnimplementedError();
}

class EvenItemsViewData {
  const EvenItemsViewData(this.items);

  factory EvenItemsViewData.fromState(final GoodState state) {
    final items = <int>[
      for (final item in state.items)
        if (item.isEven) item,
    ];
    return EvenItemsViewData(List<int>.unmodifiable(items));
  }

  final List<int> items;
}

void build(final GoodContext context) {
  context.selectState<Object, GoodState, EvenItemsViewData>(
    selector: EvenItemsViewData.fromState,
  );
}
