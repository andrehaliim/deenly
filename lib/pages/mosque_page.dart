import 'package:deenly/models/mosque_model.dart';
import 'package:deenly/proxys/mosque_proxy.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class MosquePage extends StatefulWidget {
  const MosquePage({super.key});

  @override
  State<MosquePage> createState() => _MosquePageState();
}

class _MosquePageState extends State<MosquePage> {
  List<MosqueModel> mosques = [];
  bool isLoading = true;
  String? errorMessage;
  Position? currentPosition;

  @override
  void initState() {
    _fetchMosques();
    super.initState();
  }

  Future<void> _fetchMosques() async {
    try {
      setState(() {
        isLoading = true;
      });
      List<MosqueModel> fetchedMosques = await MosqueProxy().fetchMosques();
      setState(() {
        mosques = fetchedMosques;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toInt()} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  Future<void> openDirections(double lat, double lng) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=walking',
    );

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchMosques,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (mosques.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'No mosques found within 2km.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchMosques,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: mosques.length,
      itemBuilder: (context, index) {
        final mosque = mosques[index];
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12.0),
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
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              openDirections(mosque.lat, mosque.lon);
            },
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Image.asset(
                    'assets/images/mosque.png',
                    height: 120,
                    fit: BoxFit.contain,
                    color: Colors.white,
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDistance(mosque.distance),
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.surface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (mosque.address != null)
                        Text(
                          mosque.address!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.surface,
                            height: 1.4,
                          ),
                        )
                      else
                        Row(
                          children: [
                            SizedBox(
                              height: 12,
                              width: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.teal.shade100,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Loading address...',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
