/// Source of chart trending data (for telemetry and optional UI badge).
enum ChartDataSource {
  remote,
  supabaseEdge,
  supabaseTables,
  firebaseCloud,
  firebaseFirestore,
  cache,
  unknown,
}
