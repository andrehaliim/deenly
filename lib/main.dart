import 'package:deenly/components/app_theme.dart';
import 'package:deenly/pages/main_page.dart';
import 'package:deenly/components/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((prefs) {
    final isDark = prefs.getBool('isDarkMode') ?? false;
    runApp(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(isDark),
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: const MainPage(),
        );
      },
    );
  }
}