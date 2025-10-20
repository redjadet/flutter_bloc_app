import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

class ChatModelSelector extends StatelessWidget {
  const ChatModelSelector({super.key});

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return BlocBuilder<ChatCubit, ChatState>(
      buildWhen: (final prev, final curr) =>
          prev.currentModel != curr.currentModel,
      builder: (final context, final state) {
        final ChatCubit cubit = context.read<ChatCubit>();
        final List<String> models = cubit.models;
        final String currentModel = state.currentModel ?? models.first;

        if (models.length <= 1) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${l10n.chatModelLabel}: ${_modelLabel(l10n, currentModel)}',
              style: theme.textTheme.titleMedium,
            ),
          );
        }

        return Row(
          children: <Widget>[
            Text(l10n.chatModelLabel, style: theme.textTheme.titleMedium),
            SizedBox(width: UI.horizontalGapS),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: currentModel,
                items: models
                    .map(
                      (final String model) => DropdownMenuItem<String>(
                        value: model,
                        child: Text(_modelLabel(l10n, model)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (final String? value) {
                  if (value != null) {
                    cubit.selectModel(value);
                  }
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                isExpanded: true,
              ),
            ),
          ],
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
