import 'package:flutter/material.dart';
import 'package:helppsico_mobile/presentation/screens/documents_screen.dart';
import 'package:helppsico_mobile/presentation/screens/login_screen.dart';
import 'package:helppsico_mobile/presentation/screens/dashboard_screen.dart';
import 'package:helppsico_mobile/presentation/screens/notifications_screen.dart';



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
      initialRoute: '/notifications',
      routes: {
        '/notifications': (context) => const NotificationsScreen(),
        '/login': (context) => const LoginScreen(),
        '/menu' : (context) => const DashboardScreen(),
        '/documents' : (context) => const DocumentsScreen(),
      },
    );
  }
}

