// This is a stub file for platforms that do not implement the server functionality
// ignore_for_file: camel_case_types

/// This class provides the functionality to receive the redirect from
/// the authentication server. The implementation can differ from platform
/// to platform, e.g. using a `HttpServer` or a `WebView`.
class server_dummy {
  /// Not supported on this platform
  static Future<String> startServer({
    required String callbackUrlScheme,
    required int timeout,
    required String landingPageHtml,
  }) =>
      throw UnsupportedError(
        'This platform does not support the server functionality',
      );
}
