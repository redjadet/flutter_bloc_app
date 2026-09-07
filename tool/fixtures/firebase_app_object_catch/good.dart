// Fixture: Firebase.app() caught as Object — passes the guard.
void goodOptionalFirebase() {
  try {
    if (Firebase.apps.isEmpty) {
      fallback();
      return;
    }
    final app = Firebase.app();
    use(app);
  } on Object {
    fallback();
  }
}

class Firebase {
  static final List<Object> apps = <Object>[];
  static Object app() => Object();
}

void use(Object app) {}
void fallback() {}
