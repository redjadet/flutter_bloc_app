import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/search/presentation/search_cubit.dart';
import 'package:flutter_bloc_app/features/search/presentation/search_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';

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
      TypeSafeBlocListener<SearchCubit, SearchState>(
        listenWhen: (final prev, final curr) => prev.query != curr.query,
        listener: (final context, final state) {
          if (state.query.isEmpty && _controller.text.isNotEmpty) {
            _controller.clear();
          }
        },
        child: Builder(
          builder: (final context) {
            final l10n = context.l10n;
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

            final isCupertino = PlatformAdaptive.isCupertino(context);
            final textField = PlatformAdaptive.textField(
              context: context,
              controller: _controller,
              hintText: l10n.searchHint,
              onChanged: (final value) =>
                  context.cubit<SearchCubit>().search(value),
              style: textStyle,
              padding: isCupertino
                  ? EdgeInsets.symmetric(
                      horizontal: context.responsiveHorizontalGapL,
                      vertical: context.responsiveGapM,
                    )
                  : null,
              decoration: isCupertino
                  ? null
                  : InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: context.responsiveHorizontalGapL,
                        vertical: context.responsiveGapM,
                      ),
                      hintText: l10n.searchHint,
                      hintStyle: hintStyle,
                    ),
            );

            if (isCupertino) {
              return Container(
                constraints: BoxConstraints(
                  minHeight: context.responsiveButtonHeight,
                ),
                alignment: Alignment.center,
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
                child: textField,
              );
            }

            return Container(
              constraints: BoxConstraints(
                minHeight: context.responsiveButtonHeight,
              ),
              alignment: Alignment.center,
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
              child: textField,
            );
          },
        ),
      );
}
