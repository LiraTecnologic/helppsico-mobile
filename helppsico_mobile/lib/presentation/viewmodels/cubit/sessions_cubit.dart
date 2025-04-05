

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helppsico_mobile/data/repositories/sessions_repository.dart';
import 'package:helppsico_mobile/presentation/viewmodels/bloc/sessions_state.dart';

class SessionsCubit extends Cubit<SessionsState>{

  final SessionRepository _repository;

  SessionsCubit(this._repository) : super(SessionsInitial());

  Future <void> fetchSessions() async {
  
    try {
      emit(SessionsLoading());
      final sessions = await _repository.getSessions();
      emit(SessionsLoaded(sessions));
    } catch (e) {
      emit(SessionsError(e.toString()));
    }

  
  
  }
}