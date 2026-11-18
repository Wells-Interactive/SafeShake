package com.wellsint.brainyte.safeshake

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.wellsint.brainyte.safeshake/foreground"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startForegroundMonitoring" -> {
                        val settings = call.arguments as? Map<*, *>
                        if (settings == null) {
                            result.error("invalid-settings", "Protection settings are missing.", null)
                        } else {
                            try {
                                SafeShakeForegroundService.start(this, settings)
                                result.success(true)
                            } catch (error: SecurityException) {
                                result.error("service-start-denied", error.message, null)
                            } catch (error: IllegalStateException) {
                                result.error("service-start-failed", error.message, null)
                            }
                        }
                    }
                    "updateForegroundMonitoring" -> {
                        val settings = call.arguments as? Map<*, *>
                        if (settings == null) {
                            result.error("invalid-settings", "Protection settings are missing.", null)
                        } else {
                            try {
                                SafeShakeForegroundService.update(this, settings)
                                result.success(true)
                            } catch (error: SecurityException) {
                                result.error("service-update-denied", error.message, null)
                            } catch (error: IllegalStateException) {
                                result.error("service-update-failed", error.message, null)
                            }
                        }
                    }
                    "stopForegroundMonitoring" -> {
                        SafeShakeForegroundService.stop(this)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
