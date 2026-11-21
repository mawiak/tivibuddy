package io.github.mawiak.tivibuddy

import android.app.Activity
import android.graphics.Color
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.media3.common.C
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Method channel for [Media3Player] instances. Each player gets its own
 * event channel `io.github.mawiak.tivibuddy/media3/<id>`.
 */
class Media3Plugin(private val activity: Activity, private val engine: FlutterEngine) :
    MethodChannel.MethodCallHandler {
    private val players = mutableMapOf<Long, Media3Player>()
    private var nextId = 1L

    fun register() {
        MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "create") {
            val id = nextId++
            val player = Media3Player(activity.applicationContext, engine.renderer.createSurfaceProducer())
            EventChannel(engine.dartExecutor.binaryMessenger, "$CHANNEL/$id").setStreamHandler(player)
            players[id] = player
            result.success(mapOf("id" to id, "textureId" to player.textureId))
            return
        }
        val id = call.argument<Number>("id")?.toLong()
        val player = players[id] ?: return result.error("unknown_player", "No player $id", null)
        when (call.method) {
            "open" -> player.open(
                call.argument<String>("url")!!,
                call.argument<Number>("startMs")?.toLong(),
            )
            "play" -> player.play()
            "pause" -> player.pause()
            "seek" -> player.seek(call.argument<Number>("positionMs")!!.toLong())
            "selectAudio" -> player.selectTrack(C.TRACK_TYPE_AUDIO, call.argument("track"))
            "selectText" -> player.selectTrack(C.TRACK_TYPE_TEXT, call.argument("track"))
            "refreshAudio" -> player.refreshAudio()
            "showInView" -> player.showInView(
                videoContainer(),
                call.argument<Number>("left")!!.toInt(),
                call.argument<Number>("top")!!.toInt(),
                call.argument<Number>("width")!!.toInt(),
                call.argument<Number>("height")!!.toInt(),
            )
            "showInTexture" -> player.showInTexture()
            "stop" -> player.stop()
            "dispose" -> {
                players.remove(id)?.release()
                EventChannel(engine.dartExecutor.binaryMessenger, "$CHANNEL/$id").setStreamHandler(null)
            }
            else -> return result.notImplemented()
        }
        result.success(null)
    }

    /**
     * Black layer behind the Flutter view that holds the video layers; the
     * Flutter view is transparent where the video shows (see MainActivity).
     */
    fun videoContainer(): ViewGroup {
        val content = activity.findViewById<FrameLayout>(android.R.id.content)
        content.findViewWithTag<FrameLayout>(VIDEO_TAG)?.let { return it }
        val container = FrameLayout(activity).apply {
            tag = VIDEO_TAG
            setBackgroundColor(Color.BLACK)
        }
        content.addView(
            container,
            0,
            FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
            ),
        )
        return container
    }

    companion object {
        const val CHANNEL = "io.github.mawiak.tivibuddy/media3"
        private const val VIDEO_TAG = "tivibuddy-video"
    }
}
