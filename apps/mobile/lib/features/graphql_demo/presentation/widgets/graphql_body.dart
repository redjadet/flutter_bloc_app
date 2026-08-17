import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/app/utils/bloc/cubit_helpers.dart';
import 'package:flutter_bloc_app/features/graphql_demo/graphql_demo.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Main body content for the GraphQL demo page with list view and error handling.
class GraphqlBody extends StatelessWidget {
  const GraphqlBody({
    required this.bodyData,
    required this.l10n,
    super.key,
  });

  final GraphqlBodyData bodyData;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (bodyData.countries.isEmpty) {
      return AppMessage(message: l10n.graphqlSampleEmpty);
    }

    final String capitalLabel = l10n.graphqlSampleCapitalLabel;
    final String currencyLabel = l10n.graphqlSampleCurrencyLabel;

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: context.responsiveListPadding,
      itemBuilder: (context, index) {
        final GraphqlCountry country = bodyData.countries[index];
        return GraphqlCountryCard(
          key: ValueKey<String>('graphql-country-${country.code}'),
          country: country,
          capitalLabel: capitalLabel,
          currencyLabel: currencyLabel,
        );
      },
      separatorBuilder: (_, _) => SizedBox(height: context.responsiveGapM),
      itemCount: bodyData.countries.length,
    );
  }
}

/// Builds error message for GraphQL demo based on error type.
String buildGraphqlErrorMessage(
  AppLocalizations l10n,
  GraphqlBodyData bodyData,
) => _getErrorMessageFromType(l10n, bodyData.errorType, bodyData.errorMessage);

String _getErrorMessageFromType(
  AppLocalizations l10n,
  GraphqlDemoErrorType? errorType,
  String? errorMessage,
) => _resolveErrorMessage(l10n, errorType, errorMessage);

String _resolveErrorMessage(
  AppLocalizations l10n,
  GraphqlDemoErrorType? errorType,
  String? errorMessage,
) => _getMessageForErrorType(l10n, errorType, errorMessage);

String _getMessageForErrorType(
  AppLocalizations l10n,
  GraphqlDemoErrorType? errorType,
  String? errorMessage,
) {
  switch (errorType) {
    case GraphqlDemoErrorType.network:
      return l10n.graphqlSampleNetworkError;
    case GraphqlDemoErrorType.invalidRequest:
      return l10n.graphqlSampleInvalidRequestError;
    case GraphqlDemoErrorType.server:
      return l10n.graphqlSampleServerError;
    case GraphqlDemoErrorType.data:
      return l10n.graphqlSampleDataError;
    case GraphqlDemoErrorType.unknown:
    case null:
      break;
  }
  return errorMessage ?? l10n.graphqlSampleGenericError;
}

/// Builds the error widget for GraphQL demo.
Widget buildGraphqlErrorWidget(
  BuildContext context,
  GraphqlBodyData data,
  AppLocalizations l10n,
) {
  final bool showRetry = data.lastError?.isRetryable ?? true;
  return AppMessage(
    title: l10n.graphqlSampleErrorTitle,
    message: buildGraphqlErrorMessage(l10n, data),
    isError: true,
    actions: showRetry
        ? [
            PlatformAdaptive.button(
              context: context,
              onPressed: () =>
                  CubitHelpers.safeExecute<GraphqlDemoCubit, GraphqlDemoState>(
                    context,
                    (cubit) => cubit.loadInitial(),
                  ),
              child: Text(l10n.graphqlSampleRetryButton),
            ),
          ]
        : null,
  );
}
