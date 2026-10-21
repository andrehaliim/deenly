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

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  static const int _homeIndex = 0;
  static const int _prayersIndex = 1;
  static const int _quranIndex = 2;

  final GlobalKey<HomePageState> _homeKey = GlobalKey<HomePageState>();
  final GlobalKey<PrayersPageState> _prayersKey = GlobalKey<PrayersPageState>();
  final GlobalKey<QuranPageState> _quranKey = GlobalKey<QuranPageState>();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Prayers can be marked from the adhan notification while the app is
  /// in the background, so both tabs re-read them when it comes back.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _homeKey.currentState?.loadProgress();
    _prayersKey.currentState?.reload();
  }

  void _select(int index) {
    /// Each tab picks up what the other changed since the last visit: the
    /// times synced by home, the prayers marked on the prayers tab.
    if (index == _homeIndex) _homeKey.currentState?.loadProgress();
    if (index == _prayersIndex) _prayersKey.currentState?.reload();
    setState(() {
      _selectedIndex = index;
    });
  }

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
          HomePage(key: _homeKey, onOpenPrayers: () => _select(_prayersIndex)),
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
        onTap: _select,
      ),
    );
  }
}
