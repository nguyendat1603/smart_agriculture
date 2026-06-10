import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'viewmodels/sensor_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'services/supabase_service.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/forgot_password_view.dart';
import 'views/edit_profile_view.dart';
import 'views/change_password_view.dart';
import 'views/otp_view.dart';
import 'views/reset_password_view.dart';
import 'views/main_layout.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
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

  // Initialize Supabase
  await SupabaseService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SensorViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriPulse AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/forgot_password': (context) => const ForgotPasswordView(),
        '/dashboard': (context) => const MainLayout(),
        '/edit_profile': (context) => const EditProfileView(),
        '/change_password': (context) => const ChangePasswordView(),
        '/otp': (context) => const OtpView(),
        '/reset_password': (context) => const ResetPasswordView(),
      },
    );
  }
}
