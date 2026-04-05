import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage>
    with SingleTickerProviderStateMixin {
  bool _hasPermissions = false;
  bool _isLoading = true;
  double? _qiblaDirection;
  Position? _currentPosition;
  String _location = '';

  @override
  void initState() {
    super.initState();
    _loadLocation();
    _initializeQibla();
  }

  Future<void> _loadLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final String prefLocation = prefs.getString('location') ?? '';
    setState(() {
      _location = prefLocation;
    });
  }

  Future<void> _initializeQibla() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoading = false);
      return;
    }

    _hasPermissions = true;
    _currentPosition = await Geolocator.getCurrentPosition();
    _qiblaDirection = _calculateQiblaDirection(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    setState(() {
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
    return _buildBody();
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasPermissions) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off_rounded,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            Text(
              'Location permission required',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() => _isLoading = true);
                _initializeQibla();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error reading compass',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
          );
        }

        final double? heading = snapshot.data?.heading;

        if (heading == null) {
          return Center(
            child: Text(
              'Device does not have compass sensors',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        final qiblaAngle = (_qiblaDirection ?? 0) - heading;

        double diff = qiblaAngle;
        diff = (diff + 180) % 360 - 180;

        String turnText;
        Color instructionColor;
        Color textColor;

        if (diff.abs() < 2) {
          turnText = "You are facing the Qibla!";
          instructionColor = Theme.of(context).primaryColor;
          textColor = Colors.green;
        } else if (diff > 0) {
          turnText =
              "Rotate the phone ${diff.toStringAsFixed(0)}° to the right";
          instructionColor = Theme.of(context).colorScheme.onPrimary;
          textColor = Theme.of(context).colorScheme.onTertiary;
        } else {
          turnText =
              "Rotate the phone ${math.min(diff.abs(), 359).toStringAsFixed(0)}° to the left";
          instructionColor = Theme.of(context).colorScheme.onPrimary;
          textColor = Theme.of(context).colorScheme.onTertiary;
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12.0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    size: Theme.of(context).textTheme.bodyLarge?.fontSize,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _location,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Center(
              child: SizedBox(
                width: 320,
                height: 320,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedRotation(
                      turns: -heading / 360,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                          border: Border.all(
                            color: const Color(0xFF2C2C3A),
                            width: 2,
                          ),
                        ),
                        child: CustomPaint(
                          painter: CompassDialPainter(),
                          size: const Size(320, 320),
                        ),
                      ),
                    ),

                    AnimatedRotation(
                      turns: qiblaAngle / 360,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 50,
                            bottom: 160,
                            child: Container(
                              width: 3,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFD4AF37),
                                    Color(0x00D4AF37),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Positioned(top: 20, child: _buildKaabaIcon()),
                        ],
                      ),
                    ),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFD4AF37),
                        border: Border.all(
                          color: const Color(0xFF15151D),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            Text(
              turnText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
          ],
        );
      },
    );
  }

  Widget _buildKaabaIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white24, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            blurRadius: 16,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Container(
              height: 8,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFB8860B),
                    Color(0xFFFFDF00),
                    Color(0xFFB8860B),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 19,
            right: 8,
            child: Container(
              width: 6,
              height: 10,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CompassDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final tickPaint = Paint()
      ..color = Color(0xFFE8E8E8)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final activeTickPaint = Paint()
      ..color = Color(0xFFE8E8E8)
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
        isCardinal ? activeTickPaint : tickPaint,
      );
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    void drawText(String text, double angle) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          color: text == 'N' ? const Color(0xFFD4AF37) : Colors.white70,
          fontWeight: text == 'N' ? FontWeight.bold : FontWeight.w500,
          fontSize: text == 'N' ? 24 : 18,
        ),
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
