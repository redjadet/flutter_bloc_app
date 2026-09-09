import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/features/notes_demo/domain/note.dart';
import 'package:flutter_bloc_app/features/notes_demo/presentation/cubit/notes_cubit.dart';
import 'package:flutter_bloc_app/features/notes_demo/presentation/cubit/notes_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

class const NotesDemoPage({super.key}) extends StatelessWidget {
  Future<void> _openEditor(BuildContext context, {Note? existing}) async {
    final AppLocalizations l10n = context.l10n;
    final TextEditingController titleController = TextEditingController(
      text: existing?.title ?? '',
    );
    final TextEditingController bodyController = TextEditingController(
      text: existing?.body ?? '',
    );
    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            existing == null
                ? l10n.notesDemoCreateTitle
                : l10n.notesDemoEditTitle,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: l10n.notesDemoTitleLabel,
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              SizedBox(height: dialogContext.responsiveGapS),
              TextField(
                controller: bodyController,
                decoration: InputDecoration(labelText: l10n.notesDemoBodyLabel),
                minLines: 3,
                maxLines: 5,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.notesDemoCancelButton),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.notesDemoSaveButton),
            ),
          ],
        );
      },
    );
    final String title = titleController.text;
    final String body = bodyController.text;
    titleController.dispose();
    bodyController.dispose();
    if (saved != true || !context.mounted) {
      return;
    }
    await context.read<NotesCubit>().saveNote(
      title: title,
      body: body,
      existing: existing,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notesDemoTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<NotesCubit, NotesState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(l10n.notesDemoEmpty),
                  SizedBox(height: context.responsiveGapS),
                  FilledButton(
                    onPressed: () => _openEditor(context),
                    child: Text(l10n.notesDemoCreateButton),
                  ),
                ],
              ),
            );
          }
          final List<Note> notes = List<Note>.of(state.notes, growable: false);
          return ListView.separated(
            padding: EdgeInsets.all(context.responsiveGapM),
            itemCount: notes.length,
            separatorBuilder: (_, _) =>
                SizedBox(height: context.responsiveGapS),
            itemBuilder: (context, index) {
              if (index >= notes.length) {
                return const SizedBox.shrink();
              }
              final Note note = notes[index];
              return ListTile(
                key: ValueKey<String>('notes-demo-item-${note.id}'),
                title: Text(note.title),
                subtitle: Text(
                  note.body.isEmpty ? l10n.notesDemoNoBody : note.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => _openEditor(context, existing: note),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () =>
                      context.read<NotesCubit>().deleteNote(note.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
