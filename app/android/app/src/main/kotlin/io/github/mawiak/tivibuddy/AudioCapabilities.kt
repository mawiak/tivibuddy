package io.github.mawiak.tivibuddy

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioDeviceInfo
import android.media.AudioFormat
import android.media.AudioManager
import android.os.Build
import android.provider.Settings

/**
 * Compressed audio formats the current output accepts unchanged, so the
 * player only passes through what a receiver can take. Sending a format the
 * output refuses stalls the player (frozen picture, no sound).
 *
 * Follows the checks of ExoPlayer's AudioCapabilities: the system setting for
 * encoded surround output, the Fire TV / Xiaomi switch for an external
 * surround system, and the encodings the connected HDMI sink reports.
 */
object AudioCapabilities {
    // Settings.Global.ENCODED_SURROUND_OUTPUT and its values (API 28+ names,
    // present as plain keys before).
    private const val ENCODED_SURROUND_OUTPUT = "encoded_surround_output"
    private const val ENCODED_SURROUND_OUTPUT_ENABLED_FORMATS =
        "encoded_surround_output_enabled_formats"
    private const val SURROUND_AUTO = 0
    private const val SURROUND_NEVER = 1
    private const val SURROUND_ALWAYS = 2
    private const val SURROUND_MANUAL = 3

    private const val EXTERNAL_SURROUND_SOUND = "external_surround_sound_enabled"

    private val surroundFormats = listOf(
        AudioFormat.ENCODING_AC3,
        AudioFormat.ENCODING_E_AC3,
        AudioFormat.ENCODING_DTS,
        AudioFormat.ENCODING_DTS_HD,
    )

    fun query(context: Context): Map<String, Any?> {
        val resolver = context.contentResolver
        val mode = Settings.Global.getInt(resolver, ENCODED_SURROUND_OUTPUT, SURROUND_AUTO)
        val manualFormats = Settings.Global.getString(
            resolver,
            ENCODED_SURROUND_OUTPUT_ENABLED_FORMATS,
        )
        val externalSurround = Settings.Global.getInt(resolver, EXTERNAL_SURROUND_SOUND, 0) == 1
        val vendorSwitch = Build.MANUFACTURER.equals("Amazon", ignoreCase = true) ||
            Build.MANUFACTURER.equals("Xiaomi", ignoreCase = true)

        // The sticky broadcast carries what the HDMI sink reported last.
        val plug = context.registerReceiver(null, IntentFilter(AudioManager.ACTION_HDMI_AUDIO_PLUG))
        val plugged = plug?.getIntExtra(AudioManager.EXTRA_AUDIO_PLUG_STATE, 0) == 1
        val sinkEncodings = plug?.getIntArrayExtra(AudioManager.EXTRA_ENCODINGS)?.toList().orEmpty()

        val deviceEncodings = mutableListOf<Int>()
        val manager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        for (device in manager.getDevices(AudioManager.GET_DEVICES_OUTPUTS)) {
            if (device.type == AudioDeviceInfo.TYPE_HDMI ||
                device.type == AudioDeviceInfo.TYPE_HDMI_ARC
            ) {
                deviceEncodings += device.encodings.toList()
            }
        }

        val formats = mutableSetOf<Int>()
        when (mode) {
            SURROUND_NEVER -> Unit
            SURROUND_ALWAYS -> formats += surroundFormats
            SURROUND_MANUAL -> {
                val manual = manualFormats.orEmpty().split(',')
                    .mapNotNull { it.trim().toIntOrNull() }
                // A connected sink knows better than a manual list.
                formats += if (plugged && sinkEncodings.isNotEmpty()) {
                    manual.filter { it in sinkEncodings }
                } else {
                    manual
                }
            }
            else -> {
                if (vendorSwitch && externalSurround) {
                    formats += listOf(AudioFormat.ENCODING_AC3, AudioFormat.ENCODING_E_AC3)
                }
                if (plugged) formats += sinkEncodings
            }
        }

        return mapOf(
            "formats" to formats.sorted(),
            "details" to mapOf(
                "encodedSurroundOutput" to mode,
                "encodedSurroundOutputFormats" to manualFormats,
                "externalSurroundSound" to externalSurround,
                // Fire TV only; logged to learn how it relates to the above.
                "fireTvDolbyPassthroughAvailable" to Settings.Global.getString(
                    resolver,
                    "firetv_hdmi_dolby_passthrough_available",
                ),
                "hdmiPlugged" to plugged,
                "hdmiEncodings" to sinkEncodings,
                "hdmiDeviceEncodings" to deviceEncodings,
            ),
        )
    }
}
