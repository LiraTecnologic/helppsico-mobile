import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helppsico_mobile/core/services/auth/auth_service.dart';
import 'package:helppsico_mobile/presentation/viewmodels/cubit/auth_cubit.dart';
import 'package:helppsico_mobile/presentation/views/documents_screen.dart';
import 'package:helppsico_mobile/presentation/views/login_screen.dart';
import 'package:helppsico_mobile/presentation/views/dashboard_screen.dart';
import 'package:helppsico_mobile/presentation/views/notifications_screen.dart';
import 'package:helppsico_mobile/presentation/views/rate_screen.dart';
import 'package:helppsico_mobile/presentation/views/sessions_screen.dart';
import 'package:helppsico_mobile/presentation/views/sessions_wrapper.dart';
import 'package:helppsico_mobile/presentation/viewmodels/state/auth_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          // Podemos adicionar lógica global de autenticação aqui se necessário
        },
        builder: (context, state) {
          return MaterialApp(
            title: 'HelpPsico',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.white,
              fontFamily: 'Roboto',
              useMaterial3: true,
            ),
            home: state is AuthSuccess ? const DashboardScreen() : const LoginScreen(),
            routes: {
              '/notifications': (context) => const NotificationsScreen(),
              '/login': (context) => const LoginScreen(),
              '/menu': (context) => const DashboardScreen(),
              '/avaliar-psicologo': (context) => const AvaliarPsicologoScreen(
                psicologoId: '1', 
                psicologoNome: 'Dra. Ana Martins', 
              ),
              '/documents' : (context) => const DocumentsScreen(),
              '/sessions' : (context) => const SessionsWrapper(),
            },
          );
        },
      ),
    );
  }
}