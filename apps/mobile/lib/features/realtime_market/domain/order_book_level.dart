import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_book_level.freezed.dart';

enum OrderBookSide { bid, ask }

@freezed
abstract class OrderBookLevel with _$OrderBookLevel {
  const factory OrderBookLevel({
    required double price,
    required double quantity,
    required OrderBookSide side,
  }) = _OrderBookLevel;
}
