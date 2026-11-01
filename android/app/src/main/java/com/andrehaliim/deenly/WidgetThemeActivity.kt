package com.andrehaliim.deenly

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.graphics.Typeface
import android.os.Bundle
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.core.content.res.ResourcesCompat

/**
 * Theme picker shown when the widget is placed, and again from the
 * launcher's "Widget settings" (the widget is reconfigurable).
 */
class WidgetThemeActivity : Activity() {
    private var widgetId = AppWidgetManager.INVALID_APPWIDGET_ID
    private lateinit var selected: WidgetTheme

    private lateinit var preview: FrameLayout
    private lateinit var options: LinearLayout

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        widgetId =
                intent?.extras?.getInt(
                        AppWidgetManager.EXTRA_APPWIDGET_ID,
                        AppWidgetManager.INVALID_APPWIDGET_ID
                )
                        ?: AppWidgetManager.INVALID_APPWIDGET_ID

        // Backing out of the first setup removes the widget, as Android expects.
        setResult(RESULT_CANCELED, resultIntent())
        if (widgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        setContentView(R.layout.widget_theme_picker)
        preview = findViewById(R.id.picker_preview)
        options = findViewById(R.id.picker_options)

        findViewById<TextView>(R.id.picker_title).typeface =
                ResourcesCompat.getFont(this, R.font.noto_serif_semibold_italic)
        findViewById<View>(R.id.picker_cancel).setOnClickListener { finish() }
        findViewById<View>(R.id.picker_apply).setOnClickListener { apply() }

        select(WidgetTheme.of(this, widgetId))
    }

    private fun select(theme: WidgetTheme) {
        selected = theme

        preview.removeAllViews()
        // Drop the previous fitted height so the new widget measures in full.
        preview.layoutParams = preview.layoutParams.apply { height = WRAP_CONTENT }
        val widget = DeenlyWidget.buildViews(this, theme).apply(this, preview)
        preview.addView(widget, FrameLayout.LayoutParams(dp(PREVIEW_WIDTH_DP), WRAP_CONTENT))
        preview.post { fitPreview(widget) }

        options.removeAllViews()
        WidgetTheme.entries.forEach { options.addView(buildOption(it, it == theme)) }
    }

    /**
     * The widget is laid out at home screen width so its tiles don't
     * truncate, then scaled down to fit the dialog.
     */
    private fun fitPreview(widget: View) {
        val available = preview.width - preview.paddingLeft - preview.paddingRight
        val scale = (available.toFloat() / widget.width).coerceAtMost(1f)
        widget.pivotX = 0f
        widget.pivotY = 0f
        widget.scaleX = scale
        widget.scaleY = scale
        // Pin the full height, or shrinking the frame below re-measures it shorter.
        widget.layoutParams = widget.layoutParams.apply { height = widget.height }
        preview.layoutParams =
                preview.layoutParams.apply {
                    height =
                            (widget.height * scale).toInt() +
                                    preview.paddingTop +
                                    preview.paddingBottom
                }
    }

    private fun buildOption(theme: WidgetTheme, isSelected: Boolean): View =
            LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
                gravity = Gravity.CENTER_HORIZONTAL
                setPadding(dp(8), dp(12), dp(8), dp(10))
                setBackgroundResource(
                        if (isSelected) R.drawable.picker_option_selected_background
                        else R.drawable.picker_option_background
                )
                setOnClickListener { select(theme) }
                layoutParams =
                        LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
                                .apply { setMargins(dp(4), 0, dp(4), 0) }

                addView(buildSwatch(theme, isSelected))
                addView(
                        TextView(context).apply {
                            setText(theme.label)
                            setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
                            setTypeface(typeface, Typeface.BOLD)
                            setTextColor(
                                    ContextCompat.getColor(
                                            context,
                                            if (isSelected) R.color.lightPrimary
                                            else R.color.lightOnSurfaceVariant
                                    )
                            )
                        },
                        LinearLayout.LayoutParams(
                                        LinearLayout.LayoutParams.WRAP_CONTENT,
                                        LinearLayout.LayoutParams.WRAP_CONTENT
                                )
                                .apply { topMargin = dp(8) }
                )
            }

    /** Theme card colors in a circle, with a check badge when selected. */
    private fun buildSwatch(theme: WidgetTheme, isSelected: Boolean): View =
            FrameLayout(this).apply {
                layoutParams = LinearLayout.LayoutParams(dp(48), dp(48))

                addView(
                        View(context).apply {
                            setBackgroundResource(theme.card)
                            clipToOutline = true
                        },
                        FrameLayout.LayoutParams(dp(44), dp(44), Gravity.CENTER)
                )
                addView(
                        View(context).apply { setBackgroundResource(R.drawable.picker_swatch_ring) },
                        FrameLayout.LayoutParams(dp(44), dp(44), Gravity.CENTER)
                )
                if (isSelected) {
                    addView(
                            ImageView(context).apply {
                                setImageResource(R.drawable.ic_check_circle)
                            },
                            FrameLayout.LayoutParams(dp(18), dp(18), Gravity.TOP or Gravity.END)
                    )
                }
            }

    private fun apply() {
        WidgetTheme.save(this, widgetId, selected)
        DeenlyWidget.update(this, intArrayOf(widgetId))
        setResult(RESULT_OK, resultIntent())
        finish()
    }

    private fun resultIntent() =
            Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)

    private companion object {
        /** About a 5-column widget on a phone home screen. */
        const val PREVIEW_WIDTH_DP = 380
        const val WRAP_CONTENT = FrameLayout.LayoutParams.WRAP_CONTENT
    }

    private fun dp(value: Int) =
            TypedValue.applyDimension(
                            TypedValue.COMPLEX_UNIT_DIP,
                            value.toFloat(),
                            resources.displayMetrics
                    )
                    .toInt()
}
