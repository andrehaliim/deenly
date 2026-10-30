import 'package:deenly/components/app_colors.dart';
import 'package:deenly/models/islamic_event_model.dart';
import 'package:flutter/material.dart';

/// Marker colors shared by the grid, legend, event list and day sheet.
class CalendarMarkerColor {
  static Color holiday(ThemeData theme) => theme.colorScheme.secondary;

  static Color sunnahFast(ThemeData theme) =>
      theme.extension<AppColors>()?.onMenuTile ?? theme.colorScheme.primary;

  static Color forbiddenFast(ThemeData theme) => theme.colorScheme.error;

  static Color ofFasting(ThemeData theme, FastingType fasting) {
    return fasting == FastingType.forbidden
        ? forbiddenFast(theme)
        : sunnahFast(theme);
  }

  static Color info(ThemeData theme) => theme.colorScheme.outline;

  static Color ofEvent(ThemeData theme, IslamicEventModel event) {
    return switch (event.type) {
      IslamicEventType.holiday => holiday(theme),
      IslamicEventType.fasting => sunnahFast(theme),
      IslamicEventType.info => info(theme),
    };
  }
}
