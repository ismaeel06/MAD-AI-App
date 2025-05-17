import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// This class provides the functionality to receive the redirect from
/// the authentication server. It sets up a small HTTP server and
/// waits for the redirect.
class server {
  /// Start the server and wait for the redirect
  static Future<String> startServer({
    required String callbackUrlScheme,
    required int timeout,
    required String landingPageHtml,
  }) async {
    final completer = Completer<String>();

    try {
      // Start server
      final server = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        0,
        shared: true,
      );

      // Prepare a timeout error
      Future<void>.delayed(Duration(seconds: timeout), () {
        if (completer.isCompleted) return;
        completer.completeError(
          TimeoutException(
            'Timeout waiting for authentication',
            Duration(seconds: timeout),
          ),
        );
        server.close(force: true);
      });

      // Get the port
      final port = server.port;
      debugPrint('Server started on port $port');

      // Listen for requests
      server.listen((HttpRequest request) async {
        debugPrint('Received request');

        // Respond with the landing page
        request.response.statusCode = 200;
        request.response.headers
            .set('Content-Type', 'text/html; charset=utf-8');
        request.response.write(landingPageHtml);
        await request.response.close();

        if (completer.isCompleted) return;

        // Complete the future and close the server
        completer.complete('${request.uri}');
        server.close(force: true);
      });

      // Create a custom handler URL to complete the request
      return completer.future;
    } catch (e) {
      // If the server couldn't start, propagate the error
      if (!completer.isCompleted) completer.completeError(e);
      return completer.future;
    }
  }
}
