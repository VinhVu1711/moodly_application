// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get rule_in_arb => '';

  @override
  String get user_page_section => 'Cá nhân';

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
  String get setting_theme_system => 'Hệ thống';

  @override
  String get setting_notifications => 'Thông báo';

  @override
  String get setting_notifications_subtitle => 'Cài đặt thông báo của bạn';

  @override
  String get setting_privacy => 'Bảo mật & quyền riêng tư';

  @override
  String get setting_privacy_title => 'Bảo vệ tài khoản của bạn';

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

  @override
  String get home_page_section => 'Lịch';

  @override
  String get sort_by_emotion_title => 'Lọc theo cảm xúc';

  @override
  String get cancel_button_title => 'Hủy';

  @override
  String get apply_button_title => 'Áp dụng';

  @override
  String get quote_label => 'Câu nói ngày hôm nay';

  @override
  String get close_button_title => 'Đóng';

  @override
  String get warning_title => 'Cảnh báo';

  @override
  String get warning_content => 'Bạn không thể ghi cảm xúc trong tương lai';

  @override
  String get stat_page_section => 'Thống kê';

  @override
  String get month_title => 'Tháng';

  @override
  String get year_title => 'Năm';

  @override
  String get dont_have_data_title => 'Không có dữ liệu trong phạm vi này';

  @override
  String streak_days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ngày',
      zero: 'chưa có ngày nào',
    );
    return '$_temp0';
  }

  @override
  String get pick_year_title => 'Chọn năm';

  @override
  String get mood_flow_title => 'Dòng chảy';

  @override
  String get mood_flow_year_title => 'Hành trình của bạn trong năm nay';

  @override
  String get mood_flow_month_title => 'Hành trình của bạn trong tháng này';

  @override
  String months_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tháng',
      one: '1 tháng',
      zero: 'chưa có tháng nào',
    );
    return '$_temp0';
  }

  @override
  String days_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ngày',
      one: '1 ngày',
      zero: 'Chưa có ngày nào',
    );
    return '$_temp0';
  }

  @override
  String get mood_flow_emotions_title => 'Cảm xúc';

  @override
  String get mood_distribution_title => 'Phân phối cảm xúc';

  @override
  String most_common_with(String emotion) {
    return 'Phổ biến: $emotion';
  }

  @override
  String get emotion_very_sad => 'Rất buồn';

  @override
  String get emotion_sad => 'Buồn';

  @override
  String get emotion_neutral => 'Bình thường';

  @override
  String get emotion_happy => 'Vui';

  @override
  String get emotion_very_happy => 'Rất vui';

  @override
  String get people_stranger => 'Người lạ';

  @override
  String get people_family => 'Gia đình';

  @override
  String get people_friends => 'Bạn bè';

  @override
  String get people_partner => 'Đồng nghiệp';

  @override
  String get people_lover => 'Người yêu';

  @override
  String get another_excited => 'Hào hứng';

  @override
  String get another_relaxed => 'Thư giãn';

  @override
  String get another_proud => 'Tự hào';

  @override
  String get another_hopeful => 'Hy vọng';

  @override
  String get another_happy => 'Vui vẻ';

  @override
  String get another_enthusiastic => 'Nhiệt huyết';

  @override
  String get another_pit_a_part => 'Rã rời';

  @override
  String get another_refreshed => 'Sảng khoái';

  @override
  String get another_depressed => 'Buồn bã';

  @override
  String get another_lonely => 'Cô đơn';

  @override
  String get another_anxious => 'Lo âu';

  @override
  String get another_sad => 'Buồn';

  @override
  String get another_angry => 'Tức giận';

  @override
  String get another_pressured => 'Áp lực';

  @override
  String get another_annoyed => 'Khó chịu';

  @override
  String get another_tired => 'Mệt mỏi';

  @override
  String get overall_balance_title => 'Tỉ lệ';

  @override
  String dominated_by(String emotion) {
    return 'Đa số là: $emotion';
  }

  @override
  String days_with_mood_in_month_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tổng: $count ngày ghi cảm xúc ',
      one: '1 day',
      zero: 'Chưa có ngày nào',
    );
    return '$_temp0';
  }

  @override
  String get mood_edit_page_section => 'Cảm xúc';

  @override
  String get delete_title => 'Xóa dữ liệu cảm xúc?';

  @override
  String get delete_content => 'Hành động này sẽ xóa toàn bộ dữ liệu ngày hôm nay';

  @override
  String get delete_button_title => 'Xóa';

  @override
  String get saving_status => 'Đang lưu';

  @override
  String get done_status => 'Hoàn thành';

  @override
  String get how_was_your_day => 'Ngày hôm nay của bạn thế nào?';

  @override
  String get emotions_title => 'Các cảm xúc';

  @override
  String get people_title => 'Con người';

  @override
  String get add_a_note_title => 'Thêm ghi chú(tùy chọn)';

  @override
  String get setting_theme_light => 'Sáng';

  @override
  String get setting_theme_dark => 'Tối';

  @override
  String get setting_change_password => 'Đổi mật khẩu';

  @override
  String get setting_delete_data => 'Xóa dữ liệu của tôi';

  @override
  String get setting_delete_account => 'Xóa tài khoản';

  @override
  String get hint_new_password => 'Nhập mật khẩu mới';

  @override
  String hint_confirm_password(String email) {
    return 'Xác nhận mật khẩu cho $email';
  }

  @override
  String get msg_password_changed => 'Cập nhật mật khẩu thành công';

  @override
  String get msg_data_deleted => 'Dữ liệu cá nhân đã được xóa';

  @override
  String get msg_account_deleted => 'Xóa tài khoản thành công';

  @override
  String get confirm_delete_title => 'Xác nhận xóa';

  @override
  String get confirm_delete_msg => 'Thao tác này không thể thực hiện lại';

  @override
  String get emotional_ai_title => 'Tổng hợp cảm xúc AI';

  @override
  String get select_mode_title => 'Chọn chế độ: ';

  @override
  String get week_title_ai => 'Tuần';

  @override
  String get get_advice_button => 'Nhận lời khuyên';

  @override
  String get ai_error_connection_timeout => 'Kết nối quá lâu. Vui lòng thử lại sau.';

  @override
  String get ai_error_server_unavailable => 'Không thể kết nối đến server. Vui lòng kiểm tra backend đã chạy chưa.';

  @override
  String get ai_error_network => 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.';

  @override
  String ai_error_server(int statusCode) {
    return 'Lỗi từ server: $statusCode';
  }

  @override
  String get ai_error_unknown => 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.';

  @override
  String get theme_language => 'Giao diện, ngôn ngữ';

  @override
  String get current_setting => 'Cài đặt hiện tại';

  @override
  String get current_setting_subtitle => 'Cấu hình hiện tại của bạn';

  @override
  String get change_setting => 'Chỉnh sửa cài đặt';

  @override
  String get change_setting_title => 'Bấm vào để cấu hình cài đặt của bạn';

  @override
  String get journal_title => 'Nhật ký';

  @override
  String get journal_subtitle => 'Ghi lại điều bạn muốn ghi nhớ';

  @override
  String get journal_hint => 'Hãy viết bất cứ điều gì bạn muốn chia sẻ...';

  @override
  String get journal_save => 'Lưu nhật ký';

  @override
  String get journal_empty_state => 'Chưa có nhật ký nào. Bắt đầu ghi chép nhé!';

  @override
  String get journal_login_required => 'Vui lòng đăng nhập để sử dụng nhật ký.';

  @override
  String get journal_action_edit => 'Chỉnh sửa';

  @override
  String get journal_action_delete => 'Xóa nhật ký';

  @override
  String get journal_delete_confirm => 'Nhật ký này sẽ bị xóa vĩnh viễn.';
}
