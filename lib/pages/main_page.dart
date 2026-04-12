import 'package:deenly/pages/drawer_page.dart';
import 'package:deenly/pages/home/home_page.dart';
import 'package:deenly/pages/mosque_page.dart';
import 'package:deenly/components/custom_navigation_bar.dart';
import 'package:deenly/pages/qibla_page.dart';
import 'package:deenly/pages/quran/quran_page.dart';
import 'package:deenly/pages/tasbih_page.dart';
import 'package:deenly/components/notification_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {

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
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () {
              NotificationHelper().showDailyMidnightNotification("TEST-DATE");
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const QuranPage(),
          const MosquePage(),
          const HomePage(),
          QiblaPage(isActive: _selectedIndex == 3),
          const TasbihPage(),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      endDrawer: DrawerPage() 
    );
  }
}
