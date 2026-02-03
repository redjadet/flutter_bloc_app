import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

class ChatModelSelector extends StatelessWidget {
  const ChatModelSelector({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);

    final ChatCubit cubit = context.read<ChatCubit>();
    final List<String> models = cubit.models;

    return BlocSelector<ChatCubit, ChatState, String?>(
      selector: (final state) => state.currentModel,
      builder: (final context, final currentModel) {
        // Defensive check: ensure models list is not empty
        if (models.isEmpty) {
          return const SizedBox.shrink();
        }
        final String effectiveModel = currentModel ?? models.first;

        if (models.length <= 1) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${l10n.chatModelLabel}: ${_modelLabel(l10n, effectiveModel)}',
              style: theme.textTheme.titleMedium,
            ),
          );
        }

        return CommonDropdownField<String>(
          value: effectiveModel,
          items: models
              .map(
                (final model) => DropdownMenuItem<String>(
                  value: model,
                  child: Text(_modelLabel(l10n, model)),
                ),
              )
              .toList(growable: false),
          onChanged: (final value) {
            if (value != null) {
              cubit.selectModel(value);
            }
          },
          labelText: l10n.chatModelLabel,
          labelPosition: DropdownLabelPosition.left,
          customItemLabel: (final model) => _modelLabel(l10n, model),
        );
      },
    );
  }

  String _modelLabel(final AppLocalizations l10n, final String model) {
    switch (model) {
      case 'openai/gpt-oss-20b':
        return l10n.chatModelGptOss20b;
      case 'openai/gpt-oss-120b':
        return l10n.chatModelGptOss120b;
      default:
        return model;
    }
  }
}
