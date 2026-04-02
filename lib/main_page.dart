import 'package:deenly/home_page.dart';
import 'package:deenly/mosque_page.dart';
import 'package:deenly/qibla_page.dart';
import 'package:deenly/tasbih_page.dart';
import 'package:deenly/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const HomePage(),
    const MosquePage(),
    const QiblaPage(),
    const TasbihPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final provider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.mosque_outlined),
            selectedIcon: Icon(Icons.mosque),
            label: 'Mosque',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Qibla',
          ),
          NavigationDestination(
            icon: Icon(Icons.fingerprint_outlined),
            selectedIcon: Icon(Icons.fingerprint),
            label: 'Tasbih',
          ),
        ],
      ),
      appBar: AppBar(
        title: Text('Deenly'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      endDrawer: Drawer(
        width: width * 0.75,
        child: Column(
          children: [
            Center(
              child: Switch(
                value: provider.isDarkMode,
                onChanged: (value) {
                  provider.toggleTheme(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
