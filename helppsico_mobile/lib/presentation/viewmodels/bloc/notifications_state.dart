import 'package:equatable/equatable.dart';
import 'package:helppsico_mobile/domain/entities/notification_model.dart';

//Equatable garante que, se um State tem as propriedades especificadas no override
// a UI não irá recarregar, garantindo uma melhor performance
abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationModel> notifications;

  const NotificationsLoaded(this.notifications);

  @override
  List<Object> get props => [notifications];
}

class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError(this.message);

  @override
  List<Object> get props => [message];
}