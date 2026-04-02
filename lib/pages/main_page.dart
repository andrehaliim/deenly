import 'package:deenly/pages/home_page.dart';
import 'package:deenly/pages/mosque_page.dart';
import 'package:deenly/components/custom_navigation_bar.dart';
import 'package:deenly/pages/qibla_page.dart';
import 'package:deenly/pages/tasbih_page.dart';
import 'package:deenly/components/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      appBar: AppBar(
        title: Text(
          'Deenly',
          style: GoogleFonts.notoSerif(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
          ),
        ),
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
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
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
