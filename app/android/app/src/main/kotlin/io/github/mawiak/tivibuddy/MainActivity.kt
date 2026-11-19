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
    }
}
