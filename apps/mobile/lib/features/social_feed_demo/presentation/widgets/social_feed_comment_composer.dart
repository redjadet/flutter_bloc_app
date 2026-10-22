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
    final SocialFeedCubit cubit = context.read<SocialFeedCubit>();
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
            child: _SocialFeedCommentSheet(postId: postId),
          ),
        );
      },
    );
  }
}

/// Sheet body that owns the draft [TextEditingController].
///
/// The controller lives in [State] so it is disposed when the sheet route
/// finishes its exit animation, not when `showModalBottomSheet` resolves
/// (the field is still mounted during the reverse transition).
class const _SocialFeedCommentSheet({required final String postId})
    extends StatefulWidget {
  @override
  State<_SocialFeedCommentSheet> createState() =>
      _SocialFeedCommentSheetState();
}

class _SocialFeedCommentSheetState extends State<_SocialFeedCommentSheet> {
  static const SocialFeedCommentPolicy _policy = SocialFeedCommentPolicy();
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String body = _controller.text;
    setState(() {});
    final bool accepted = await context.read<SocialFeedCubit>().submitComment(
      postId: widget.postId,
      body: body,
    );
    if (!mounted) {
      return;
    }
    if (accepted) {
      Navigator.of(context).pop();
    }
    // Rejection / queue write failure: keep sheet + draft.
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool valid = _policy.isValid(_controller.text);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextField(
          key: const ValueKey('social-feed-comment-field'),
          controller: _controller,
          maxLines: 3,
          enabled: true,
          decoration: InputDecoration(labelText: l10n.socialFeedDemoComment),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        FilledButton(
          key: const ValueKey('social-feed-comment-submit'),
          onPressed: valid ? _submit : null,
          child: Text(l10n.socialFeedDemoSubmitComment),
        ),
      ],
    );
  }
}
