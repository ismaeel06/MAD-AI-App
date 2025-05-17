import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel_flutter_web_auth_2.dart';

/// The interface that implementations of flutter_web_auth_2 must implement.
abstract class FlutterWebAuth2Platform extends PlatformInterface {
  /// Constructs a FlutterWebAuth2Platform.
  FlutterWebAuth2Platform() : super(token: _token);

  static final Object _token = Object();

  static FlutterWebAuth2Platform _instance = MethodChannelFlutterWebAuth2();

  /// The default instance of [FlutterWebAuth2Platform] to use.
  ///
  /// Defaults to [MethodChannelFlutterWebAuth2].
  static FlutterWebAuth2Platform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [FlutterWebAuth2Platform] when they register themselves.
  static set instance(FlutterWebAuth2Platform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Ask the user to authenticate to the specified web service.
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
    required Map<String, dynamic> options,
  }) {
    throw UnimplementedError('authenticate() has not been implemented.');
  }

  /// Clean up any dangling authentication flows.
  Future<void> clearAllDanglingCalls() {
    throw UnimplementedError(
        'clearAllDanglingCalls() has not been implemented.');
  }
}
