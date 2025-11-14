import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/search/presentation/search_cubit.dart';
import 'package:flutter_bloc_app/features/search/presentation/search_state.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

class SearchTextField extends StatefulWidget {
  const SearchTextField({super.key});

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: 'dogs');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) =>
      BlocListener<SearchCubit, SearchState>(
        listenWhen: (final prev, final curr) => prev.query != curr.query,
        listener: (final context, final state) {
          if (state.query.isEmpty && _controller.text.isNotEmpty) {
            _controller.clear();
          }
        },
        child: Builder(
          builder: (final context) {
            final theme = Theme.of(context);
            final colors = theme.colorScheme;
            final textStyle = theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
              fontSize: context.responsiveBodySize,
            );
            final hintStyle = theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: context.responsiveBodySize,
            );

            return Container(
              height: context.responsiveButtonHeight,
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border.all(
                  color: colors.onSurface,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(
                  context.responsiveBorderRadius,
                ),
              ),
              child: TextField(
                controller: _controller,
                onChanged: (final value) =>
                    context.read<SearchCubit>().search(value),
                style: textStyle,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: context.responsiveHorizontalGapL,
                    vertical: context.responsiveGapM,
                  ),
                  hintText: 'Search...',
                  hintStyle: hintStyle,
                ),
              ),
            );
          },
        ),
      );
}
