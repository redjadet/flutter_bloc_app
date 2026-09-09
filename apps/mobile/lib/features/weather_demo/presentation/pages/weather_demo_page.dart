import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/features/weather_demo/domain/weather_snapshot.dart';
import 'package:flutter_bloc_app/features/weather_demo/presentation/cubit/weather_cubit.dart';
import 'package:flutter_bloc_app/features/weather_demo/presentation/cubit/weather_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

class const WeatherDemoPage({super.key}) extends StatefulWidget {
  @override
  State<WeatherDemoPage> createState() => _WeatherDemoPageState();
}

class _WeatherDemoPageState extends State<WeatherDemoPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch() {
    unawaited(context.read<WeatherCubit>().search(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.weatherDemoTitle)),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.responsiveGapM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: l10n.weatherDemoCityLabel,
                  hintText: l10n.weatherDemoCityHint,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _onSearch(),
              ),
              SizedBox(height: context.responsiveGapS),
              FilledButton(
                onPressed: _onSearch,
                child: Text(l10n.weatherDemoSearchButton),
              ),
              SizedBox(height: context.responsiveGapM),
              Expanded(
                child: BlocBuilder<WeatherCubit, WeatherState>(
                  builder: (context, state) {
                    return switch (state) {
                      WeatherIdle() => Center(
                        child: Text(l10n.weatherDemoIdleHint),
                      ),
                      WeatherLoading() => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      WeatherSuccess(:final snapshot) => _WeatherResult(
                        snapshot: snapshot,
                        l10n: l10n,
                      ),
                      WeatherFailureState(:final failure) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              failure.displayMessage,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: context.responsiveGapS),
                            OutlinedButton(
                              onPressed: () =>
                                  context.read<WeatherCubit>().retry(),
                              child: Text(l10n.weatherDemoRetryButton),
                            ),
                          ],
                        ),
                      ),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class const _WeatherResult({
  required final WeatherSnapshot snapshot,
  required final AppLocalizations l10n,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return ListView(
      children: <Widget>[
        Text(snapshot.placeName, style: textTheme.headlineSmall),
        SizedBox(height: context.responsiveGapS),
        Text(
          '${snapshot.temperatureC.toStringAsFixed(1)} °C',
          style: textTheme.displaySmall,
        ),
        Text(snapshot.weatherDescription, style: textTheme.titleMedium),
        SizedBox(height: context.responsiveGapS),
        Text(
          l10n.weatherDemoWindLabel(snapshot.windSpeedKmh.toStringAsFixed(1)),
        ),
        if (snapshot.hourly.isNotEmpty) ...<Widget>[
          SizedBox(height: context.responsiveGapM),
          Text(l10n.weatherDemoHourlyTitle, style: textTheme.titleMedium),
          SizedBox(height: context.responsiveGapS),
          Builder(
            builder: (context) {
              final List<WeatherHourlyPoint> hourly =
                  List<WeatherHourlyPoint>.of(snapshot.hourly, growable: false);
              return SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: hourly.length,
                  separatorBuilder: (_, _) =>
                      SizedBox(width: context.responsiveGapS),
                  itemBuilder: (context, index) {
                    if (index >= hourly.length) {
                      return const SizedBox.shrink();
                    }
                    final WeatherHourlyPoint point = hourly[index];
                    final String hour =
                        '${point.time.hour.toString().padLeft(2, '0')}:00';
                    return Column(
                      key: ValueKey<String>(
                        'weather-demo-hourly-${point.time.toIso8601String()}',
                      ),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(hour),
                        Text('${point.temperatureC.toStringAsFixed(0)}°'),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ],
        SizedBox(height: context.responsiveGapL),
        Text(l10n.weatherDemoAttribution, style: textTheme.bodySmall),
      ],
    );
  }
}
