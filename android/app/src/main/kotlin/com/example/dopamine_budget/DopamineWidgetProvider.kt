package com.example.dopamine_budget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.*
import android.widget.RemoteViews
import android.app.PendingIntent
import kotlin.math.*

private fun segmentCenters(count: Int): List<Pair<Float, Float>> {
    val sweep = 360f / count
    return (0 until count).map { i ->
        val angleDeg = -90f + sweep * i + sweep / 2f
        val angleRad = Math.toRadians(angleDeg.toDouble())
        val x = 200f + 120f * kotlin.math.cos(angleRad).toFloat()
        val y = 200f + 120f * kotlin.math.sin(angleRad).toFloat()
        Pair(x, y)
    }
}

class DopamineWidgetProvider : AppWidgetProvider() {

    companion object {
        const val ACTION_HABIT_CLICK = "com.example.dopamine_budget.HABIT_CLICK"
        const val ACTION_OPEN_APP = "com.example.dopamine_budget.OPEN_APP"
        const val ACTION_MIDNIGHT_RESET = "com.example.dopamine_budget.MIDNIGHT_RESET"
        const val EXTRA_HABIT_ID = "habit_id"
        const val PREFS_NAME = "HomeWidgetPreferences"

        val COLOR_BACKGROUND       = Color.parseColor("#1A2421")
        val COLOR_SURFACE_ELEVATED = Color.parseColor("#2A3D37")
        val COLOR_PRIMARY          = Color.parseColor("#8EB897")
        val COLOR_TEXT_SECONDARY   = Color.parseColor("#A8B5AF")
        val COLOR_DISABLED         = Color.parseColor("#6E7A75")
        val COLOR_SECONDARY_ACCENT = Color.parseColor("#D3A26D")

        fun habitBtnId(index: Int): Int = when (index) {
            0 -> R.id.habit_btn_0
            1 -> R.id.habit_btn_1
            2 -> R.id.habit_btn_2
            3 -> R.id.habit_btn_3
            4 -> R.id.habit_btn_4
            5 -> R.id.habit_btn_5
            else -> R.id.habit_btn_0
        }
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
        scheduleMidnightAlarm(context)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            ACTION_HABIT_CLICK -> {
                val habitId = intent.getStringExtra(EXTRA_HABIT_ID) ?: return
                val launchIntent = context.packageManager
                    .getLaunchIntentForPackage(context.packageName)?.apply {
                        putExtra(EXTRA_HABIT_ID, habitId)
                        putExtra("widget_action", "habit_click")
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                    }
                launchIntent?.let { context.startActivity(it) }
            }
            ACTION_OPEN_APP -> {
                val launchIntent = context.packageManager
                    .getLaunchIntentForPackage(context.packageName)?.apply {
                        putExtra("widget_action", "open_session")
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                    }
                launchIntent?.let { context.startActivity(it) }
            }
            ACTION_MIDNIGHT_RESET -> {
                val manager = AppWidgetManager.getInstance(context)
                val ids = manager.getAppWidgetIds(
                    ComponentName(context, DopamineWidgetProvider::class.java)
                )
                for (id in ids) {
                    updateWidget(context, manager, id)
                }
                scheduleMidnightAlarm(context)
            }
        }
    }

    private fun scheduleMidnightAlarm(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as android.app.AlarmManager
        val intent = Intent(context, DopamineWidgetProvider::class.java).apply {
            action = ACTION_MIDNIGHT_RESET
        }
        val pi = PendingIntent.getBroadcast(
            context, 1, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val calendar = java.util.Calendar.getInstance().apply {
            add(java.util.Calendar.DAY_OF_YEAR, 1)
            set(java.util.Calendar.HOUR_OF_DAY, 0)
            set(java.util.Calendar.MINUTE, 0)
            set(java.util.Calendar.SECOND, 5)
            set(java.util.Calendar.MILLISECOND, 0)
        }

        try {
            alarmManager.setExactAndAllowWhileIdle(
                android.app.AlarmManager.RTC_WAKEUP,
                calendar.timeInMillis,
                pi
            )
        } catch (e: Exception) {
            alarmManager.set(
                android.app.AlarmManager.RTC_WAKEUP,
                calendar.timeInMillis,
                pi
            )
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        val hasSession   = prefs.getString("has_active_session", "0") == "1"
        val dayStatus    = prefs.getString("day_status", "regular") ?: "regular"
        val sessionPhase = prefs.getString("session_phase", "0")?.toIntOrNull() ?: 0

        val views = RemoteViews(context.packageName, R.layout.dopamine_widget)
        val size  = 400

        val bitmap = when {
            dayStatus == "broken" -> drawBrokenState(size)
            !hasSession           -> drawNoSessionState(size)
            else                  -> drawHabitsState(prefs, size, sessionPhase)
        }
        views.setImageViewBitmap(R.id.widget_canvas_view, bitmap)

        // Hide all habit buttons by default
        for (i in 0 until 6) {
            views.setViewVisibility(habitBtnId(i), android.view.View.GONE)
        }

        when {
            // NO SESSION — whole widget opens app
            !hasSession && dayStatus != "broken" -> {
                val intent = Intent(context, DopamineWidgetProvider::class.java).apply {
                    action = ACTION_OPEN_APP
                }
                val pi = PendingIntent.getBroadcast(
                    context, 0, intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_canvas_view, pi)
            }

            // BROKEN — no interaction
            dayStatus == "broken" -> {
                // no click handlers
            }

            // ACTIVE SESSION — show segment buttons
            else -> {
                val idsRaw  = prefs.getString("habit_ids",   "") ?: ""
                val costs   = (prefs.getString("habit_costs", "") ?: "").split(",")
                val balance = prefs.getString("balance", "0")?.toIntOrNull() ?: 0
                val ids     = idsRaw.split(",").filter { it.isNotEmpty() }
                val count   = ids.size.coerceAtMost(6)
                val sessionId = prefs.getString("session_id", "") ?: ""

                // Get widget pixel size to map button margins
                val options  = appWidgetManager.getAppWidgetOptions(appWidgetId)
                val minW = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 146)
                val minH = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 146)
                // Use minimum dimension for square widget
                val widgetDp = minOf(minW, minH).toFloat()
                // Button size in dp
                val btnDp = 72f
                val centers = segmentCenters(count)

                for (i in 0 until count) {
                    val habitId   = ids.getOrElse(i) { "" }
                    val scoreCost = costs.getOrElse(i) { "0" }.toIntOrNull() ?: 0
                    val canAfford = if (sessionPhase == 0) true else (balance >= scoreCost)

                    if (!canAfford || habitId.isEmpty() || sessionId.isEmpty()) continue

                    val (bx, by) = centers[i]
                    // Map from bitmap space (400x400) to widget dp space
                    val marginLeftDp = (bx / 400f * widgetDp - btnDp / 2f).toInt()
                    val marginTopDp  = (by / 400f * widgetDp - btnDp / 2f).toInt()

                    val btnId = habitBtnId(i)
                    views.setViewVisibility(btnId, android.view.View.VISIBLE)

                    // Position button via margins (API 31+)
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
                        views.setViewLayoutMargin(
                            btnId,
                            android.widget.RemoteViews.MARGIN_LEFT,
                            marginLeftDp.toFloat(),
                            android.util.TypedValue.COMPLEX_UNIT_DIP
                        )
                        views.setViewLayoutMargin(
                            btnId,
                            android.widget.RemoteViews.MARGIN_TOP,
                            marginTopDp.toFloat(),
                            android.util.TypedValue.COMPLEX_UNIT_DIP
                        )
                    }

                    // PendingIntent per button
                    val tapIntent = Intent(context, TransparentTapActivity::class.java).apply {
                        putExtra(TransparentTapActivity.EXTRA_HABIT_INDEX, i)
                        putExtra(TransparentTapActivity.EXTRA_WIDGET_ID, appWidgetId)
                    }
                    val pi = PendingIntent.getActivity(
                        context,
                        appWidgetId * 10 + i,
                        tapIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
                    )
                    views.setOnClickPendingIntent(btnId, pi)
                }
            }
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    fun updateWidgetPublic(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        updateWidget(context, appWidgetManager, appWidgetId)
    }

    // ─── STATE: BROKEN ────────────────────────────────────────────────────────

    private fun drawBrokenState(size: Int): Bitmap {
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val cx = size / 2f
        val cy = size / 2f

        canvas.drawColor(COLOR_BACKGROUND)
        drawPeacefulSmiley(canvas, cx, cy - size * 0.12f, size * 0.25f)

        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color     = COLOR_TEXT_SECONDARY
            textSize  = size * 0.072f
            typeface  = Typeface.create("sans-serif", Typeface.NORMAL)
            textAlign = Paint.Align.CENTER
        }
        canvas.drawText("Увидимся", cx, cy + size * 0.22f, paint)
        canvas.drawText("завтра",   cx, cy + size * 0.32f, paint)

        return bitmap
    }

    // ─── STATE: NO SESSION ────────────────────────────────────────────────────

    private fun drawNoSessionState(size: Int): Bitmap {
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val cx = size / 2f
        val cy = size / 2f

        canvas.drawColor(COLOR_BACKGROUND)
        drawEnergizedSmiley(canvas, cx, cy - size * 0.15f, size * 0.22f)

        val btnW    = size * 0.72f
        val btnH    = size * 0.20f
        val btnTop  = cy + size * 0.10f
        val btnRect = RectF(cx - btnW / 2, btnTop, cx + btnW / 2, btnTop + btnH)

        val btnPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = COLOR_PRIMARY }
        canvas.drawRoundRect(btnRect, btnH / 2, btnH / 2, btnPaint)

        val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color     = COLOR_BACKGROUND
            textSize  = size * 0.060f
            typeface  = Typeface.create("sans-serif-medium", Typeface.NORMAL)
            textAlign = Paint.Align.CENTER
        }
        canvas.drawText("К новым",      cx, btnTop + btnH * 0.40f, textPaint)
        canvas.drawText("приключениям", cx, btnTop + btnH * 0.80f, textPaint)

        return bitmap
    }

    // ─── STATE: HABITS PIE ────────────────────────────────────────────────────

    private fun drawHabitsState(prefs: SharedPreferences, size: Int, phase: Int): Bitmap {
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val cx = size / 2f
        val cy = size / 2f

        canvas.drawColor(COLOR_BACKGROUND)

        val idsRaw    = prefs.getString("habit_ids",    "") ?: ""
        val emojisRaw = prefs.getString("habit_emojis", "") ?: ""
        val costsRaw  = prefs.getString("habit_costs",  "") ?: ""
        val balance   = prefs.getString("balance",      "0")?.toFloatOrNull() ?: 0f
        val limit     = prefs.getString("daily_limit",  "0")?.toFloatOrNull() ?: 0f

        if (idsRaw.isEmpty()) return bitmap

        val ids    = idsRaw.split(",")
        val emojis = emojisRaw.split(",")
        val costs  = costsRaw.split(",").map { it.toIntOrNull() ?: 0 }
        val count  = ids.size.coerceAtMost(6)

        val sweepAngle    = 360f / count
        val outerRadius   = size * 0.42f
        val innerRadius   = size * 0.18f
        val segStrokeWidth = size * 0.012f  // переименовано во избежание конфликта с Paint.strokeWidth

        val segmentPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.FILL }
        val dividerPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style       = Paint.Style.STROKE
            strokeWidth = segStrokeWidth
            color       = COLOR_BACKGROUND
        }
        val ovalRect = RectF(cx - outerRadius, cy - outerRadius, cx + outerRadius, cy + outerRadius)

        // Вынесен за пределы цикла — textSize не меняется между итерациями
        val emojiPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            textAlign = Paint.Align.CENTER
            textSize  = size * 0.10f
        }

        var allDisabled = true

        for (i in 0 until count) {
            val startAngle = -90f + sweepAngle * i
            val habitCost  = costs.getOrElse(i) { 0 }

            val canAfford = if (phase == 0) true else (balance >= habitCost && limit > 0f)
            if (canAfford) allDisabled = false

            segmentPaint.color = if (canAfford) COLOR_SURFACE_ELEVATED else COLOR_DISABLED

            val path = Path()
            path.moveTo(cx, cy)
            path.arcTo(ovalRect, startAngle, sweepAngle - 0.5f, false)
            path.close()
            canvas.drawPath(path, segmentPaint)
            canvas.drawPath(path, dividerPaint)

            val emojiAngleDeg = startAngle + sweepAngle / 2f
            val emojiAngleRad = Math.toRadians(emojiAngleDeg.toDouble())
            val emojiRadius   = (outerRadius + innerRadius) / 2f
            val ex = cx + emojiRadius * cos(emojiAngleRad).toFloat()
            val ey = cy + emojiRadius * sin(emojiAngleRad).toFloat()

            canvas.drawText(
                emojis.getOrElse(i) { "❓" },
                ex,
                ey + emojiPaint.textSize * 0.35f,
                emojiPaint
            )
        }

        // Donut hole background
        val holePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = COLOR_BACKGROUND }
        canvas.drawCircle(cx, cy, innerRadius, holePaint)

        // Determine if any habit is unaffordable (control phase only)
        val hasAnyDisabled = phase == 1 && (0 until count).any { i ->
            val cost = costs.getOrElse(i) { 0 }
            balance < cost
        }

        // Orange stroke on donut hole if any disabled
        if (hasAnyDisabled) {
            val strokePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                style = Paint.Style.STROKE
                color = COLOR_SECONDARY_ACCENT
                strokeWidth = segStrokeWidth * 3f
            }
            canvas.drawCircle(cx, cy, innerRadius - segStrokeWidth * 1.5f, strokePaint)
        }

        // Counter text
        val counterText = if (phase == 0) {
            // Calibration: show spent today
            prefs.getString("spent_today", "0") ?: "0"
        } else {
            // Control: show remaining balance
            balance.toInt().toString()
        }

        val counterPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            textAlign = Paint.Align.CENTER
            textSize  = innerRadius * 0.72f
            typeface  = Typeface.create("sans-serif-medium", Typeface.BOLD)
            color     = if (hasAnyDisabled) COLOR_SECONDARY_ACCENT else COLOR_PRIMARY
        }

        if (hasAnyDisabled) {
            // Counter + STOP label
            val stopLabelSize = innerRadius * 0.38f
            canvas.drawText(
                counterText,
                cx,
                cy - stopLabelSize * 0.3f,
                counterPaint.apply { textSize = innerRadius * 0.60f }
            )
            val stopPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                textAlign = Paint.Align.CENTER
                textSize  = stopLabelSize
                typeface  = Typeface.create("sans-serif-medium", Typeface.BOLD)
                color     = COLOR_SECONDARY_ACCENT
            }
            canvas.drawText("STOP", cx, cy + stopLabelSize * 1.1f, stopPaint)
        } else {
            canvas.drawText(counterText, cx, cy + counterPaint.textSize * 0.35f, counterPaint)
        }

        // Outer accent ring
        val ringPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style       = Paint.Style.STROKE
            color       = COLOR_PRIMARY
            strokeWidth = segStrokeWidth * 1.5f
        }
        canvas.drawCircle(cx, cy, outerRadius + segStrokeWidth, ringPaint)

        return bitmap
    }

    // ─── SMILEYS ──────────────────────────────────────────────────────────────

    private fun drawPeacefulSmiley(canvas: Canvas, cx: Float, cy: Float, r: Float) {
        val facePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = COLOR_SURFACE_ELEVATED
            style = Paint.Style.FILL
        }
        val linePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color       = COLOR_PRIMARY
            style       = Paint.Style.STROKE
            strokeWidth = r * 0.12f
            strokeCap   = Paint.Cap.ROUND
        }

        canvas.drawCircle(cx, cy, r, facePaint)

        val eyeY    = cy - r * 0.15f
        val eyeOffX = r * 0.35f
        val eyeW    = r * 0.25f

        for (sign in listOf(-1f, 1f)) {
            val ex   = cx + sign * eyeOffX
            val path = Path()
            path.moveTo(ex - eyeW, eyeY)
            path.quadTo(ex, eyeY - r * 0.15f, ex + eyeW, eyeY)
            canvas.drawPath(path, linePaint)
        }

        val mouthPath = Path()
        mouthPath.moveTo(cx - r * 0.3f, cy + r * 0.25f)
        mouthPath.quadTo(cx, cy + r * 0.45f, cx + r * 0.3f, cy + r * 0.25f)
        canvas.drawPath(mouthPath, linePaint)
    }

    private fun drawEnergizedSmiley(canvas: Canvas, cx: Float, cy: Float, r: Float) {
        val facePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = COLOR_SURFACE_ELEVATED
            style = Paint.Style.FILL
        }
        val linePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color       = COLOR_SECONDARY_ACCENT
            style       = Paint.Style.STROKE
            strokeWidth = r * 0.12f
            strokeCap   = Paint.Cap.ROUND
        }
        val eyePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = COLOR_SECONDARY_ACCENT
            style = Paint.Style.FILL
        }

        canvas.drawCircle(cx, cy, r, facePaint)

        val eyeY    = cy - r * 0.15f
        val eyeOffX = r * 0.35f
        canvas.drawCircle(cx - eyeOffX, eyeY, r * 0.10f, eyePaint)
        canvas.drawCircle(cx + eyeOffX, eyeY, r * 0.10f, eyePaint)

        val mouthPath = Path()
        mouthPath.moveTo(cx - r * 0.4f, cy + r * 0.15f)
        mouthPath.quadTo(cx, cy + r * 0.60f, cx + r * 0.4f, cy + r * 0.15f)
        canvas.drawPath(mouthPath, linePaint)
    }
}