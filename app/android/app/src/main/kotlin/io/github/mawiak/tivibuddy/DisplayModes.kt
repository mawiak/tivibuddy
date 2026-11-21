package io.github.mawiak.tivibuddy

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioManager
import android.hardware.display.DisplayManager
import android.os.Handler
import android.os.Looper
import android.view.Display
import kotlin.math.abs

/**
 * Switches the display to a refresh rate that fits the video, like the
 * "match frame rate" option of common players: 23.976 fps films at
 * 23.976 Hz instead of 60 Hz avoid uneven frame repeats (judder). Only
 * modes with the current resolution are considered.
 *
 * Finding and applying a mode are separate steps, so playback can pause
 * while the TV resynchronises; HDMI also renegotiates audio then.
 */
object DisplayModes {
    /** Relative deviation still counted as the same rate (23.976 vs 24 is 0.1 %). */
    private const val TOLERANCE = 0.0015

    /** The TV needs a moment after the switch before audio and picture settle. */
    private const val SETTLE_MS = 500L
    private const val TIMEOUT_MS = 5_000L

    /**
     * HDMI renegotiates audio after the picture; until the sink reports its
     * formats again the output only takes PCM, and a player starting then
     * stays without passthrough.
     */
    private const val AUDIO_TIMEOUT_MS = 4_000L

    @Suppress("DEPRECATION")
    private fun display(activity: Activity): Display = activity.windowManager.defaultDisplay

    /**
     * The mode for [fps]: `modeId` 0 when the current mode fits or none
     * does, with a `message` for the log.
     */
    fun find(activity: Activity, fps: Double): Map<String, Any> {
        val display = display(activity)
        val current = display.mode
        val best = display.supportedModes
            .filter {
                it.physicalWidth == current.physicalWidth &&
                    it.physicalHeight == current.physicalHeight
            }
            .mapNotNull { mode -> score(mode.refreshRate.toDouble(), fps)?.let { mode to it } }
            .minByOrNull { it.second }
            ?.first
        return when {
            best == null -> mapOf(
                "modeId" to 0,
                "message" to "display: no mode for $fps fps at ${describe(current)}, " +
                    "available ${display.supportedModes.joinToString { describe(it) }}",
            )
            best.modeId == current.modeId -> mapOf(
                "modeId" to 0,
                "message" to "display: ${describe(current)} already fits $fps fps",
            )
            else -> mapOf(
                "modeId" to best.modeId,
                "message" to "display: switching from ${describe(current)} to ${describe(best)} for $fps fps",
            )
        }
    }

    /**
     * Applies [modeId], or the default mode for 0, and calls [done] once the
     * display reports the new mode and HDMI audio is back, each with a
     * timeout, plus a moment to settle.
     */
    fun apply(activity: Activity, modeId: Int, done: (String) -> Unit) {
        val attributes = activity.window.attributes
        if (attributes.preferredDisplayModeId == modeId) {
            done("display: unchanged")
            return
        }
        val manager = activity.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
        val handler = Handler(Looper.getMainLooper())
        val displayId = display(activity).displayId
        val started = System.currentTimeMillis()
        var displayReport: String? = null
        var audioReport: String? = null
        var finished = false
        lateinit var listener: DisplayManager.DisplayListener
        lateinit var receiver: BroadcastReceiver

        fun finish() {
            if (finished) return
            finished = true
            manager.unregisterDisplayListener(listener)
            activity.unregisterReceiver(receiver)
            handler.removeCallbacksAndMessages(null)
            val message = "${displayReport ?: "display: no change reported"}, " +
                (audioReport ?: "no hdmi audio event")
            handler.postDelayed({ done(message) }, SETTLE_MS)
        }

        fun check() {
            if (displayReport != null && audioReport != null) finish()
        }

        listener = object : DisplayManager.DisplayListener {
            override fun onDisplayChanged(id: Int) {
                if (id != displayId || displayReport != null) return
                val mode = display(activity).mode
                if (modeId == 0 || mode.modeId == modeId) {
                    displayReport = "display: now ${describe(mode)} " +
                        "after ${System.currentTimeMillis() - started} ms"
                    // Waiting for audio starts with the new picture.
                    handler.postDelayed(::finish, AUDIO_TIMEOUT_MS)
                    check()
                }
            }

            override fun onDisplayAdded(id: Int) = Unit

            override fun onDisplayRemoved(id: Int) = Unit
        }
        // Listening from the start, as HDMI audio may return before the
        // display reports its new mode.
        receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                // The sticky last state arrives first; only news count.
                if (isInitialStickyBroadcast) return
                if (intent.getIntExtra(AudioManager.EXTRA_AUDIO_PLUG_STATE, 0) == 1) {
                    audioReport = "hdmi audio back after ${System.currentTimeMillis() - started} ms"
                    check()
                }
            }
        }
        manager.registerDisplayListener(listener, handler)
        activity.registerReceiver(receiver, IntentFilter(AudioManager.ACTION_HDMI_AUDIO_PLUG))
        handler.postDelayed(::finish, TIMEOUT_MS)
        attributes.preferredDisplayModeId = modeId
        activity.window.attributes = attributes
    }

    /** Whether the window asks for a mode other than the default. */
    fun isSwitched(activity: Activity) = activity.window.attributes.preferredDisplayModeId != 0

    /**
     * How well [rate] shows [fps], lower is better; null when the rate would
     * repeat frames unevenly. The highest whole multiple wins, so 25 fps TV
     * gets 50 Hz instead of a flickering 25 Hz, while 23.976 fps films keep
     * 23.976 Hz where no 47.952 Hz mode exists.
     */
    private fun score(rate: Double, fps: Double): Double? =
        (1..3).mapNotNull { multiple ->
            val deviation = abs(rate - fps * multiple) / (fps * multiple)
            if (deviation <= TOLERANCE) deviation - multiple else null
        }.minOrNull()

    private fun describe(mode: Display.Mode) =
        "${mode.physicalWidth}x${mode.physicalHeight}@${"%.3f".format(mode.refreshRate)}"
}
