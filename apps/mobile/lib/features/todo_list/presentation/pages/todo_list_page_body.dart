part of 'todo_list_page.dart';

class _TodoListBody extends StatefulWidget {
  const _TodoListBody();

  @override
  State<_TodoListBody> createState() => _TodoListBodyState();
}

class _TodoListBodyState extends State<_TodoListBody> {
  late final ScrollController _listScrollController;

  @override
  void initState() {
    super.initState();
    _listScrollController = ScrollController();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => ViewStatusSwitcher<TodoListCubit, TodoListState, TodoListLifecycleData>(
    selector: TodoListLifecycleData.fromState,
    isLoading: (data) => data.isLoading,
    isError: (data) => data.hasError,
    loadingBuilder: (_) => const CommonLoadingWidget(),
    errorBuilder: (context, data) => CommonErrorView(
      message: data.errorMessage ?? context.l10n.todoListLoadError,
      onRetry: () => context.cubit<TodoListCubit>().loadInitial(),
    ),
    builder: (context, _) =>
        TypeSafeBlocSelector<
          TodoListCubit,
          TodoListState,
          TodoListListProjection
        >(
          selector: TodoListListProjection.fromState,
          builder: (context, listData) => _TodoListSuccessBody(
            listData: listData,
            scrollController: _listScrollController,
          ),
        ),
  );
}

class _TodoListSuccessBody extends StatelessWidget {
  const _TodoListSuccessBody({
    required this.listData,
    required this.scrollController,
  });

  final TodoListListProjection listData;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final List<TodoItem> filteredItems = listData.filteredItems;
    final TodoListCubit cubit = context.cubit<TodoListCubit>();
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return CommonMaxWidth(
      maxWidth: context.contentMaxWidth,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final _TodoHeaderLayout layout = _TodoHeaderLayout.resolve(
            context: context,
            listData: listData,
            filteredItems: filteredItems,
            availableHeight: constraints.maxHeight,
          );
          final List<Widget> headerChildren = _todoHeaderChildren(
            context: context,
            layout: layout,
            listData: listData,
            filteredItems: filteredItems,
            cubit: cubit,
            theme: theme,
            colors: colors,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _todoHeaderShell(
                headerChildren: headerChildren,
                scrollController: scrollController,
              ),
              _todoListPane(
                context: context,
                layout: layout,
                listData: listData,
                filteredItems: filteredItems,
                cubit: cubit,
                scrollController: scrollController,
                padTop: headerChildren.isNotEmpty,
              ),
            ],
          );
        },
      ),
    );
  }
}
