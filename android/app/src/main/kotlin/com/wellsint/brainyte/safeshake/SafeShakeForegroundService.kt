package com.wellsint.brainyte.safeshake

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.location.Location
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import android.os.CountDownTimer
import android.os.IBinder
import android.telephony.SmsManager
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import com.google.android.gms.tasks.CancellationTokenSource
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.functions.FirebaseFunctions
import kotlin.math.sqrt

class SafeShakeForegroundService : Service(), SensorEventListener {
    companion object {
        private const val CHANNEL_ID = "safeshake_protection"
        private const val NOTIFICATION_ID = 2001
        internal const val SETTINGS_NAME = "protection_settings"
        private const val ACTION_START = "com.wellsint.brainyte.safeshake.START"
        private const val ACTION_UPDATE = "com.wellsint.brainyte.safeshake.UPDATE"
        private const val ACTION_STOP = "com.wellsint.brainyte.safeshake.STOP"
        private const val ACTION_CANCEL_ALERT = "com.wellsint.brainyte.safeshake.CANCEL_ALERT"
        private const val SHAKE_COOLDOWN_MS = 30_000L
        private const val SHAKE_DEBOUNCE_MS = 1_000L
        private const val IMMEDIATE_CANCEL_SECONDS = 10

        private const val EXTRA_SENSITIVITY = "sensitivity"
        private const val EXTRA_ALERT_MODE = "alertMode"
        private const val EXTRA_COUNTDOWN_SECONDS = "countdownSeconds"
        private const val EXTRA_EMERGENCY_MESSAGE = "emergencyMessage"
        private const val EXTRA_LOCATION_ENABLED = "locationSharingEnabled"
        private const val PREF_SMS_NUMBERS = "sms_numbers"
        private const val SHAKE_WINDOW_MS = 3000L
        private const val MIN_SHAKES = 2

        fun start(context: Context, settings: Map<*, *>) {
            val intent = Intent(context, SafeShakeForegroundService::class.java)
                .setAction(ACTION_START)
                .putExtras(settings.toBundle())
            startServiceCompat(context, intent)
        }

        fun update(context: Context, settings: Map<*, *>) {
            val intent = Intent(context, SafeShakeForegroundService::class.java)
                .setAction(ACTION_UPDATE)
                .putExtras(settings.toBundle())
            startServiceCompat(context, intent)
        }

        fun stop(context: Context) {
            context.getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)
                .edit()
                .putBoolean("protectionActive", false)
                .apply()
            context.stopService(Intent(context, SafeShakeForegroundService::class.java))
        }

