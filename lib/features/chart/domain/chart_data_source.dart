/// Source of chart trending data (for telemetry and optional UI badge).
enum ChartDataSource {
  remote,
  supabaseEdge,
  supabaseTables,
  cache,
  unknown,
}
