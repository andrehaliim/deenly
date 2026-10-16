import 'dart:async';

import 'package:deenly/l10n/app_localizations.dart';
import 'package:deenly/models/mosque_model.dart';
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

class _MosquePageState extends State<MosquePage> {
  List<MosqueModel> mosques = [];
  bool isLoading = true;
  bool _hasFetched = false;
  _MosqueError? _error;

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

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toInt()} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.couldNotOpenMaps)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final error = _error;
    if (error != null) {
      final l10n = AppLocalizations.of(context)!;
      return _buildCenteredMessage(
        icon: Icons.error_outline,
        message: switch (error) {
          _MosqueError.location => l10n.mosqueLocationUnavailable,
          _MosqueError.other => l10n.mosqueLoadFailed,
        },
      );
    }

    if (mosques.isEmpty) {
      return _buildCenteredMessage(
        icon: Icons.mosque_outlined,
        message: AppLocalizations.of(context)!.noMosqueFound,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchMosques(showLocalLoading: false),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: mosques.length,
        itemBuilder: (context, index) => _buildMosqueCard(mosques[index]),
      ),
    );
  }

  Widget _buildCenteredMessage({
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: _fetchMosques,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.mosqueTryAgain,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMosqueCard(MosqueModel mosque) {
    final isPending = mosque.address == 'Address pending...';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openDirections(mosque.lat, mosque.lon),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              bottom: 0,
              child: Image.asset(
                'assets/images/mosque.png',
                height: 120,
                fit: BoxFit.contain,
                color: Theme.of(context).colorScheme.onPrimary,
                colorBlendMode: BlendMode.modulate,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mosque.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDistance(mosque.distance),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (isPending)
                    Row(
                      children: [
                        SizedBox(
                          height: 12,
                          width: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimary.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.mosqueLoadAddress,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimary.withValues(alpha: 0.5),
                              ),
                        ),
                      ],
                    )
                  else
                    Text(
                      mosque.address ?? 'error',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        height: 1.4,
                      ),
                    ),
                ],
              ),
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
