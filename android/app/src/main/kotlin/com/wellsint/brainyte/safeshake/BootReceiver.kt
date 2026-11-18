package com.wellsint.brainyte.safeshake

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        if (action != Intent.ACTION_BOOT_COMPLETED &&
            action != Intent.ACTION_MY_PACKAGE_REPLACED &&
            action != "android.intent.action.QUICKBOOT_POWERON" &&
            action != "android.intent.action.LOCKED_BOOT_COMPLETED"
        ) {
            return
        }

        val preferences = context.getSharedPreferences(
            SafeShakeForegroundService.SETTINGS_NAME,
            Context.MODE_PRIVATE,
        )

        if (!preferences.getBoolean("protectionActive", false)) {
            return
        }

        val settings = mapOf(
            "shakeSensitivity" to (preferences.getString("sensitivity", "medium") ?: "medium"),
            "alertMode" to (preferences.getString("alertMode", "immediate") ?: "immediate"),
            "countdownSeconds" to preferences.getInt("countdownSeconds", 10),
            "emergencyMessage" to (preferences.getString("emergencyMessage", "EMERGENCY ALERT! I may be in danger and need help.") ?: "EMERGENCY ALERT! I may be in danger and need help."),
            "locationSharingEnabled" to preferences.getBoolean("locationSharingEnabled", false),
        )

        SafeShakeForegroundService.start(context.applicationContext, settings)
    }
}
