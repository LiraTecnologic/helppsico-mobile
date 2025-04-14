import 'package:flutter/material.dart';
import 'package:helppsico_mobile/presentation/views/documents_screen.dart';
import 'package:helppsico_mobile/presentation/views/login_screen.dart';
import 'package:helppsico_mobile/presentation/views/dashboard_screen.dart';
import 'package:helppsico_mobile/presentation/views/notifications_screen.dart';
import 'package:helppsico_mobile/presentation/views/sessions_wrapper.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HelpPsico',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/login',
      routes: {
        '/notifications': (context) => const NotificationsScreen(),
        '/login': (context) => const LoginScreen(),
        '/menu': (context) => const DashboardScreen(),
        '/documents': (context) => const DocumentsScreen(),
        '/sessions': (context) => const SessionsWrapper(),
      },
    );
  }
}