# simple_downloader

A flutter package for handle downloading file using http in more simple & easy.


## Getting Started

In your flutter project add the dependency in your pubspec.yaml:
```yml
dependencies:
...
simple_downloader: ^0.0.3
```

## Usage

### importing package
```
import 'package:simple_downloader/simple_downloader.dart';
```
### Initialize 
```
late SimpleDownloader _downloader;

double _progress = 0.0;
int _offset = 0;
int _total = 0;
DownloadStatus _status = DownloadStatus.undefined;
DownloaderTask _task = const DownloaderTask(
    url:"https://images.unsplash.com/photo-1615220368123-9bb8faf4221b?ixlib=rb-1.2.1&dl=vadim-kaipov-f6jkAE1ZWuY-unsplash.jpg&q=80&fm=jpg&crop=entropy&cs=tinysrgb",
    fileName: "images_downloaded.jpg",
    bufferSize:
        1024, // if bufferSize value not set, default value is 64 ( 64 Kb )
    );

@override
void initState() {
    super.initState();
    init();
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

```

### Dispose
```
@override
void dispose() {
    _downloader.dispose();
    super.dispose();
}

```

### To start downloader
```
_downloader.download();
```

### To pause downloader
```
_downloader.pause();
```

### To resume downloader
```
_downloader.resume();
```

### To cancel downloader
```
_downloader.cancel();
```

### To retry downloader
```
_downloader.retry();
```

### To restart downloader
```
_downloader.restart();
```

### To open downloaded file if complete ( Support android only )
```
_downloader.open().then(
    (isSuccess) {
        if (!isSuccess!) {
        print(context, "Failed to open downloaded file.");
        }
    },
);
```

## Android Integration

In order to handle click action to open the downloaded file, you need to add some additional configurations.

Add the following to AndroidManifest.xml:
```
<application>
        ...
        <provider
            android:name="adry.app.simple_downloader.FileProvider"
            android:authorities="${applicationId}.simple_downloader.provider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/file_path"/>
        </provider>  
<application>
```

In order to open APK files, your application needs REQUEST_INSTALL_PACKAGES permission.

Add the following to AndroidManifest.xml:
```
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />     
```

## Note
This plugin is not support for downloading file from google drive.
