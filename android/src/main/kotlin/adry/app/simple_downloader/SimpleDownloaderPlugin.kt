package adry.app.simple_downloader

import android.content.Context
import android.os.Build
import androidx.annotation.NonNull
import adry.app.simple_downloader.IntentUtils.validatedFileIntent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File


/** FlDownloaderPlugin */
class SimpleDownloaderPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context : Context 

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "simple_downloader")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when(call.method){
      "getPlatformVersion"-> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "openFile"-> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        open(call, result)
      }
      else ->  result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
  
  private fun open(call: MethodCall, result: Result) {
    val savedDir:String? = call.argument<String>("savedDir")
    val fileName:String? =call.argument<String>("fileName")
    val mimeType:String? = call.argument<String>("mimeType")

    val saveFilePath:String = savedDir + File.separator.toString() + fileName
    val intent = validatedFileIntent(context, saveFilePath, mimeType!!)
    if (intent == null) {
      result.success(false)
    }else{
      context.startActivity(intent)
      result.success(true)
    }
  }
}
