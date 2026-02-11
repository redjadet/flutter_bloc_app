import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_dataset.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/cubit/dispersion_cubit.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/cubit/dispersion_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_max_width.dart';

class DispersionCombineDatasetsBody extends StatefulWidget {
  const DispersionCombineDatasetsBody({
    required this.datasets,
    this.errorMessage,
    super.key,
  });

  final List<DispersionDataset> datasets;
  final String? errorMessage;

  @override
  State<DispersionCombineDatasetsBody> createState() => _DispersionCombineDatasetsBodyState();
}

class _DispersionCombineDatasetsBodyState extends State<DispersionCombineDatasetsBody> {
  final Set<String> _selectedIds = <String>{};
  final TextEditingController _nameController = TextEditingController();
  String? _validationError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final String name = _nameController.text.trim();
    _validationError = null;
    if (name.isEmpty) {
      setState(
        () => _validationError = context.l10n.dispersionDerivedDatasetNameRequired,
      );
      return;
    }
    if (_selectedIds.length < 2) {
      setState(
        () => _validationError = context.l10n.dispersionSelectAtLeastTwo,
      );
      return;
    }
    unawaited(
      context.cubit<DispersionCubit>().createDerivedDataset(
        name,
        _selectedIds.toList(),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final String? errorToShow = _validationError ?? widget.errorMessage;
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.responsiveGapM),
      child: CommonMaxWidth(
        maxWidth: context.contentMaxWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            PlatformAdaptive.outlinedButton(
              context: context,
              onPressed: () {
                context.cubit<DispersionCubit>().setScreen(
                  DispersionScreen.home,
                );
              },
              child: Text(l10n.dispersionBack),
            ),
            SizedBox(height: context.responsiveGapM),
            Text(
              l10n.dispersionCombineDatasetsTitle,
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(height: context.responsiveGapM),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.dispersionDerivedDatasetName,
                hintText: l10n.dispersionDerivedDatasetNameHint,
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
            SizedBox(height: context.responsiveGapM),
            Text(
              l10n.dispersionDatasets(widget.datasets.length),
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: context.responsiveGapS),
            if (widget.datasets.isEmpty)
              Padding(
                padding: EdgeInsets.all(context.responsiveGapM),
                child: Text(
                  l10n.dispersionNoDatasets,
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              ...widget.datasets.map<Widget>(
                (final DispersionDataset ds) => CheckboxListTile(
                  value: _selectedIds.contains(ds.id),
                  onChanged: (final bool? value) {
                    setState(() {
                      if (value ?? false) {
                        _selectedIds.add(ds.id);
                      } else {
                        _selectedIds.remove(ds.id);
                      }
                    });
                  },
                  title: Text(ds.name),
                  subtitle: Text(
                    '${ds.pointCount} ${l10n.dispersionPoints}',
                  ),
                  secondary: ds.isDerived
                      ? Chip(
                          label: Text(
                            l10n.dispersionDerived,
                            style: theme.textTheme.labelSmall,
                          ),
                        )
                      : null,
                ),
              ),
            if (errorToShow != null && errorToShow.isNotEmpty) ...[
              SizedBox(height: context.responsiveGapS),
              Material(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.all(context.responsiveGapS),
                  child: Text(
                    errorToShow,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
            ],
            SizedBox(height: context.responsiveGapM),
            PlatformAdaptive.filledButton(
              context: context,
              onPressed: _submit,
              child: Text(l10n.dispersionCreateCombined),
            ),
          ],
        ),
      ),
    );
  }
}
