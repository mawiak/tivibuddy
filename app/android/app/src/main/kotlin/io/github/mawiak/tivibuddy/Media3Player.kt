package io.github.mawiak.tivibuddy

import android.content.Context
import android.os.Handler
import android.os.Looper
import androidx.annotation.OptIn
import androidx.media3.common.AudioAttributes
import androidx.media3.common.C
import androidx.media3.common.Format
import androidx.media3.common.MediaItem
import androidx.media3.common.MimeTypes
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.common.TrackSelectionOverride
import androidx.media3.common.Tracks
import androidx.media3.common.VideoSize
import androidx.media3.common.text.CueGroup
import androidx.media3.common.util.UnstableApi
import androidx.media3.datasource.DefaultDataSource
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.exoplayer.DecoderReuseEvaluation
import androidx.media3.exoplayer.DefaultLoadControl
import androidx.media3.exoplayer.DefaultRenderersFactory
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.analytics.AnalyticsListener
import androidx.media3.exoplayer.audio.AudioSink
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory
import androidx.media3.exoplayer.video.VideoFrameMetadataListener
import androidx.media3.extractor.DefaultExtractorsFactory
import androidx.media3.extractor.ts.DefaultTsPayloadReaderFactory
import io.flutter.plugin.common.EventChannel
import io.flutter.view.TextureRegistry

/**
 * One Media3 ExoPlayer rendering into a Flutter texture. Reports state,
 * tracks, subtitles and diagnostics as maps through [events]; see
 * media3_playback_engine.dart for the Dart side.
 *
 * Endless MPEG-TS live streams have no duration; they count as started as
 * soon as the player is ready, which wrappers that wait for a duration
 * never report.
 */
