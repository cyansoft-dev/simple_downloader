# simple_downloader

A flutter package for handle downloading file using http in more simple & easy.

## Getting Started

In your flutter project add the dependency in your pubspec.yaml:
```yml
dependencies:
...
simple_downloader: ^0.0.1
```

## Usage

### importing package
```
import 'package:simple_downloader/simple_downloader.dart';
```
### Initialize 
```
late FlDownloader _downloader;

double _progress = 0;
DownloadStatus _status = DownloadStatus.undefined;

@override
void initState() {
    super.initState();
    init();
}

Future<void> init() async {
    final pathFile = (await path.getExternalStorageDirectory())!.path;
    if (!mounted) return;

    _downloader = FlDownloader.init(
        task: DownloaderTask(
    url: "https://file-examples.com/storage/fe2de9ae4662c61a094f3db/2017/10/file_example_JPG_2500kB.jpg",
    downloadPath: pathFile,
    fileName: "Downloaded.jpg",
    ));

    _downloader.callback.addListener(() {
    setState(() {
        _progress = _downloader.callback.progress;
        _status = _downloader.callback.status;
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

### To open downloaded file if complete ( Support android only )
```
final isSuccess = (await _downloader.open())!;

if(!isSuccess){
    debugPrint("Failed to open downloaded file.");
}
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

