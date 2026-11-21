package io.github.mawiak.tivibuddy

import android.app.Activity
import android.view.Display
import kotlin.math.abs

/**
 * Switches the display to a refresh rate that fits the video, like the
 * "match frame rate" option of common players: 23.976 fps films at
 * 23.976 or 24 Hz instead of 60 Hz avoid uneven frame repeats (judder).
 * Only modes with the current resolution are considered; the window's
 * preferred mode is cleared again when playback ends.
 */
object DisplayModes {
    /** Relative deviation still counted as the same rate (23.976 vs 24 is 0.1 %). */
    private const val TOLERANCE = 0.0015

    fun match(activity: Activity, fps: Double): String {
        @Suppress("DEPRECATION")
        val display: Display = activity.windowManager.defaultDisplay
        val current = display.mode
        val best = display.supportedModes
            .filter {
                it.physicalWidth == current.physicalWidth &&
                    it.physicalHeight == current.physicalHeight
            }
            .mapNotNull { mode -> score(mode.refreshRate.toDouble(), fps)?.let { mode to it } }
            .minByOrNull { it.second }
            ?.first
            ?: return "display: no mode for $fps fps at ${describe(current)}, " +
                "available ${display.supportedModes.joinToString { describe(it) }}"
        if (best.modeId == current.modeId) {
            return "display: ${describe(current)} already fits $fps fps"
        }
        val attributes = activity.window.attributes
        attributes.preferredDisplayModeId = best.modeId
        activity.window.attributes = attributes
        return "display: switched from ${describe(current)} to ${describe(best)} for $fps fps"
    }

    fun reset(activity: Activity): String {
        val attributes = activity.window.attributes
        if (attributes.preferredDisplayModeId == 0) return "display: default mode"
        attributes.preferredDisplayModeId = 0
        activity.window.attributes = attributes
        return "display: back to the default mode"
    }

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
