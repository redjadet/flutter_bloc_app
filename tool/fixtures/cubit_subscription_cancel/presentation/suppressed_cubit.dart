class SuppressedCubit {
  void start(final Stream<int> stream) {
    // check-ignore: fixture documents warn-only suppression
    stream.listen((final _) {});
  }
}
