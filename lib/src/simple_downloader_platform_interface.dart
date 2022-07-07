import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'simple_downloader_task.dart';
import 'simple_downloader_method_channel.dart';

abstract class SimpleDownloaderPlatform extends PlatformInterface {
  /// Constructs a SimpleDownloaderPlatform.
  SimpleDownloaderPlatform() : super(token: _token);

  static final Object _token = Object();

  static SimpleDownloaderPlatform _instance = MethodChannelSimpleDownloader();

  /// The default instance of [SimpleDownloaderPlatform] to use.
  ///
  /// Defaults to [MethodChannelSimpleDownloader].
  static SimpleDownloaderPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SimpleDownloaderPlatform] when
  /// they register themselves.
  static set instance(SimpleDownloaderPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool?> openFile(DownloaderTask task) {
    throw UnimplementedError('');
  }
}
