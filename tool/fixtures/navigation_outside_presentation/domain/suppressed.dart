import 'package:go_router/go_router.dart'; // check-ignore: fixture — navigation API allowed in test

void navigateSuppressed(
  final GoRouter router, // check-ignore: fixture
) {
  router.go('/suppressed-fixture'); // check-ignore: fixture
}
