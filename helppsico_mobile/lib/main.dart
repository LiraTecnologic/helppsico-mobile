import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:helppsico_mobile/core/services/notification/notification_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import 'package:helppsico_mobile/presentation/viewmodels/cubit/auth_cubit.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/auth/auth_service.dart';
import 'package:helppsico_mobile/presentation/views/documents_screen.dart';
import 'package:helppsico_mobile/presentation/views/login_screen.dart';
import 'package:helppsico_mobile/presentation/views/dashboard_screen.dart';
import 'package:helppsico_mobile/presentation/views/notifications_screen.dart';
import 'package:helppsico_mobile/presentation/views/review_screen.dart';
import 'package:helppsico_mobile/presentation/views/sessions_wrapper.dart';
import 'package:helppsico_mobile/presentation/viewmodels/state/auth_state.dart';

final GetIt getIt = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = await SecureStorageService.create();
  getIt.registerSingleton<SecureStorageService>(storage);
  getIt.registerSingleton<IGenericHttp>(GenericHttp());
  getIt.registerSingleton<AuthService>(AuthService());

  NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) {
          return AuthCubit();
        }),
      ],
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {},
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
            home: state is AuthSuccess
                ? const DashboardScreen()
                : const LoginScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/menu': (context) => const DashboardScreen(),
              '/avaliar-psicologo': (context) => const AvaliarPsicologoScreen(),
              '/documents': (context) => const DocumentsScreen(),
              '/sessions': (context) => const SessionsWrapper(),
              '/notifications': (context) => const NotificationsScreen(),
            },
          );
        },
      ),
    );
  }
}