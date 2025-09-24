// main.dart
import 'package:flutter/material.dart';
import 'package:moodlyy_application/app/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://dznyqpjisucohdvcjxid.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR6bnlxcGppc3Vjb2hkdmNqeGlkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1NjAwOTIsImV4cCI6MjA3MzEzNjA5Mn0.lSKmjBRkzmIvQZaxZqQlQtNIfOFoExAw8WZIUxS6764',
  );

  // Chạy ứng dụng
  runApp(const MoodlyyyApp());
}
