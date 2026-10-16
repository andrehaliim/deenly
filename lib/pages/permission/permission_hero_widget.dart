import 'package:deenly/components/app_theme.dart';
import 'package:flutter/material.dart';

/// Illustration at the top of a permission step: a main icon with a small
/// badge and a soft pulsing halo behind it.
class PermissionHeroWidget extends StatefulWidget {
  final IconData icon;
  final IconData badgeIcon;

  const PermissionHeroWidget({
    super.key,
    required this.icon,
    required this.badgeIcon,
  });

  @override
  State<PermissionHeroWidget> createState() => _PermissionHeroWidgetState();
}

class _PermissionHeroWidgetState extends State<PermissionHeroWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = theme.extension<AppColors>();

    return Container(
      height: 168,
      width: double.infinity,
      decoration: BoxDecoration(
        color: appColors?.surfaceLow ?? colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final value = Curves.easeOut.transform(_controller.value);
              return Transform.scale(
                scale: 1 + value * 0.6,
                child: Opacity(opacity: 1 - value, child: child),
              );
            },
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.secondary.withValues(alpha: 0.3),
              ),
            ),
          ),
          SizedBox(
            width: 104,
            height: 104,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primaryContainer,
                    ),
                    child: Icon(
                      widget.icon,
                      size: 44,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.secondary,
                      border: Border.all(
                        color: appColors?.surfaceLow ?? colorScheme.surface,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      widget.badgeIcon,
                      size: 18,
                      color: colorScheme.onSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
