import 'package:http/http.dart' as http;

/// Extension methods for convenient HTTP client usage with error mapping
extension HttpRequestExtensions on http.BaseRequest {
  /// Clone a request for retry purposes
  http.BaseRequest clone() {
    if (this is http.Request) {
      final http.Request original = this as http.Request;
      final http.Request cloned = http.Request(original.method, original.url);
      cloned.headers.addAll(original.headers);
      if (original.body.isNotEmpty) {
        cloned.body = original.body;
      }
      return cloned;
    } else if (this is http.MultipartRequest) {
      throw UnsupportedError(
        'Cannot clone MultipartRequest safely; file streams are single-use.',
      );
    } else {
      throw UnsupportedError('Cannot clone request of type $runtimeType');
    }
  }
}
