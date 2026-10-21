import 'dart:math' as math;

import 'package:deenly/components/app_colors.dart';
import 'package:deenly/components/prayer_sync_helper.dart';
import 'package:deenly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QiblaPage extends StatefulWidget {
  final bool isActive;
  const QiblaPage({super.key, this.isActive = false});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  bool _isLoading = true;
  double? _qiblaDirection;
  String _location = '';

  @override
  void initState() {
    super.initState();
    if (widget.isActive) init();
  }

  @override
  void didUpdateWidget(QiblaPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      init();
    }
  }

  Future<void> init() async {
    await _loadLocation();
  }

  Future<void> _loadLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final prefLocation = prefs.getString(PrayerSyncHelper.keyLocationName);
    final lat = prefs.getDouble(PrayerSyncHelper.keyLatitude);
    final lng = prefs.getDouble(PrayerSyncHelper.keyLongitude);

    if (!mounted) return;
    setState(() {
      // Without a saved location the direction would be computed from
      // 0,0, so show a message instead of a wrong Qibla.
      _qiblaDirection = lat != null && lng != null
          ? _calculateQiblaDirection(lat, lng)
          : null;
      _location = prefLocation ?? '';
      _isLoading = false;
    });
  }

  double _calculateQiblaDirection(double lat, double lon) {
    const double kaabaLat = 21.422487;
    const double kaabaLng = 39.826206;

    final lat1 = lat * math.pi / 180.0;
    final lon1 = lon * math.pi / 180.0;

    final lat2 = kaabaLat * math.pi / 180.0;
    final lon2 = kaabaLng * math.pi / 180.0;

    final dLon = lon2 - lon1;

    final y = math.sin(dLon) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    var brng = math.atan2(y, x);
    brng = brng * 180.0 / math.pi;

    return (brng + 360.0) % 360.0;
  }

  @override
  Widget build(BuildContext context) {
    // The page lives in an IndexedStack; only listen to the compass while
    // the tab is visible so the sensor does not run in the background.
    if (!widget.isActive) return const SizedBox.shrink();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final l10n = AppLocalizations.of(context);
    final qiblaDirection = _qiblaDirection;
    if (qiblaDirection == null) {
      return _QiblaStatus(
        icon: Icons.location_off_rounded,
        message: l10n?.qiblaNoLocation ?? '',
      );
    }

    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _QiblaStatus(
            icon: Icons.explore_off_rounded,
            message: l10n?.errorRead ?? '',
            isError: true,
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final heading = snapshot.data?.heading;
        if (heading == null) {
          return _QiblaStatus(
            icon: Icons.explore_off_rounded,
            message: l10n?.errorNotSupport ?? '',
            isError: true,
          );
        }

        return _QiblaView(
          location: _location,
          qiblaDirection: qiblaDirection,
          heading: heading,
        );
      },
    );
  }
}

class _QiblaView extends StatelessWidget {
  final String location;
  final double qiblaDirection;
  final double heading;

  const _QiblaView({
    required this.location,
    required this.qiblaDirection,
    required this.heading,
  });

