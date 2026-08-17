import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/demo_balance.dart';
import 'package:flutter_bloc_app/features/igaming_demo/domain/game_round_result.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/cubit/game_cubit.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/cubit/game_state.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/widgets/slot_machine_spinner.dart';
import 'package:flutter_bloc_app/features/igaming_demo/presentation/widgets/slot_symbol_text_style.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';
import 'package:material_ui/material_ui.dart';

part 'game_page_legend.part.dart';
part 'game_page_sections.part.dart';

/// Game page for one play-for-fun round: stake, spin, result.
class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.igamingDemoGameTitle,
      body: Builder(
        builder: (context) {
          final errorMessage = context
              .selectState<GameCubit, GameState, String?>(
                selector: _gameErrorMessage,
              );
          if (errorMessage case final String message?) {
            return CommonErrorView(
              message: message,
              onRetry: () => context.cubit<GameCubit>().loadBalance(),
            );
          }
          return const _GameScaffold();
        },
      ),
    );
  }
}

String? _gameErrorMessage(GameState state) =>
    state.mapOrNull(error: (error) => error.message);

DemoBalance? _displayBalance(GameState state) => state.when(
  idle: (balance, selectedStake) => balance,
  placingBet: (balance, selectedStake) => balance,
  spinning: (balance, bet, targetIndices) => DemoBalance(
    amountUnits: (balance.amountUnits - bet).clamp(0, balance.amountUnits),
  ),
  result: (
    roundResult,
    newBalance,
    selectedStake,
    targetIndices,
  ) => newBalance,
  error: (message) => null,
);

bool _isSpinning(GameState state) =>
    state.mapOrNull(spinning: (spinning) => true) ?? false;

GameRoundResult? _roundResult(GameState state) =>
    state.mapOrNull(result: (result) => result.roundResult);
