import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_provider.dart';
import 'providers/download_provider.dart';
import 'screens/home_screen.dart';
import 'services/fdroid_api_service.dart';

void main() {
  runApp(const FloridApp());
}

class FloridApp extends StatelessWidget {
  const FloridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FDroidApiService>(create: (_) => FDroidApiService()),
        ChangeNotifierProxyProvider<FDroidApiService, AppProvider>(
          create: (context) => AppProvider(
            Provider.of<FDroidApiService>(context, listen: false),
          ),
          update: (context, apiService, previous) =>
              previous ?? AppProvider(apiService),
        ),
        ChangeNotifierProxyProvider<FDroidApiService, DownloadProvider>(
          create: (context) => DownloadProvider(
            Provider.of<FDroidApiService>(context, listen: false),
          ),
          update: (context, apiService, previous) =>
              previous ?? DownloadProvider(apiService),
        ),
      ],
      child: MaterialApp(
        title: 'Florid - F-Droid Client',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(elevation: 0),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.dark,
          ),
          appBarTheme: const AppBarTheme(elevation: 0),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
