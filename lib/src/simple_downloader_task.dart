import 'package:flutter/foundation.dart';

@immutable
class DownloaderTask {
  final String? url;
  final String? downloadPath;
  final String? fileName;
  final int? bufferSize;

  const DownloaderTask(
      {this.url, this.downloadPath, this.fileName, this.bufferSize});

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
