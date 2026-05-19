import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_navigation.dart';

class AppLocale {
  static bool isInitialized = false;

  // 100% safe, crash-free currency formatting that works everywhere (even in debug F5)
  static String formatCurrency(double amount, String symbol) {
    try {
      final formatter = NumberFormat.currency(
        symbol: symbol,
        decimalDigits: 0,
      );
      final raw = formatter.format(amount);
      return raw.replaceAll(',', '.');
    } catch (_) {
      return '$symbol${amount.toStringAsFixed(0)}';
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for id_ID locale
  try {
    await initializeDateFormatting('id_ID', null);
    AppLocale.isInitialized = true;
  } catch (_) {
    AppLocale.isInitialized = false;
  }

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
