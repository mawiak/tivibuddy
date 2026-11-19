package io.github.mawiak.tivibuddy

import android.content.Context
import androidx.media3.common.C
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Method channel for [Media3Player] instances. Each player gets its own
 * event channel `io.github.mawiak.tivibuddy/media3/<id>`.
 */
class Media3Plugin(private val context: Context, private val engine: FlutterEngine) :
    MethodChannel.MethodCallHandler {
    private val players = mutableMapOf<Long, Media3Player>()
    private var nextId = 1L

    fun register() {
        MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "create") {
            val id = nextId++
            val player = Media3Player(context, engine.renderer.createSurfaceProducer())
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
            "stop" -> player.stop()
            "dispose" -> {
                players.remove(id)?.release()
                EventChannel(engine.dartExecutor.binaryMessenger, "$CHANNEL/$id").setStreamHandler(null)
            }
            else -> return result.notImplemented()
        }
        result.success(null)
    }

    companion object {
        const val CHANNEL = "io.github.mawiak.tivibuddy/media3"
    }
}
