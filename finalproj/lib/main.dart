import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'pages/auth_wrapper.dart';

final pb = PocketBase('http://127.0.0.1:8090');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1976D2),
        hintColor: const Color(0xFFFF9800),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}
