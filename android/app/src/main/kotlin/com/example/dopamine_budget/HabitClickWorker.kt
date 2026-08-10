package com.example.dopamine_budget

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.content.ContentValues
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.text.SimpleDateFormat
import java.util.*

class HabitClickWorker(
    context: Context,
    params: WorkerParameters,
) : CoroutineWorker(context, params) {

    companion object {
        const val KEY_HABIT_ID    = "habit_id"
        const val KEY_SCORE_COST  = "score_cost"
        const val KEY_SESSION_ID  = "session_id"
        const val DB_PATH = "/data/data/com.example.dopamine_budget/app_flutter/db.sqlite"
    }

    override suspend fun doWork(): Result = withContext(Dispatchers.IO) {
        val habitId   = inputData.getString(KEY_HABIT_ID)   ?: return@withContext Result.failure()
        val scoreCost = inputData.getInt(KEY_SCORE_COST, 0)
        val sessionId = inputData.getString(KEY_SESSION_ID) ?: return@withContext Result.failure()

        try {
            val db = SQLiteDatabase.openDatabase(
                DB_PATH,
                null,
                SQLiteDatabase.OPEN_READWRITE
            )

            db.use {
                // Check day is not broken
                val now       = Calendar.getInstance()
                val dateStr   = String.format(
                    "%04d-%02d-%02d",
                    now.get(Calendar.YEAR),
                    now.get(Calendar.MONTH) + 1,
                    now.get(Calendar.DAY_OF_MONTH)
                )

                val dayCursor = it.rawQuery(
                    "SELECT day_status FROM days_table WHERE date = ?",
                    arrayOf(dateStr)
                )
                val isBroken = dayCursor.use { c ->
                    if (c.moveToFirst()) c.getString(0) == "broken" else false
                }
                if (isBroken) return@withContext Result.failure()

                // Insert habit log
                val sdf = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS000", Locale.US)
                sdf.timeZone = java.util.TimeZone.getTimeZone("UTC")
                val timestamp = sdf.format(now.time) + "Z"

                val values = ContentValues().apply {
                    put("id",         UUID.randomUUID().toString())
                    put("habit_id",   habitId)
                    put("session_id", sessionId)
                    put("timestamp",  timestamp)
                    put("updated_at", timestamp)
                    putNull("user_id")
                }
                it.insertOrThrow("habit_logs_table", null, values)

                // Degrade day status if needed
                val statusCursor = it.rawQuery(
                    "SELECT day_status FROM days_table WHERE date = ?",
                    arrayOf(dateStr)
                )
                val dayStatus = statusCursor.use { c ->
                    if (c.moveToFirst()) c.getString(0) else null
                }
                if (dayStatus == "ideal") {
                    val updateVals = ContentValues().apply {
                        put("day_status", "almost_ideal")
                    }
                    it.update("days_table", updateVals, "date = ?", arrayOf(dateStr))
                }
            }

            // Update widget SharedPreferences balance
            updateWidgetBalance(habitId, scoreCost)

            // Flag that a habit log was written locally and still needs to
            // be pushed to Supabase — Flutter picks this up on next resume.
            val prefs = applicationContext.getSharedPreferences(
                "HomeWidgetPreferences", Context.MODE_PRIVATE
            )
            prefs.edit().putBoolean("pending_habit_log_push", true).apply()

            Result.success()
        } catch (e: Exception) {
            android.util.Log.e("HabitClickWorker", "doWork failed: $e")
            Result.failure()
        }
    }

    private fun updateWidgetBalance(habitId: String, scoreCost: Int) {
        val prefs = applicationContext.getSharedPreferences(
            "HomeWidgetPreferences", Context.MODE_PRIVATE
        )
        val currentBalance = prefs.getString("balance", "0")?.toIntOrNull() ?: 0
        val newBalance = (currentBalance - scoreCost).coerceAtLeast(0)

        // Also update spent_today
        val currentSpent = prefs.getString("spent_today", "0")?.toIntOrNull() ?: 0

        prefs.edit()
            .putString("balance", newBalance.toString())
            .putString("spent_today", (currentSpent + scoreCost).toString())
            .apply()

        // Trigger widget redraw
        val manager = android.appwidget.AppWidgetManager.getInstance(applicationContext)
        val ids = manager.getAppWidgetIds(
            android.content.ComponentName(
                applicationContext,
                DopamineWidgetProvider::class.java
            )
        )
        for (id in ids) {
            DopamineWidgetProvider().updateWidgetPublic(applicationContext, manager, id)
        }
    }
}
