import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/qr_provider.dart';
import 'providers/theme_provider.dart';
import 'views/home_screen.dart';
import 'views/history_screen.dart';
import 'views/form_screen.dart';

const appVersion = 'v1.2.0';

class BarcodeApp extends StatelessWidget {
  const BarcodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QrProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (ctx, themeProvider, _) => MaterialApp(
          title: 'مولّد الباركود الذكي',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeProvider.mode,
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ar', 'SA')],
          locale: const Locale('ar', 'SA'),
          initialRoute: '/',
          routes: {
            '/': (_) => const HomeScreen(),
            '/history': (_) => const HistoryScreen(),
            '/form': (_) => const FormScreen(),
          },
        ),
      ),
    );
  }
}
