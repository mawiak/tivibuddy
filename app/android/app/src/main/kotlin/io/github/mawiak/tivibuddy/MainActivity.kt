package io.github.mawiak.tivibuddy

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Media3Plugin(applicationContext, flutterEngine).register()
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "io.github.mawiak.tivibuddy/audio",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "passthroughCapabilities" ->
                    result.success(AudioCapabilities.query(applicationContext))
                else -> result.notImplemented()
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "io.github.mawiak.tivibuddy/display",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "find" -> result.success(DisplayModes.find(this, call.argument<Double>("fps")!!))
                "apply" -> DisplayModes.apply(this, call.argument<Int>("modeId")!!) {
                    result.success(it)
                }
                "isSwitched" -> result.success(DisplayModes.isSwitched(this))
                else -> result.notImplemented()
            }
        }
    }
}
