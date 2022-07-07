export 'src/simple_downloader_task.dart';
export 'src/simple_downloader_callback.dart' show DownloadStatus;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

import 'src/simple_downloader_callback.dart';
import 'src/simple_downloader_task.dart';
import 'src/simple_downloader_method.dart';
import 'src/simple_downloader_platform_interface.dart';

/// this class using singleton pattern.
class SimpleDownloader {
  static SimpleDownloader? _instance;
  static StreamSubscription? _subscription;

  final Client _client;
  final DownloaderTask _task;
  final DownloaderCallback _callback;

  DownloaderCallback get callback => _callback;

  late DownloaderMethod _method;
  SimpleDownloader._internal(this._client, this._task, this._callback) {
    _method =
        DownloaderMethod(client: _client, task: _task, callback: _callback);
  }

  /// static method to initialize a this class.
  static SimpleDownloader init({required DownloaderTask task}) {
    if (_instance == null) {
      final Client client = Client();
      final DownloaderCallback callback = DownloaderCallback();
      return SimpleDownloader._internal(client, task, callback);
    }

    return _instance!;
  }

  /// disposing callback, http client & stream subsciption
  /// to release the memory allocated.
  void dispose() {
    _callback.dispose();
    _client.close();
    _subscription?.cancel();
  }

  /// start download file.
  Future<void> download() async {
    _subscription = await _method.start();
  }

  /// pause downloading file.
  Future<void> pause() async {
    _callback.status = DownloadStatus.paused;
    _subscription?.pause();
  }

  /// resume downloading file.
  Future<void> resume() async {
    _callback.status = DownloadStatus.resume;
    _subscription?.resume();
  }

  /// cancel downloading file.
  Future<void> cancel() async {
    _callback.status = DownloadStatus.canceled;
    _subscription?.cancel();
  }

  /// retry downloading file.
  Future<void> retry() async {
    download();
  }

  /// try to open downloaded file.
  Future<bool?> open() async {
    final result = await SimpleDownloaderPlatform.instance.openFile(_task);
    debugPrint("$result");

    return result;
  }

  /// delete downloaded file.
  Future<bool?> delete() async {
    return await _method.deleteFiles();
  }
}
