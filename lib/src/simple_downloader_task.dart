import 'package:flutter/foundation.dart';

@immutable
class DownloaderTask {
  /// to set url
  final String? url;

  final String? downloadPath;

  /// to set file name of downloaded file
  /// dont forget to add extension of file name.
  final String? fileName;

  /// to set value of buffer size
  /// default 64 ( this mean 64 kb or 64 * 1024 )
  final int bufferSize;

  const DownloaderTask(
      {this.url, this.downloadPath, this.fileName, this.bufferSize = 64});

  DownloaderTask copyWith({
    String? url,
    String? downloadPath,
    String? fileName,
    int? bufferSize,
  }) {
    return DownloaderTask(
      url: url ?? this.url,
      downloadPath: downloadPath ?? this.downloadPath,
      fileName: fileName ?? this.fileName,
      bufferSize: bufferSize ?? this.bufferSize,
    );
  }
}
