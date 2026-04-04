import 'package:flutter/material.dart';

class HomePrayerProgress extends StatefulWidget {
  const HomePrayerProgress({super.key});

  @override
  State<HomePrayerProgress> createState() => _HomePrayerProgressState();
}

class _HomePrayerProgressState extends State<HomePrayerProgress> {
  final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              Text(
                'Prayer Progress',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Spacer(),
              Text(
                '3/5 completed',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(prayers.length, (index) {
              final prayer = prayers[index];
              bool isLast = index == prayers.length - 1;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: !isLast
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade400,
                        ),
                        shape: BoxShape.circle,
                        color: !isLast
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surface,
                      ),
                      child: Icon(
                        !isLast ? Icons.check : Icons.circle,
                        color: !isLast
                            ? Theme.of(context).colorScheme.onPrimary
                            : Colors.grey.shade400,
                        size: 20,
                      ),
                    ),
                    Text(
                      prayer,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}