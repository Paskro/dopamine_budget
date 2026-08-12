package com.example.dopamine_budget

import android.content.Context
import androidx.work.Data
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager

object WidgetClickHandler {

    fun logHabitClick(
        context: Context,
        habitId: String,
        scoreCost: Int,
        sessionId: String,
        widgetId: Int,
    ) {
        val data = Data.Builder()
            .putString(HabitClickWorker.KEY_HABIT_ID,   habitId)
            .putInt(HabitClickWorker.KEY_SCORE_COST,    scoreCost)
            .putString(HabitClickWorker.KEY_SESSION_ID, sessionId)
            .build()

        val request = OneTimeWorkRequestBuilder<HabitClickWorker>()
            .setInputData(data)
            .build()

        WorkManager.getInstance(context).enqueue(request)
    }
}
