class GoodState {
  const GoodState(this.items);

  final List<int> items;
}

class GoodContext {
  T selectState<C, S, T>({required T Function(S state) selector}) =>
      throw UnimplementedError();
}

class EvenItemsViewData {
  const EvenItemsViewData(this.items);

  factory EvenItemsViewData.fromState(GoodState state) {
    final items = <int>[
      for (item in state.items)
        if (item.isEven) item,
    ];
    return EvenItemsViewData(List<int>.unmodifiable(items));
  }

  final List<int> items;
}

void build(GoodContext context) {
  context.selectState<Object, GoodState, EvenItemsViewData>(
    selector: EvenItemsViewData.fromState,
  );
}
