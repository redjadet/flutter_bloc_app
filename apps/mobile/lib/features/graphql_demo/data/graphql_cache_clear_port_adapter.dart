import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_cache_repository.dart';
import 'package:utilities/utilities.dart';

class GraphqlCacheClearPortAdapter implements GraphqlCacheClearPort {
  GraphqlCacheClearPortAdapter(this._repository);

  final GraphqlCacheRepository _repository;

  @override
  Future<void> clear() => _repository.clear();
}
