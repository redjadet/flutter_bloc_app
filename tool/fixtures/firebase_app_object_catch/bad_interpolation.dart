// Fixture: Firebase.app() inside string interpolation must still fail the guard.
void badInterpolatedFirebase() {
  try {
    log('${Firebase.app()}');
  } on Exception {
    fallback();
  }
}

class Firebase {
  static Object app() => Object();
}

void log(Object message) {}
void fallback() {}
