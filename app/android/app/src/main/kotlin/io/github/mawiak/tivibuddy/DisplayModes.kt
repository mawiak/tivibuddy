package io.github.mawiak.tivibuddy

import android.app.Activity
import android.content.Context
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
    private const val SETTLE_MS = 1_000L
    private const val TIMEOUT_MS = 5_000L

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
     * display reports the change and has settled, or after a timeout.
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
        var finished = false
        lateinit var listener: DisplayManager.DisplayListener
        fun finish(message: String) {
            if (finished) return
            finished = true
            manager.unregisterDisplayListener(listener)
            handler.removeCallbacksAndMessages(null)
            handler.postDelayed({ done(message) }, SETTLE_MS)
        }
        listener = object : DisplayManager.DisplayListener {
            override fun onDisplayChanged(id: Int) {
                if (id != displayId) return
                val mode = display(activity).mode
                if (modeId == 0 || mode.modeId == modeId) {
                    finish("display: now ${describe(mode)}")
                }
            }

            override fun onDisplayAdded(id: Int) = Unit

            override fun onDisplayRemoved(id: Int) = Unit
        }
        manager.registerDisplayListener(listener, handler)
        handler.postDelayed(
            { finish("display: no change reported within $TIMEOUT_MS ms, now ${describe(display(activity).mode)}") },
            TIMEOUT_MS,
        )
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
