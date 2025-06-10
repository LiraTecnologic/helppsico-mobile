
import 'package:equatable/equatable.dart';
import 'package:helppsico_mobile/domain/entities/session_model.dart';

abstract class SessionsState extends Equatable {
  const SessionsState();

  @override
  List<Object> get props => [];

}


class SessionsInitial extends SessionsState {}

class SessionsLoading extends SessionsState {}

class SessionsLoaded extends SessionsState{
  final List<SessionModel> sessions;

  const SessionsLoaded(this.sessions);
  

  @override
  List<Object> get props =>[sessions];
}

class SessionsError extends SessionsState {
  final String message;

  const SessionsError(this.message);

  @override
  List<Object> get props => [message];
}
