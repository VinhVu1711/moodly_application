// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get user_header_title => 'Tài khoản của bạn';

  @override
  String get section_account_info => 'Thông tin tài khoản';

  @override
  String get field_email => 'Email';

  @override
  String get section_settings => 'Cài đặt';

  @override
  String get setting_language => 'Ngôn ngữ';

  @override
  String get setting_language_vi => 'Tiếng Việt';

  @override
  String get setting_language_en => 'Tiếng Anh';

  @override
  String get setting_theme => 'Giao diện';

  @override
  String get setting_theme_system => 'Theo hệ thống';

  @override
  String get setting_notifications => 'Thông báo';

  @override
  String get setting_privacy => 'Bảo mật & quyền riêng tư';

  @override
  String get section_about => 'Về ứng dụng';

  @override
  String get about_app_info => 'Thông tin ứng dụng';

  @override
  String about_version(String version) {
    return 'Phiên bản $version';
  }

  @override
  String get about_help => 'Trợ giúp & Hỗ trợ';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get logout_confirm_title => 'Xác nhận đăng xuất';

  @override
  String get logout_confirm_msg => 'Bạn có chắc chắn muốn đăng xuất?';

  @override
  String get btn_cancel => 'Hủy';

  @override
  String get btn_ok => 'Đăng xuất';
}
