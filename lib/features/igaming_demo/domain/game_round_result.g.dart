// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_round_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GameRoundResult _$GameRoundResultFromJson(Map<String, dynamic> json) =>
    _GameRoundResult(
      betAmount: (json['betAmount'] as num).toInt(),
      payoutAmount: (json['payoutAmount'] as num).toInt(),
      isWin: json['isWin'] as bool,
    );

Map<String, dynamic> _$GameRoundResultToJson(_GameRoundResult instance) =>
    <String, dynamic>{
      'betAmount': instance.betAmount,
      'payoutAmount': instance.payoutAmount,
      'isWin': instance.isWin,
    };
