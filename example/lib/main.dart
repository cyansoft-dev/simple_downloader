import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart' as path;
import 'package:simple_downloader/simple_downloader.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SimpleDownloader _downloader;

  double _progress = 0.0;
  int _offset = 0;
  int _total = 0;

  DownloadStatus _status = DownloadStatus.undefined;
  DownloaderTask _task = const DownloaderTask(
    url:
        "https://file-examples.com/storage/fe2de9ae4662c61a094f3db/2017/10/file_example_JPG_2500kB.jpg",
    fileName: "file_example.jpg",
  );

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    _downloader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            height: 150,
            width: double.maxFinite,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 3),
                    spreadRadius: 3,
                    blurRadius: 3,
                  )
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ListTile(
                  visualDensity:
                      const VisualDensity(horizontal: -4, vertical: 0),
                  title: Text(_task.fileName ?? ""),
                  subtitle: labelStatus,
                  trailing: trailingIcon,
                ),
                const SizedBox(height: 25.0),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${_offset ~/ 1024} Kb / ${_total ~/ 1024} Kb",
                              textAlign: TextAlign.right),
                          Text("${_progress.floor()} %",
                              textAlign: TextAlign.right),
                        ],
                      ),
                      const SizedBox(height: 5),
                      LinearProgressIndicator(
                        value: _progress / 100,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> init() async {
    final pathFile = (await path.getExternalStorageDirectory())!.path;
    if (!mounted) return;

    _task = _task.copyWith(
      downloadPath: pathFile,
    );

    _downloader = SimpleDownloader.init(task: _task);

    _downloader.callback.addListener(() {
      setState(() {
        _progress = _downloader.callback.progress;
        _status = _downloader.callback.status;
        _total = _downloader.callback.total;
        _offset = _downloader.callback.offset;
      });
    });
  }

  Widget get labelStatus {
    switch (_status) {
      case DownloadStatus.running:
        return const Text("Downloading");
      case DownloadStatus.completed:
        return const Text("Download Completed");
      case DownloadStatus.failed:
        return const Text("Download Failed");
      case DownloadStatus.paused:
        return const Text("Download Paused");
      case DownloadStatus.deleted:
        return const Text("File Deleted");
      case DownloadStatus.canceled:
        return const Text("Download Canceled");
      default:
        return const Text("Waiting..");
    }
  }

  Widget? get trailingIcon {
    if (_status == DownloadStatus.undefined ||
        _status == DownloadStatus.deleted) {
      return IconButton(
        splashRadius: 20,
        onPressed: () => _downloader.download(),
        constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
        icon: const Icon(
          Icons.play_arrow,
        ),
      );
    }
    if (_status == DownloadStatus.running) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            splashRadius: 20,
            onPressed: () => _downloader.pause(),
            constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
            icon: const Icon(
              Icons.pause,
              color: Colors.green,
            ),
          ),
          IconButton(
            splashRadius: 20,
            onPressed: () => _downloader.cancel(),
            constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
            icon: const Icon(
              Icons.close,
              color: Colors.red,
            ),
          ),
        ],
      );
    }
    if (_status == DownloadStatus.paused) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            splashRadius: 20,
            onPressed: () => _downloader.resume(),
            constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
            icon: const Icon(
              Icons.play_arrow,
              color: Colors.blue,
            ),
          ),
          IconButton(
            splashRadius: 20,
            onPressed: () => _downloader.cancel(),
            constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
            icon: const Icon(
              Icons.close,
              color: Colors.red,
            ),
          ),
        ],
      );
    }

    if (_status == DownloadStatus.completed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            tooltip: "Open file",
            splashRadius: 20,
            onPressed: () async {
              _downloader.open().then(
                (isSuccess) {
                  if (!isSuccess!) {
                    showMessage(context, "Failed to open downloaded file.");
                  }
                },
              );
            },
            constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
            icon: const Icon(
              Icons.file_open,
              color: Colors.green,
            ),
          ),
          IconButton(
            tooltip: "Delete file",
            splashRadius: 20,
            onPressed: () => _downloader.delete(),
            constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ],
      );
    }

    if (_status == DownloadStatus.failed ||
        _status == DownloadStatus.canceled) {
      return IconButton(
        splashRadius: 20,
        onPressed: () => _downloader.retry(),
        constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
        icon: const Icon(
          Icons.refresh,
          color: Colors.green,
        ),
      );
    }

    return null;
  }

  Future<void> showMessage(
    BuildContext context,
    String message,
  ) async {
    final size = MediaQuery.of(context).size;
    return showModalBottomSheet(
        elevation: 2,
        isDismissible: false,
        enableDrag: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        context: context,
        builder: (builder) {
          return SizedBox(
            height: 250,
            child: Stack(children: [
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  splashRadius: 25,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    size: 25,
                  ),
                ),
              ),
              Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: 0.8 * size.width,
                  ),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                left: 20,
                child: ElevatedButton(
                  child: const Text(
                    "OK",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ]),
          );
        });
  }
}
