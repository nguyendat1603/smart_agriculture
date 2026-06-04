import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'viewmodels/sensor_viewmodel.dart';
import 'views/login_view.dart';
import 'views/dashboard_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCAn9mvQrMiNUj072JMqzlI21kv8fdvd0c",
        authDomain: "project1-bacb2.firebaseapp.com",
        // Điền chính xác URL Firebase từ file ESP32 của bạn
        databaseURL:
            "https://project1-bacb2-default-rtdb.asia-southeast1.firebasedatabase.app",
        projectId: "project1-bacb2",
        storageBucket: "project1-bacb2.firebasestorage.app",
        messagingSenderId: "1059114138043",
        appId: "11:1059114138043:web:524414a4d5bf75cecb6c9e",
      ),
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  runApp(
    // Đăng ký tầng nghiệp vụ vào hệ thống toàn cục của Flutter
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SensorViewModel())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Agriculture',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginView(),
        '/dashboard': (context) => const DashboardView(),
      },
    );
  }
}
