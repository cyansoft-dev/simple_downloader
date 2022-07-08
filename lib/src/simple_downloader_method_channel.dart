// ignore_for_file: depend_on_referenced_packages

import 'simple_downloader_task.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

import 'simple_downloader_platform_interface.dart';

/// An implementation of [SimpleDownloaderPlatform] that uses method channels.
class MethodChannelSimpleDownloader extends SimpleDownloaderPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('simple_downloader');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool?> openFile(DownloaderTask task) async {
    try {
      final extFile = extension('${task.downloadPath!}/${task.fileName!}');
      if (extFile.isEmpty) {
        throw Exception("failed to get extension downloaded file.");
      }

      final mimeType =
          lookupMimeType('${task.downloadPath!}/${task.fileName!}');

      if (mimeType == null) {
        throw Exception("failed to get content type downloaded file.");
      }

      final result = await methodChannel.invokeMethod<bool>('openFile', {
        "savedDir": task.downloadPath,
        "fileName": task.fileName,
        "mimeType": mimeType
      });

      return result;
    } on PlatformException catch (e) {
      final error = e;
      throw error;
    }
  }
}
