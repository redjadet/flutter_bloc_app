import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_loading_widget.dart';

/// Switches between loading, error, and success content using a single
/// [BlocSelector]. Intended to reduce repeated status checks in widgets.
class ViewStatusSwitcher<C extends StateStreamable<S>, S, T>
    extends StatelessWidget {
  const ViewStatusSwitcher({
    required this.selector,
    required this.isLoading,
    required this.isError,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    super.key,
  });

  final T Function(S state) selector;
  final bool Function(T data) isLoading;
  final bool Function(T data) isError;
  final Widget Function(BuildContext context, T data) builder;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(BuildContext context, T data)? errorBuilder;

  @override
  Widget build(final BuildContext context) =>
      BlocSelector<C, S, T>(selector: selector, builder: _buildFromData);

  Widget _buildFromData(final BuildContext context, final T data) {
    if (isLoading(data)) {
      return loadingBuilder?.call(context) ?? const CommonLoadingWidget();
    }

    if (isError(data)) {
      return errorBuilder?.call(context, data) ??
          const CommonErrorView(
            message: 'Something went wrong',
          );
    }

    return builder(context, data);
  }
}
