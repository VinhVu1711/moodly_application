import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:moodlyy_application/features/calendar/presentation/calendar_page.dart';
import 'package:moodlyy_application/features/stats/presentation/stats_page.dart';

// NEW: tách thành file riêng
import 'package:moodlyy_application/features/ai/presentation/ai_page.dart';
import 'package:moodlyy_application/features/user/presentation/user_page.dart';

class AppShell extends StatefulWidget {
  final int initialIndex;
  const AppShell({super.key, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index;

  // seed color nhấn nhá
  static const mint = Color(0xFF90B7C2);

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  late final List<Widget> _pages = const [
    CalendarPage(), // 0
    StatsPage(), // 1
    SizedBox(), // 2 (nút mood ở giữa)
    AiPage(), // 3  <-- đổi từ Favorites -> AI
    UserPage(), // 4
  ];

  void _onNavTap(int i) {
    if (i == 2) {
      // nút mood nhanh
      context.push('/mood/new');
      return;
    }
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
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
          // ĐỔI: tab AI
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined), // gợi ý icon AI
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'AI',
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
