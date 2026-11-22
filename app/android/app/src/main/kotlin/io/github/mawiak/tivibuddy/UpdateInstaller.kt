package io.github.mawiak.tivibuddy

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import java.io.File

/**
 * Hands a downloaded update to the Android package installer. Android
 * always asks the user to confirm; apps installed from outside a store
 * also need the "install unknown apps" permission once.
 */
object UpdateInstaller {
    fun canInstall(activity: Activity): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.O ||
            activity.packageManager.canRequestPackageInstalls()

    /** Opens the per-app setting; Fire OS may lack it, then the general one. */
    fun openInstallPermission(activity: Activity) {
        val perApp = Intent(
            Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
            Uri.parse("package:${activity.packageName}"),
        )
        try {
            activity.startActivity(perApp)
        } catch (_: ActivityNotFoundException) {
            activity.startActivity(Intent(Settings.ACTION_SECURITY_SETTINGS))
        }
    }

    fun install(activity: Activity, path: String) {
        val uri = FileProvider.getUriForFile(
            activity,
            "${activity.packageName}.updates",
            File(path),
        )
        val intent = Intent(Intent.ACTION_VIEW)
            .setDataAndType(uri, "application/vnd.android.package-archive")
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_ACTIVITY_NEW_TASK)
        activity.startActivity(intent)
    }
}
