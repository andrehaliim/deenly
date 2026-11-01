import 'package:deenly/components/drawer_provider.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/pages/setting/prayer_adjustment_tile.dart';
import 'package:deenly/pages/setting/setting_info_card.dart';
import 'package:deenly/pages/setting/setting_section.dart';
import 'package:deenly/pages/setting/setting_subpage.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Shifts each prayer time by whole minutes. Edits only apply once saved,
/// after which the page closes.
class PrayerAdjustmentPage extends StatefulWidget {
  const PrayerAdjustmentPage({super.key, this.onSaved});

  final VoidCallback? onSaved;

  @override
  State<PrayerAdjustmentPage> createState() => _PrayerAdjustmentPageState();
}

class _PrayerAdjustmentPageState extends State<PrayerAdjustmentPage> {
  /// Unsaved edits. Rebuilt from the saved values every time the page
  /// opens, so changes that were never saved are discarded.
  final Map<String, int> _pendingAdjustments = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final drawerProvider = context.read<DrawerProvider>();
    for (final prayer in DrawerProvider.prayers) {
      _pendingAdjustments[prayer] = drawerProvider.adjustmentOf(prayer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingSubpage(
      title: l10n?.settingTimeTitle ?? '',
      children: [
        SettingInfoCard(
          icon: Icons.schedule_rounded,
          title: l10n?.settingTimeInfoTitle ?? '',
          description: l10n?.settingTimeInfoDesc ?? '',
        ),
        SettingSection(
          children: [
            for (final prayer in DrawerProvider.prayers)
              PrayerAdjustmentTile(
                prayerName: PrayerProxy().getPrayerLabel(context, prayer),
                adjustment: _pendingAdjustments[prayer] ?? 0,
                onChanged: (value) {
                  setState(() {
                    _pendingAdjustments[prayer] = value;
                  });
                },
              ),
            _SaveButton(
              label: l10n?.settingSaveButton ?? '',
              isSaving: _isSaving,
              onPressed: _saveAdjustments,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _saveAdjustments() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });

    try {
      await context.read<DrawerProvider>().saveAdjustments(
        Map.of(_pendingAdjustments),
      );
      widget.onSaved?.call();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Saving prayer adjustments failed: $e');
      final l10n = mounted ? AppLocalizations.of(context) : null;
      if (l10n != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.adjustmentSaveFailed)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.label,
    required this.isSaving,
    required this.onPressed,
  });

  final String label;
  final bool isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: isSaving ? null : onPressed,
          style: FilledButton.styleFrom(
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          icon: isSaving
              ? SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                )
              : const Icon(Icons.check_rounded, size: 20),
          label: Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isSaving ? null : theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
