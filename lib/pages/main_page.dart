import 'package:deenly/pages/home/home_page.dart';
import 'package:deenly/components/custom_navigation_bar.dart';
import 'package:deenly/pages/prayers_page.dart';
import 'package:deenly/pages/quran/quran_page.dart';
import 'package:deenly/pages/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:deenly/components/app_theme.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const int _prayersIndex = 1;
  static const int _quranIndex = 2;

  final GlobalKey<HomePageState> _homeKey = GlobalKey<HomePageState>();
  final GlobalKey<PrayersPageState> _prayersKey = GlobalKey<PrayersPageState>();
  final GlobalKey<QuranPageState> _quranKey = GlobalKey<QuranPageState>();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Deenly',
          style: Theme.of(context).extension<AppTextStyles>()?.brandTitle,
        ),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          _selectedIndex == _quranIndex
              ? IconButton(
                  icon: Icon(
                    (_quranKey.currentState?.isSearching ?? false)
                        ? Icons.close
                        : Icons.search,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _quranKey.currentState?.toggleSearch();
                    });
                  },
                )
              : Container(),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomePage(key: _homeKey),
          PrayersPage(key: _prayersKey),
          QuranPage(key: _quranKey),
          SettingPage(
            showAppBar: false,
            onSaved: () {
              _homeKey.currentState?.loadPrayerData(false);
              _prayersKey.currentState?.reload();
            },
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          /// Picks up times synced by the home tab since the last visit.
          if (index == _prayersIndex) _prayersKey.currentState?.reload();
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
