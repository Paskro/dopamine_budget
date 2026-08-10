package com.example.dopamine_budget

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.plugin.common.MethodChannel

object WidgetClickHandler {

    private const val CHANNEL = "com.example.dopamine_budget/widget_click"

    fun logHabitClick(
        context: Context,
        habitId: String,
        scoreCost: Int,
        sessionId: String,
        widgetId: Int,
    ) {
        try {
            val appContext = context.applicationContext
            val loader = FlutterLoader()
            if (!loader.initialized()) {
                loader.startInitialization(appContext)
            }
            loader.ensureInitializationComplete(appContext, null)

            val engine = FlutterEngine(appContext)

            // Register plugins so MethodChannel works in headless engine
            io.flutter.plugins.GeneratedPluginRegistrant.registerWith(engine)

            // Use named entrypoint
            val entrypoint = DartExecutor.DartEntrypoint(
                loader.findAppBundlePath(),
                "widgetClickEntrypoint"
            )
            engine.dartExecutor.executeDartEntrypoint(entrypoint)

            val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)

            // Give Dart time to initialize before sending
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                channel.invokeMethod("logHabitClick", mapOf(
                    "habitId"   to habitId,
                    "scoreCost" to scoreCost,
                    "sessionId" to sessionId,
                ))
            }, 500)

            // Refresh widget and destroy engine after Dart has time to execute
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                val manager = AppWidgetManager.getInstance(appContext)
                val ids = manager.getAppWidgetIds(
                    ComponentName(appContext, DopamineWidgetProvider::class.java)
                )
                for (id in ids) {
                    DopamineWidgetProvider().updateWidgetPublic(appContext, manager, id)
                }
                engine.destroy()
            }, 2500)

        } catch (e: Exception) {
            android.util.Log.e("WidgetClickHandler", "logHabitClick failed: $e")
        }
    }
}
