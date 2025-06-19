import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/data/datasource/sessions_data_source.dart';
import 'package:helppsico_mobile/data/repositories/sessions_repository.dart';
import 'package:helppsico_mobile/presentation/viewmodels/cubit/session_notification_cubit.dart';
import 'package:helppsico_mobile/presentation/viewmodels/cubit/sessions_cubit.dart';
import 'package:helppsico_mobile/presentation/viewmodels/state/sessions_state.dart';
import 'package:helppsico_mobile/presentation/views/sessions_screen.dart';

class SessionsWrapper extends StatefulWidget {
  const SessionsWrapper({Key? key}) : super(key: key);

  @override
  State<SessionsWrapper> createState() => _SessionsWrapperState();
}

class _SessionsWrapperState extends State<SessionsWrapper> {
  late SessionsCubit _sessionsCubit;
  late SessionNotificationCubit _notificationCubit;

  @override
  void initState() {
    super.initState();
    final sessionsDataSource = SessionsDataSource(GenericHttp()); // Corrected typo
    final sessionsRepository = SessionRepository(sessionsDataSource);
    _sessionsCubit = SessionsCubit(sessionsRepository);
    _notificationCubit = SessionNotificationCubit();

    _notificationCubit.init();
  }

  @override
  void dispose() {
    _sessionsCubit.close();
    _notificationCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SessionsCubit>.value(value: _sessionsCubit),
        BlocProvider<SessionNotificationCubit>.value(value: _notificationCubit),
      ],
      child: BlocListener<SessionsCubit, SessionsState>(
        listener: (context, state) {
          if (state is SessionsLoaded) {
            _notificationCubit.updateAllSessionsNotifications(state.sessions);
          }
        },
        child: const SessionsPage(),
      ),
    );
  }
}
