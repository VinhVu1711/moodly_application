// lib/app/app.dart

import 'package:flutter/material.dart';
import 'package:moodlyy_application/app/di.dart';
import 'package:moodlyy_application/app/root_router.dart';
import 'package:provider/provider.dart';

class MoodlyyyApp extends StatelessWidget {
  const MoodlyyyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // bọc toàn bộ app trong MultiProvider để inject các service/VM
      providers:
          buildProviders(), //list các provider sử dụng trong ứng dụng này
      child:
          const RootRouter(), //chỗ này ko cần MaterialApp nữa vì RootRouter đã có có rồi
    );
  }
}
