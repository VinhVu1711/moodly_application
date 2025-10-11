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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// If just modify the content -> hot restart, If add key or placeholder -> flutter gen-l10n or stop the app and flutter run. DO NOT MODIFY THE GENERATED FILE
  ///
  /// In en, this message translates to:
  /// **''**
  String get rule_in_arb;

  /// User Page Section
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user_page_section;

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
  /// **'System'**
  String get setting_theme_system;

  /// Setting item: notifications
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get setting_notifications;

  /// The subtitle of notification
  ///
  /// In en, this message translates to:
  /// **'Your notification settings'**
  String get setting_notifications_subtitle;

  /// Setting item: privacy and security
  ///
  /// In en, this message translates to:
  /// **'Privacy & security'**
  String get setting_privacy;

  /// The subtitle of privacy and security
  ///
  /// In en, this message translates to:
  /// **'Protect your account'**
  String get setting_privacy_title;

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

  /// Label of calendar section
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get home_page_section;

  /// Label of sort
  ///
  /// In en, this message translates to:
  /// **'Sort by main emotion'**
  String get sort_by_emotion_title;

  /// Label of button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel_button_title;

  /// Label
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply_button_title;

  /// Label
  ///
  /// In en, this message translates to:
  /// **'Quote of today'**
  String get quote_label;

  /// Label of button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close_button_title;

  /// Label
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning_title;

  /// content
  ///
  /// In en, this message translates to:
  /// **'You can not write mood in the future'**
  String get warning_content;

  /// Label of stat section
  ///
  /// In en, this message translates to:
  /// **'Stat'**
  String get stat_page_section;

  /// Month title
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month_title;

  /// Year title
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year_title;

  /// Dont have data title
  ///
  /// In en, this message translates to:
  /// **'Uh...Sorry don\'t have data in this range'**
  String get dont_have_data_title;

  /// Render streak length in days with proper pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 days} =1{1 day} other{{count} days}}'**
  String streak_days(int count);

  /// Title
  ///
  /// In en, this message translates to:
  /// **'Pick a year'**
  String get pick_year_title;

  /// title
  ///
  /// In en, this message translates to:
  /// **'Mood Flow'**
  String get mood_flow_title;

  /// title
  ///
  /// In en, this message translates to:
  /// **'Your emotional journey this year'**
  String get mood_flow_year_title;

  /// title
  ///
  /// In en, this message translates to:
  /// **'Your emotional journey this month'**
  String get mood_flow_month_title;

  /// Render month count with proper pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 months} =1{1 month} other{{count} months}}'**
  String months_count(int count);

  /// Render day count with proper pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 days} =1{1 day} other{{count} days}}'**
  String days_count(int count);

  /// title
  ///
  /// In en, this message translates to:
  /// **'Emotions'**
  String get mood_flow_emotions_title;

  /// title
  ///
  /// In en, this message translates to:
  /// **'Mood Distribution'**
  String get mood_distribution_title;

  /// Label for the most common emotion
  ///
  /// In en, this message translates to:
  /// **'Most common: {emotion}'**
  String most_common_with(String emotion);

  /// title
  ///
  /// In en, this message translates to:
  /// **'Very sad'**
  String get emotion_very_sad;

  /// title
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get emotion_sad;

  /// title
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get emotion_neutral;

  /// title
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get emotion_happy;

  /// title
  ///
  /// In en, this message translates to:
  /// **'Very happy'**
  String get emotion_very_happy;

  /// title
  ///
  /// In en, this message translates to:
  /// **'Stranger'**
  String get people_stranger;

  /// title
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get people_family;

  /// title
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get people_friends;

  /// title
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get people_partner;

  /// title
  ///
  /// In en, this message translates to:
  /// **'Lover'**
  String get people_lover;

  /// Secondary emotion: excited
  ///
  /// In en, this message translates to:
  /// **'Excited'**
  String get another_excited;

  /// Secondary emotion: relaxed
  ///
  /// In en, this message translates to:
  /// **'Relaxed'**
  String get another_relaxed;

  /// Secondary emotion: proud
  ///
  /// In en, this message translates to:
  /// **'Proud'**
  String get another_proud;

  /// Secondary emotion: hopeful
  ///
  /// In en, this message translates to:
  /// **'Hopeful'**
  String get another_hopeful;

  /// Secondary emotion: happy
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get another_happy;

  /// Secondary emotion: enthusiastic
  ///
  /// In en, this message translates to:
  /// **'Enthusiastic'**
  String get another_enthusiastic;

  /// Secondary emotion: 'pit-a-part' (matches asset pit-a-part.png)
  ///
  /// In en, this message translates to:
  /// **'Pit-a-part'**
  String get another_pit_a_part;

  /// Secondary emotion: refreshed
  ///
  /// In en, this message translates to:
  /// **'Refreshed'**
  String get another_refreshed;

  /// Secondary emotion: depressed
  ///
  /// In en, this message translates to:
  /// **'Depressed'**
  String get another_depressed;

  /// Secondary emotion: lonely
  ///
  /// In en, this message translates to:
  /// **'Lonely'**
  String get another_lonely;

  /// Secondary emotion: anxious
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get another_anxious;

  /// Secondary emotion: sad
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get another_sad;

  /// Secondary emotion: angry
  ///
  /// In en, this message translates to:
  /// **'Angry'**
  String get another_angry;

  /// Secondary emotion: pressured
  ///
  /// In en, this message translates to:
  /// **'Pressured'**
  String get another_pressured;

  /// Secondary emotion: annoyed
  ///
  /// In en, this message translates to:
  /// **'Annoyed'**
  String get another_annoyed;

  /// Secondary emotion: tired
  ///
  /// In en, this message translates to:
  /// **'Tired'**
  String get another_tired;

  /// title
  ///
  /// In en, this message translates to:
  /// **'Overall Balance'**
  String get overall_balance_title;

  /// Label for the dominated by
  ///
  /// In en, this message translates to:
  /// **'Dominated by: {emotion}'**
  String dominated_by(String emotion);

  /// Render day count with proper pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Don\'t have yet} =1{1 day} other{TotalMood: {count} day with mood }}'**
  String days_with_mood_in_month_count(int count);

  /// label
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get mood_edit_page_section;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Delete this mood?'**
  String get delete_title;

  /// label
  ///
  /// In en, this message translates to:
  /// **'This will remove your mood(everything) for this day'**
  String get delete_content;

  /// Button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete_button_title;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving_status;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done_status;

  /// label
  ///
  /// In en, this message translates to:
  /// **'How was your day?'**
  String get how_was_your_day;

  /// title
  ///
  /// In en, this message translates to:
  /// **'Emotions'**
  String get emotions_title;

  /// title
  ///
  /// In en, this message translates to:
  /// **'Peoples'**
  String get people_title;

  /// title
  ///
  /// In en, this message translates to:
  /// **'Add a note(optional)'**
  String get add_a_note_title;

  /// Label
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get setting_theme_light;

  /// Label
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get setting_theme_dark;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get setting_change_password;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Delete My Data'**
  String get setting_delete_data;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get setting_delete_account;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get hint_new_password;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Confirm your password for {email}'**
  String hint_confirm_password(String email);

  /// label
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully!'**
  String get msg_password_changed;

  /// label
  ///
  /// In en, this message translates to:
  /// **'All personal data deleted.'**
  String get msg_data_deleted;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully.'**
  String get msg_account_deleted;

  /// label
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirm_delete_title;

  /// label
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get confirm_delete_msg;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'vi': return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
