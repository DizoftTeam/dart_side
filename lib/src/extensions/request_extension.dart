import 'dart:io';
import 'dart:convert';

///
/// This extension add some methods for simple work with request
///
extension DartSideRequest on HttpRequest {
  ///
  /// Get Request as Json
  ///
  /// If this request is not a json - [Null] will be returned
  ///
  Future<dynamic?> json() async {
    if (this.method != 'GET' &&
        this.headers.contentType?.mimeType != 'application/json') {
      return null;
    }

    return jsonDecode(
      await utf8.decoder.bind(this).join(),
    );
  }
}
