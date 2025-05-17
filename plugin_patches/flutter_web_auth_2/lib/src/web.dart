// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html';
import 'dart:js_util' as js_util;

import 'package:flutter/foundation.dart';
import 'package:window_to_front/window_to_front.dart';

/// A wrapper around `window.open` on the Web.
class web {
  /// Open a new browser window and return the callback URL after the redirect.
  static Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
    required int timeout,
    required String? windowName,
    required String? debugOrigin,
    required bool silentAuth,
  }) async {
    final completer = Completer<String>();

    // Prepare the origin regex for validation
    final customCallbackHostRegex = debugOrigin != null
        ? RegExp('^$debugOrigin')
        : RegExp('^${Uri.base.origin}');

    // Set up the message event handler
    final subscription = window.onMessage.listen((event) {
      if (completer.isCompleted) return;
      if (event.origin.isEmpty) return;

      if (kDebugMode) print('EVENT MESSAGE ${event.data} ${event.origin}');

      if (customCallbackHostRegex.hasMatch(event.origin)) {
        if (event.data is String && event.data.startsWith(callbackUrlScheme)) {
          completer.complete(event.data as String);
        }
      }
    });

    // Set a timeout
    Future<void>.delayed(Duration(seconds: timeout), () {
      if (completer.isCompleted) return;
      completer.completeError(
        TimeoutException(
          'Timeout waiting for authentication',
          Duration(seconds: timeout),
        ),
      );
    });

    // Use an iframe for silent auth
    if (silentAuth) {
      final iframeElem = IFrameElement()
        ..style.position = 'absolute'
        ..style.top = '-9999px'
        ..style.left = '-9999px'
        ..src = url;
      document.body!.append(iframeElem);

      try {
        await completer.future;
      } finally {
        iframeElem.remove();
        subscription.cancel();
      }

      // Bring the window back to front
      await WindowToFront.activate();

      return completer.future;
    }

    // Use window.open for interactive auth
    final popupWidth = 450;
    final popupHeight = 600;

    final left =
        (window.screenX ?? 0) + ((window.outerWidth ?? 0) - popupWidth) / 2;
    final top =
        (window.screenY ?? 0) + ((window.outerHeight ?? 0) - popupHeight) / 2;

    final features = '''
      popup=yes,
      width=$popupWidth,
      height=$popupHeight,
      left=$left,
      top=$top
    '''
        .trim();

    // Open the popup
    final popup = window.open(url, windowName ?? '', features);

    // Check for popup blockers
    if (popup == null) {
      subscription.cancel();
      throw Exception(
        'Popup was blocked by the browser. '
        'Please allow popups for this domain.',
      );
    }

    // Set interval to check if popup is closed
    final checkClosedTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (js_util.getProperty(popup, 'closed') == true) {
        if (!completer.isCompleted) {
          completer.completeError(Exception('User closed the popup window'));
        }
        timer.cancel();
        subscription.cancel();
      }
    });

    try {
      await completer.future;
    } finally {
      checkClosedTimer.cancel();
      subscription.cancel();
      popup.close();
    }

    // Bring the window back to front
    await WindowToFront.activate();

    return completer.future;
  }
}
