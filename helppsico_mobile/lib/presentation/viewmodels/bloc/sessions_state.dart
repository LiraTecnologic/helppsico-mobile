
import 'package:equatable/equatable.dart';
import 'package:helppsico_mobile/data/models/session_model.dart';

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
  //Equivalente à:
  //const SessionsLoaded(List<NotificationModel> sessions)
  //: this.sessions = sessions;

  @override
  List<Object> get props =>[sessions];
}

class SessionsError extends SessionsState{
  final String message;

  const SessionsError(this.message);

  


}
