import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_inbox_item.dart';

/// Offline-first inbox port for the business phone line demo.
abstract interface class CarrierInboxRepository {
  Future<List<CarrierInboxItem>> fetchAll();

  Stream<List<CarrierInboxItem>> watchAll();

  Future<void> save(CarrierInboxItem item);

  Future<void> markRead(String id);

  /// Seeds demo rows when the local box is empty.
  Future<void> ensureSeeded();
}
