package com.andrehaliim.deenly

import android.content.Context
import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes

/** Color skins for [DeenlyWidget], picked per widget in [WidgetThemeActivity]. */
enum class WidgetTheme(
        @StringRes val label: Int,
        @DrawableRes val card: Int,
        @DrawableRes val tile: Int,
        @DrawableRes val tileActive: Int,
        @DrawableRes val chip: Int,
        @DrawableRes val nextBox: Int,
        /** Title text; also tints the logo unless [logoKeepsColors]. */
        @ColorRes val brand: Int,
        val logoKeepsColors: Boolean,
        @ColorRes val accent: Int,
        @ColorRes val secondaryText: Int,
        @ColorRes val nextName: Int,
        @ColorRes val countdown: Int,
        @ColorRes val tileIcon: Int,
        @ColorRes val tileTime: Int,
        @ColorRes val tilePeriod: Int,
        @ColorRes val activeAccent: Int,
        @ColorRes val activeText: Int
) {
    LIGHT(
            label = R.string.widget_theme_light,
            card = R.drawable.widget_card_background,
            tile = R.drawable.prayer_tile_background,
            tileActive = R.drawable.prayer_tile_active_background,
            chip = R.drawable.location_chip_background,
            nextBox = R.drawable.next_prayer_background,
            brand = R.color.lightPrimary,
            logoKeepsColors = false,
            accent = R.color.widgetAccent,
            secondaryText = R.color.lightOnSurfaceVariant,
            nextName = R.color.lightPrimary,
            countdown = R.color.lightPrimary,
            tileIcon = R.color.lightOnSurfaceVariant,
            tileTime = R.color.lightOnSurface,
            tilePeriod = R.color.lightOutline,
            activeAccent = R.color.widgetAccent,
            activeText = R.color.widgetOnPrimary
    ),
    DARK(
            label = R.string.widget_theme_dark,
            card = R.drawable.widget_card_background_dark,
            tile = R.drawable.prayer_tile_background_dark,
            tileActive = R.drawable.prayer_tile_active_background_dark,
            chip = R.drawable.location_chip_background_dark,
            nextBox = R.drawable.next_prayer_background_dark,
            brand = R.color.widgetDarkBrand,
            logoKeepsColors = false,
            accent = R.color.widgetAccent,
            secondaryText = R.color.widgetDarkOnSurfaceVariant,
            nextName = R.color.widgetDarkBrand,
            countdown = R.color.widgetDarkBrand,
            tileIcon = R.color.widgetDarkOnSurfaceVariant,
            tileTime = R.color.widgetDarkOnSurface,
            tilePeriod = R.color.widgetDarkOutline,
            activeAccent = R.color.widgetAccent,
            activeText = R.color.widgetOnPrimary
    ),
    DEENLY(
            label = R.string.widget_theme_deenly,
            card = R.drawable.widget_card_background_primary,
            tile = R.drawable.prayer_tile_background_primary,
            tileActive = R.drawable.prayer_tile_active_background_primary,
            chip = R.drawable.location_chip_background_primary,
            nextBox = R.drawable.next_prayer_background_primary,
            brand = R.color.widgetOnPrimary,
            // The launcher artwork is already cream and gold on teal.
            logoKeepsColors = true,
            accent = R.color.widgetAccent,
            secondaryText = R.color.widgetPrimaryOnSurfaceVariant,
            nextName = R.color.widgetOnPrimary,
            countdown = R.color.widgetAccent,
            tileIcon = R.color.widgetPrimaryOnSurfaceVariant,
            tileTime = R.color.widgetOnPrimary,
            tilePeriod = R.color.widgetPrimaryOutline,
            activeAccent = R.color.lightPrimary,
            activeText = R.color.lightOnSurfaceVariant
    );

    companion object {
        private const val PREFS_NAME = "deenly_widget_themes"

        private fun key(widgetId: Int) = "theme_$widgetId"

        fun of(context: Context, widgetId: Int): WidgetTheme {
            val name = prefs(context).getString(key(widgetId), null)
            return entries.firstOrNull { it.name == name } ?: LIGHT
        }

        fun save(context: Context, widgetId: Int, theme: WidgetTheme) {
            prefs(context).edit().putString(key(widgetId), theme.name).apply()
        }

        fun delete(context: Context, widgetIds: IntArray) {
            prefs(context).edit().apply { widgetIds.forEach { remove(key(it)) } }.apply()
        }

        private fun prefs(context: Context) =
                context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }
}
