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
    int completedCount = _prayerProgress.values.where((v) => v).length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prayer Progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withAlpha(100),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$completedCount/${_prayerNames.length} Completed',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _prayerNames.map((prayer) {
              final isCompleted = _prayerProgress[prayer] ?? false;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _toggleProgress(prayer),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isCompleted
                              ? LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.primary,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isCompleted
                              ? null
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainer.withAlpha(150),
                          border: Border.all(
                            color: isCompleted
                                ? Colors.transparent
                                : Theme.of(
                                    context,
                                  ).colorScheme.outline.withAlpha(50),
                          ),
                          boxShadow: isCompleted
                              ? [
                                  BoxShadow(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withAlpha(80),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Icon(
                          isCompleted
                              ? Icons.check_rounded
                              : Icons.radio_button_off_rounded,
                          color: isCompleted
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant.withAlpha(100),
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        prayer,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              fontWeight: isCompleted
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isCompleted
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withAlpha(150),
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
