import 'package:flutter/material.dart';
import 'core/session_manager.dart';
import 'core/constants.dart';
import 'screens/login_email_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final evaluadorId = await SessionManager.getEvaluadorId();

  runApp(MyApp(initialRoute: evaluadorId != null ? '/dashboard' : '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  MyApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Evaluación CBA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.senaGreen),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.senaGreen,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.senaGreen,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(vertical: 16),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => LoginEmailScreen(),
        '/dashboard': (context) => DashboardScreen(),
      },
    );
  }
}