package io.github.mawiak.tivibuddy

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.TransparencyMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    /**
     * Flutter draws on a transparent surface above the window, so the video
     * layer of Media3Plugin below it shows wherever Flutter leaves the
     * screen transparent (full screen playback).
     */
    override fun getTransparencyMode() = TransparencyMode.transparent

    private var media3: Media3Plugin? = null

    override fun onStart() {
        super.onStart()
        // The black layer exists from the start, so nothing undefined shows
        // where Flutter leaves the screen transparent.
        media3?.videoContainer()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        media3 = Media3Plugin(this, flutterEngine).also { it.register() }
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
            "io.github.mawiak.tivibuddy/updates",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "canInstall" -> result.success(UpdateInstaller.canInstall(this))
                "openInstallPermission" -> {
                    UpdateInstaller.openInstallPermission(this)
                    result.success(null)
                }
                "install" -> {
                    UpdateInstaller.install(this, call.argument<String>("path")!!)
                    result.success(null)
                }
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
