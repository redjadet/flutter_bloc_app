import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_comment_policy.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/cubit/social_feed_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class SocialFeedCommentComposer {
  static Future<void> show(
    BuildContext context, {
    required String postId,
  }) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SocialFeedCubit cubit = context.read<SocialFeedCubit>();
    final TextEditingController controller = TextEditingController();
    const SocialFeedCommentPolicy policy = SocialFeedCommentPolicy();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return BlocProvider<SocialFeedCubit>.value(
          value: cubit,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.viewInsetsOf(sheetContext).bottom + 16,
            ),
            child: StatefulBuilder(
              builder: (builderContext, setState) {
                final bool valid = policy.isValid(controller.text);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      key: const ValueKey('social-feed-comment-field'),
                      controller: controller,
                      maxLines: 3,
                      enabled: true,
                      decoration: InputDecoration(
                        labelText: l10n.socialFeedDemoComment,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      key: const ValueKey('social-feed-comment-submit'),
                      onPressed: valid
                          ? () async {
                              final String body = controller.text;
                              setState(() {});
                              final bool accepted = await builderContext
                                  .read<SocialFeedCubit>()
                                  .submitComment(postId: postId, body: body);
                              if (!sheetContext.mounted) {
                                return;
                              }
                              if (accepted) {
                                Navigator.of(sheetContext).pop();
                              }
                              // Rejection / queue write failure: keep sheet + draft.
                            }
                          : null,
                      child: Text(l10n.socialFeedDemoSubmitComment),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
