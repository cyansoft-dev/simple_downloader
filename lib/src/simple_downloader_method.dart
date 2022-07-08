import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:http/http.dart';

import 'simple_downloader_callback.dart';
import 'simple_downloader_task.dart';

/// Controller to handle process downloading file
class DownloaderMethod {
  final Client client;
  final DownloaderTask task;
  final DownloaderCallback callback;

  DownloaderMethod(
      {required this.client, required this.task, required this.callback});

  Future<StreamSubscription> start() async {
    late StreamSubscription subscription;
    int total = 0;
    int offset = 0;

    try {
      Client httpClient = client;
      Request request = Request('GET', Uri.parse(task.url!));
      StreamedResponse response = await httpClient.send(request);
      total = response.contentLength!;

      // Open file
      File file = await _createFile();

      final reader = ChunkedStreamReader(response.stream);

      subscription = _streamData(reader).listen((buffer) async {
        // accumulate length downloaded
        offset += buffer.length;

        // Write buffer to disk
        file.writeAsBytesSync(buffer, mode: FileMode.writeOnlyAppend);

        // callback download progress
        callback
          ..offset = offset
          ..total = total
          ..progress = (offset / total) * 100
          ..status = DownloadStatus.running;
      }, onDone: () async {
        // rename file
        await file.rename('${task.downloadPath!}/${task.fileName!}');

        // callback download progress
        callback.status = DownloadStatus.completed;
      }, onError: (error) {
        subscription.pause();

        // callback download progress
        callback.status = DownloadStatus.failed;
      });

      return subscription;
    } catch (e) {
      rethrow;
    }
  }

  Stream<Uint8List> _streamData(ChunkedStreamReader<int> reader) async* {
    // set the chunk size
    int chunkSize = task.bufferSize;
    Uint8List buffer;
    do {
      buffer = await reader.readBytes(chunkSize);
      yield buffer;
    } while (buffer.length == chunkSize);
  }

  Future<bool> deleteFiles() async {
    try {
      final file = File('${task.downloadPath!}/${task.fileName!}');

      if (await file.exists()) {
        await file.delete();
      }

      /// callback download progress
      callback
        ..progress = 0.0
        ..status = DownloadStatus.deleted;

      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  Future<File> _createFile() async {
    try {
      // checking file .tmp or download file is exists or not
      // if file exists, file delete first before create.
      final tempFile = File('${task.downloadPath!}/${task.fileName!}.tmp');
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      final file = File('${task.downloadPath!}/${task.fileName!}');
      if (await file.exists()) {
        await file.delete();
      }

      await tempFile.create(recursive: true);

      return Future.value(tempFile);
    } catch (e) {
      rethrow;
    }
  }
}
