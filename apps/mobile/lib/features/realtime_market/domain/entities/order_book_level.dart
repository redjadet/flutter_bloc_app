import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_book_level.freezed.dart';

enum OrderBookSide { bid, ask }

@freezed
abstract class OrderBookLevel with _$OrderBookLevel {
  const factory OrderBookLevel({
    required final double price,
    required final double quantity,
    required final OrderBookSide side,
  }) = _OrderBookLevel;
}
