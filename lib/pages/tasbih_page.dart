import 'dart:math' as math;

import 'package:deenly/components/app_theme.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int selectedTarget = 33;
  int currentCount = 0;
  int _selectedTasbihIndex = 0;
  late FixedExtentScrollController _scrollController;

  static const List<({String latin, String arabic})> _tasbihItems = [
    (latin: 'Subhanallah', arabic: 'سُبْحَانَ اللَّهِ'),
    (latin: 'Alhamdulillah', arabic: 'الْحَمْدُ لِلَّهِ'),
    (latin: 'Allahu Akbar', arabic: 'اللَّهُ أَكْبَرُ'),
    (latin: 'Laa ilaha illallah', arabic: 'لَا إِلَهَ إِلَّا اللَّهُ'),
    (latin: 'Astaghfirullah', arabic: 'أَسْتَغْفِرُ اللَّهَ'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 0.94).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _controller.reverse();
          }
        });
    _scrollController = FixedExtentScrollController(
      initialItem: _tasbihItems.length * 100,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _vibrate() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 50);
    }
  }

  void _vibrate2Times() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 100);
    }
  }

  void _vibrateLong() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 1000);
    }
  }

  void _onCount() {
    _controller.forward(from: 0.0);
    final hasTarget = selectedTarget != -1;
    // A tap after a finished round starts the next round.
    final nextCount = hasTarget && currentCount >= selectedTarget
        ? 1
        : currentCount + 1;
    if (hasTarget && nextCount == selectedTarget) {
      _vibrateLong();
    } else {
      _vibrate();
    }
    setState(() {
      currentCount = nextCount;
    });
  }

  void _onDhikrChanged(int index) {
    final length = _tasbihItems.length;
    setState(() {
      _selectedTasbihIndex = (index % length + length) % length;
    });
    _vibrate();
  }

  void _reset() {
    _vibrate2Times();
    setState(() {
      currentCount = 0;
    });
  }

  void selectTarget(int target) {
    setState(() {
      selectedTarget = target;
      currentCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        children: [
          _SectionTitle(title: l10n?.sessionTitle ?? ''),
          const SizedBox(height: 8),
          _DhikrSelector(
            controller: _scrollController,
            items: [for (final item in _tasbihItems) item.latin],
            selectedIndex: _selectedTasbihIndex,
            onChanged: _onDhikrChanged,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: _CounterButton(
                count: currentCount,
                target: selectedTarget,
                arabic: _tasbihItems[_selectedTasbihIndex].arabic,
                scale: _scaleAnimation,
                onTap: _onCount,
              ),
            ),
          ),
          _SectionTitle(title: l10n?.sessionSelect ?? ''),
          const SizedBox(height: 8),
          _TargetSelector(selected: selectedTarget, onSelected: selectTarget),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: _reset,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: Text(l10n?.sessionReset ?? ''),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DhikrSelector extends StatelessWidget {
  final FixedExtentScrollController controller;
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _DhikrSelector({
    required this.controller,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hintColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.4);

    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            colorScheme.surfaceContainerLow,
            Color.alphaBlend(
              colorScheme.primary.withValues(alpha: 0.06),
              colorScheme.surfaceContainerLow,
            ),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotatedBox(
            quarterTurns: 3,
            child: ListWheelScrollView.useDelegate(
              controller: controller,
              itemExtent: 150,
              perspective: 0.003,
              diameterRatio: 2.0,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: onChanged,
              childDelegate: ListWheelChildLoopingListDelegate(
                children: [
                  for (var i = 0; i < items.length; i++)
                    RotatedBox(
                      quarterTurns: 1,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style:
                              (i == selectedIndex
                                      ? theme.textTheme.titleMedium
                                      : theme.textTheme.bodyMedium)
                                  ?.copyWith(
                                    color: i == selectedIndex
                                        ? colorScheme.primary
                                        : hintColor,
                                    fontWeight: i == selectedIndex
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ) ??
                              const TextStyle(),
                          child: Text(
                            items[i],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.chevron_left_rounded, color: hintColor),
                  Icon(Icons.chevron_right_rounded, color: hintColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final int count;
  final int target;
  final String arabic;
  final Animation<double> scale;
  final VoidCallback onTap;

  const _CounterButton({
    required this.count,
    required this.target,
    required this.arabic,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final onCard = colorScheme.onPrimary;
    final hasTarget = target != -1;
    final progress = hasTarget ? (count / target).clamp(0.0, 1.0) : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final dimension = math.min(constraints.maxWidth, constraints.maxHeight);

        return Center(
          child: ScaleTransition(
            scale: scale,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: SizedBox.square(
                dimension: dimension,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary,
                            Color.alphaBlend(
                              colorScheme.secondary.withValues(alpha: 0.35),
                              colorScheme.primary,
                            ),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.all(dimension * 0.04),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(end: progress),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return CircularProgressIndicator(
                              value: value,
                              strokeWidth: 6,
                              strokeCap: StrokeCap.round,
                              backgroundColor: onCard.withValues(alpha: 0.15),
                              color: colorScheme.secondaryFixedDim,
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(dimension * 0.18),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Text(
                                arabic,
                                key: ValueKey(arabic),
                                textDirection: TextDirection.rtl,
                                style: GoogleFonts.notoNaskhArabic(
                                  textStyle: theme.textTheme.titleLarge,
                                  fontWeight: FontWeight.w600,
                                  color: onCard.withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: ScaleTransition(
                                      scale: Tween(
                                        begin: 0.8,
                                        end: 1.0,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  ),
                              child: Text(
                                count.toString(),
                                key: ValueKey(count),
                                style: theme
                                    .extension<AppTextStyles>()
                                    ?.counter
                                    .copyWith(color: onCard),
                              ),
                            ),
                            Text(
                              hasTarget ? '/ $target' : '∞',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.secondaryFixedDim,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n?.sessionTap ?? '',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: onCard.withValues(alpha: 0.7),
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TargetSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;

  const _TargetSelector({required this.selected, required this.onSelected});

  static const _targets = [33, 100, -1];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          for (final target in _targets)
            Expanded(
              child: _TargetOption(
                label: target == -1 ? '∞' : target.toString(),
                isSelected: target == selected,
                onTap: () => onSelected(target),
              ),
            ),
        ],
      ),
    );
  }
}

class _TargetOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TargetOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = BorderRadius.circular(16);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primary : Colors.transparent,
        borderRadius: radius,
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
