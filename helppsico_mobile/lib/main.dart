import 'package:flutter/material.dart';
import 'package:helppsico_mobile/presentation/screens/documents_screen.dart';
import 'package:helppsico_mobile/presentation/screens/login_screen.dart';
import 'package:helppsico_mobile/presentation/screens/dashboard_screen.dart';
import 'package:helppsico_mobile/presentation/screens/notifications_screen.dart';

import 'package:helppsico_mobile/presentation/screens/rate_screen.dart';

import 'package:helppsico_mobile/presentation/screens/sessions_screen.dart';




void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  



  const MyApp({super.key});


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

      initialRoute: '/menu',


      routes: {
        '/notifications': (context) => const NotificationsScreen(),
        '/login': (context) => const LoginScreen(),
        '/menu': (context) => const DashboardScreen(),
        '/avaliar-psicologo': (context) => const AvaliarPsicologoScreen(
          psicologoId: '1', 
          psicologoNome: 'Dra. Ana Martins', 
        ),
        '/documents' : (context) => const DocumentsScreen(),
        '/sessions' : (context) => const SessionsPage(),

      },
    );
  }
}

