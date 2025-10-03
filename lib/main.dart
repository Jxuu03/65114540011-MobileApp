import 'package:flutter/material.dart';
import 'pages/auth_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  const bool isWeb = identical(0, 0.0);
  if (isWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
        authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '',
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '',
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
        appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
        measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID'] ?? '',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Oedering App',
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
