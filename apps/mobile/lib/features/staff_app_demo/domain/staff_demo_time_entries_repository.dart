import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_time_entry_summary.dart';

abstract interface class StaffDemoTimeEntriesRepository {
  Future<List<StaffDemoTimeEntrySummary>> fetchRecent({int limit = 20});
}
