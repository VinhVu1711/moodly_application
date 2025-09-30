import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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
    Locale('vi'),
  ];

  /// Header title on user page
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get user_header_title;

  /// Title of the account info section
  ///
  /// In en, this message translates to:
  /// **'Account information'**
  String get section_account_info;

  /// Label for email field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get field_email;

  /// Title of the settings section
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get section_settings;

  /// Setting item: language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get setting_language;

  /// Option label for Vietnamese language
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get setting_language_vi;

  /// Option label for English language
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get setting_language_en;

  /// Setting item: theme/appearance
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get setting_theme;

  /// Theme option: follow system
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get setting_theme_system;

  /// Setting item: notifications
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get setting_notifications;

  /// Setting item: privacy and security
  ///
  /// In en, this message translates to:
  /// **'Privacy & security'**
  String get setting_privacy;

  /// Title of the about section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get section_about;

  /// Row title: app information
  ///
  /// In en, this message translates to:
  /// **'App information'**
  String get about_app_info;

  /// Version string with placeholder
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String about_version(String version);

  /// Row title: help and support
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get about_help;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// Title of the logout confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm sign out'**
  String get logout_confirm_title;

  /// Message of the logout confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get logout_confirm_msg;

  /// Common button: cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btn_cancel;

  /// Common button: OK/confirm sign out
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get btn_ok;
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
