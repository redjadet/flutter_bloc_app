import 'package:design_system/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/cubit/genui_demo_cubit.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/cubit/genui_demo_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_loading_widget.dart';
import 'package:genui/genui.dart' as genui;

part 'genui_demo_content_widgets.part.dart';

class GenUiDemoContent extends StatefulWidget {
  const GenUiDemoContent({super.key});

  @override
  State<GenUiDemoContent> createState() => _GenUiDemoContentState();
}

class _GenUiDemoContentState extends State<GenUiDemoContent> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    final cubit = context.cubit<GenUiDemoCubit>();
    await cubit.sendMessage(text);
  }

  @override
  Widget build(final BuildContext context) {
    final isInitial = context.selectState<GenUiDemoCubit, GenUiDemoState, bool>(
      selector: (final state) =>
          state.maybeWhen(initial: () => true, orElse: () => false),
    );

    if (isInitial) {
      return const CommonLoadingWidget();
    }

    return Column(
      children: [
        const Expanded(child: _GenUiMainSection()),
        _GenUiInputRow(
          textController: _textController,
          onSendMessage: _sendMessage,
        ),
      ],
    );
  }
}
