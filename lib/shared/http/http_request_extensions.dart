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
      final http.MultipartRequest original = this as http.MultipartRequest;
      final http.MultipartRequest cloned = http.MultipartRequest(
        original.method,
        original.url,
      );
      cloned.headers.addAll(original.headers);
      cloned.fields.addAll(original.fields);
      cloned.files.addAll(original.files);
      return cloned;
    } else {
      throw UnsupportedError('Cannot clone request of type $runtimeType');
    }
  }
}
