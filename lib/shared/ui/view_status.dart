/// Shared view status lifecycle for presentation-layer states.
enum ViewStatus { initial, loading, success, error }

extension ViewStatusX on ViewStatus {
  bool get isInitial => this == ViewStatus.initial;
  bool get isLoading => this == ViewStatus.loading;
  bool get isSuccess => this == ViewStatus.success;
  bool get isError => this == ViewStatus.error;
}
