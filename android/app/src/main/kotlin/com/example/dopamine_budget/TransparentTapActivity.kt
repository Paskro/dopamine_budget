package com.example.dopamine_budget

import android.app.Activity
import android.content.Context
import android.os.Bundle
import android.os.VibrationEffect
import android.os.Vibrator

class TransparentTapActivity : Activity() {

    companion object {
        const val EXTRA_HABIT_INDEX = "habit_index"
        const val EXTRA_WIDGET_ID   = "widget_id"
        const val PREFS_NAME        = "HomeWidgetPreferences"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val habitIndex = intent.getIntExtra(EXTRA_HABIT_INDEX, -1)
        val widgetId   = intent.getIntExtra(EXTRA_WIDGET_ID, -1)

        if (habitIndex < 0) { finish(); return }

        val prefs     = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val appActive = prefs.getString("app_active", "0") == "1"
        if (appActive) { finish(); return }

        val ids       = (prefs.getString("habit_ids",   "") ?: "").split(",").filter { it.isNotEmpty() }
        val costs     = (prefs.getString("habit_costs", "") ?: "").split(",")
        val phase     = prefs.getString("session_phase", "0")?.toIntOrNull() ?: 0
        val balance   = prefs.getString("balance",       "0")?.toIntOrNull() ?: 0
        val sessionId = prefs.getString("session_id",    "") ?: ""

        val habitId   = ids.getOrElse(habitIndex) { "" }
        val scoreCost = costs.getOrElse(habitIndex) { "0" }.toIntOrNull() ?: 0

        if (habitId.isEmpty() || sessionId.isEmpty()) { finish(); return }
        if (phase == 1 && balance < scoreCost) { finish(); return }

        vibrate()

        WidgetClickHandler.logHabitClick(
            context   = this,
            habitId   = habitId,
            scoreCost = scoreCost,
            sessionId = sessionId,
            widgetId  = widgetId,
        )

        finish()
    }

    private fun vibrate() {
        try {
            val v = getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator ?: return
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                v.vibrate(VibrationEffect.createOneShot(100, VibrationEffect.DEFAULT_AMPLITUDE))
            } else {
                @Suppress("DEPRECATION")
                v.vibrate(100)
            }
        } catch (_: Exception) {}
    }
}
