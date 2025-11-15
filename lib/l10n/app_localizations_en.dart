// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get rule_in_arb => '';

  @override
  String get user_page_section => 'User';

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
  String get setting_theme_system => 'System';

  @override
  String get setting_notifications => 'Notifications';

  @override
  String get setting_notifications_subtitle => 'Your notification settings';

  @override
  String get setting_privacy => 'Privacy & security';

  @override
  String get setting_privacy_title => 'Protect your account';

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

  @override
  String get home_page_section => 'Calendar';

  @override
  String get sort_by_emotion_title => 'Sort by main emotion';

  @override
  String get cancel_button_title => 'Cancel';

  @override
  String get apply_button_title => 'Apply';

  @override
  String get quote_label => 'Quote of today';

  @override
  String get close_button_title => 'Close';

  @override
  String get warning_title => 'Warning';

  @override
  String get warning_content => 'You can not write mood in the future';

  @override
  String get stat_page_section => 'Stat';

  @override
  String get month_title => 'Month';

  @override
  String get year_title => 'Year';

  @override
  String get dont_have_data_title => 'Uh...Sorry don\'t have data in this range';

  @override
  String streak_days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
      zero: '0 days',
    );
    return '$_temp0';
  }

  @override
  String get pick_year_title => 'Pick a year';

  @override
  String get mood_flow_title => 'Mood Flow';

  @override
  String get mood_flow_year_title => 'Your emotional journey this year';

  @override
  String get mood_flow_month_title => 'Your emotional journey this month';

  @override
  String months_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '1 month',
      zero: '0 months',
    );
    return '$_temp0';
  }

  @override
  String days_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
      zero: '0 days',
    );
    return '$_temp0';
  }

  @override
  String get mood_flow_emotions_title => 'Emotions';

  @override
  String get mood_distribution_title => 'Mood Distribution';

  @override
  String most_common_with(String emotion) {
    return 'Most common: $emotion';
  }

  @override
  String get emotion_very_sad => 'Very sad';

  @override
  String get emotion_sad => 'Sad';

  @override
  String get emotion_neutral => 'Neutral';

  @override
  String get emotion_happy => 'Happy';

  @override
  String get emotion_very_happy => 'Very happy';

  @override
  String get people_stranger => 'Stranger';

  @override
  String get people_family => 'Family';

  @override
  String get people_friends => 'Friends';

  @override
  String get people_partner => 'Partner';

  @override
  String get people_lover => 'Lover';

  @override
  String get another_excited => 'Excited';

  @override
  String get another_relaxed => 'Relaxed';

  @override
  String get another_proud => 'Proud';

  @override
  String get another_hopeful => 'Hopeful';

  @override
  String get another_happy => 'Happy';

  @override
  String get another_enthusiastic => 'Enthusiastic';

  @override
  String get another_pit_a_part => 'Pit-a-part';

  @override
  String get another_refreshed => 'Refreshed';

  @override
  String get another_depressed => 'Depressed';

  @override
  String get another_lonely => 'Lonely';

  @override
  String get another_anxious => 'Anxious';

  @override
  String get another_sad => 'Sad';

  @override
  String get another_angry => 'Angry';

  @override
  String get another_pressured => 'Pressured';

  @override
  String get another_annoyed => 'Annoyed';

  @override
  String get another_tired => 'Tired';

  @override
  String get overall_balance_title => 'Overall Balance';

  @override
  String dominated_by(String emotion) {
    return 'Dominated by: $emotion';
  }

  @override
  String days_with_mood_in_month_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'TotalMood: $count day with mood ',
      one: '1 day',
      zero: 'Don\'t have yet',
    );
    return '$_temp0';
  }

  @override
  String get mood_edit_page_section => 'Mood';

  @override
  String get delete_title => 'Delete this mood?';

  @override
  String get delete_content => 'This will remove your mood(everything) for this day';

  @override
  String get delete_button_title => 'Delete';

  @override
  String get saving_status => 'Saving...';

  @override
  String get done_status => 'Done';

  @override
  String get how_was_your_day => 'How was your day?';

  @override
  String get emotions_title => 'Emotions';

  @override
  String get people_title => 'Peoples';

  @override
  String get add_a_note_title => 'Add a note(optional)';

  @override
  String get setting_theme_light => 'Light';

  @override
  String get setting_theme_dark => 'Dark';

  @override
  String get setting_change_password => 'Change Password';

  @override
  String get setting_delete_data => 'Delete My Data';

  @override
  String get setting_delete_account => 'Delete Account';

  @override
  String get hint_new_password => 'Enter new password';

  @override
  String hint_confirm_password(String email) {
    return 'Confirm your password for $email';
  }

  @override
  String get msg_password_changed => 'Password updated successfully!';

  @override
  String get msg_data_deleted => 'All personal data deleted.';

  @override
  String get msg_account_deleted => 'Account deleted successfully.';

  @override
  String get confirm_delete_title => 'Confirm deletion';

  @override
  String get confirm_delete_msg => 'This action cannot be undone.';

  @override
  String get emotional_ai_title => 'AI Emotional Summary';

  @override
  String get select_mode_title => 'Select mode: ';

  @override
  String get week_title_ai => 'Week';

  @override
  String get get_advice_button => 'Get advice';

  @override
  String get ai_error_connection_timeout => 'Connection timeout. Please try again later.';

  @override
  String get ai_error_server_unavailable => 'Cannot connect to server. Please check if backend is running.';

  @override
  String get ai_error_network => 'Network error. Please check your internet connection.';

  @override
  String ai_error_server(int statusCode) {
    return 'Server error: $statusCode';
  }

  @override
  String get ai_error_unknown => 'An unknown error occurred. Please try again.';

  @override
  String get theme_language => 'Theme, Language';

  @override
  String get current_setting => 'Current settings';

  @override
  String get current_setting_subtitle => 'Your current preferences';

  @override
  String get change_setting => 'Change setting';

  @override
  String get change_setting_title => 'Tap to modify your preferences';
}
