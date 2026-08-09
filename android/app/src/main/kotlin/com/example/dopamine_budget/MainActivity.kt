package com.example.dopamine_budget

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.dopamine_budget/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { _, result ->
            result.success(null)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleWidgetIntent()
    }

    override fun onNewIntent(intent: android.content.Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleWidgetIntent()
    }

    private fun handleWidgetIntent() {
        val action  = intent?.getStringExtra("widget_action") ?: return
        val habitId = intent?.getStringExtra("habit_id")
        val prefs   = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        prefs.edit()
            .putString("flutter.widget_action",   action)
            .putString("flutter.widget_habit_id", habitId ?: "")
            .apply()
    }
}
