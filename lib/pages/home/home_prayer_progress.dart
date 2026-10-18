import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePrayerProgress extends StatefulWidget {
  const HomePrayerProgress({super.key});

  @override
  State<HomePrayerProgress> createState() => _HomePrayerProgressState();
}

class _HomePrayerProgressState extends State<HomePrayerProgress> {
  final List<String> _prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  Map<String, bool> _prayerProgress = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = "${now.year}-${now.month}-${now.day}";
    final lastResetDate = prefs.getString('prayerProgressLastReset') ?? "";

    if (lastResetDate != today) {
      for (var prayer in _prayerNames) {
        await prefs.setBool('${prayer.toLowerCase()}Progress', false);
      }
      await prefs.setString('prayerProgressLastReset', today);
    }

    final Map<String, bool> progress = {};
    for (var prayer in _prayerNames) {
      progress[prayer] =
          prefs.getBool('${prayer.toLowerCase()}Progress') ?? false;
    }

    if (mounted) {
      setState(() {
        _prayerProgress = progress;
      });
    }
  }

  Future<void> _toggleProgress(String prayer) async {
    final prefs = await SharedPreferences.getInstance();
    final bool currentValue = _prayerProgress[prayer] ?? false;
    final String key = '${prayer.toLowerCase()}Progress';
    await prefs.setBool(key, !currentValue);
    _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final completedCount = _prayerProgress.values.where((v) => v).length;
    final progress = completedCount / _prayerNames.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n?.prayerProgress ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$completedCount/${_prayerNames.length} '
                  '${l10n?.completed ?? ''}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: colorScheme.secondary,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final prayer in _prayerNames)
                Expanded(
                  child: _PrayerCheckItem(
                    label: PrayerProxy().getPrayerLabel(context, prayer),
                    isCompleted: _prayerProgress[prayer] ?? false,
                    onTap: () => _toggleProgress(prayer),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrayerCheckItem extends StatelessWidget {
  final String label;
  final bool isCompleted;
  final VoidCallback onTap;

  const _PrayerCheckItem({
    required this.label,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? colorScheme.primary
                  : colorScheme.primaryContainer.withValues(alpha: 0.5),
              border: Border.all(
                color: isCompleted
                    ? colorScheme.primary
                    : colorScheme.primary.withValues(alpha: 0.25),
              ),
              boxShadow: isCompleted
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : const [],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                isCompleted ? Icons.check_rounded : Icons.mosque_outlined,
                key: ValueKey(isCompleted),
                size: 20,
                color: isCompleted
                    ? colorScheme.onPrimary
                    : colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: isCompleted ? FontWeight.bold : FontWeight.w500,
                color: isCompleted
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
