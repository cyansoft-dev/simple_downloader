#import "FlDownloaderPlugin.h"
#if __has_include(<simple_downloader/simple_downloader-Swift.h>)
#import <simple_downloader/simple_downloader-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "simple_downloader-Swift.h"
#endif

@implementation FlDownloaderPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlDownloaderPlugin registerWithRegistrar:registrar];
}
@end
