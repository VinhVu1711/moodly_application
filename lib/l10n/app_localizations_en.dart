// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get user_header_title => 'Your account';

  @override
  String get section_account_info => 'Account information';

  @override
  String get field_email => 'Email';

  @override
  String get section_settings => 'Settings';

  @override
  String get setting_language => 'Language';

  @override
  String get setting_language_vi => 'Vietnamese';

  @override
  String get setting_language_en => 'English';

  @override
  String get setting_theme => 'Appearance';

  @override
  String get setting_theme_system => 'Follow system';

  @override
  String get setting_notifications => 'Notifications';

  @override
  String get setting_privacy => 'Privacy & security';

  @override
  String get section_about => 'About';

  @override
  String get about_app_info => 'App information';

  @override
  String about_version(String version) {
    return 'Version $version';
  }

  @override
  String get about_help => 'Help & Support';

  @override
  String get logout => 'Sign out';

  @override
  String get logout_confirm_title => 'Confirm sign out';

  @override
  String get logout_confirm_msg => 'Are you sure you want to sign out?';

  @override
  String get btn_cancel => 'Cancel';

  @override
  String get btn_ok => 'Sign out';
}
