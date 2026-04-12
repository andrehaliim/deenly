import 'package:deenly/pages/main_page.dart';
import 'package:deenly/proxys/location_proxy.dart';
import 'package:flutter/material.dart';

class NoLocationPage extends StatefulWidget {
  const NoLocationPage({super.key});

  @override
  State<NoLocationPage> createState() => _NoLocationPageState();
}

class _NoLocationPageState extends State<NoLocationPage> {
  final LocationProxy _locationProxy = LocationProxy();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Location permission denied',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _locationProxy.requestPermission().then((value) {
                      if (value == true) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const MainPage()),
                        );
                      } else if (value == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Location permission denied forever, please enable it in settings'),
                            backgroundColor: Theme.of(context).colorScheme.error,
                          ),
                        );
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Retry',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )
    );
  }
}