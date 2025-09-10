import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/counter_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CounterActions extends StatelessWidget {
  const CounterActions({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n =
        Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizationsEn();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: () => context.read<CounterCubit>().increment(),
          tooltip: l10n.incrementTooltip,
          child: Icon(Icons.add, size: 24.sp),
        ),
        SizedBox(height: 12.h),
        FloatingActionButton(
          onPressed: () => context.read<CounterCubit>().decrement(),
          tooltip: l10n.decrementTooltip,
          child: Icon(Icons.remove, size: 24.sp),
        ),
      ],
    );
  }
}
