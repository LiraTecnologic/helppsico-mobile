import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:helppsico_mobile/core/services/notification/notification_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import 'package:helppsico_mobile/presentation/viewmodels/cubit/auth_cubit.dart';
import 'package:helppsico_mobile/presentation/viewmodels/cubit/review_cubit.dart';
import 'package:helppsico_mobile/data/datasource/review_datasource.dart'; // Added for ReviewDataSource
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart'; // Added for GenericHttp
import 'package:helppsico_mobile/core/services/auth/auth_service.dart'; // Added for AuthService
import 'package:helppsico_mobile/presentation/views/documents_screen.dart';
import 'package:helppsico_mobile/presentation/views/login_screen.dart';
import 'package:helppsico_mobile/presentation/views/dashboard_screen.dart';
import 'package:helppsico_mobile/presentation/views/notifications_screen.dart';
import 'package:helppsico_mobile/presentation/views/review_screen.dart';
import 'package:helppsico_mobile/presentation/views/sessions_wrapper.dart';
import 'package:helppsico_mobile/presentation/viewmodels/state/auth_state.dart';


final GetIt getIt = GetIt.instance; 

Future <void> main() async {
  print('[main.dart] main function started.');
  WidgetsFlutterBinding.ensureInitialized();
  print('[main.dart] WidgetsFlutterBinding initialized.');

  final storage = await SecureStorageService.create();
  print('[main.dart] SecureStorageService created.');

  //garante que storage seja único para toda a aplicação 
  getIt.registerSingleton<SecureStorageService>(storage);
  print('[main.dart] SecureStorageService registered as singleton.');

  

  
  NotificationService().init();
  print('[main.dart] NotificationService initialized.');

  // Initialize services needed for ReviewDataSource



  // // Fetch psicologo info
  // Map<String, String>? psicologoInfo;
  // try {
  //   // Corrected method name from getPsicologoInfo to _getPsicologoInfo if it was intended to be private
  //   // However, since it's being called from main.dart, it should be public.
  //   // Assuming getPsicologoInfo is the correct public method name in ReviewDataSource after previous changes.
  //   psicologoInfo = await reviewDataSource.getPsicologoInfo(); 
  //   print('Fetched psicologo info for ReviewCubit: $psicologoInfo'); // Debug print to check if info is fetched correctly
  // } catch (e) {
  //   print('Failed to get psicologo info for ReviewCubit: $e');
  //   // Handle error appropriately, maybe fallback to default or show error
  // }

  // runApp(MyApp(psicologoInfo: psicologoInfo));
  print('[main.dart] Calling runApp with MyApp.');
  runApp(const MyApp()); // Assuming psicologoInfo is handled differently now or not needed at this stage
}

class MyApp extends StatelessWidget {
  // final Map<String, String>? psicologoInfo; // Assuming this is no longer passed directly
  const MyApp({super.key}); // Adjusted constructor

  // const MyApp({super.key, this.psicologoInfo}); // Original constructor if psicologoInfo is still needed



  @override
  Widget build(BuildContext context) {
    print('[main.dart] MyApp build method called.');
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) {
          print('[main.dart] Creating AuthCubit in MyApp BlocProvider.');
          return AuthCubit();
        }),
      ],
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          print('[main.dart] MyApp AuthCubit listener, state: $state');
          // Podemos adicionar lógica global de autenticação aqui se necessário
        },
        builder: (context, state) {
          print('[main.dart] MyApp AuthCubit builder, state: $state. Determining initial screen.');
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
                ? () { print('[main.dart] AuthSuccess: Showing DashboardScreen.'); return const DashboardScreen(); }() 
                : () { print('[main.dart] Not AuthSuccess (State: $state): Showing LoginScreen.'); return const LoginScreen(); }(),
            routes: {
             
              '/login': (context) => const LoginScreen(),
              '/menu': (context) => const DashboardScreen(),
        '/avaliar-psicologo': (context) => const AvaliarPsicologoScreen(),
              '/documents' : (context) => const DocumentsScreen(),
              '/sessions' : (context) => const SessionsWrapper(),
              '/notifications': (context) => const NotificationsScreen(),
            },
          );
        },
      ),
    );
  }
}