@OptIn(UnstableApi::class)
class Media3Player(
    context: Context,
    private val producer: TextureRegistry.SurfaceProducer,
) : EventChannel.StreamHandler {
    private var sink: EventChannel.EventSink? = null
    private val pending = mutableListOf<Map<String, Any?>>()
    private val handler = Handler(Looper.getMainLooper())

    private val player: ExoPlayer

    init {
        // Hardware decoders first; a software decoder when one fails.
        val renderers = DefaultRenderersFactory(context).setEnableDecoderFallback(true)
        val extractors = DefaultExtractorsFactory()
            // Broadcast streams often start without an IDR frame and
            // without access unit delimiters.
            .setTsExtractorFlags(
                DefaultTsPayloadReaderFactory.FLAG_ALLOW_NON_IDR_KEYFRAMES or
                    DefaultTsPayloadReaderFactory.FLAG_DETECT_ACCESS_UNITS,
            )
            .setConstantBitrateSeekingEnabled(true)
        val http = DefaultHttpDataSource.Factory()
            .setUserAgent("TiviBuddy")
            .setAllowCrossProtocolRedirects(true)
            .setConnectTimeoutMs(15_000)
            .setReadTimeoutMs(15_000)
        val sources = DefaultMediaSourceFactory(DefaultDataSource.Factory(context, http), extractors)
        // Smaller than the defaults for devices with 1 GB of memory (RES-1).
        val load = DefaultLoadControl.Builder()
            .setBufferDurationsMs(15_000, 40_000, 1_000, 2_000)
            .build()
        player = ExoPlayer.Builder(context, renderers)
            .setMediaSourceFactory(sources)
            .setLoadControl(load)
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(C.USAGE_MEDIA)
                    .setContentType(C.AUDIO_CONTENT_TYPE_MOVIE)
                    .build(),
                true,
            )
            .build()
        // Subtitles only when a stream marks them forced, like with mpv.
        player.trackSelectionParameters = player.trackSelectionParameters.buildUpon()
            .setIgnoredTextSelectionFlags(C.SELECTION_FLAG_DEFAULT)
            .build()
        player.playWhenReady = true
        player.addListener(PlayerEvents())
        player.addAnalyticsListener(Diagnostics())

        producer.setCallback(object : TextureRegistry.SurfaceProducer.Callback {
            override fun onSurfaceAvailable() {
                player.setVideoSurface(producer.surface)
            }

            override fun onSurfaceCleanup() {
                player.setVideoSurface(null)
            }
        })
        player.setVideoSurface(producer.surface)
    }

    val textureId: Long get() = producer.id()

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        sink = events
        pending.forEach(events::success)
        pending.clear()
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    private fun send(event: String, values: Map<String, Any?> = emptyMap()) {
        val map = values + ("event" to event)
        sink?.success(map) ?: pending.add(map)
    }

    private fun log(message: String) = send("log", mapOf("message" to message))

    /**
     * Measures the frame rate from the timestamps of the first frames:
     * containers such as MKV and endless TS streams often do not state it,
     * and matching the display needs it.
     */
    private val frameRate = object : VideoFrameMetadataListener {
        private val deltas = mutableListOf<Long>()
        private var last = C.TIME_UNSET

        fun reset() = synchronized(this) {
            deltas.clear()
            last = C.TIME_UNSET
        }

        override fun onVideoFrameAboutToBeRendered(
            presentationTimeUs: Long,
            releaseTimeNs: Long,
            format: Format,
            mediaFormat: android.media.MediaFormat?,
        ) {
            val fps = synchronized(this) {
                if (deltas.size >= SAMPLES) return
                if (last != C.TIME_UNSET && presentationTimeUs > last) {
                    deltas += presentationTimeUs - last
                }
                last = presentationTimeUs
                if (deltas.size < SAMPLES) return
                // The median ignores gaps from dropped or repeated frames.
                1_000_000.0 / deltas.sorted()[SAMPLES / 2]
            }
            handler.post { send("frameRate", mapOf("fps" to fps)) }
        }
    }

    init {
        player.setVideoFrameMetadataListener(frameRate)
    }

    fun open(url: String, startMs: Long?) {
        frameRate.reset()
        val item = MediaItem.Builder().setUri(url)
        if (url.contains(".m3u8")) item.setMimeType(MimeTypes.APPLICATION_M3U8)
        if (startMs != null && startMs > 0) {
            player.setMediaItem(item.build(), startMs)
        } else {
            player.setMediaItem(item.build())
        }
        player.prepare()
        player.play()
    }

    fun play() = player.play()

    fun pause() = player.pause()

    fun seek(positionMs: Long) = player.seekTo(positionMs)

    companion object {
        private const val SAMPLES = 48
    }

    fun stop() {
        player.stop()
        player.clearMediaItems()
    }

    /** Selects the track `group:index` of [type], or switches [type] off for null. */
    fun selectTrack(type: Int, id: String?) {
        val builder = player.trackSelectionParameters.buildUpon()
        if (id == null) {
            builder.setTrackTypeDisabled(type, true)
        } else {
            val (group, index) = id.split(':').map(String::toInt)
            val trackGroup = player.currentTracks.groups.getOrNull(group) ?: return
            builder.setTrackTypeDisabled(type, false)
                .setOverrideForType(TrackSelectionOverride(trackGroup.mediaTrackGroup, index))
        }
        player.trackSelectionParameters = builder.build()
    }

    fun release() {
        handler.removeCallbacksAndMessages(null)
        player.release()
        producer.release()
        sink?.endOfStream()
        sink = null
    }

    private val positionTicker = object : Runnable {
        override fun run() {
            send("position", mapOf("positionMs" to player.currentPosition))
            handler.postDelayed(this, 500)
        }
    }

    private inner class PlayerEvents : Player.Listener {
        override fun onPlaybackStateChanged(playbackState: Int) {
            if (playbackState == Player.STATE_READY) {
                val duration = player.duration
                send("duration", mapOf("durationMs" to if (duration == C.TIME_UNSET) null else duration))
            }
            sendState()
        }

        override fun onIsPlayingChanged(isPlaying: Boolean) {
            handler.removeCallbacks(positionTicker)
            if (isPlaying) handler.post(positionTicker)
            sendState()
        }

        override fun onPlayerError(error: PlaybackException) {
            send("error", mapOf("code" to error.errorCodeName, "message" to (error.message ?: "")))
        }

        override fun onVideoSizeChanged(videoSize: VideoSize) {
            if (videoSize.width == 0 || videoSize.height == 0) return
            producer.setSize(videoSize.width, videoSize.height)
            send(
                "videoSize",
                mapOf(
                    "width" to videoSize.width,
                    "height" to videoSize.height,
                    "ratio" to videoSize.width * videoSize.pixelWidthHeightRatio / videoSize.height,
                ),
            )
        }

        override fun onTracksChanged(tracks: Tracks) = sendTracks(tracks)

        override fun onCues(cueGroup: CueGroup) {
            val text = cueGroup.cues.mapNotNull { it.text?.toString() }.joinToString("\n")
            send("cues", mapOf("text" to text.ifEmpty { null }))
        }
    }

    private fun sendState() {
        val state = when (player.playbackState) {
            Player.STATE_BUFFERING -> "buffering"
            Player.STATE_READY -> "ready"
            Player.STATE_ENDED -> "ended"
            else -> "idle"
        }
        send(
            "state",
            mapOf(
                "state" to state,
                "playing" to player.isPlaying,
                // Empty at a stall means the network or provider did not deliver.
                "bufferedMs" to player.totalBufferedDuration,
            ),
        )
    }

    private fun sendTracks(tracks: Tracks) {
        val audio = mutableListOf<Map<String, Any?>>()
        val text = mutableListOf<Map<String, Any?>>()
        tracks.groups.forEachIndexed { groupIndex, group ->
            for (index in 0 until group.length) {
                if (!group.isTrackSupported(index)) continue
                val format = group.getTrackFormat(index)
                val track = mapOf(
                    "id" to "$groupIndex:$index",
                    "language" to format.language,
                    "label" to format.label,
                    "mimeType" to format.sampleMimeType,
                    "channels" to format.channelCount.takeIf { it != Format.NO_VALUE },
                    "selected" to group.isTrackSelected(index),
                )
                when (group.type) {
                    C.TRACK_TYPE_AUDIO -> audio += track
                    C.TRACK_TYPE_TEXT -> text += track
                }
            }
        }
        send("tracks", mapOf("audio" to audio, "text" to text))
    }

    /** What the device actually does, for diagnostic reports. */
    private inner class Diagnostics : AnalyticsListener {
        override fun onVideoDecoderInitialized(
            eventTime: AnalyticsListener.EventTime,
            decoderName: String,
            initializedTimestampMs: Long,
            initializationDurationMs: Long,
        ) = log("video decoder $decoderName")

        override fun onAudioDecoderInitialized(
            eventTime: AnalyticsListener.EventTime,
            decoderName: String,
            initializedTimestampMs: Long,
            initializationDurationMs: Long,
        ) = log("audio decoder $decoderName")

        override fun onVideoInputFormatChanged(
            eventTime: AnalyticsListener.EventTime,
            format: Format,
            decoderReuseEvaluation: DecoderReuseEvaluation?,
        ) = log(
            "video ${format.sampleMimeType} ${format.width}x${format.height}" +
                if (format.frameRate > 0) " ${format.frameRate} fps" else "",
        )

        override fun onAudioInputFormatChanged(
            eventTime: AnalyticsListener.EventTime,
            format: Format,
            decoderReuseEvaluation: DecoderReuseEvaluation?,
        ) = log("audio ${format.sampleMimeType} ${format.channelCount} ch ${format.sampleRate} Hz")

        override fun onAudioTrackInitialized(
            eventTime: AnalyticsListener.EventTime,
            audioTrackConfig: AudioSink.AudioTrackConfig,
        ) = log(
            "audio output encoding ${encodingName(audioTrackConfig.encoding)}, " +
                "${audioTrackConfig.sampleRate} Hz, tunneling ${audioTrackConfig.tunneling}",
        )

        override fun onDroppedVideoFrames(
            eventTime: AnalyticsListener.EventTime,
            droppedFrames: Int,
            elapsedMs: Long,
        ) = log("dropped $droppedFrames frames in $elapsedMs ms")

        override fun onAudioUnderrun(
            eventTime: AnalyticsListener.EventTime,
            bufferSize: Int,
            bufferSizeMs: Long,
            elapsedSinceLastFeedMs: Long,
        ) = log("audio underrun")
    }

    /** Passthrough shows as AC3, E-AC3 or DTS here; PCM means decoded audio. */
    private fun encodingName(encoding: Int) = when (encoding) {
        C.ENCODING_PCM_16BIT -> "pcm16"
        C.ENCODING_PCM_FLOAT -> "pcm-float"
        C.ENCODING_AC3 -> "ac3 (passthrough)"
        C.ENCODING_E_AC3 -> "e-ac3 (passthrough)"
        C.ENCODING_E_AC3_JOC -> "e-ac3-joc (passthrough)"
        C.ENCODING_DTS -> "dts (passthrough)"
        C.ENCODING_DTS_HD -> "dts-hd (passthrough)"
        C.ENCODING_DOLBY_TRUEHD -> "truehd (passthrough)"
        else -> "$encoding"
    }
}
