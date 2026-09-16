class SuppressedCubit {
  void start(Stream<int> stream) {
    // check-ignore: fixture documents warn-only suppression
    stream.listen((_) {});
  }
}
