import 'package:flutter/services.dart';

import 'flutter_web_auth_2_platform_interface.dart';

/// An implementation of [FlutterWebAuth2Platform] that uses method channels.
class MethodChannelFlutterWebAuth2 extends FlutterWebAuth2Platform {
  /// The method channel used to interact with the native platform.
  final methodChannel = const MethodChannel('flutter_web_auth_2');

  @override
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
    required Map<String, dynamic> options,
  }) async {
    final result = await methodChannel.invokeMethod<String>('authenticate', {
      'url': url,
      'callbackUrlScheme': callbackUrlScheme,
      'options': options,
    });

    if (result == null) {
      throw Exception('Unexpected null result from authenticate call');
    }

    return result;
  }

  @override
  Future<void> clearAllDanglingCalls() async {
    await methodChannel.invokeMethod<void>('cleanUpDanglingCalls');
  }
}
