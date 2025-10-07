import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/wardrobe_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/selected_items_provider.dart';
import 'providers/locale_provider.dart';
import 'services/sound_service.dart';
import 'l10n/app_localizations.dart';
import 'config/app_theme.dart';
import 'constants/app_constants.dart';

// GlobalKey для иконки корзины (используется для flying animation)
final GlobalKey cartIconKey = GlobalKey();

// GlobalKey для навигационной иконки "Главная"
final GlobalKey homeIconKey = GlobalKey();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.hiveBoxWardrobe);
  await Hive.openBox(AppConstants.hiveBoxSettings);

  // Initialize sound service
  await SoundService().initialize();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: VirtualTryOnApp(),
    ),
  );
}

class VirtualTryOnApp extends ConsumerWidget {
  const VirtualTryOnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Virtual Try-On',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
      ],
      initialRoute: AppConstants.routeLogin,
      routes: {
        AppConstants.routeLogin: (context) => const LoginScreen(),
        AppConstants.routeHome: (context) => const MainNavigator(),
      },
    );
  }
}

class MainNavigator extends ConsumerWidget {
  const MainNavigator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final selectedItemsCount = ref.watch(selectedItemsProvider).length;
    final l10n = AppLocalizations.of(context)!;

    final List<Widget> screens = [
      const HomeScreen(),
      const WardrobeScreen(),
      const ShopScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(navigationIndexProvider.notifier).state = index;
        },
        destinations: [
          NavigationDestination(
            key: homeIconKey,
            icon: Badge(
              key: cartIconKey,
              label:
                  selectedItemsCount > 0 ? Text('$selectedItemsCount') : null,
              isLabelVisible: selectedItemsCount > 0,
              child: const Icon(Icons.home_outlined),
            ),
            selectedIcon: Badge(
              label:
                  selectedItemsCount > 0 ? Text('$selectedItemsCount') : null,
              isLabelVisible: selectedItemsCount > 0,
              child: const Icon(Icons.home),
            ),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.checkroom_outlined),
            selectedIcon: const Icon(Icons.checkroom),
            label: l10n.navWardrobe,
          ),
          NavigationDestination(
            icon: const Icon(Icons.store_outlined),
            selectedIcon: const Icon(Icons.store),
            label: l10n.navShops,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