        private fun startServiceCompat(context: Context, intent: Intent) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        private fun Map<*, *>.toBundle() = android.os.Bundle().apply {
            putString(EXTRA_SENSITIVITY, this@toBundle["shakeSensitivity"] as? String)
            putString(EXTRA_ALERT_MODE, this@toBundle["alertMode"] as? String)
            putInt(EXTRA_COUNTDOWN_SECONDS, (this@toBundle["countdownSeconds"] as? Number)?.toInt() ?: 10)
            putString(EXTRA_EMERGENCY_MESSAGE, this@toBundle["emergencyMessage"] as? String)
            putBoolean(EXTRA_LOCATION_ENABLED, this@toBundle["locationSharingEnabled"] as? Boolean ?: false)
        }
    }

    private lateinit var sensorManager: SensorManager
    private var linearAccelerationSensor: Sensor? = null
    private var alertCountdown: CountDownTimer? = null
    private var alertPending = false
    private var lastShakeAt = 0L
    private var lastEventAt = 0L
    private val shakeTimes = mutableListOf<Long>()
    private var threshold = 2.3f

    override fun onCreate() {
        super.onCreate()
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        linearAccelerationSensor = sensorManager.getDefaultSensor(Sensor.TYPE_LINEAR_ACCELERATION)
        createChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopSelf()
                return START_NOT_STICKY
            }
            ACTION_CANCEL_ALERT -> {
                cancelPendingAlert()
                return START_STICKY
            }
        }

        if (intent != null) {
            saveSettings(intent.extras)
        } else {
            restoreSettings()
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            val serviceType = if (
                isLocationSharingAvailable()
            ) {
                android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION
            } else {
                android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
            }
            startForeground(
                NOTIFICATION_ID,
                buildNotification("Protection is active. Shake monitoring is on."),
                serviceType,
            )
        } else {
            startForeground(
                NOTIFICATION_ID,
                buildNotification("Protection is active. Shake monitoring is on."),
            )
        }

        registerSensor()
        return START_STICKY
    }

    override fun onSensorChanged(event: SensorEvent) {
        if (alertPending || event.values.size < 3) return

        val now = System.currentTimeMillis()
        if (now - lastEventAt < SHAKE_DEBOUNCE_MS) return
        lastEventAt = now

        val magnitude = sqrt(
            event.values[0] * event.values[0] +
                event.values[1] * event.values[1] +
                event.values[2] * event.values[2],
        )
        if (magnitude < threshold) return

        shakeTimes.add(now)
        shakeTimes.removeIf { now - it > SHAKE_WINDOW_MS }

        if (shakeTimes.size < MIN_SHAKES) return
        if (now - lastShakeAt < SHAKE_COOLDOWN_MS) {
            shakeTimes.clear()
            return
        }
        lastShakeAt = now
        shakeTimes.clear()
        beginAlertCountdown()
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) = Unit

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        alertCountdown?.cancel()
        sensorManager.unregisterListener(this)
        getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putBoolean("protectionActive", false)
            .apply()
        super.onDestroy()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
    }

    private fun registerSensor() {
        val sensor = linearAccelerationSensor
        if (sensor == null) {
            updateNotification("This device does not provide a shake sensor.")
            return
        }
        sensorManager.unregisterListener(this)
        sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_GAME)
    }

    private fun beginAlertCountdown() {
        alertPending = true
        val preferences = getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)
        val mode = preferences.getString(EXTRA_ALERT_MODE, "immediate")
        val configuredSeconds = preferences.getInt(EXTRA_COUNTDOWN_SECONDS, 10).coerceIn(3, 30)
        val seconds = if (mode == "countdown") configuredSeconds else IMMEDIATE_CANCEL_SECONDS

        alertCountdown = object : CountDownTimer(seconds * 1000L, 1000L) {
            override fun onTick(millisUntilFinished: Long) {
                updateNotification(
                    "Possible alert in ${(millisUntilFinished + 999L) / 1000L}s. Cancel if this was accidental.",
                    showCancel = true,
                )
            }

            override fun onFinish() {
                alertCountdown = null
                sendEmergencyAlert()
            }
        }.start()
    }

    private fun cancelPendingAlert() {
        alertCountdown?.cancel()
        alertCountdown = null
        alertPending = false
        updateNotification("Protection is active. Shake monitoring is on.")
    }

    private fun sendEmergencyAlert() {
        val user = FirebaseAuth.getInstance().currentUser
        if (user == null) {
            showAlertFailure("Sign in again to send an alert.")
            return
        }

        val preferences = getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)
        val template = preferences.getString(EXTRA_EMERGENCY_MESSAGE, null)
            ?: "EMERGENCY ALERT! I may be in danger and need help."
        val locationEnabled = preferences.getBoolean(EXTRA_LOCATION_ENABLED, false)
        if (!locationEnabled || !hasLocationPermission()) {
            submitAlert(composeMessage(template, null, locationEnabled))
            return
        }

        try {
            val locationClient = LocationServices.getFusedLocationProviderClient(this)
            locationClient.getCurrentLocation(
                Priority.PRIORITY_HIGH_ACCURACY,
                CancellationTokenSource().token,
            )
                .addOnSuccessListener { location ->
                    submitAlert(composeMessage(template, location, locationEnabled))
                }
                .addOnFailureListener {
                    submitAlert(composeMessage(template, null, locationEnabled))
                }
        } catch (_: SecurityException) {
            submitAlert(composeMessage(template, null, locationEnabled))
        }
    }

    private fun submitAlert(message: String) {
        if (!hasInternet()) {
            sendSmsFallback(message)
            return
        }
        FirebaseFunctions.getInstance("europe-west1")
            .getHttpsCallable("sendEmergencyAlert")
            .call(mapOf("message" to message))
            .addOnSuccessListener {
                updateNotification("Emergency alert sent. Protection remains active.")
                alertPending = false
            }
            .addOnFailureListener { error ->
                sendSmsFallback(message)
            }
    }

    private fun hasInternet(): Boolean {
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val network = cm.activeNetwork
            if (network == null) return false
            val caps = cm.getNetworkCapabilities(network)
            caps != null && (caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) ||
                caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) ||
                caps.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET))
        } else {
            val network = cm.activeNetworkInfo
            network != null && network.isConnected
        }
    }

    private fun sendSmsFallback(message: String) {
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS) !=
            PackageManager.PERMISSION_GRANTED) {
            showAlertFailure("No internet and SMS permission not granted.")
            return
        }
        val preferences = getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)
        val numbers = preferences.getString(PREF_SMS_NUMBERS, null)
        if (numbers.isNullOrBlank()) {
            showAlertFailure("No internet and no SMS fallback numbers saved.")
            return
        }
        val smsManager = SmsManager.getDefault()
        val numberList = numbers.split(",").filter { it.isNotBlank() }
        var sent = 0
        for (number in numberList) {
            try {
                smsManager.sendTextMessage(number.trim(), null, message, null, null)
                sent++
            } catch (e: Exception) {
                // continue to next number
            }
        }
        if (sent > 0) {
            updateNotification("Emergency SMS sent to $sent contact(s).")
            alertPending = false
        } else {
            showAlertFailure("No internet and SMS fallback failed.")
        }
    }

    private fun composeMessage(template: String, location: Location?, enabled: Boolean): String {
        val locationText = when {
            !enabled -> "Location sharing disabled"
            location != null ->
                "https://maps.google.com/?q=${location.latitude},${location.longitude}"
            else -> "Location unavailable"
        }
        return if (template.contains("[LOCATION LINK]")) {
            template.replace("[LOCATION LINK]", locationText)
        } else if (enabled) {
            "$template\n\nMy location: $locationText"
        } else {
            template
        }
    }

    private fun showAlertFailure(message: String) {
        alertPending = false
        updateNotification("Alert failed: $message")
    }

    private fun hasLocationPermission(): Boolean =
        ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED ||
            ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED

    private fun isLocationSharingAvailable(): Boolean {
        val enabled = getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)
            .getBoolean(EXTRA_LOCATION_ENABLED, false)
        return enabled && hasLocationPermission()
    }

    private fun saveSettings(extras: android.os.Bundle?) {
        if (extras == null) return
        val preferences = getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)
        preferences.edit()
            .putString(EXTRA_SENSITIVITY, extras.getString(EXTRA_SENSITIVITY) ?: "medium")
            .putString(EXTRA_ALERT_MODE, extras.getString(EXTRA_ALERT_MODE) ?: "immediate")
            .putInt(EXTRA_COUNTDOWN_SECONDS, extras.getInt(EXTRA_COUNTDOWN_SECONDS, 10))
            .putString(EXTRA_EMERGENCY_MESSAGE, extras.getString(EXTRA_EMERGENCY_MESSAGE))
            .putBoolean(EXTRA_LOCATION_ENABLED, extras.getBoolean(EXTRA_LOCATION_ENABLED, false))
            .putBoolean("protectionActive", true)
            .apply()

        threshold = when (extras.getString(EXTRA_SENSITIVITY)) {
            "low" -> 4.0f
            "high" -> 1.5f
            else -> 2.3f
        }
    }

    private fun restoreSettings() {
        val preferences = getSharedPreferences(SETTINGS_NAME, Context.MODE_PRIVATE)
        threshold = when (preferences.getString(EXTRA_SENSITIVITY, "medium")) {
            "low" -> 4.0f
            "high" -> 1.5f
            else -> 2.3f
        }
    }

    private fun updateNotification(message: String, showCancel: Boolean = false) {
        val manager = getSystemService(NotificationManager::class.java)
        manager?.notify(NOTIFICATION_ID, buildNotification(message, showCancel))
    }

    private fun buildNotification(message: String, showCancel: Boolean = false) =
        NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(if (showCancel) "SafeShake: alert countdown" else "SafeShake protection")
            .setContentText(message)
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .apply {
                if (showCancel) {
                    val cancelIntent = Intent(this@SafeShakeForegroundService, SafeShakeForegroundService::class.java)
                        .setAction(ACTION_CANCEL_ALERT)
                    val cancelPendingIntent = PendingIntent.getService(
                        this@SafeShakeForegroundService,
                        2002,
                        cancelIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                    )
                    addAction(0, "Cancel alert", cancelPendingIntent)
                }
            }
            .build()

    private fun createChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val channel = NotificationChannel(
            CHANNEL_ID,
            "SafeShake protection",
            NotificationManager.IMPORTANCE_LOW,
        )
        channel.setSound(null, null)
        val manager = getSystemService(NotificationManager::class.java)
        manager?.createNotificationChannel(channel)
    }
}
