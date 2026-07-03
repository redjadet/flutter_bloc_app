import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_loading_widget.dart';

/// Loads deferred libraries before rendering the requested page.
class DeferredPage extends StatefulWidget {
  const DeferredPage({
    required this.loadLibrary,
    required this.builder,
    super.key,
    this.loadingBuilder,
    this.errorMessageBuilder,
  });

  final Future<void> Function() loadLibrary;
  final WidgetBuilder builder;
  final WidgetBuilder? loadingBuilder;
  final String Function(BuildContext context, Object error)?
  errorMessageBuilder;

  @override
  State<DeferredPage> createState() => _DeferredPageState();
}

class _DeferredPageState extends State<DeferredPage> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = widget.loadLibrary();
  }

  void _retry() {
    setState(() {
      _loadFuture = widget.loadLibrary();
    });
  }

  @override
  Widget build(final BuildContext context) => FutureBuilder<void>(
    future: _loadFuture,
    builder: (final context, final snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          final Object? error = snapshot.error;
          if (error case final resolvedError?) {
            final String message =
                widget.errorMessageBuilder?.call(context, resolvedError) ??
                context.l10n.featureLoadError;
            return CommonErrorView(message: message, onRetry: _retry);
          }
        }
        return widget.builder(context);
      }
      return widget.loadingBuilder?.call(context) ??
          const CommonLoadingWidget();
    },
  );
}
