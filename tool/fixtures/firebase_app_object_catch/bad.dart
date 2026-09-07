// Fixture: Firebase.app() caught only as Exception — fails the guard.
void badOptionalFirebase() {
  try {
    final app = Firebase.app();
    use(app);
  } on Exception {
    fallback();
  }
}

class Firebase {
  static Object app() => Object();
}

void use(Object app) {}
void fallback() {}
