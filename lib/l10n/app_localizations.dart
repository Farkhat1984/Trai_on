import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Virtual Try-On'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @wardrobe.
  ///
  /// In en, this message translates to:
  /// **'Wardrobe'**
  String get wardrobe;

  /// No description provided for @shops.
  ///
  /// In en, this message translates to:
  /// **'Shops'**
  String get shops;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @tryOnVirtually.
  ///
  /// In en, this message translates to:
  /// **'Try on clothes virtually'**
  String get tryOnVirtually;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @signInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithApple;

  /// No description provided for @byContinuingYouAccept.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you accept the terms of use\nand privacy policy'**
  String get byContinuingYouAccept;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSettings.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeSettings;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get soundEffects;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @acquiring.
  ///
  /// In en, this message translates to:
  /// **'Acquiring'**
  String get acquiring;

  /// No description provided for @paymentSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'Payment system settings'**
  String get paymentSystemSettings;

  /// No description provided for @acquiringInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Acquiring settings (in development)'**
  String get acquiringInDevelopment;

  /// No description provided for @wardrobeTitle.
  ///
  /// In en, this message translates to:
  /// **'Wardrobe'**
  String get wardrobeTitle;

  /// No description provided for @itemsInWardrobe.
  ///
  /// In en, this message translates to:
  /// **'Items in wardrobe'**
  String get itemsInWardrobe;

  /// No description provided for @clearWardrobe.
  ///
  /// In en, this message translates to:
  /// **'Clear wardrobe'**
  String get clearWardrobe;

  /// No description provided for @clearWardrobeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear wardrobe?'**
  String get clearWardrobeConfirm;

  /// No description provided for @clearWardrobeMessage.
  ///
  /// In en, this message translates to:
  /// **'This action will delete all items from your wardrobe. This action cannot be undone.'**
  String get clearWardrobeMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @wardrobeCleared.
  ///
  /// In en, this message translates to:
  /// **'Wardrobe cleared'**
  String get wardrobeCleared;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version: 1.0.0'**
  String get version;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a model from description or upload a photo, add clothes and try on a new look!'**
  String get aboutDescription;

  /// No description provided for @aiImageGeneration.
  ///
  /// In en, this message translates to:
  /// **'AI image generation'**
  String get aiImageGeneration;

  /// No description provided for @virtualTryOn.
  ///
  /// In en, this message translates to:
  /// **'Virtual try-on'**
  String get virtualTryOn;

  /// No description provided for @personalWardrobe.
  ///
  /// In en, this message translates to:
  /// **'Personal wardrobe'**
  String get personalWardrobe;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language settings'**
  String get languageSettings;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian;

  /// No description provided for @tryOnComplete.
  ///
  /// In en, this message translates to:
  /// **'Try-on complete!'**
  String get tryOnComplete;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @googleSignInStub.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google (stub)'**
  String get googleSignInStub;

  /// No description provided for @appleSignInStub.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple (stub)'**
  String get appleSignInStub;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navWardrobe.
  ///
  /// In en, this message translates to:
  /// **'Wardrobe'**
  String get navWardrobe;

  /// No description provided for @navShops.
  ///
  /// In en, this message translates to:
  /// **'Shops'**
  String get navShops;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @loadingMagicInProgress.
  ///
  /// In en, this message translates to:
  /// **'Magic in progress...'**
  String get loadingMagicInProgress;

  /// No description provided for @pickingYourNewLook.
  ///
  /// In en, this message translates to:
  /// **'Picking your new look!'**
  String get pickingYourNewLook;

  /// No description provided for @generateOrUploadModel.
  ///
  /// In en, this message translates to:
  /// **'Generate a model or upload a photo'**
  String get generateOrUploadModel;

  /// No description provided for @enterDescriptionOrPress.
  ///
  /// In en, this message translates to:
  /// **'Enter description in the field below or press the button'**
  String get enterDescriptionOrPress;

  /// No description provided for @wardrobeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Wardrobe is empty'**
  String get wardrobeEmpty;

  /// No description provided for @addClothesToStart.
  ///
  /// In en, this message translates to:
  /// **'Add clothes to get started'**
  String get addClothesToStart;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
