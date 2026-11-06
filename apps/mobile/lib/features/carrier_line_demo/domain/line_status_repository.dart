import 'package:flutter_bloc_app/features/carrier_line_demo/domain/line_status.dart';

/// Read port for eSIM / porting / billing status cards.
abstract interface class LineStatusRepository {
  Future<LineStatusSnapshot> fetch();
}
