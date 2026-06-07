// check-ignore: fixture proves reviewed suppression path
import '../data/order_dto.dart';

class SuppressedDomain {
  const SuppressedDomain(this.dto);

  final OrderDto dto;
}
