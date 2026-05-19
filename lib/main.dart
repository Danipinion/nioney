import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay styling for a premium fullscreen dark look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Lock orientation to portrait for stable UI layouts
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: const NioneyApp(),
    ),
  );
}

class NioneyApp extends StatelessWidget {
  const NioneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return MaterialApp(
      title: 'Nioney',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(
        context,
        provider.currentPalette,
        ThemeMode.light,
      ),
      darkTheme: AppTheme.buildTheme(
        context,
        provider.currentPalette,
        ThemeMode.dark,
      ),
      themeMode: provider.themeMode,
      home: const HomeNavigation(),
    );
  }
}
