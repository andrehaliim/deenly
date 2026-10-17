import 'dart:async';

import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/mosque_model.dart';
import 'package:deenly/pages/mosque/mosque_card_widget.dart';
import 'package:deenly/pages/quran/eight_point_star_painter.dart';
import 'package:deenly/pages/quran/staggered_entrance_widget.dart';
import 'package:deenly/proxys/mosque_proxy.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class MosquePage extends StatefulWidget {
  /// Whether the tab is visible. Mosques are only fetched (GPS + network)
  /// once the user actually opens the tab.
  final bool isActive;

  const MosquePage({super.key, this.isActive = false});

  @override
  State<MosquePage> createState() => _MosquePageState();
}

class _MosquePageState extends State<MosquePage>
    with SingleTickerProviderStateMixin {
  List<MosqueModel> mosques = [];
  bool isLoading = true;
  bool _hasFetched = false;
  _MosqueError? _error;

  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.isActive) _fetchMosques();
  }

  @override
  void didUpdateWidget(MosquePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Fetch on first open, and retry on reopen after a failure.
    final becameActive = widget.isActive && !oldWidget.isActive;
    if (becameActive && (!_hasFetched || _error != null)) _fetchMosques();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _fetchMosques({bool showLocalLoading = true}) async {
    _hasFetched = true;
    setState(() {
      if (showLocalLoading) isLoading = true;
      _error = null;
    });

    try {
      final fetchedMosques = await MosqueProxy().fetchMosques();
      if (!mounted) return;
      setState(() {
        mosques = fetchedMosques;
      });
      _entranceController.forward(from: 0);
    } catch (e) {
      debugPrint('Fetching mosques failed: $e');
      if (!mounted) return;
      setState(() {
        _error = _isLocationError(e)
            ? _MosqueError.location
            : _MosqueError.other;
      });
    } finally {
      if (mounted && showLocalLoading) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _openDirections(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=walking',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      final message = AppLocalizations.of(context)?.couldNotOpenMaps;
      if (message == null) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _body());
  }

  Widget _body() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final l10n = AppLocalizations.of(context);
    final error = _error;
    if (error != null) {
      return _StatusMessage(
        icon: Icons.location_off_rounded,
        message: switch (error) {
          _MosqueError.location => l10n?.mosqueLocationUnavailable ?? '',
          _MosqueError.other => l10n?.mosqueLoadFailed ?? '',
        },
        onRetry: _fetchMosques,
      );
    }

    if (mosques.isEmpty) {
      return _StatusMessage(
        icon: Icons.mosque_outlined,
        message: l10n?.noMosqueFound ?? '',
        onRetry: _fetchMosques,
      );
    }

    return Column(
      children: [
        _SectionTitle(
          title: l10n?.nearbyMosques ?? '',
          trailing: _CountBadge(count: mosques.length),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            color: Theme.of(context).colorScheme.primary,
            onRefresh: () => _fetchMosques(showLocalLoading: false),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: mosques.length,
              itemBuilder: (context, index) {
                final mosque = mosques[index];
                return StaggeredEntrance(
                  animation: _entranceController,
                  index: index,
                  child: MosqueCard(
                    mosque: mosque,
                    onTap: () => _openDirections(mosque.lat, mosque.lon),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trailing = this.trailing;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
          ?trailing,
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        count.toString(),
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback onRetry;

  const _StatusMessage({
    required this.icon,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 96,
              child: CustomPaint(
                painter: EightPointStarPainter(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  filled: true,
                ),
                foregroundPainter: EightPointStarPainter(
                  color: colorScheme.primary.withValues(alpha: 0.6),
                  strokeWidth: 2,
                ),
                child: Center(
                  child: Icon(icon, size: 36, color: colorScheme.primary),
                ),
              ),
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
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n?.mosqueTryAgain ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}

enum _MosqueError { location, other }

/// GPS is off, permission is missing, or no fix came in time.
bool _isLocationError(Object error) =>
    error is LocationServiceDisabledException ||
    error is PermissionDeniedException ||
    error is PermissionRequestInProgressException ||
    error is TimeoutException;
