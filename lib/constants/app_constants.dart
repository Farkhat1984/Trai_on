import 'package:flutter/material.dart';

/// Application-wide constants for consistent values across the app
class AppConstants {
  AppConstants._();

  // ==================== Animation Durations ====================

  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration flyingAnimationDuration = Duration(milliseconds: 800);
  static const Duration fadeAnimationDuration = Duration(milliseconds: 500);

  // ==================== API & Network ====================

  static const Duration apiConnectTimeout = Duration(seconds: 120);
  static const Duration apiReceiveTimeout = Duration(seconds: 120);
  static const int maxApiRetryAttempts = 3;
  static const int initialRetryDelayMs = 3000;

  // ==================== Image Processing ====================

  static const int imageMaxWidth = 1536;
  static const int imageMaxHeight = 1536;
  static const int imageQuality = 90;
  static const int imageCompressionMinWidth = 1280;
  static const int imageCompressionMinHeight = 1280;
  static const int imageCompressionQuality = 90;
  static const int imageCacheWidth = 800;

  // ==================== UI Dimensions ====================

  static const double borderRadiusSmall = 10.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 12.0;
  static const double paddingLarge = 16.0;
  static const double paddingXLarge = 24.0;

  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
  static const double iconSizeXLarge = 64.0;
  static const double iconSizeXXLarge = 80.0;
  static const double iconSizeHuge = 100.0;

  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // ==================== Grid & Layout ====================

  static const int wardrobeGridCrossAxisCount = 2;
  static const double wardrobeGridCrossAxisSpacing = 16.0;
  static const double wardrobeGridMainAxisSpacing = 16.0;
  static const double wardrobeGridChildAspectRatio = 0.75;

  static const double carouselHeight = 120.0;
  static const double carouselItemWidth = 100.0;
  static const double carouselItemSpacing = 8.0;

  // ==================== Constraints ====================

  static const double personDisplayMinHeight = 400.0;
  static const double personDisplayMaxHeight = 600.0;

  // ==================== Border Widths ====================

  static const double borderWidthThin = 1.0;
  static const double borderWidthMedium = 2.0;
  static const double borderWidthThick = 3.0;

  // ==================== Opacity Values ====================

  static const double opacityDisabled = 0.3;
  static const double opacityMedium = 0.5;
  static const double opacityHigh = 0.7;
  static const double opacityLight = 0.8;
  static const double opacityVeryLight = 0.9;

  // ==================== Audio ====================

  static const int soundPoolClickPlayers = 3;
  static const int soundPoolFlyingPlayers = 1;
  static const double soundInitialVolume = 0.8;
  static const int soundFadeOutSteps = 20;

  // ==================== Image Generation ====================

  /// Portrait aspect ratio for person images (2:3)
  static const String aspectRatioPortrait = '2:3';

  /// Square aspect ratio for clothing images (1:1)
  static const String aspectRatioSquare = '1:1';

  static const double generationTemperature = 0.2;
  static const int generationTopK = 32;
  static const int generationTopP = 1;
  static const int generationMaxOutputTokens = 8192;

  // ==================== Hive Box Names ====================

  static const String hiveBoxWardrobe = 'wardrobe';
  static const String hiveBoxSettings = 'settings';

  // ==================== Settings Keys ====================

  static const String settingsKeyThemeMode = 'themeMode';
  static const String settingsKeySoundEnabled = 'soundEnabled';
  static const String settingsKeyLocale = 'locale';

  // ==================== Routes ====================

  static const String routeLogin = '/login';
  static const String routeHome = '/home';

  // ==================== Asset Paths ====================

  static const String assetLogoPath = 'assets/images/logo.png';
  static const String assetSoundClick = 'assets/sounds/click.wav';
  static const String assetSoundWhoosh = 'assets/sounds/whoosh.wav';

  // ==================== Gallery ====================

  static const String galleryAlbumName = 'Virtual Try-On';

  // ==================== Edge Insets ====================

  static const EdgeInsets paddingAllSmall = EdgeInsets.all(paddingSmall);
  static const EdgeInsets paddingAllMedium = EdgeInsets.all(paddingMedium);
  static const EdgeInsets paddingAllLarge = EdgeInsets.all(paddingLarge);
  static const EdgeInsets paddingAllXLarge = EdgeInsets.all(paddingXLarge);

  static const EdgeInsets paddingHorizontalSmall = EdgeInsets.symmetric(horizontal: paddingSmall);
  static const EdgeInsets paddingHorizontalMedium = EdgeInsets.symmetric(horizontal: paddingMedium);
  static const EdgeInsets paddingHorizontalLarge = EdgeInsets.symmetric(horizontal: paddingLarge);
  static const EdgeInsets paddingHorizontalXLarge = EdgeInsets.symmetric(horizontal: paddingXLarge);

  static const EdgeInsets paddingVerticalSmall = EdgeInsets.symmetric(vertical: paddingSmall);
  static const EdgeInsets paddingVerticalMedium = EdgeInsets.symmetric(vertical: paddingMedium);
  static const EdgeInsets paddingVerticalLarge = EdgeInsets.symmetric(vertical: paddingLarge);
  static const EdgeInsets paddingVerticalXLarge = EdgeInsets.symmetric(vertical: paddingXLarge);
}
