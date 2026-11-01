package com.andrehaliim.deenly

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.andrehaliim.deenly/sensors")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Some budget devices (e.g. Galaxy M12) expose a virtual rotation
                    // vector sensor without a real magnetometer, so the compass
                    // plugin reports a heading that never changes.
                    "hasMagnetometer" -> {
                        val sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
                        result.success(sensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD) != null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
