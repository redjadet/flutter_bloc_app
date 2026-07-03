/// Port for clearing the GraphQL demo/offline cache from diagnostics UI without
/// depending on `graphql_demo` presentation or domain types.
abstract class GraphqlCacheClearPort {
  Future<void> clear();
}
