import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:moodlyy_application/features/auth/vm/auth_vm.dart';
import 'package:moodlyy_application/features/calendar/presentation/calendar_page.dart';

// Stub pages (tạo tạm thời)
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Stats (coming soon)'));
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Favorites (coming soon)'));
}

class UserPage extends StatelessWidget {
  const UserPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const ListTile(
          leading: CircleAvatar(child: Icon(Icons.person)),
          title: Text('Tài khoản của bạn'),
          subtitle: Text('VN/EN • Light/Dark • Thông báo'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Đăng xuất'),
          onTap: () async {
            await context.read<AuthVM>().signOut();
          },
        ),
      ],
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  // Màu seed (mint) của app — dùng cho nhấn nhá
  static const mint = Color(0xFF90B7C2);

  late final List<Widget> _pages = const [
    CalendarPage(), // 0 - Lịch
    StatsPage(), // 1 - Biểu đồ
    SizedBox(), // 2 - Mặt cười (không có page, sẽ push /mood/new)
    FavoritesPage(), // 3 - Yêu thích
    UserPage(), // 4 - Người dùng
  ];

  void _onNavTap(int i) {
    if (i == 2) {
      // Tab Mặt cười: mở trang react mood nhanh
      context.push('/mood/new');
      return; // không đổi tab hiện tại
    }
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onNavTap,
        indicatorColor: mint.withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Lịch',
          ),
          NavigationDestination(
            icon: Icon(Icons.stacked_line_chart_outlined),
            selectedIcon: Icon(Icons.stacked_line_chart),
            label: 'Biểu đồ',
          ),
          NavigationDestination(
            icon: Icon(Icons.sentiment_satisfied_outlined),
            selectedIcon: Icon(Icons.sentiment_satisfied),
            label: 'Mood',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Yêu thích',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}
