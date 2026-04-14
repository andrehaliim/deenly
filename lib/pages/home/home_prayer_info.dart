import 'package:deenly/components/widget_helper.dart';
import 'package:deenly/models/prayer_model.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomePrayerInfo extends StatefulWidget {
  final String location;
  final PrayerModel prayerModel;
  final Function() onRefreshLocation;

  const HomePrayerInfo({
    super.key,
    required this.location,
    required this.prayerModel,
    required this.onRefreshLocation,
  });

  @override
  State<HomePrayerInfo> createState() => _HomePrayerInfoState();
}

class _HomePrayerInfoState extends State<HomePrayerInfo> {
  late Map<String, String> _next;

  final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  bool _showPrayerTimes = false;

  @override
  void initState() {
    super.initState();
    _next = PrayerProxy().getNextPrayer(widget.prayerModel.toJson());
    updateWidget();
  }

  void updateWidget() async {
    await WidgetHelper().updateWidgetNextPrayer(_next['nextPrayer']!);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.5),
              BlendMode.darken,
            ),
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: widget.onRefreshLocation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 20,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.location,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Next Prayer',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.prayerModel.hijriDate} ${widget.prayerModel.hijriMonth} ${widget.prayerModel.hijriYear} \n ${DateFormat('dd MMM yyyy').format(DateFormat('dd-MM-yyyy').parse(widget.prayerModel.date))}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _next['nextPrayer'] ?? '',
              style: GoogleFonts.notoSerif(
                textStyle: Theme.of(context).textTheme.headlineLarge,
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _next['nextTime'] ?? '',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    children: [
                      Text(
                        'Prayer Times',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),

                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showPrayerTimes = !_showPrayerTimes;
                          });
                        },
                        child: AnimatedRotation(
                          turns: _showPrayerTimes ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            Icons.arrow_drop_down,
                            size: 32,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: ClipRect(
                    child: AnimatedAlign(
                      alignment: Alignment.topCenter,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      heightFactor: _showPrayerTimes ? 1.0 : 0.0,
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          ...prayers.map((prayer) {
                            final isNext = prayer == _next['nextPrayer'];
                            final time = widget.prayerModel.toJson()[prayer];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: isNext
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isNext
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(
                                          context,
                                        ).colorScheme.outline.withAlpha(50),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    prayer,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          fontWeight: isNext
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          color: isNext
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.onPrimary
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                        ),
                                  ),
                                  Text(
                                    time ?? '',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isNext
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.onPrimary
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