  @override
  Widget build(BuildContext context) {
    final qiblaAngle = qiblaDirection - heading;
    final diff = (qiblaAngle + 180) % 360 - 180;
    final isFacing = diff.abs() < 2;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        children: [
          _LocationCard(location: location, qiblaDirection: qiblaDirection),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final dimension = math.min(
                    math.min(constraints.maxWidth, constraints.maxHeight),
                    320.0,
                  );
                  return Center(
                    child: _Compass(
                      dimension: dimension,
                      heading: heading,
                      qiblaAngle: qiblaAngle,
                      isFacing: isFacing,
                    ),
                  );
                },
              ),
            ),
          ),
          _TurnHint(diff: diff, isFacing: isFacing),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String location;
  final double qiblaDirection;

  const _LocationCard({required this.location, required this.qiblaDirection});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = theme.extension<AppColors>();
    final l10n = AppLocalizations.of(context);
    final onCard = colorScheme.onPrimary;
    const radius = BorderRadius.all(Radius.circular(20));

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: appColors?.heroGradient,
        boxShadow: [
          BoxShadow(
            color: appColors?.heroShadow ?? colorScheme.shadow,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: onCard.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.location_on_rounded,
                size: 22,
                color: colorScheme.secondaryFixedDim,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.qiblaDirection ?? '',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: onCard.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location.isEmpty ? '-' : location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: onCard,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${qiblaDirection.toStringAsFixed(0)}°',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.secondaryFixedDim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Compass extends StatelessWidget {
  final double dimension;
  final double heading;
  final double qiblaAngle;
  final bool isFacing;

  const _Compass({
    required this.dimension,
    required this.heading,
    required this.qiblaAngle,
    required this.isFacing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = theme.extension<AppColors>();
    final onDial = colorScheme.onPrimary;
    final dialSize = Size.square(dimension);
    const rotationDuration = Duration(milliseconds: 300);

    return SizedBox.square(
      dimension: dimension,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isFacing
                      ? colorScheme.secondary.withValues(alpha: 0.55)
                      : colorScheme.primary.withValues(alpha: 0.25),
                  blurRadius: isFacing ? 36 : 24,
                  spreadRadius: isFacing ? 4 : 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
          AnimatedRotation(
            turns: -heading / 360,
            duration: rotationDuration,
            curve: Curves.easeOut,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: appColors?.heroGradient,
                border: Border.all(
                  color: onDial.withValues(alpha: 0.15),
                  width: 4,
                ),
              ),
              child: CustomPaint(
                size: dialSize,
                painter: CompassDialPainter(
                  tickColor: onDial.withValues(alpha: 0.85),
                  northStyle: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondaryFixedDim,
                  ),
                  labelStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: onDial.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
          AnimatedRotation(
            turns: qiblaAngle / 360,
            duration: rotationDuration,
            curve: Curves.easeOut,
            child: SizedBox.square(
              dimension: dimension,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: dimension * 0.18,
                    bottom: dimension / 2,
                    child: Container(
                      width: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colorScheme.secondaryFixedDim,
                            colorScheme.secondaryFixedDim.withValues(alpha: 0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Positioned(
                    top: dimension * 0.06,
                    child: _KaabaMarker(isFacing: isFacing),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.secondaryFixedDim,
              border: Border.all(color: onDial, width: 3),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.secondary.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          Positioned(
            top: -22,
            child: Icon(
              Icons.arrow_drop_down_rounded,
              size: 36,
              color: isFacing
                  ? colorScheme.secondary
                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _KaabaMarker extends StatelessWidget {
  final bool isFacing;

  const _KaabaMarker({required this.isFacing});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isFacing ? colorScheme.secondaryFixedDim : colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.secondaryFixedDim, width: 2),
        boxShadow: [
          BoxShadow(
            color: colorScheme.secondary.withValues(alpha: 0.35),
            blurRadius: 14,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FaIcon(
        FontAwesomeIcons.kaaba,
        size: 18,
        color: colorScheme.onSurface,
      ),
    );
  }
}

class _TurnHint extends StatelessWidget {
  final double diff;
  final bool isFacing;

  const _TurnHint({required this.diff, required this.isFacing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final String text;
    final IconData icon;
    if (isFacing) {
      text = l10n?.qiblaFacing ?? '';
      icon = Icons.check_circle_rounded;
    } else if (diff > 0) {
      text = l10n?.qiblaRotate(diff.toStringAsFixed(0), l10n.right) ?? '';
      icon = Icons.rotate_right_rounded;
    } else {
      final degree = math.min(diff.abs(), 359).toStringAsFixed(0);
      text = l10n?.qiblaRotate(degree, l10n.left) ?? '';
      icon = Icons.rotate_left_rounded;
    }

    final foreground = isFacing ? colorScheme.onPrimary : colorScheme.onSurface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isFacing ? colorScheme.primary : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFacing
              ? colorScheme.primary
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(
              icon,
              key: ValueKey(icon),
              size: 20,
              color: isFacing
                  ? colorScheme.secondaryFixedDim
                  : colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QiblaStatus extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool isError;

  const _QiblaStatus({
    required this.icon,
    required this.message,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = isError ? colorScheme.error : colorScheme.primary;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: accent.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(icon, size: 36, color: accent),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompassDialPainter extends CustomPainter {
  CompassDialPainter({
    required this.tickColor,
    required this.northStyle,
    required this.labelStyle,
  });

  final Color tickColor;
  final TextStyle? northStyle;
  final TextStyle? labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final tickPaint = Paint()
      ..color = tickColor.withValues(alpha: tickColor.a * 0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final activeTickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 360; i += 5) {
      final isMajor = i % 30 == 0;
      final isCardinal = i % 90 == 0;

      final tickLength = isCardinal ? 16.0 : (isMajor ? 12.0 : 6.0);

      final angle = i * math.pi / 180;
      final startPoint = Offset(
        center.dx + (radius - 10) * math.sin(angle),
        center.dy - (radius - 10) * math.cos(angle),
      );
      final endPoint = Offset(
        center.dx + (radius - 10 - tickLength) * math.sin(angle),
        center.dy - (radius - 10 - tickLength) * math.cos(angle),
      );

      canvas.drawLine(
        startPoint,
        endPoint,
        isMajor ? activeTickPaint : tickPaint,
      );
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    void drawText(String text, double angle) {
      textPainter.text = TextSpan(
        text: text,
        style: text == 'N' ? northStyle : labelStyle,
      );
      textPainter.layout();

      final textOffset = Offset(
        center.dx + (radius - 40) * math.sin(angle) - textPainter.width / 2,
        center.dy - (radius - 40) * math.cos(angle) - textPainter.height / 2,
      );

      canvas.save();
      canvas.translate(
        textOffset.dx + textPainter.width / 2,
        textOffset.dy + textPainter.height / 2,
      );
      canvas.rotate(angle);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    drawText('N', 0);
    drawText('E', math.pi / 2);
    drawText('S', math.pi);
    drawText('W', 3 * math.pi / 2);
  }

  @override
  bool shouldRepaint(covariant CompassDialPainter oldDelegate) =>
      oldDelegate.tickColor != tickColor ||
      oldDelegate.northStyle != northStyle ||
      oldDelegate.labelStyle != labelStyle;
}
